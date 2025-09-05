#!/bin/bash
set -euo pipefail

# Путь к environment
ENV_FILE="./environment"

if [[ ! -f "$ENV_FILE" ]]; then
    echo ">>> Не найден файл environment: $ENV_FILE"
    exit 1
fi

source "$ENV_FILE"

# Дефолтный лимит
LIMIT="${CHECK_LIMIT:-100000}"

# Проверка обязательных переменных
if [[ -z "${MONGO_SOURCE_URI:-}" || -z "${SOURCE_DB:-}" || -z "${TARGET_URI:-}" || -z "${TARGET_DB:-}" ]]; then
    echo ">>> Не заданы MONGO_SOURCE_URI, SOURCE_DB, TARGET_URI, TARGET_DB или LIMIT в $ENV_FILE"
    exit 1
fi

echo "Начинаем проверку целостности данных между БД"
echo "Источник: $MONGO_SOURCE_URI (DB: $SOURCE_DB)"
echo "Цель: $TARGET_URI (DB: $TARGET_DB)"
echo "Лимит документов для проверки: $LIMIT"
echo "=============================================="

DEBUG_DIR="./debug_scripts"
mkdir -p "$DEBUG_DIR"

# Получаем список коллекций источника
source_collections=$(mongosh "$MONGO_SOURCE_URI" --quiet --eval "
db = db.getSiblingDB('$SOURCE_DB');
db.getCollectionNames().filter(c => !c.startsWith('system.')).join(',')
" || true)

IFS=',' read -r -a collections <<< "$source_collections"

# Функция генерации скрипта MD5
generate_md5_script() {
    local db_name="$1"
    local collection="$2"
    local file_path="$3"

    [[ -z "$collection" ]] && return

    cat > "$file_path" <<EOF
const crypto = require("crypto");
db = db.getSiblingDB("$db_name");
const collection = "$collection";
const limit = $LIMIT;

let count = 0;
const hash = crypto.createHash("md5");

const cursor = db[collection].find().sort({_id:1}).limit(limit);
while (cursor.hasNext()) {
    const doc = cursor.next();
    count++;
    hash.update(JSON.stringify(doc));
}

print(hash.digest("hex") + "," + count);
EOF
}

all_match=true
report_txt="checksum_report.txt"
report_html="checksum_report.html"
> "$report_txt"
> "$report_html"

for coll in "${collections[@]}"; do
    coll=$(echo "$coll" | xargs)
    [[ -z "$coll" ]] && continue

    # Безопасное имя файла
    safe_coll=$(echo "$coll" | sed 's/[^a-zA-Z0-9_-]/_/g')

    src_script="$DEBUG_DIR/get_checksum_source_${safe_coll}.js"
    tgt_script="$DEBUG_DIR/get_checksum_target_${safe_coll}.js"

    generate_md5_script "$SOURCE_DB" "$coll" "$src_script"
    generate_md5_script "$TARGET_DB" "$coll" "$tgt_script"

    # Получаем MD5 и количество документов
    src_out=$(mongosh "$MONGO_SOURCE_URI" --quiet "$src_script")
    tgt_out=$(mongosh "$TARGET_URI" --quiet "$tgt_script")

    src_hash=$(echo "$src_out" | cut -d',' -f1)
    src_count=$(echo "$src_out" | cut -d',' -f2)
    tgt_hash=$(echo "$tgt_out" | cut -d',' -f1)
    tgt_count=$(echo "$tgt_out" | cut -d',' -f2)

    echo "Проверяем коллекцию: $coll"
    if [[ "$src_hash" == "$tgt_hash" && "$src_count" == "$tgt_count" ]]; then
        echo "✓ Коллекция $coll: OK (документов: $src_count)"
        echo "Коллекция $coll: OK, документов: $src_count" >> "$report_txt"
    else
        all_match=false
        echo "✗ Коллекция $coll: НЕСООТВЕТСТВИЕ"
        echo "  Источник: $src_count ($src_hash)"
        echo "  Цель:     $tgt_count ($tgt_hash)"
        echo "Коллекция $coll: НЕСООТВЕТСТВИЕ, источник: $src_count ($src_hash), цель: $tgt_count ($tgt_hash)" >> "$report_txt"
    fi
    echo "----------------------------------------------"
done

if $all_match; then
    echo "✅ Все коллекции совпадают!"
else
    echo "❌ Обнаружены несоответствия!"
fi

echo ">>> Отчет сохранён в $report_html и $report_txt"
echo ">>> Скрипты для дебага сохранены в $DEBUG_DIR"