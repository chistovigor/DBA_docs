#!/bin/bash
set -euo pipefail

### === Конфигурация ===
ENV_FILE="./environment"
DEFAULT_CHECK_LIMIT=100000
DEBUG_INDEX_DIR="./debug_indexes"
DEBUG_CHECKSUM_DIR="./debug_scripts"
REPORT_FILE_HTML="migration_report_postgresql.html"
REPORT_FILE_TXT="migration_report_postgresql.txt"

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
  echo "  ./mongo_to_postgresql_full_report.sh help       # показать эту справку"
  echo ""
  echo "Пример файла environment (замещённые чувствительные данные):"
  echo "  MONGO_SOURCE_URI=\"mongodb://root:some_password1@some_server1:27017/admin\""
  echo "  SOURCE_DB=\"test2\""
  echo "  TARGET_USERNAME=\"username\""
  echo "  TARGET_PASSWORD=\"some_password2\""
  echo "  TARGET_URI=\"mongodb://username:some_password2@localhost:27017/postgres?authSource=admin\""
  echo "  TARGET_DB=\"postgres\""
  echo "  CHECK_LIMIT=100000       # необязательная, по умолчанию 100000"
  exit 0
fi

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

install_mongo_tools() {
  if ! command -v mongodump &> /dev/null; then
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb.gpg
    echo "deb [ signed-by=/usr/share/keyrings/mongodb.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" \
      | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    sudo apt-get update -y
    sudo apt-get install -y mongodb-org-tools
  fi
}
install_mongo_tools

### === Функции для создания индексов ===
create_indexes() {
  echo ">>> Создание индексов для каждой коллекции (кроме _id)..."
  local collections
  collections=$(mongosh --quiet "${MONGO_SOURCE_URI%/*}/$SOURCE_DB" --authenticationDatabase="admin" \
    --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

  for coll in $collections; do
    echo ">>> Обрабатываем коллекцию: $coll"
    INDEX_SCRIPT="$DEBUG_INDEX_DIR/create_indexes_${coll}.js"

    mongosh --quiet "${MONGO_SOURCE_URI%/*}/$SOURCE_DB" --authenticationDatabase="admin" \
      --eval "
        const indexes = db.getSiblingDB('$SOURCE_DB')['$coll'].getIndexes();
        indexes.forEach(idx => {
          if (!('_id' in idx.key)) {
            const keyJson = JSON.stringify(idx.key);
            const opts = {...idx};
            delete opts.key;
            delete opts.ns;
            print('db.getSiblingDB(\"$TARGET_DB\").'$coll'.createIndex(' + keyJson + ',' + JSON.stringify(opts) + ');');
          }
        });
      " > "$INDEX_SCRIPT"

    mongosh "$TARGET_URI" --file "$INDEX_SCRIPT"
    echo ">>> Индексы для $coll созданы в БД-приемнике"
  done
}

### === Функции для проверки целостности данных ===
check_checksum() {
  echo ">>> Проверка целостности данных (лимит: $CHECK_LIMIT)..."

  collections=$(mongosh --quiet "${MONGO_SOURCE_URI%/*}/$SOURCE_DB" --authenticationDatabase="admin" \
    --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

  echo "" > "$REPORT_FILE_TXT"
  echo "<html><head><meta charset='UTF-8'><title>Отчет проверки данных</title></head><body>" > "$REPORT_FILE_HTML"
  echo "<h1>Проверка целостности данных</h1><table border=1><tr><th>Коллекция</th><th>Источник</th><th>Приёмник</th><th>MD5 Source</th><th>MD5 Target</th><th>Время Source</th><th>Время Target</th></tr>" >> "$REPORT_FILE_HTML"

  for coll in $collections; do
    SRC_START=$(date +%s)
    SRC_HASH_CNT=$(mongosh "${MONGO_SOURCE_URI%/*}/$SOURCE_DB" --authenticationDatabase="admin" --quiet --eval "
      const crypto = require('crypto');
      const dbname = '$SOURCE_DB';
      const collname = '$coll';
      const limit = $CHECK_LIMIT;
      let count = 0;
      const hash = crypto.createHash('md5');
      const cursor = db.getSiblingDB(dbname)[collname].find().sort({_id:1}).limit(limit);
      while(cursor.hasNext()){ const doc = cursor.next(); count++; hash.update(JSON.stringify(doc)); }
      print(hash.digest('hex') + ',' + count);
    ")
    SRC_END=$(date +%s)
    SRC_HASH=$(echo "$SRC_HASH_CNT" | cut -d',' -f1)
    SRC_COUNT=$(echo "$SRC_HASH_CNT" | cut -d',' -f2)
    SRC_TIME=$((SRC_END-SRC_START))

    DST_START=$(date +%s)
    DST_HASH_CNT=$(mongosh "$TARGET_URI" --quiet --eval "
      const crypto = require('crypto');
      const dbname = '$TARGET_DB';
      const collname = '$coll';
      const limit = $CHECK_LIMIT;
      let count = 0;
      const hash = crypto.createHash('md5');
      const cursor = db.getSiblingDB(dbname)[collname].find().sort({_id:1}).limit(limit);
      while(cursor.hasNext()){ const doc = cursor.next(); count++; hash.update(JSON.stringify(doc)); }
      print(hash.digest('hex') + ',' + count);
    ")
    DST_END=$(date +%s)
    DST_HASH=$(echo "$DST_HASH_CNT" | cut -d',' -f1)
    DST_COUNT=$(echo "$DST_HASH_CNT" | cut -d',' -f2)
    DST_TIME=$((DST_END-DST_START))

    STATUS="OK"
    [[ "$SRC_HASH" != "$DST_HASH" ]] && STATUS="НЕСООТВЕТСТВИЕ"

    echo "$coll | $SRC_COUNT | $DST_COUNT | $SRC_HASH | $DST_HASH | $SRC_TIME s | $DST_TIME s | $STATUS" >> "$REPORT_FILE_TXT"
    echo "<tr><td>$coll</td><td>$SRC_COUNT</td><td>$DST_COUNT</td><td>$SRC_HASH</td><td>$DST_HASH</td><td>${SRC_TIME}s</td><td>${DST_TIME}s</td></tr>" >> "$REPORT_FILE_HTML"
  done

  echo "</table></body></html>" >> "$REPORT_FILE_HTML"
  echo ">>> Генерация текстового и HTML отчета завершена"
  echo ">>> Отчет сохранён в $REPORT_FILE_HTML и $REPORT_FILE_TXT"
}

### === Основной блок ===
case "$MODE" in
  full)
    echo ">>> Полный режим: миграция данных, создание индексов и проверка целостности"
    
    ### Запуск контейнеров только в полном режиме
    echo ">>> Запускаем PostgreSQL и FerretDB..."
    docker compose up -d
    sleep 15

    ### Миграция данных
    echo ">>> Экспортируем данные из MongoDB..."
    rm -rf dump && mkdir dump
    MONGO_URI_BASE="${MONGO_SOURCE_URI%/*}"
    collections=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
      --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')
    for coll in $collections; do
      echo "  -> Экспорт коллекции $coll"
      mongoexport --uri="$MONGO_URI_BASE/$SOURCE_DB" --collection="$coll" --out="dump/${coll}.json" --authenticationDatabase="admin"
    done

    echo ">>> Импортируем данные в FerretDB..."
    for coll_file in dump/*.json; do
      coll=$(basename "$coll_file" .json)
      echo "  -> Импорт коллекции $coll"
      mongoimport --uri="$TARGET_URI" --collection="$coll" --drop --file="$coll_file"
    done

    create_indexes
    check_checksum
    ;;
  create_index)
    echo ">>> Режим только создание индексов"
    create_indexes
    ;;
  check_checksum)
    echo ">>> Режим только проверка целостности данных"
    check_checksum
    ;;
  *)
    echo ">>> Неизвестный режим: $MODE"
    exit 1
    ;;
esac
