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

TARGET_URI="mongodb://${TARGET_USERNAME}:${TARGET_PASSWORD}@localhost:27017/${TARGET_DB}"

DEBUG_INDEX_DIR="./debug_indexes"
DEBUG_CHECKSUM_DIR="./debug_scripts"
mkdir -p "$DEBUG_INDEX_DIR" "$DEBUG_CHECKSUM_DIR"

REPORT_HTML="checksum_report.html"
REPORT_TXT="checksum_report.txt"

function usage() {
  echo "Использование: $0 [режим]"
  echo "Режимы:"
  echo "  create_index   - только создание индексов"
  echo "  check_checksum - только проверка контрольных сумм"
  echo "  help           - вывод этой справки"
  echo "  без аргумента  - полный цикл: миграция данных + создание индексов + проверка"
  exit 0
}

[[ "${1:-}" == "help" ]] && usage

MODE="${1:-full}"

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

# Docker
if ! command -v docker &> /dev/null; then
  echo ">>> Устанавливаем Docker..."
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "$USER"
fi

# Docker Compose
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

# MongoDB tools
install_mongo_tools() {
  if ! command -v mongodump &> /dev/null; then
    echo ">>> Устанавливаем MongoDB tools..."
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb.gpg
    echo "deb [ signed-by=/usr/share/keyrings/mongodb.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" \
      | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    sudo apt-get update -y
    sudo apt-get install -y mongodb-org-tools
  fi
}
install_mongo_tools

### === Docker Compose файл ===
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

### === Миграция данных и создание индексов ===
MONGO_URI_BASE="${MONGO_SOURCE_URI%/*}"

if [[ "$MODE" == "full" || "$MODE" == "create_index" ]]; then
  if [[ "$MODE" == "full" ]]; then
    echo ">>> Запускаем PostgreSQL и FerretDB..."
    $DOCKER_COMPOSE up -d
    sleep 15

    echo ">>> Экспортируем коллекции из MongoDB..."
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

    echo ">>> Импортируем коллекции в FerretDB..."
    for coll_file in dump/*.json; do
      coll=$(basename "$coll_file" .json)
      echo "  -> Импорт коллекции $coll"
      mongoimport --uri="$TARGET_URI" --collection="$coll" --drop --file="$coll_file"
    done
  else
    collections=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
      --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')
  fi

  ### === Создание индексов ===
  echo ">>> Создание индексов для каждой коллекции (кроме _id)..."
  for coll in $collections; do
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
            print('db.getSiblingDB(\"$TARGET_DB\")[\"' + '$coll' + '\"]' + '.createIndex(' + keyJson + ',' + JSON.stringify(opts) + ');');
          }
        });
      " > "$INDEX_SCRIPT"

    echo "  -> Применяем индексы для $coll"
    mongosh "$TARGET_URI" --file "$INDEX_SCRIPT"
  done
fi

### === Проверка контрольных сумм ===
if [[ "$MODE" == "full" || "$MODE" == "check_checksum" ]]; then
  LIMIT=${LIMIT:-100000}
  echo ">>> Проверяем целостность данных между БД (лимит $LIMIT)..."

  echo "Коллекция | Источник (кол-во / MD5) | Приёмник (кол-во / MD5)" > "$REPORT_TXT"
  echo "<html><head><meta charset='UTF-8'><title>Отчёт контрольных сумм</title></head><body><table border=1><tr><th>Коллекция</th><th>Источник</th><th>Приёмник</th></tr>" > "$REPORT_HTML"

  collections=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
      --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

  for coll in $collections; do
    SRC_SCRIPT="$DEBUG_CHECKSUM_DIR/get_checksum_source_${coll}.js"
    DST_SCRIPT="$DEBUG_CHECKSUM_DIR/get_checksum_target_${coll}.js"

    cat > "$SRC_SCRIPT" <<EOF
const crypto = require("crypto");
db = db.getSiblingDB("${SOURCE_DB}");
const collection = "${coll}";
const limit = ${LIMIT};
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

    cat > "$DST_SCRIPT" <<EOF
const crypto = require("crypto");
db = db.getSiblingDB("${TARGET_DB}");
const collection = "${coll}";
const limit = ${LIMIT};
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

    SRC_RESULT=$(mongosh "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" --quiet --file "$SRC_SCRIPT")
    DST_RESULT=$(mongosh "$TARGET_URI" --quiet --file "$DST_SCRIPT")

    SRC_HASH=$(echo "$SRC_RESULT" | cut -d, -f1)
    SRC_COUNT=$(echo "$SRC_RESULT" | cut -d, -f2)
    DST_HASH=$(echo "$DST_RESULT" | cut -d, -f1)
    DST_COUNT=$(echo "$DST_RESULT" | cut -d, -f2)

    COLOR="green"
    [[ "$SRC_HASH" != "$DST_HASH" || "$SRC_COUNT" != "$DST_COUNT" ]] && COLOR="red"

    # текстовый отчет
    echo "$coll | $SRC_COUNT / $SRC_HASH | $DST_COUNT / $DST_HASH" >> "$REPORT_TXT"

    # html отчет
    echo "<tr><td>$coll</td><td>$SRC_COUNT / $SRC_HASH</td><td><font color='$COLOR'>$DST_COUNT / $DST_HASH</font></td></tr>" >> "$REPORT_HTML"
  done

  echo "</table></body></html>" >> "$REPORT_HTML"
  echo ">>> Отчёты сохранены в $REPORT_TXT и $REPORT_HTML"
fi

echo ">>> Скрипт завершён. Скрипты для дебага: $DEBUG_INDEX_DIR и $DEBUG_CHECKSUM_DIR"
