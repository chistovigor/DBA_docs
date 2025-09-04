#!/bin/bash
set -e

# === Загружаем конфиг ===
if [ ! -f environment ]; then
  echo "Ошибка: файл environment не найден!"
  exit 1
fi
source environment

if [ -z "$MONGO_SOURCE_URI" ] || [ -z "$SOURCE_DB" ] || [ -z "$TARGET_DB" ]; then
  echo "Ошибка: в environment должны быть заданы MONGO_SOURCE_URI, SOURCE_DB и TARGET_DB"
  exit 1
fi

# === Проверка и установка зависимостей ===
echo ">>> Проверяем наличие необходимых утилит..."

install_if_missing() {
  CMD=$1
  PKG=$2
  if ! command -v $CMD &> /dev/null; then
    echo ">>> Устанавливаем $PKG..."
    sudo apt-get update -y
    sudo apt-get install -y $PKG
  else
    echo ">>> $CMD уже установлен"
  fi
}

# Docker
if ! command -v docker &> /dev/null; then
  echo ">>> Устанавливаем Docker..."
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker $USER
fi

# Docker Compose
if ! command -v docker-compose &> /dev/null; then
  echo ">>> Устанавливаем docker-compose..."
  sudo apt-get update -y
  sudo apt-get install -y docker-compose-plugin
fi

# PostgreSQL client (нужен для CockroachDB тоже)
install_if_missing psql "postgresql-client"

# MongoDB tools
install_mongo_tools() {
  if ! command -v mongodump &> /dev/null; then
    echo ">>> Подключаем репозиторий MongoDB (jammy, подходит для noble)..."
    sudo rm -f /etc/apt/sources.list.d/mongodb-org-6.0.list
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb.gpg
    echo "deb [ signed-by=/usr/share/keyrings/mongodb.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" \
      | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    sudo apt-get update -y
    echo ">>> Устанавливаем MongoDB Database Tools..."
    sudo apt-get install -y mongodb-org-tools
  else
    echo ">>> MongoDB Tools уже установлены"
  fi
}
install_mongo_tools

# === Конфигурация ===
DUMP_DIR="./mongo_dump"
REPORT_FILE="./migration_report.html"

COCKROACH_IMAGE="cockroachdb/cockroach:v23.1.11"
FERRET_IMAGE="ghcr.io/ferretdb/ferretdb:latest"
CRDB_PORT=26257
FERRET_PORT=27017
CRDB_USER="root"

# === 1. Запуск контейнеров CockroachDB и FerretDB ===
cat > docker-compose.yml <<EOF
version: '3.8'

services:
  cockroach:
    image: $COCKROACH_IMAGE
    command: start-single-node --insecure
    ports:
      - "$CRDB_PORT:26257"
      - "8080:8080"

  ferretdb:
    image: $FERRET_IMAGE
    environment:
      FERRETDB_POSTGRESQL_URL: postgres://$CRDB_USER@cockroach:$CRDB_PORT/$TARGET_DB?sslmode=disable
    ports:
      - "$FERRET_PORT:27017"
    depends_on:
      - cockroach
EOF

echo ">>> Запускаем CockroachDB и FerretDB..."
docker-compose up -d
sleep 20

# === 2. Экспорт данных из MongoDB ===
echo ">>> Экспортируем данные из исходной MongoDB..."
rm -rf "$DUMP_DIR"
mongodump --uri="$MONGO_SOURCE_URI" --out="$DUMP_DIR"

# === 3. Импорт данных в FerretDB ===
echo ">>> Импортируем данные в FerretDB..."
mongorestore --uri="mongodb://localhost:$FERRET_PORT/$TARGET_DB" "$DUMP_DIR/$SOURCE_DB"

# === 4. Сравнение и отчёт ===
echo ">>> Считаем документы в коллекциях..."

COLLECTIONS=$(mongo "$MONGO_SOURCE_URI" --quiet --eval "db.getSiblingDB('$SOURCE_DB').getCollectionNames()" | tr -d '[]" ,' | tr '\n' ' ')

SRC_TOTAL=0
DST_TOTAL=0
TABLE_ROWS=""

for COL in $COLLECTIONS; do
  SRC_COUNT=$(mongo "$MONGO_SOURCE_URI" --quiet --eval "db.getSiblingDB('$SOURCE_DB').$COL.countDocuments()")
  DST_COUNT=$(mongo --quiet --host localhost --port $FERRET_PORT --eval "db.getSiblingDB('$TARGET_DB').$COL.countDocuments()")
  
  SRC_TOTAL=$((SRC_TOTAL + SRC_COUNT))
  DST_TOTAL=$((DST_TOTAL + DST_COUNT))
  
  if [ "$SRC_COUNT" -eq "$DST_COUNT" ]; then
    STATUS="Совпадает"
    CLASS="ok"
  else
    STATUS="Различие"
    CLASS="fail"
  fi
  
  TABLE_ROWS+="<tr><td>$COL</td><td>$SRC_COUNT</td><td>$DST_COUNT</td><td class=\"$CLASS\">$STATUS</td></tr>"
done

cat > $REPORT_FILE <<EOF
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<title>Отчёт о миграции MongoDB → CockroachDB через FerretDB</title>
<style>
  body { font-family: Arial, sans-serif; margin: 20px; }
  h1 { color: #333; }
  table { border-collapse: collapse; width: 80%; margin-bottom: 20px; }
  th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
  th { background-color: #f2f2f2; }
  .ok { background-color: #c8e6c9; }
  .fail { background-color: #ffcdd2; }
</style>
</head>
<body>
<h1>Отчёт о миграции данных (MongoDB → CockroachDB через FerretDB)</h1>
<p><b>Исходная база:</b> $SOURCE_DB</p>
<p><b>Целевая база:</b> $TARGET_DB</p>
<p><b>Всего документов:</b> Источник = $SRC_TOTAL, Приёмник = $DST_TOTAL</p>

<h2>Сравнение по коллекциям</h2>
<table>
<tr><th>Коллекция</th><th>Документов в источнике</th><th>Документов в приёмнике</th><th>Статус</th></tr>
$TABLE_ROWS
</table>

</body>
</html>
EOF

echo ">>> Отчёт создан: $REPORT_FILE"
