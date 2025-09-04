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

if [[ -z "${MONGO_SOURCE_URI:-}" || -z "${SOURCE_DB:-}" || -z "${TARGET_DB:-}" ]]; then
  echo ">>> Не заданы MONGO_SOURCE_URI, SOURCE_DB, TARGET_DB в файле $ENV_FILE"
  exit 1
fi

REPORT_FILE="migration_report_postgresql.html"

### === Установка зависимостей ===
echo ">>> Проверяем наличие необходимых утилит..."

install_if_missing() {
  local cmd=$1
  local pkg=$2
  if ! command -v "$cmd" &> /dev/null; then
    echo ">>> Устанавливаем $pkg..."
    sudo apt-get update -y
    sudo apt-get install -y "$pkg"
  else
    echo ">>> $pkg уже установлен"
  fi
}

# Базовые утилиты
install_if_missing git git
install_if_missing curl curl
install_if_missing jq jq

# Docker
if ! command -v docker &> /dev/null; then
  echo ">>> Устанавливаем Docker..."
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "$USER"
fi

# Docker Compose (v1/v2)
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
    echo ">>> Подключаем репозиторий MongoDB (jammy для noble)..."
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

### === Docker Compose файл ===
cat > docker-compose.yml <<EOF
services:
  postgres:
    image: ghcr.io/ferretdb/postgres-documentdb:17-0.106.0-ferretdb-2.5.0
    restart: on-failure
    environment:
      - POSTGRES_USER=username
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=${TARGET_DB}
    volumes:
      - ./data:/var/lib/postgresql/data

  ferretdb:
    image: ghcr.io/ferretdb/ferretdb:2.5.0
    restart: on-failure
    ports:
      - 27017:27017
    environment:
      - FERRETDB_POSTGRESQL_URL=postgres://username:password@postgres:5432/${TARGET_DB}

networks:
  default:
    name: ferretdb
EOF

### === Запуск контейнеров ===
echo ">>> Запускаем PostgreSQL и FerretDB..."
$DOCKER_COMPOSE up -d
sleep 15

### === Миграция данных ===
echo ">>> Делаем dump из MongoDB..."
rm -rf dump
# убираем имя БД из URI (например /admin), чтобы не конфликтовало с --db
MONGO_URI_BASE="${MONGO_SOURCE_URI%/*}"
mongodump --uri="$MONGO_URI_BASE" --db="$SOURCE_DB" --authenticationDatabase=admin --out=dump

echo ">>> Восстанавливаем dump в FerretDB..."
mongorestore --uri="mongodb://localhost:27017" --nsInclude="${SOURCE_DB}.*" dump/"$SOURCE_DB" --drop

### === Сравнение данных ===
echo ">>> Сравниваем количество документов..."
SRC_COUNTS=$(mongo "$MONGO_SOURCE_URI/$SOURCE_DB" --quiet --eval 'db.getCollectionNames().map(c => ({c:c, count:db[c].countDocuments()}))' | jq -r '.[] | "\(.c),\(.count)"')
DST_COUNTS=$(mongo "mongodb://localhost:27017/$SOURCE_DB" --quiet --eval 'db.getCollectionNames().map(c => ({c:c, count:db[c].countDocuments()}))' | jq -r '.[] | "\(.c),\(.count)"')

### === Генерация HTML отчёта ===
echo ">>> Генерируем HTML отчёт..."
{
  echo "<html><head><meta charset='UTF-8'><title>Отчёт миграции MongoDB → PostgreSQL</title></head><body>"
  echo "<h1>Сравнение количества документов</h1>"
  echo "<table border=1><tr><th>Коллекция</th><th>Источник (MongoDB)</th><th>Приёмник (PostgreSQL/FerretDB)</th></tr>"

  while IFS=, read -r col cnt; do
    src_cnt=$cnt
    dst_cnt=$(echo "$DST_COUNTS" | grep "^$col," | cut -d',' -f2)
    [[ -z "$dst_cnt" ]] && dst_cnt=0
    color="green"
    [[ "$src_cnt" != "$dst_cnt" ]] && color="red"
    echo "<tr><td>$col</td><td>$src_cnt</td><td><font color='$color'>$dst_cnt</font></td></tr>"
  done <<< "$SRC_COUNTS"

  echo "</table></body></html>"
} > "$REPORT_FILE"

echo ">>> Готово! Отчёт сохранён в $REPORT_FILE"