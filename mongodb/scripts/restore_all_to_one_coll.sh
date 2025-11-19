#!/bin/bash

DB="db name to - nsTo "                                             
COLL="collections - nsTo "
DUMP_DIR="/opt/ssd2/backup/xxxx"
MONGOS_HOST="sc-lux1-slots-prod-cluster-mongo-mongos1.prod.slt.lan"
MONGOS_PORT=27017
USERNAME="root"
PASSWORD="Password"
AUTH_DB="admin"
LOG_FILE="/var/log/restore_${DB}_${COLL}_$(date +%F_%H-%M-%S).log"

echo "Starting restore: $(date) ---" | tee -a "$LOG_FILE"
echo "From dump path: $DUMP_DIR" | tee -a "$LOG_FILE"
echo "To collection:  $DB.$COLL" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

SECONDS=0

for bson_file in "$DUMP_DIR"/*.bson; do
  coll_name=$(basename "$bson_file" .bson)
  echo " [$coll_name] Starting restore..." | tee -a "$LOG_FILE"

  mongorestore \
    --host "$MONGOS_HOST" --port "$MONGOS_PORT" \
    --username "$USERNAME" --password "$PASSWORD" \
    --authenticationDatabase "$AUTH_DB" \
    --nsFrom="${DB}.${coll_name}" \
    --nsTo="${DB}.${COLL}" \
#    --db "$DB" \
#    --collection "$COLL" \
    "$bson_file" \
    >>"$LOG_FILE" 2>&1

  if [[ $? -ne 0 ]]; then
    echo " [$coll_name] Restore Error!" | tee -a "$LOG_FILE"
  else
    echo " [$coll_name] Restore completed" | tee -a "$LOG_FILE"
  fi
    echo "" | tee -a "$LOG_FILE"
done

duration=$SECONDS
echo "Restore done: $(date)" | tee -a "$LOG_FILE"
echo "Restore time: $((duration / 60)) min $((duration % 60)) sec" | tee -a "$LOG_FILE"
