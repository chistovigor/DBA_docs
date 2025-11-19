Скрипт restore_all_to_one_coll.sh для рестора и переопределнеия коллекций в одну  (было n коллекций на каждый день станет - одна )

Переменные:
DB="db name to - nsTo "
COLL="collections - nsTo "
DUMP_DIR="/opt/ssd2/backup/xxxx"
MONGOS_HOST="sc-lux1-slots-prod-cluster-mongo-mongos1.prod.slt.lan"
MONGOS_PORT=27017
USERNAME="root"
PASSWORD="Password"
AUTH_DB="admin"
LOG_FILE="/var/log/restore_${DB}_${COLL}_$(date +%F_%H-%M-%S).log"

Указывается имя базы и коллекции для восстановления (DB= и COLL=)
Указывается путь к директории бэкапа (DUMP_DIR=)
Указывается параметры подключения к MongoDB через mongos (MONGOS_HOST=, MONGOS_PORT, USERNAME, PASSWORD, AUTH_DB)


Цикл рестора
for bson_file in "$DUMP_DIR"/*.bson; do
  coll_name=$(basename "$bson_file" .bson)
  echo " [$coll_name] Starting restore..." | tee -a "$LOG_FILE"

  mongorestore \
    --host "$MONGOS_HOST" --port "$MONGOS_PORT" \
    --username "$USERNAME" --password "$PASSWORD" \
    --authenticationDatabase "$AUTH_DB" \
    --db "$DB" \
    --collection "$COLL" \
    "$bson_file" \
    >>"$LOG_FILE" 2>&1

Определяется имя исходной коллекции и выполняется рестор в целевую коллекцию $COLL

  
 Проверка результата
  if [[ $? -ne 0 ]]; then
    echo " [$coll_name] Restore Error!" | tee -a "$LOG_FILE"
  else
    echo " [$coll_name] Restore completed" | tee -a "$LOG_FILE"
  fi
    echo "" | tee -a "$LOG_FILE"
done

Выпод времени рестора
duration=$SECONDS
echo "Restore done: $(date)" | tee -a "$LOG_FILE"
echo "Restore time: $((duration / 60)) min $((duration % 60)) sec" | tee -a "$LOG_FILE"
