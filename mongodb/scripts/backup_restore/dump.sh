set -e
[ -f .env ] && source .env

SRC_HOST="${SRC_HOST:-localhost:27017}"
DST_HOST="${DST_HOST:-localhost:27017}"
MONGO_USER="${MONGO_USER:-root}"
MONGO_PASS="${MONGO_PASS:-pass}"
AUTH_DB="${AUTH_DB:-admin}"
DUMP_DIR="${DUMP_DIR:-./mongo_dumps}"
THREADS="${THREADS:-4}"
DB="${1:-$DB}" 

mongodump \
  --host="$SRC_HOST" \
  --username="$MONGO_USER" \
  --password="$MONGO_PASS" \
  --authenticationDatabase="$AUTH_DB" \
  --authenticationMechanism="SCRAM-SHA-1" \
  --compressors="zstd" \
  --gzip \
  --db="$DB" \
  --readPreference="secondary" \
  --numParallelCollections=$THREADS \
  --excludeCollectionsWithPrefix="SlotResults-2023" \
  --excludeCollectionsWithPrefix="SlotResults-2024" \
  --excludeCollectionsWithPrefix="SlotResults-2025-01" \
  --excludeCollectionsWithPrefix="SlotResults-2025-02" \
  --excludeCollectionsWithPrefix="SlotResults-2025-03" \
  --excludeCollectionsWithPrefix="SlotResults-2025-04" \
  --excludeCollectionsWithPrefix="replays_daily_2023" \
  --excludeCollectionsWithPrefix="replays_daily_2024" \
  --excludeCollectionsWithPrefix="replays_daily_2025-01" \
  --excludeCollectionsWithPrefix="replays_daily_2025-02" \
  --excludeCollectionsWithPrefix="replays_daily_2025-03" \
  --excludeCollectionsWithPrefix="replays_daily_2025-04" \
  --excludeCollectionsWithPrefix="TransactionsV2-2023" \
  --excludeCollectionsWithPrefix="TransactionsV2-2024" \
  --excludeCollectionsWithPrefix="TransactionsV2-2025-01" \
  --excludeCollectionsWithPrefix="TransactionsV2-2025-02" \
  --excludeCollectionsWithPrefix="TransactionsV2-2025-03" \
  --excludeCollectionsWithPrefix="TransactionsV2-2025-04" \
  --excludeCollectionsWithPrefix="SlotResults_demo-" \
  --excludeCollectionsWithPrefix="transactionsMapTable_monthly_" \
  --excludeCollection="SlotResults" \
  --excludeCollection="TransactionsV2" \
  --excludeCollection="ReplaysMapTable" \
  --excludeCollection="ReplaysMapTableV2" \
  --out="$DUMP_DIR"