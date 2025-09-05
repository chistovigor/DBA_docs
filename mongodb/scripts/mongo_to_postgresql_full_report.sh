#!/bin/bash
set -euo pipefail

### === Конфигурация ===
ENV_FILE="./environment"
DEFAULT_CHECK_LIMIT=100000

if [[ ! -f "$ENV_FILE" ]]; then
  echo ">>> Файл $ENV_FILE не найден!"
  exit 1
fi

# Загружаем переменные
set -a
source "$ENV_FILE"
set +a

# Проверка ключевых переменных
: "${MONGO_SOURCE_URI:?Не задано MONGO_SOURCE_URI в $ENV_FILE}"
: "${SOURCE_DB:?Не задано SOURCE_DB в $ENV_FILE}"
: "${TARGET_URI:?Не задано TARGET_URI в $ENV_FILE}"
: "${TARGET_DB:?Не задано TARGET_DB в $ENV_FILE}"

CHECK_LIMIT=${CHECK_LIMIT:-$DEFAULT_CHECK_LIMIT}

# Определяем режим работы
MODE="${1:-full}"
if [[ "$MODE" == "help" ]]; then
  echo "Использование:"
  echo "  ./mongo_to_postgresql_full_report.sh            # полный режим миграции"
  echo "  ./mongo_to_postgresql_full_report.sh create_index  # только создание индексов"
  echo "  ./mongo_to_postgresql_full_report.sh check_checksum # только проверка целостности данных"
  echo "  ./mongo_to_postgresql_full_report.sh help       # показать помощь"
  exit 0
fi

REPORT_FILE_HTML="migration_report_postgresql.html"
REPORT_FILE_TXT="migration_report_postgresql.txt"
DEBUG_INDEX_DIR="./debug_indexes"
DEBUG_CHECKSUM_DIR="./debug_scripts"
mkdir -p "$DEBUG_INDEX_DIR" "$DEBUG_CHECKSUM_DIR"

### === Установка зависимостей ===
install_if_missing() {
  local cmd=$1
  local pkg=$2
  if ! command -v "$cmd" &> /dev/null; then
    echo ">>> Устанавливаем $pkg..."
    sudo apt-get update -y
    sudo apt-get install -y "$pkg"
  fi
}
install_if_missing git git
install_if_missing curl curl
install_if_missing jq jq

# Docker и Docker Compose только для full
if [[ "$MODE" == "full" ]]; then
  if ! command -v docker &> /dev/null; then
    echo ">>> Устанавливаем Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER"
  fi

  if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
  elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
  else
    echo ">>> Устанавливаем docker-compose-plugin..."
    sudo apt-get update -y
    sudo apt-get install -y docker-compose-plugin
    DOCKER_COMPOSE="docker compose"
  fi
fi

# MongoDB tools
install_mongo_tools() {
  if ! command -v mongodump &> /dev/null; then
    echo ">>> Подключаем репозиторий MongoDB..."
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb.gpg
    echo "deb [ signed-by=/usr/share/keyrings/mongodb.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" \
      | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    sudo apt-get update -y
    sudo apt-get install -y mongodb-org-tools
  fi
}
install_mongo_tools

### === Docker Compose файл (только для full) ===
if [[ "$MODE" == "full" ]]; then
cat > docker-compose.yml <<EOF
services:
  postgres:
    image: ghcr.io/ferretdb/postgres-documentdb:17-0.106.0-ferretdb-2.5.0
    restart: on-failure
    environment:
      - POSTGRES_USER=${TARGET_USERNAME}
      - POSTGRES_PASSWORD=${TARGET_PASSWORD}
      - POSTGRES_DB=postgres
    volumes:
      - ./data:/var/lib/postgresql/data

  ferretdb:
    image: ghcr.io/ferretdb/ferretdb:2.5.0
    restart: on-failure
    ports:
      - 27017:27017
    environment:
      - FERRETDB_POSTGRESQL_URL=postgres://username:password@postgres:5432/postgres

networks:
  default:
    name: ferretdb
EOF
fi

### === Запуск контейнеров только для full ===
if [[ "$MODE" == "full" ]]; then
  echo ">>> Запускаем PostgreSQL и FerretDB..."
  $DOCKER_COMPOSE up -d
  sleep 15
fi

### === Миграция данных ===
if [[ "$MODE" == "full" ]]; then
  echo ">>> Экспорт коллекций из MongoDB..."
  rm -rf dump && mkdir dump
  MONGO_URI_BASE="${MONGO_SOURCE_URI%/*}"

  collections=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
    --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

  for coll in $collections; do
    echo "  -> Экспорт коллекции $coll"
    mongoexport --uri="$MONGO_URI_BASE/$SOURCE_DB" \
      --collection="$coll" \
      --out="dump/${coll}.json" \
      --authenticationDatabase="admin"
  done

  echo ">>> Импортируем коллекции в FerretDB..."
  for coll_file in dump/*.json; do
    coll=$(basename "$coll_file" .json)
    echo "  -> Импорт коллекции $coll"
    mongoimport --uri="$TARGET_URI" \
      --collection="$coll" \
      --drop \
      --file="$coll_file"
  done
fi

### === Создание индексов ===
if [[ "$MODE" == "full" || "$MODE" == "create_index" ]]; then
  echo ">>> Создание индексов для каждой коллекции (кроме _id)..."
  MONGO_URI_BASE="${MONGO_SOURCE_URI%/*}"
  collections=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
    --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

  for coll in $collections; do
    echo ">>> Обрабатываем коллекцию: $coll"
    INDEX_SCRIPT="$DEBUG_INDEX_DIR/create_indexes_${coll}.js"

    mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
      --eval "
        const indexes = db.getSiblingDB('$SOURCE_DB')['$coll'].getIndexes();
        indexes.forEach(idx => {
          if (!('_id' in idx.key)) {
            const keyJson = JSON.stringify(idx.key);
            const opts = {...idx};
            delete opts.key;
            delete opts.ns;
            print('db.getSiblingDB(\"$TARGET_DB\").' + '$coll' + '.createIndex(' + keyJson + ',' + JSON.stringify(opts) + ');');
          }
        });
      " > "$INDEX_SCRIPT"

    echo ">>> Скрипт индексов для $coll сохранён в $INDEX_SCRIPT"
    mongosh "$TARGET_URI" --file "$INDEX_SCRIPT"
    echo ">>> Индексы для $coll созданы в БД-приемнике"
  done
fi

### === Проверка целостности данных ===
if [[ "$MODE" == "full" || "$MODE" == "check_checksum" ]]; then
  echo ">>> Проверка целостности данных (лимит: $CHECK_LIMIT)..."

  MONGO_URI_BASE="${MONGO_SOURCE_URI%/*}"
  collections=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
    --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

  echo ">>> Генерация текстового и HTML отчета..."
  {
    echo "Отчет миграции MongoDB → PostgreSQL/FerretDB"
    echo "Проверка целостности данных (лимит: $CHECK_LIMIT)"
    echo "---------------------------------------------"
  } > "$REPORT_FILE_TXT"

  echo "<html><head><meta charset='UTF-8'><title>Отчёт миграции MongoDB → PostgreSQL</title></head><body>" > "$REPORT_FILE_HTML"
  echo "<h1>Сравнение документов и MD5</h1>" >> "$REPORT_FILE_HTML"
  echo "<table border=1><tr><th>Коллекция</th><th>Источник (документы / MD5 / время)</th><th>Приёмник (документы / MD5 / время)</th></tr>" >> "$REPORT_FILE_HTML"

  for coll in $collections; do
    echo ">>> Проверяем коллекцию: $coll"

    # Источник
    start_src=$(date +%s%3N)
    SRC_HASH_CNT=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" --eval "
      const crypto = require('crypto');
      db = db.getSiblingDB('$SOURCE_DB');
      const collection='$coll';
      const limit=$CHECK_LIMIT;
      const hash=crypto.createHash('md5');
      let count=0;
      const cursor=db[collection].find().sort({_id:1}).limit(limit);
      while(cursor.hasNext()){ let d=cursor.next(); count++; hash.update(JSON.stringify(d)); }
      print(hash.digest('hex') + ',' + count);
    ")
    end_src=$(date +%s%3N)
    src_time=$((end_src - start_src))

    # Приёмник
    start_dst=$(date +%s%3N)
    DST_HASH_CNT=$(mongosh --quiet "$TARGET_URI" --eval "
      const crypto = require('crypto');
      db = db.getSiblingDB('$TARGET_DB');
      const collection='$coll';
      const limit=$CHECK_LIMIT;
      const hash=crypto.createHash('md5');
      let count=0;
      const cursor=db[collection].find().sort({_id:1}).limit(limit);
      while(cursor.hasNext()){ let d=cursor.next(); count++; hash.update(JSON.stringify(d)); }
      print(hash.digest('hex') + ',' + count);
    ")
    end_dst=$(date +%s%3N)
    dst_time=$((end_dst - start_dst))

    src_md5=$(echo "$SRC_HASH_CNT" | cut -d',' -f1)
    src_count=$(echo "$SRC_HASH_CNT" | cut -d',' -f2)
    dst_md5=$(echo "$DST_HASH_CNT" | cut -d',' -f1)
    dst_count=$(echo "$DST_HASH_CNT" | cut -d',' -f2)

    color="green"
    [[ "$src_md5" != "$dst_md5" ]] && color="red"

    # Текстовый отчет
    echo "Коллекция: $coll" >> "$REPORT_FILE_TXT"
    echo "  Источник: $src_count документов / MD5: $src_md5 / время: ${src_time}ms" >> "$REPORT_FILE_TXT"
    echo "  Приёмник: $dst_count документов / MD5: $dst_md5 / время: ${dst_time}ms" >> "$REPORT_FILE_TXT"
    echo "  Результат: $( [[ $color == green ]] && echo OK || echo НЕСООТВЕТСТВИЕ )" >> "$REPORT_FILE_TXT"
    echo "---------------------------------------------" >> "$REPORT_FILE_TXT"

    # HTML отчет
    echo "<tr><td>$coll</td><td>$src_count / $src_md5 / ${src_time}ms</td><td><font color='$color'>$dst_count / $dst_md5 / ${dst_time}ms</font></td></tr>" >> "$REPORT_FILE_HTML"
  done

  echo "</table></body></html>" >> "$REPORT_FILE_HTML"
  echo ">>> Отчет сохранён в $REPORT_FILE_HTML и $REPORT_FILE_TXT"
fi
