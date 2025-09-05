#!/bin/bash
set -euo pipefail

### === Конфигурация ===
ENV_FILE="./environment"
DEBUG_DIR="./debug_scripts"
DEBUG_CHECK_DIR="./debug_check"

TXT_REPORT="migration_report_postgresql.txt"
REPORT_FILE="migration_report_postgresql.html"

if [[ ! -f "$ENV_FILE" ]]; then
  echo ">>> Файл $ENV_FILE не найден!"
  exit 1
fi

# Загружаем переменные
set -a
source "$ENV_FILE"
set +a

# Проверяем ключевые переменные
: "${MONGO_SOURCE_URI:?Не задано MONGO_SOURCE_URI в $ENV_FILE}"
: "${SOURCE_DB:?Не задано SOURCE_DB в $ENV_FILE}"
: "${TARGET_URI:?Не задано TARGET_URI в $ENV_FILE}"
: "${TARGET_DB:?Не задано TARGET_DB в $ENV_FILE}"
CHECK_LIMIT="${CHECK_LIMIT:-100000}"

# Определяем режим работы
MODE="${1:-full}"
if [[ "$MODE" == "help" ]]; then
    echo "Использование: $0 [full|create_index|check_checksum|help]"
    echo "  full           - миграция данных + создание индексов + проверка"
    echo "  create_index   - только создание индексов"
    echo "  check_checksum - только проверка MD5 и количества документов"
    echo "  help           - показать это сообщение"
    exit 0
fi

# Проверка и создание директорий для скриптов дебага
mkdir -p "$DEBUG_DIR" "$DEBUG_CHECK_DIR/src" "$DEBUG_CHECK_DIR/dst"

MONGO_URI_BASE="${MONGO_SOURCE_URI%/*}"

### === Миграция данных (только в full) ===
if [[ "$MODE" == "full" ]]; then
    echo ">>> Делаем экспорт из MongoDB в JSON..."
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
fi

### === Создание индексов ===
if [[ "$MODE" == "full" || "$MODE" == "create_index" ]]; then
    echo ">>> Создание индексов для каждой коллекции (кроме _id)..."
    collections=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
      --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

    for coll in $collections; do
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
                print('db.getSiblingDB(\"$TARGET_DB\").'$coll'.createIndex(' + keyJson + ',' + JSON.stringify(opts) + ');');
              }
            });
          " > "$INDEX_SCRIPT"

        mongosh "$TARGET_URI" --file "$INDEX_SCRIPT"
        echo ">>> Индексы для $coll созданы в БД-приемнике"
    done
    [[ "$MODE" == "create_index" ]] && exit 0
fi

### === Проверка целостности данных ===
if [[ "$MODE" == "full" || "$MODE" == "check_checksum" ]]; then
    echo ">>> Проверка целостности данных (лимит: $CHECK_LIMIT)..."

    SRC_COUNTS=""
    DST_COUNTS=""

    collections=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
      --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

    for coll in $collections; do
        # Скрипт для источника
        SRC_JS="$DEBUG_CHECK_DIR/src/get_checksum_${coll}.js"
        cat > "$SRC_JS" <<JS
const crypto = require("crypto");
db = db.getSiblingDB("$SOURCE_DB");
const collection = "$coll";
const limit = $CHECK_LIMIT;
let count = 0;
const hash = crypto.createHash("md5");
const cursor = db[collection].find().sort({_id:1}).limit(limit);
while (cursor.hasNext()) { const doc = cursor.next(); count++; hash.update(JSON.stringify(doc)); }
print(hash.digest("hex") + "," + count);
JS
        SRC_RESULT=$(mongosh "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" --file "$SRC_JS" | tr -d '\r')
        SRC_HASH=$(echo "$SRC_RESULT" | cut -d',' -f1)
        SRC_CNT=$(echo "$SRC_RESULT" | cut -d',' -f2)

        # Скрипт для приёмника
        DST_JS="$DEBUG_CHECK_DIR/dst/get_checksum_${coll}.js"
        cat > "$DST_JS" <<JS
const crypto = require("crypto");
db = db.getSiblingDB("$TARGET_DB");
const collection = "$coll";
const limit = $CHECK_LIMIT;
let count = 0;
const hash = crypto.createHash("md5");
const cursor = db[collection].find().sort({_id:1}).limit(limit);
while (cursor.hasNext()) { const doc = cursor.next(); count++; hash.update(JSON.stringify(doc)); }
print(hash.digest("hex") + "," + count);
JS
        DST_RESULT=$(mongosh "$TARGET_URI" --file "$DST_JS" | tr -d '\r')
        DST_HASH=$(echo "$DST_RESULT" | cut -d',' -f1)
        DST_CNT=$(echo "$DST_RESULT" | cut -d',' -f2)

        SRC_COUNTS+="$coll,$SRC_CNT,$SRC_HASH"$'\n'
        DST_COUNTS+="$coll,$DST_CNT,$DST_HASH"$'\n'
    done

    echo ">>> Генерация текстового и HTML отчета..."
    echo "Проверка первых $CHECK_LIMIT документов каждой коллекции" > "$TXT_REPORT"

    {
      echo "<html><head><meta charset='UTF-8'><title>Отчёт миграции MongoDB → PostgreSQL</title></head><body>"
      echo "<h1>Сравнение MD5 и количества документов (лимит $CHECK_LIMIT)</h1>"
      echo "<table border=1><tr><th>Коллекция</th><th>Источник (MongoDB)</th><th>Хеш</th><th>Приёмник (PostgreSQL/FerretDB)</th><th>Хеш</th></tr>"

      while IFS=, read -r col src_cnt src_hash; do
          dst_line=$(echo "$DST_COUNTS" | grep "^$col,")
          dst_cnt=$(echo "$dst_line" | cut -d',' -f2)
          dst_hash=$(echo "$dst_line" | cut -d',' -f3)

          [[ -z "$dst_cnt" ]] && dst_cnt=0
          [[ -z "$dst_hash" ]] && dst_hash="N/A"

          color="green"
          [[ "$src_cnt" != "$dst_cnt" || "$src_hash" != "$dst_hash" ]] && color="red"

          echo "$col: источник=$src_cnt/$src_hash, приёмник=$dst_cnt/$dst_hash" >> "$TXT_REPORT"
          echo "<tr><td>$col</td><td>$src_cnt</td><td>$src_hash</td><td><font color='$color'>$dst_cnt</font></td><td><font color='$color'>$dst_hash</font></td></tr>"
      done <<< "$SRC_COUNTS"

      echo "</table></body></html>"
    } > "$REPORT_FILE"

    echo ">>> Проверка завершена. Отчёт сохранён в $REPORT_FILE и $TXT_REPORT"
fi
