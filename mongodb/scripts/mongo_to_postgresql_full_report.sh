#!/bin/bash
set -euo pipefail

### === Конфигурация ===
ENV_FILE="./environment"
DEBUG_DIR="./debug_scripts"
mkdir -p "$DEBUG_DIR"

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
CHECK_LIMIT="${CHECK_LIMIT:-100000}"

REPORT_FILE="migration_report_postgresql.html"
TXT_REPORT_FILE="migration_report_postgresql.txt"

MODE="${1:-}"

show_help() {
  cat <<EOF
Использование: $0 [режим]

Режимы:
  create_index   - только создание индексов
  check_checksum - только проверка целостности (с подсчётом и хешем)
  help           - вывод помощи
  (по умолчанию) - полная миграция данных + создание индексов + проверка

Файл environment должен содержать:
  MONGO_SOURCE_URI="mongodb://user:pass@some_server:27017/admin"
  SOURCE_DB="имя_источника"
  TARGET_USERNAME="username"
  TARGET_PASSWORD="password"
  TARGET_DB="postgres"
  TARGET_URI="mongodb://username:password@localhost:27017/postgres?authSource=admin"
  CHECK_LIMIT=100000   # необязательная, по умолчанию 100000
EOF
}

if [[ "$MODE" == "help" ]]; then
  show_help
  exit 0
fi

install_if_missing() {
  local cmd=$1
  local pkg=$2
  if ! command -v "$cmd" &> /dev/null; then
    echo ">>> Устанавливаем $pkg..."
    sudo apt-get update -y
    sudo apt-get install -y "$pkg"
  fi
}

### === Установка утилит ===
install_if_missing jq jq
install_if_missing mongosh mongodb-org-tools
install_if_missing docker docker
install_if_missing docker-compose docker-compose-plugin

MONGO_URI_BASE="${MONGO_SOURCE_URI%/*}"

### === Функция создания контейнеров и запуска ===
start_containers() {
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
      - FERRETDB_POSTGRESQL_URL=postgres://${TARGET_USERNAME}:${TARGET_PASSWORD}@postgres:5432/postgres

networks:
  default:
    name: ferretdb
EOF

  echo ">>> Запускаем PostgreSQL и FerretDB..."
  docker compose up -d
  sleep 15
}

### === Функция миграции данных ===
migrate_data() {
  echo ">>> Делаем export из MongoDB в JSON..."
  rm -rf dump && mkdir dump

  collections=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
    --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

  for coll in $collections; do
    echo "  -> Экспорт коллекции $coll"
    mongoexport --uri="$MONGO_URI_BASE/$SOURCE_DB" \
      --collection="$coll" \
      --out="dump/${coll}.json" \
      --authenticationDatabase="admin"
  done

  echo ">>> Восстанавливаем dump в FerretDB..."
  for coll_file in dump/*.json; do
    coll=$(basename "$coll_file" .json)
    echo "  -> Импорт коллекции $coll"
    mongoimport --uri="$TARGET_URI" \
      --collection="$coll" \
      --drop \
      --file="$coll_file"
  done
}

### === Функция создания индексов ===
create_indexes() {
  echo ">>> Создание индексов для каждой коллекции (кроме _id)..."
  collections=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
    --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

  for coll in $collections; do
    echo ">>> Обрабатываем коллекцию: $coll"
    INDEX_SCRIPT="$DEBUG_DIR/create_indexes_${coll}.js"

    mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
      --eval "
        const indexes = db.getSiblingDB('$SOURCE_DB')['$coll'].getIndexes();
        indexes.forEach(idx => {
          if (!('_id' in idx.key)) {
            const keyJson = JSON.stringify(idx.key);
            const opts = {...idx};
            delete opts.key;
            delete opts.ns;
            print('db.getSiblingDB(\"$TARGET_DB\")[\"$coll\"].createIndex(' + keyJson + ',' + JSON.stringify(opts) + ');');
          }
        });
      " > "$INDEX_SCRIPT"

    mongosh "$TARGET_URI" --file "$INDEX_SCRIPT"
    echo ">>> Индексы для $coll созданы в БД-приемнике"
  done
}

### === Функция проверки целостности данных ===
check_checksum() {
  echo ">>> Проверка целостности данных (лимит: $CHECK_LIMIT)..."

  collections=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
    --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

  TXT_REPORT=""
  HTML_REPORT="<html><head><meta charset='UTF-8'><title>Отчёт миграции MongoDB → PostgreSQL</title></head><body>"
  HTML_REPORT+="<h1>Сравнение количества документов и хешей</h1>"
  HTML_REPORT+="<table border=1><tr><th>Коллекция</th><th>Источник (Count)</th><th>Источник (MD5)</th><th>Приёмник (Count)</th><th>Приёмник (MD5)</th><th>Статус</th><th>Время (ms)</th></tr>"

  for coll in $collections; do
    echo ">>> Проверяем коллекцию: $coll"

    START_SRC=$(date +%s%3N)
    SRC_HASH_COUNT=$(mongosh "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" --quiet --eval "
      const crypto = require('crypto');
      db = db.getSiblingDB('$SOURCE_DB');
      const collection = '$coll';
      const limit = $CHECK_LIMIT;
      let count = 0;
      const hash = crypto.createHash('md5');
      const cursor = db[collection].find().sort({_id:1}).limit(limit);
      while(cursor.hasNext()){const doc=cursor.next(); count++; hash.update(JSON.stringify(doc));}
      print(hash.digest('hex')+','+count);
    ")
    END_SRC=$(date +%s%3N)
    SRC_TIME=$((END_SRC-START_SRC))
    SRC_HASH=$(echo "$SRC_HASH_COUNT" | cut -d',' -f1)
    SRC_COUNT=$(echo "$SRC_HASH_COUNT" | cut -d',' -f2)

    START_DST=$(date +%s%3N)
    DST_HASH_COUNT=$(mongosh "$TARGET_URI" --quiet --eval "
      const crypto = require('crypto');
      db = db.getSiblingDB('$TARGET_DB');
      const collection = '$coll';
      const limit = $CHECK_LIMIT;
      let count = 0;
      const hash = crypto.createHash('md5');
      const cursor = db[collection].find().sort({_id:1}).limit(limit);
      while(cursor.hasNext()){const doc=cursor.next(); count++; hash.update(JSON.stringify(doc));}
      print(hash.digest('hex')+','+count);
    ")
    END_DST=$(date +%s%3N)
    DST_TIME=$((END_DST-START_DST))
    DST_HASH=$(echo "$DST_HASH_COUNT" | cut -d',' -f1)
    DST_COUNT=$(echo "$DST_HASH_COUNT" | cut -d',' -f2)

    STATUS="OK"
    [[ "$SRC_HASH" != "$DST_HASH" || "$SRC_COUNT" != "$DST_COUNT" ]] && STATUS="НЕСООТВЕТСТВИЕ"

    COLOR="green"
    [[ "$STATUS" == "НЕСООТВЕТСТВИЕ" ]] && COLOR="red"

    TXT_REPORT+="Коллекция: $coll | Источник: $SRC_COUNT ($SRC_HASH, ${SRC_TIME}ms) | Приёмник: $DST_COUNT ($DST_HASH, ${DST_TIME}ms) | Статус: $STATUS\n"
    HTML_REPORT+="<tr><td>$coll</td><td>$SRC_COUNT</td><td>$SRC_HASH</td><td>$DST_COUNT</td><td>$DST_HASH</td><td><font color='$COLOR'>$STATUS</font></td><td>${SRC_TIME} / ${DST_TIME}</td></tr>"
  done

  HTML_REPORT+="</table></body></html>"

  echo -e "$TXT_REPORT" > "$TXT_REPORT_FILE"
  echo "$HTML_REPORT" > "$REPORT_FILE"

  echo ">>> Генерация текстового и HTML отчета завершена"
  echo ">>> Отчет сохранён в $REPORT_FILE и $TXT_REPORT_FILE"
}

### === Основной блок ===
case "$MODE" in
  create_index)
    echo ">>> Режим только создание индексов"
    create_indexes
    ;;
  check_checksum)
    echo ">>> Режим только проверка целостности данных"
    check_checksum
    ;;
  "" )
    echo ">>> Основной режим: миграция данных + создание индексов + проверка"
    start_containers
    migrate_data
    create_indexes
    check_checksum
    ;;
  * )
    show_help
    ;;
esac
