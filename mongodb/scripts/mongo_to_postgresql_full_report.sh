#!/bin/bash
set -euo pipefail

ENV_FILE="./environment"
DEBUG_INDEX_DIR="./debug_indexes"
REPORT_FILE_HTML="migration_report_postgresql.html"
REPORT_FILE_TXT="migration_report_postgresql.txt"

# Проверяем файл окружения
if [[ ! -f "$ENV_FILE" ]]; then
  echo ">>> Файл $ENV_FILE не найден!"
  exit 1
fi

# Загружаем переменные
set -a
source "$ENV_FILE"
set +a

# Установка переменной LIMIT по умолчанию
: "${CHECK_LIMIT:=100000}"

# Проверка ключевых переменных
: "${MONGO_SOURCE_URI:?Не задано MONGO_SOURCE_URI в $ENV_FILE}"
: "${SOURCE_DB:?Не задано SOURCE_DB в $ENV_FILE}"
: "${TARGET_URI:?Не задано TARGET_URI в $ENV_FILE}"
: "${TARGET_DB:?Не задано TARGET_DB в $ENV_FILE}"

MODE="${1:-main}"

case "$MODE" in
  help)
    echo "Использование: $0 [mode]"
    echo "Режимы работы:"
    echo "  (пусто)      : Полная миграция данных с созданием индексов и проверкой."
    echo "  create_index  : Только создание индексов (кроме _id) в БД-приемнике."
    echo "  check_checksum: Только проверка целостности данных и генерация отчетов."
    echo "  help          : Вывод этой помощи."
    echo ""
    echo "Пример файла environment:"
    cat <<EOL
MONGO_SOURCE_URI="mongodb://root:some_pass1@some_server1:27017/admin"
SOURCE_DB="test2"
TARGET_URI="mongodb://username:some_pass2@localhost:27017/postgres?authSource=admin"
TARGET_DB="postgres"
TARGET_USERNAME="username"
TARGET_PASSWORD="password"
CHECK_LIMIT=100000
EOL
    exit 0
    ;;
esac

start_time_total=$(date +%s)

# --- Функция создания индексов ---
create_indexes() {
  echo ">>> Создание индексов для каждой коллекции (кроме _id)..."
  mkdir -p "$DEBUG_INDEX_DIR"

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
            print(\`db.getSiblingDB('${TARGET_DB}').${coll}.createIndex(\${keyJson},\${JSON.stringify(opts)});\`);
          }
        });
      " > "$INDEX_SCRIPT"

    echo ">>> Скрипт индексов для $coll сохранён в $INDEX_SCRIPT"

    mongosh "$TARGET_URI" --file "$INDEX_SCRIPT"
    echo ">>> Индексы для $coll созданы в БД-приемнике"
  done
  echo ">>> Синхронизация индексов завершена."
}

# --- Функция проверки целостности данных ---
check_checksum() {
  echo ">>> Проверка целостности данных (лимит: $CHECK_LIMIT)..."
  START_CHECK=$(date +%s)

  collections=$(mongosh --quiet "${MONGO_SOURCE_URI%/*}/$SOURCE_DB" --authenticationDatabase="admin" \
    --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

  TXT_REPORT=""
  HTML_REPORT="<html><head><meta charset='UTF-8'><title>Отчёт миграции MongoDB → PostgreSQL</title></head><body>"
  HTML_REPORT+="<h1>Сравнение целостности коллекций</h1>"
  HTML_REPORT+="<table border=1><tr><th>Коллекция</th><th>Источник</th><th>Хеш (MD5)</th><th>Приёмник</th><th>Хеш (MD5)</th><th>Статус</th><th>Время</th></tr>"

  for coll in $collections; do
    echo ">>> Проверяем коллекцию: $coll"
    START_COLL=$(date +%s)

    # Источник
    SRC_HASH_COUNT=$(mongosh --quiet "${MONGO_SOURCE_URI%/*}/$SOURCE_DB" --authenticationDatabase="admin" --eval "
      const crypto = require('crypto');
      db = db.getSiblingDB('$SOURCE_DB');
      const collection = '$coll';
      const limit = $CHECK_LIMIT;
      let count = 0;
      const hash = crypto.createHash('md5');
      const cursor = db[collection].find().sort({_id:1}).limit(limit);
      while(cursor.hasNext()) { const doc = cursor.next(); count++; hash.update(JSON.stringify(doc)); }
      print(hash.digest('hex') + ',' + count);
    ")
    SRC_HASH=$(echo "$SRC_HASH_COUNT" | cut -d',' -f1)
    SRC_COUNT=$(echo "$SRC_HASH_COUNT" | cut -d',' -f2)

    # Приёмник
    DST_HASH_COUNT=$(mongosh --quiet "$TARGET_URI" --eval "
      const crypto = require('crypto');
      db = db.getSiblingDB('$TARGET_DB');
      const collection = '$coll';
      const limit = $CHECK_LIMIT;
      let count = 0;
      const hash = crypto.createHash('md5');
      const cursor = db[collection].find().sort({_id:1}).limit(limit);
      while(cursor.hasNext()) { const doc = cursor.next(); count++; hash.update(JSON.stringify(doc)); }
      print(hash.digest('hex') + ',' + count);
    ")
    DST_HASH=$(echo "$DST_HASH_COUNT" | cut -d',' -f1)
    DST_COUNT=$(echo "$DST_HASH_COUNT" | cut -d',' -f2)

    STATUS="OK"
    [[ "$SRC_HASH" != "$DST_HASH" ]] && STATUS="НЕСООТВЕТСТВИЕ"

    END_COLL=$(date +%s)
    DURATION=$((END_COLL-START_COLL))

    TXT_REPORT+="Коллекция: $coll | Источник: $SRC_COUNT ($SRC_HASH) | Приёмник: $DST_COUNT ($DST_HASH) | Статус: $STATUS | Время: ${DURATION}s\n"
    HTML_REPORT+="<tr><td>$coll</td><td>$SRC_COUNT</td><td>$SRC_HASH</td><td>$DST_COUNT</td><td>$DST_HASH</td><td>$STATUS</td><td>${DURATION}s</td></tr>"
  done

  END_CHECK=$(date +%s)
  TOTAL_DURATION=$((END_CHECK-START_CHECK))

  HTML_REPORT+="</table>"
  HTML_REPORT+="<p>Общее время проверки: ${TOTAL_DURATION}s</p></body></html>"

  echo -e "$TXT_REPORT" > "$REPORT_FILE_TXT"
  echo "$HTML_REPORT" > "$REPORT_FILE_HTML"

  echo ">>> Проверка целостности данных завершена за ${TOTAL_DURATION}s"
  echo ">>> Отчёт сохранён в $REPORT_FILE_HTML и $REPORT_FILE_TXT"
}

# --- Основной режим ---
if [[ "$MODE" == "create_index" ]]; then
  echo ">>> Режим только создание индексов"
  create_indexes
  exit 0
elif [[ "$MODE" == "check_checksum" ]]; then
  echo ">>> Режим только проверки целостности данных"
  check_checksum
  exit 0
else
  echo ">>> Полная миграция данных с созданием индексов и проверкой..."

  # --- Миграция данных ---
  echo ">>> Делаем export из MongoDB в JSON..."
  rm -rf dump && mkdir dump

  MONGO_URI_BASE=$(echo "$MONGO_SOURCE_URI" | sed -E 's|/[^/]+$||')
  collections=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
    --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

  for coll in $collections; do
    echo "  -> Экспорт коллекции $coll"
    mongoexport --uri="$MONGO_URI_BASE/$SOURCE_DB" --collection="$coll" --out="dump/${coll}.json" --authenticationDatabase="admin"
  done

  echo ">>> Восстанавливаем dump в FerretDB..."
  for coll_file in dump/*.json; do
    coll=$(basename "$coll_file" .json)
    echo "  -> Импорт коллекции $coll"
    mongoimport --uri="$TARGET_URI" --collection="$coll" --drop --file="$coll_file"
  done

  # --- Создание индексов ---
  create_indexes

  # --- Проверка целостности ---
  check_checksum

fi

END_TOTAL=$(date +%s)
echo ">>> Общее время выполнения скрипта: $((END_TOTAL-start_time_total))s"
