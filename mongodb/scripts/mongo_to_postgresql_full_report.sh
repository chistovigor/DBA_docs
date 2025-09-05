#!/bin/bash
set -euo pipefail

### === Конфигурация ===
ENV_FILE="./environment"

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
: "${TARGET_USERNAME:?Не задано TARGET_USERNAME в $ENV_FILE}"
: "${TARGET_PASSWORD:?Не задано TARGET_PASSWORD в $ENV_FILE}"

# Лимит документов для проверки
LIMIT="${CHECK_LIMIT:-100000}"

MODE="${1:-full}"  # full / create_index / check_checksum / help

DEBUG_INDEX_DIR="./debug_indexes"
DEBUG_CHECK_DIR="./debug_scripts"
mkdir -p "$DEBUG_INDEX_DIR" "$DEBUG_CHECK_DIR"

REPORT_FILE="migration_report_postgresql.html"
TXT_REPORT="migration_report_postgresql.txt"

print_help() {
    echo "Использование: $0 [mode]"
    echo "Режимы:"
    echo "  full           Полная миграция данных + создание индексов + проверка целостности"
    echo "  create_index   Только создание индексов"
    echo "  check_checksum Только проверка целостности данных"
    echo "  help           Вывод этой справки"
}

[[ "$MODE" == "help" ]] && { print_help; exit 0; }

MONGO_URI_BASE="${MONGO_SOURCE_URI%/*}"

### === Функции ===
install_if_missing() {
  local cmd=$1 pkg=$2
  if ! command -v "$cmd" &> /dev/null; then
    echo ">>> Устанавливаем $pkg..."
    sudo apt-get update -y
    sudo apt-get install -y "$pkg"
  fi
}

install_mongo_tools() {
  if ! command -v mongodump &> /dev/null; then
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb.gpg
    echo "deb [ signed-by=/usr/share/keyrings/mongodb.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" \
      | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    sudo apt-get update -y
    sudo apt-get install -y mongodb-org-tools
  fi
}

### === Установка зависимостей ===
install_if_missing git git
install_if_missing curl curl
install_if_missing jq jq
install_mongo_tools

### === Docker Compose ===
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

if [[ "$MODE" == "full" || "$MODE" == "create_index" ]]; then
    echo ">>> Запускаем PostgreSQL и FerretDB..."
    docker compose up -d
    sleep 15
fi

### === Миграция данных ===
if [[ "$MODE" == "full" ]]; then
    echo ">>> Экспортируем данные из MongoDB..."
    rm -rf dump && mkdir dump

    collections=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
        --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

    for coll in $collections; do
        echo "  -> Экспорт коллекции $coll"
        mongoexport --uri="$MONGO_URI_BASE/$SOURCE_DB" --collection="$coll" \
            --out="dump/${coll}.json" --authenticationDatabase="admin"
    done

    echo ">>> Импортируем коллекции в FerretDB..."
    for coll_file in dump/*.json; do
        coll=$(basename "$coll_file" .json)
        echo "  -> Импорт коллекции $coll"
        mongoimport --uri="$TARGET_URI" --collection="$coll" --drop --file="$coll_file"
    done
fi

### === Создание индексов (кроме _id) ===
if [[ "$MODE" == "full" || "$MODE" == "create_index" ]]; then
    echo ">>> Создание индексов для каждой коллекции (кроме _id)..."

    collections=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
        --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

    for coll in $collections; do
        INDEX_SCRIPT="$DEBUG_INDEX_DIR/create_indexes_${coll}.js"

        mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
          --eval "
            db.getSiblingDB('$SOURCE_DB')['$coll'].getIndexes().forEach(idx => {
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
        echo ">>> Индексы для $coll созданы"
    done
fi

### === Проверка целостности данных ===
if [[ "$MODE" == "full" || "$MODE" == "check_checksum" ]]; then
    echo ">>> Проверка целостности данных (лимит: $LIMIT)..."

    SRC_COUNTS=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
      --eval "
print('[');
var collections = db.getCollectionNames();
for (var i = 0; i < collections.length; i++) {
  var c = collections[i];
  var count = db[c].countDocuments();
  print(JSON.stringify({c: c, count: Math.min(count, $LIMIT)}) + (i < collections.length - 1 ? ',' : ''));
}
print(']');
" | jq -r '.[] | "\(.c),\(.count)"')

    DST_COUNTS=$(mongosh --quiet "$TARGET_URI" \
      --eval "
print('[');
var collections = db.getCollectionNames();
for (var i = 0; i < collections.length; i++) {
  var c = collections[i];
  var count = db[c].countDocuments();
  print(JSON.stringify({c: c, count: Math.min(count, $LIMIT)}) + (i < collections.length - 1 ? ',' : ''));
}
print(']');
" | jq -r '.[] | "\(.c),\(.count)"')

    echo ">>> Генерация текстового и HTML отчета..."
    echo "Проверка первых $LIMIT документов каждой коллекции" > "$TXT_REPORT"

    {
      echo "<html><head><meta charset='UTF-8'><title>Отчёт миграции MongoDB → PostgreSQL</title></head><body>"
      echo "<h1>Сравнение количества документов (лимит $LIMIT)</h1>"
      echo "<table border=1><tr><th>Коллекция</th><th>Источник (MongoDB)</th><th>Приёмник (PostgreSQL/FerretDB)</th></tr>"

      while IFS=, read -r col cnt; do
          src_cnt=$cnt
          dst_cnt=$(echo "$DST_COUNTS" | grep "^$col," | cut -d',' -f2)
          [[ -z "$dst_cnt" ]] && dst_cnt=0
          color="green"
          [[ "$src_cnt" != "$dst_cnt" ]] && color="red"

          echo "$col: источник=$src_cnt, приёмник=$dst_cnt" >> "$TXT_REPORT"
          echo "<tr><td>$col</td><td>$src_cnt</td><td><font color='$color'>$dst_cnt</font></td></tr>"
      done <<< "$SRC_COUNTS"

      echo "</table></body></html>"
    } > "$REPORT_FILE"

    echo ">>> Проверка завершена. Отчёт сохранён в $REPORT_FILE и $TXT_REPORT"
fi
