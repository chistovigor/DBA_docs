Скрипт dump_select_coll.sh  для снятия дампа коллекций по временому промежутку в формате db.collections-2025-05-01

Переменные:
PASSWORD="password"
AUTH_DB="admin"
DB_NAME="gamesdb"
COLL_PREFIX="TransactionsV2"
START_DATE="2025-05-01"
END_DATE="2025-07-03"
OUTPUT_DIR="/opt/ssd2/backup/${DB_NAME}-selected"
HOST="127.0.0.1"
PORT="27017"
USERNAME="root"

Настраивает параметры подключения к MongoDB (HOST, PORT, USERNAME, PASSWORD, AUTH_DB)
Указывается имя базы данных (DB_NAME)
Указывается имя коллекции (COLL_PREFIX)
Указывается необходимый промежуток дат  (START_DATE, END_DATE)
Указывается дирка куда будут сохраняться дампы 

Генерация реггулярки для выборки по датам с переменных, с построчной обработкой полученого списка коллекций и проверкой на наличие коллкций
generate_regex_range() {
  local prefix="$1"
  local start="$2"
  local end="$3"

  local start_ts=$(date -d "$start" +%s)
  local end_ts=$(date -d "$end" +%s)
  local current_ts=$start_ts

  local pattern_list=()

  while [[ $current_ts -le $end_ts ]]; do
    local current_date=$(date -d "@$current_ts" +%Y-%m-%d)
    pattern_list+=("${prefix}-${current_date}")
    current_ts=$((current_ts + 86400))  
  done

  local joined=$(IFS='|'; echo "${pattern_list[*]}")
  echo "^(${joined})$"
}

IFS=$'\n'

REGEX=$(generate_regex_range "$COLL_PREFIX" "$START_DATE" "$END_DATE")

COLLECTIONS=$(mongosh --quiet \
  --host "$HOST" --port "$PORT" \
  --username "$USERNAME" --password "$PASSWORD" \
  --authenticationDatabase "$AUTH_DB" \
  --eval "db.getCollectionNames().filter(n => /$REGEX/.test(n)).join('\n')" "$DB_NAME")

if [[ -z "$COLLECTIONS" ]]; then
  echo "No collections found."
  exit 1
fi  

Создание дирки для дампа и сам дамп, с выводом статуса
mkdir -p "$OUTPUT_DIR"
for coll in $COLLECTIONS; do
  echo "Dumping $coll"

  mongodump \
    --host "$HOST" --port "$PORT" \
    --username "$USERNAME" --password "$PASSWORD" \
    --authenticationDatabase "$AUTH_DB" \
    --db "$DB_NAME" --collection "$coll" \
    --out "$OUTPUT_DIR"

  if [[ $? -ne 0 ]]; then
    echo "Error dumping $coll" >&2
  else
    echo "Done: $coll"
  fi
done

Подсчет времени выполнения дампа всех выбранных колекций
END=$(date +%s)
DURATION=$((END - START))

echo "Dump completed in $((DURATION / 60)) min $((DURATION % 60)) sec"
