#!/bin/bash
# Обновляет (заменяет) секцию setParameter в mongod.conf
#  - сохраняет права/владельца
#  - делает бэкап (без секунд) рядом со скриптом
#  - логирует рядом со скриптом
#  - перезапускает mongod и делает откат при ошибке

set -euo pipefail

START_TIME=$(date +%s)

MONGOD_CONF="${1:-/etc/mongod.conf}"           # путь к конфику, по умолчанию /etc/mongod.conf
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/update_mongod.log"
BACKUP_FILE="$SCRIPT_DIR/mongod.conf.bak_$(date +%Y%m%d_%H%M)"

echo "=== $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG_FILE"
echo "Config: $MONGOD_CONF" >> "$LOG_FILE"
echo "Backup: $BACKUP_FILE" >> "$LOG_FILE"

# Проверки
if [ ! -f "$MONGOD_CONF" ]; then
  echo "ERROR: конфиг $MONGOD_CONF не найден" | tee -a "$LOG_FILE"
  exit 1
fi

# Сохраняем права/владельца
ORIG_MODE=$(stat -c "%a" "$MONGOD_CONF")
ORIG_OWNER=$(stat -c "%u" "$MONGOD_CONF")
ORIG_GROUP=$(stat -c "%g" "$MONGOD_CONF")

# Делаем бэкап (с сохранением атрибутов)
cp -p "$MONGOD_CONF" "$BACKUP_FILE"
if [ $? -ne 0 ]; then
  echo "ERROR: не удалось создать бэкап $BACKUP_FILE" | tee -a "$LOG_FILE"
  exit 1
fi
echo "Backup created: $BACKUP_FILE" >> "$LOG_FILE"

# Функция отката
rollback() {
  echo "[$(date '+%F %T')] ROLLBACK: восстанавливаем из $BACKUP_FILE" | tee -a "$LOG_FILE"
  cp -p "$BACKUP_FILE" "$MONGOD_CONF"
  chmod "$ORIG_MODE" "$MONGOD_CONF" || true
  chown "$ORIG_OWNER":"$ORIG_GROUP" "$MONGOD_CONF" || true
  echo "[$(date '+%F %T')] ROLLBACK: рестарт mongod" | tee -a "$LOG_FILE"
  systemctl restart mongod || true
  END_TIME=$(date +%s)
  echo "[$(date '+%F %T')] ROLLBACK finished. Duration: $((END_TIME-START_TIME))s" | tee -a "$LOG_FILE"
  exit 1
}

# Обновляем секцию setParameter: — надёжно заменяем существующую секцию на нужный блок
TMP_FILE=$(mktemp)
awk '
  BEGIN { replaced=0 }
  # если строка — точная запись setParameter: (возможно с ведущими пробелами)
  /^[[:space:]]*setParameter:[[:space:]]*$/ {
    # печатаем ровно "setParameter:" (в том же месте, что и было)
    prefix = gensub(/^([[:space:]]*).*/, "\\1", "g")
    print prefix "setParameter:"
    # печатаем нужный блок с ровно 2 пробелами отступа
    print prefix "  oplogBatchDelayMillis: 20"
    print prefix "  replWriterThreadCount: 32"
    print prefix "  replBatchLimitOperations: 2000  # default 5000"
    print prefix "  replBatchLimitBytes: 33554432    # 32 MB, default 100MB"
    replaced=1
    # теперь читаем и пропускаем последующие строки с отступом (внутренние строки блока)
    while (getline > 0) {
      if ($0 ~ /^[[:space:]]+/) {
        # пропустить — это часть старого блока
        continue
      } else {
        # встретили следующую топ-уровневую строку — печатаем её и продолжаем обработку основного потока
        print $0
        next
      }
    }
    next
  }
  { print $0 }
  END {
    if (replaced == 0) {
      # если setParameter: не был найден, добавим его в конец файла
      print ""
      print "setParameter:"
      print "  oplogBatchDelayMillis: 20"
      print "  replWriterThreadCount: 32"
      print "  replBatchLimitOperations: 2000  # default 5000"
      print "  replBatchLimitBytes: 33554432    # 32 MB, default 100MB"
    }
  }
' "$MONGOD_CONF" > "$TMP_FILE"

# Проверка успешности генерации
if [ ! -s "$TMP_FILE" ]; then
  echo "ERROR: tmp file empty or not created" | tee -a "$LOG_FILE"
  rm -f "$TMP_FILE"
  rollback
fi

# Применяем новый файл, сохраняя права/владельца
mv "$TMP_FILE" "$MONGOD_CONF"
chmod "$ORIG_MODE" "$MONGOD_CONF"
chown "$ORIG_OWNER":"$ORIG_GROUP" "$MONGOD_CONF"

echo "[$(date '+%F %T')] Updated setParameter in $MONGOD_CONF" | tee -a "$LOG_FILE"

# Перезапуск MongoDB
echo "[$(date '+%F %T')] Restarting mongod..." | tee -a "$LOG_FILE"
if ! systemctl restart mongod; then
  echo "ERROR: mongod не запустился после изменения конфига" | tee -a "$LOG_FILE"
  rollback
fi

# Проверка статуса
if systemctl is-active --quiet mongod; then
  END_TIME=$(date +%s)
  echo "[$(date '+%F %T')] OK: mongod active. Total duration: $((END_TIME-START_TIME))s" | tee -a "$LOG_FILE"
  exit 0
else
  echo "ERROR: mongod не активен после рестарта" | tee -a "$LOG_FILE"
  rollback
fi