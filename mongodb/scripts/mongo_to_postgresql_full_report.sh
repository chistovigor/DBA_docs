#!/bin/bash
set -e

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
  echo ">>> Выйдите и войдите снова в систему, чтобы docker заработал без sudo!"
fi

# Docker Compose
if ! command -v docker-compose &> /dev/null; then
  echo ">>> Устанавливаем docker-compose..."
  sudo apt-get update -y
  sudo apt-get install -y docker-compose-plugin
fi

# MongoDB tools
install_if_missing mongo "mongodb-clients"
install_if_missing mongodump "mongodb-database-tools"
install_if_missing mongorestore "mongodb-database-tools"

# PostgreSQL client
install_if_missing psql "postgresql-client"

# === Конфигурация ===
MONGO_SOURCE_URI="mongodb://user:pass@mongo-source:27017/source_db"
SOURCE_DB="source_db"
TARGET_DB="target_db"
DUMP_DIR="./mongo_dump"
REPORT_FILE="./migration_report.html"

POSTGRES_IMAGE="postgres:15"
FERRET_IMAGE="ghcr.io/ferretdb/ferretdb:latest"
POSTGRES_PORT=5432
FERRET_PORT=27017
POSTGRES_USER="postgres"
POSTGRES_PASSWORD="postgres"

# === 1. Запуск контейнеров PostgreSQL и FerretDB ===
cat > docker-compose.yml <<EOF
version: '3.8'

services:
  postgres:
    image: $POSTGRES_IMAGE
    environment:
      POSTGRES_USER: $POSTGRES_USER
      POSTGRES_PASSWORD: $POSTGRES_PASSWORD
      POSTGRES_DB: $TARGET_DB
    ports:
      - "$POSTGRES_PORT:5432"

  ferretdb:
    image: $FERRET_IMAGE
    environment:
      FERRETDB_POSTGRESQL_URL: postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@postgres:$POSTGRES_PORT/$TARGET_DB?sslmode=disable
    ports:
      - "$FERRET_PORT:27017"
    depends_on:
      - postgres
EOF

echo ">>> Запускаем PostgreSQL и FerretDB..."
docker-compose up -d
sleep 15

# === 2. Экспорт данных из MongoDB ===
echo ">>> Экспортируем данные из исходной MongoDB..."
rm -rf "$DUMP_DIR"
mongodump --uri="$MONGO_SOURCE_URI" --out="$DUMP_DIR"

# === 3. Импорт данных в FerretDB (PostgreSQL backend) ===
echo ">>> Импортируем данные в FerretDB..."
mongorestore --uri="mongodb://localhost:$FERRET_PORT/$TARGET_DB" "$DUMP_DIR/$SOURCE_DB"

# === 4. Сбор статистики по коллекциям ===
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

# === 5. Генерация HTML-отчета ===
cat > $REPORT_FILE <<EOF
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<title>Отчёт о миграции MongoDB → PostgreSQL через FerretDB</title>
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
<h1>Отчёт о миграции данных (MongoDB → PostgreSQL через FerretDB)</h1>
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
echo "Откройте его в браузере для просмотра результатов."
