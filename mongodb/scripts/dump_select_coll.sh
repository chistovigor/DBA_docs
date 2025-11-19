#!/bin/bash

PASSWORD="password"
DB_NAME="db_name"
COLL_PREFIX="collections_name"
START_DATE="2025-05-01"
END_DATE="2025-07-03"
OUTPUT_DIR="/opt/ssd2/backup/${DB_NAME}-selected"
HOST="127.0.0.1"
PORT="27017"
AUTH_DB="admin"
USERNAME="root"
LOG_FILE="/var/log/dump_${DB_NAME}_${COLL_PREFIX}_$(date +%F_%H-%M-%S).log"

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
  echo "No collections found." | tee -a "$LOG_FILE"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

START=$(date +%s) 
echo "Starting dump from database: $DB_NAME" | tee -a "$LOG_FILE"

for coll in $COLLECTIONS; do
  echo "Dumping $coll" | tee -a "$LOG_FILE"

  mongodump \
    --host "$HOST" --port "$PORT" \
    --username "$USERNAME" --password "$PASSWORD" \
    --authenticationDatabase "$AUTH_DB" \
    --db "$DB_NAME" --collection "$coll" \
    --out "$OUTPUT_DIR" \
    >>"$LOG_FILE" 2>&1

  if [[ $? -ne 0 ]]; then
    echo "Error dumping $coll" | tee -a "$LOG_FILE"
  else
    echo "Done: $coll" | tee -a "$LOG_FILE"
  fi
done

END=$(date +%s)
DURATION=$((END - START))

echo "Dump completed in $((DURATION / 60)) min $((DURATION % 60)) sec" | tee -a "$LOG_FILE"
