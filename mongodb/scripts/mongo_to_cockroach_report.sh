#!/bin/bash
set -euo pipefail

START_TIME=$(date +%s%3N)  # время старта в ms

### === Конфигурация ===
ENV_FILE="./environment"

if [[ "${1:-}" == "help" ]]; then
  echo ">>> Скрипт миграции MongoDB → PostgreSQL (FerretDB + CockroachDB)"
  echo ""
  echo "Доступные режимы:"
  echo "  (без параметров)  - полный цикл: миграция данных + индексы + проверка"
  echo "  create_index      - только создание индексов"
  echo "  check_checksum    - только проверка данных (хеши, количество)"
  echo "  install_service   - установка CockroachDB и FerretDB + проверка записи"
  echo "  help              - эта справка"
  echo ""
  echo "Пример файла environment:"
  cat <<EOF
MONGO_SOURCE_URI="mongodb://root:some_password1@some_server1:27017/admin"
SOURCE_DB="test2"

TARGET_USERNAME="username"
TARGET_PASSWORD="some_password2"
TARGET_DB="ferret_test2"

CHECK_LIMIT=500000
EOF
  exit 0
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo ">>> Файл $ENV_FILE не найден!"
  exit 1
fi

# Загружаем переменные
set -a
source "$ENV_FILE"
set +a

# Значение по умолчанию
CHECK_LIMIT="${CHECK_LIMIT:-100000}"

# Проверяем ключевые переменные
: "${MONGO_SOURCE_URI:?Не задано MONGO_SOURCE_URI в $ENV_FILE}"
: "${SOURCE_DB:?Не задан SOURCE_DB в $ENV_FILE}"
: "${TARGET_USERNAME:?Не задан TARGET_USERNAME в $ENV_FILE}"
: "${TARGET_PASSWORD:?Не задан TARGET_PASSWORD в $ENV_FILE}"
: "${TARGET_DB:?Не задан TARGET_DB в $ENV_FILE}"

TARGET_URI="mongodb://${TARGET_USERNAME}:${TARGET_PASSWORD}@localhost:27017/${TARGET_DB}?authSource=admin"

REPORT_HTML="migration_report_postgresql.html"
REPORT_TXT="migration_report_postgresql.txt"

DEBUG_DIR="./debug_scripts"
mkdir -p "$DEBUG_DIR"

### === Установка CockroachDB + FerretDB ===
install_service() {
  echo ">>> Установка CockroachDB..."
  if ! command -v cockroach &>/dev/null; then
    curl -sSL https://binaries.cockroachdb.com/cockroach-v24.2.2.linux-amd64.tgz -o cockroach.tgz
    tar xzf cockroach.tgz
    sudo cp -i cockroach-v24.2.2.linux-amd64/cockroach /usr/local/bin/
    sudo mkdir -p /usr/local/lib/cockroach && sudo cp -i cockroach-v24.2.2.linux-amd64/lib/* /usr/local/lib/cockroach/
    rm -rf cockroach*
  fi

  echo ">>> Запуск CockroachDB..."
  pkill -f "cockroach" || true
  cockroach start-single-node --insecure --background --listen-addr=localhost:26257 --http-addr=localhost:8080

  echo ">>> Установка FerretDB..."
  if ! command -v ferretdb &>/dev/null; then
    curl -L https://github.com/FerretDB/FerretDB/releases/download/v2.5.0/ferretdb-linux-amd64.tar.gz -o ferretdb.tgz
    tar xzf ferretdb.tgz
    sudo cp ferretdb /usr/local/bin/
    rm -rf ferretdb*
  fi

  echo ">>> Запуск FerretDB..."
  pkill -f "ferretdb" || true
  FERRETDB_POSTGRESQL_URL="postgresql://root@localhost:26257/${TARGET_DB}?sslmode=disable" \
    ferretdb --listen-addr=127.0.0.1:27017 > ferretdb.log 2>&1 &

  sleep 5

  echo ">>> Проверка записи/чтения..."
  mongosh "$TARGET_URI" --eval "
    db.test_install.drop();
    db.test_install.insertOne({x: 1, y: 'hello'});
    printjson(db.test_install.findOne({x: 1}));
  "
}

### === Генерация случайных данных (install_service) ===
generate_test_data() {
  echo ">>> Генерация 10000 случайных документов..."
  mongosh "$TARGET_URI" --eval "
    db.random_data.drop();
    for (let i = 0; i < 10000; i++) {
      db.random_data.insertOne({
        intField: Math.floor(Math.random() * 100000),
        strField: 'str_' + Math.random().toString(36).substring(7),
        boolField: Math.random() > 0.5,
        dateField: new Date()
      });
    }
    print('Inserted: ' + db.random_data.countDocuments());
  "
}

### === Создание индексов ===
create_indexes() {
  echo ">>> Создание индексов для каждой коллекции (кроме _id)..."
  collections=$(mongosh --quiet "${MONGO_SOURCE_URI%/*}/$SOURCE_DB" \
    --authenticationDatabase="admin" \
    --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')

  for coll in $collections; do
    echo ">>> Обрабатываем коллекцию: $coll"
    INDEX_SCRIPT="$DEBUG_DIR/create_indexes_${coll}.js"

    mongosh --quiet "${MONGO_SOURCE_URI%/*}/$SOURCE_DB" --authenticationDatabase="admin" \
      --eval "
        const indexes = db.getSiblingDB('$SOURCE_DB')['$coll'].getIndexes();
        indexes.forEach(idx => {
          if (!('_id' in idx.key)) {
            const keyJson = JSON.stringify(idx.key);
            const opts = {...idx};
            delete opts.key;
            delete opts.ns;
            print('db.getSiblingDB(\"$TARGET_DB\").$coll.createIndex(' + keyJson + ',' + JSON.stringify(opts) + ');');
          }
        });
      " > "$INDEX_SCRIPT"

    mongosh "$TARGET_URI" --file "$INDEX_SCRIPT"
    echo ">>> Индексы для $coll созданы"
  done
}

### === Проверка данных (checksum) ===
check_checksum() {
  echo ">>> Проверка целостности данных (лимит: $CHECK_LIMIT)..."

  SRC_JSON="$DEBUG_DIR/source.json"
  DST_JSON="$DEBUG_DIR/target.json"

  mongosh --quiet "$MONGO_SOURCE_URI" --eval "
    const crypto = require('crypto');
    const dbSrc = db.getSiblingDB('$SOURCE_DB');
    const collections = dbSrc.getCollectionNames();
    print('[');
    for (let i=0; i<collections.length; i++) {
      const coll = collections[i];
      let count = 0;
      const hash = crypto.createHash('md5');
      const start = Date.now();
      const cursor = dbSrc[coll].find().sort({_id:1}).limit($CHECK_LIMIT);
      while(cursor.hasNext()) {
        const doc = cursor.next();
        count++;
        hash.update(JSON.stringify(doc));
      }
      const elapsed = Date.now() - start;
      print(JSON.stringify({c: coll, count: count, hash: hash.digest('hex'), time_ms: elapsed}) + (i<collections.length-1 ? ',' : ''));
    }
    print(']');
  " > "$SRC_JSON"

  mongosh --quiet "$TARGET_URI" --eval "
    const crypto = require('crypto');
    const dbDst = db.getSiblingDB('$TARGET_DB');
    const collections = dbDst.getCollectionNames();
    print('[');
    for (let i=0; i<collections.length; i++) {
      const coll = collections[i];
      let count = 0;
      const hash = crypto.createHash('md5');
      const start = Date.now();
      const cursor = dbDst[coll].find().sort({_id:1}).limit($CHECK_LIMIT);
      while(cursor.hasNext()) {
        const doc = cursor.next();
        count++;
        hash.update(JSON.stringify(doc));
      }
      const elapsed = Date.now() - start;
      print(JSON.stringify({c: coll, count: count, hash: hash.digest('hex'), time_ms: elapsed}) + (i<collections.length-1 ? ',' : ''));
    }
    print(']');
  " > "$DST_JSON"

  SRC=$(cat "$SRC_JSON" | jq -r '.[] | "\(.c),\(.count),\(.hash),\(.time_ms)"')
  DST=$(cat "$DST_JSON" | jq -r '.[] | "\(.c),\(.count),\(.hash),\(.time_ms)"')

  echo ">>> Генерация текстового и HTML отчета..."
  {
    echo "=== Отчет сравнения MongoDB → FerretDB ==="
    echo "Лимит документов: $CHECK_LIMIT"
    echo ""
    echo "Коллекция | Источник (count, hash, ms) | Приемник (count, hash, ms)"
    while IFS=, read -r col cnt hash t; do
      dst_line=$(echo "$DST" | grep "^$col,")
      if [[ -n "$dst_line" ]]; then
        IFS=, read -r col2 cnt2 hash2 t2 <<< "$dst_line"
        echo "$col | $cnt, $hash, ${t}ms | $cnt2, $hash2, ${t2}ms"
      fi
    done <<< "$SRC"
    echo ""
    echo "Общее время выполнения скрипта: ${TOTAL_TIME}ms"
  } > "$REPORT_TXT"

  {
    echo "<html><head><meta charset='UTF-8'><title>Отчет MongoDB → FerretDB</title></head><body>"
    echo "<h1>Сравнение данных</h1>"
    echo "<p>Лимит документов: $CHECK_LIMIT</p>"
    echo "<table border=1><tr><th>Коллекция</th><th>Источник</th><th>Приемник</th></tr>"
    while IFS=, read -r col cnt hash t; do
      dst_line=$(echo "$DST" | grep "^$col,")
      if [[ -n "$dst_line" ]]; then
        IFS=, read -r col2 cnt2 hash2 t2 <<< "$dst_line"
        color="green"
        [[ "$cnt" != "$cnt2" || "$hash" != "$hash2" ]] && color="red"
        echo "<tr><td>$col</td><td>$cnt, $hash, ${t}ms</td><td><font color='$color'>$cnt2, $hash2, ${t2}ms</font></td></tr>"
      fi
    done <<< "$SRC"
    echo "</table>"
    echo "<p><b>Общее время выполнения скрипта: ${TOTAL_TIME}ms</b></p>"
    echo "</body></html>"
  } > "$REPORT_HTML"

  echo ">>> Отчет сохранен в $REPORT_HTML и $REPORT_TXT"
}

### === Полный режим миграции ===
full_migration() {
  echo ">>> Экспорт коллекций из MongoDB..."
  rm -rf dump && mkdir dump
  MONGO_URI_BASE=$(echo "$MONGO_SOURCE_URI" | sed -E 's|/[^/]+$||')
  collections=$(mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin" \
    --eval "db.getCollectionNames().join(' ')" | tr -d '[],\"')
  for coll in $collections; do
    mongoexport --uri="$MONGO_URI_BASE/$SOURCE_DB" --collection="$coll" \
      --out="dump/${coll}.json" --authenticationDatabase="admin"
  done

  echo ">>> Импорт в FerretDB..."
  for coll_file in dump/*.json; do
    coll=$(basename "$coll_file" .json)
    mongoimport --uri="$TARGET_URI" --collection="$coll" --drop --file="$coll_file"
  done

  create_indexes
  check_checksum
}

### === Основная логика ===
MODE="${1:-full}"

case "$MODE" in
  install_service)
    install_service
    generate_test_data
    ;;
  create_index)
    create_indexes
    ;;
  check_checksum)
    check_checksum
    ;;
  full)
    full_migration
    ;;
  *)
    echo "Неизвестный режим: $MODE"
    exit 1
    ;;
esac

END_TIME=$(date +%s%3N)
TOTAL_TIME=$((END_TIME - START_TIME))
echo ">>> Общее время выполнения: ${TOTAL_TIME}ms"
