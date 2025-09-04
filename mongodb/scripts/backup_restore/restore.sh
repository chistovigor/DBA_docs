set -e
shopt -s nullglob 
[ -f .env ] && source .env

SRC_HOST="${SRC_HOST:-localhost:27017}"
DST_HOST="${DST_HOST:-localhost:27017}"
MONGO_USER="${MONGO_USER:-root}"
MONGO_PASS="${MONGO_PASS:-pass}"
AUTH_DB="${AUTH_DB:-admin}"
DUMP_DIR="${DUMP_DIR:-./mongo_dumps}"
THREADS="${THREADS:-4}"
DB="${1:-$DB}" 

for bson_file in "$DUMP_DIR/$DB"/some_coll_1_-*.bson.gz; do
  col=$(basename "$bson_file" .bson.gz)
  mongorestore \
    --host="$DST_HOST" \
    --username="$MONGO_USER" \
    --password="$MONGO_PASS" \
    --authenticationDatabase="$AUTH_DB" \
    --authenticationMechanism="SCRAM-SHA-1" \
    --gzip \
    --compressors="zstd" \
    --dir="$DUMP_DIR" \
    --nsFrom="$DB.$col" \
    --nsInclude="$DB.$col" \
    --nsTo="$DB.dest_coll_1" \
    --numParallelCollections=1 \
    --numInsertionWorkersPerCollection=$THREADS
done

for bson_file in "$DUMP_DIR/$DB"/some_coll_2_-*.bson.gz; do
  col=$(basename "$bson_file" .bson.gz)
  mongorestore \
    --host="$DST_HOST" \
    --username="$MONGO_USER" \
    --password="$MONGO_PASS" \
    --authenticationDatabase="$AUTH_DB" \
    --authenticationMechanism="SCRAM-SHA-1" \
    --gzip \
    --compressors="zstd" \
    --dir="$DUMP_DIR" \
    --nsInclude="$DB.$col" \
    --nsFrom="$DB.$col" \
    --nsTo="$DB.dest_coll_2" \
    --numParallelCollections=1 \
    --numInsertionWorkersPerCollection=$THREADS
done

for bson_file in "$DUMP_DIR/$DB"/some_coll_3_-*.bson.gz; do
  col=$(basename "$bson_file" .bson.gz)
  mongorestore \
    --host="$DST_HOST" \
    --username="$MONGO_USER" \
    --password="$MONGO_PASS" \
    --authenticationDatabase="$AUTH_DB" \
    --authenticationMechanism="SCRAM-SHA-1" \
    --gzip \
    --compressors="zstd" \
    --dir="$DUMP_DIR" \
    --nsInclude="$DB.$col" \
    --nsFrom="$DB.$col" \
    --nsTo="$DB.dest_coll_3" \
    --numParallelCollections=1 \
    --numInsertionWorkersPerCollection=$THREADS
done

mongorestore \
  --host="$DST_HOST" \
  --username="$MONGO_USER" \
  --password="$MONGO_PASS" \
  --authenticationDatabase="$AUTH_DB" \
  --authenticationMechanism="SCRAM-SHA-1" \
  --gzip \
  --compressors="zstd" \
  --dir="$DUMP_DIR" \
  --nsInclude="$DB.*" \
  --nsExclude="$DB.some_coll_1_-*" \
  --nsExclude="$DB.some_coll_2_-*" \
  --nsExclude="$DB.some_coll_3_-*" \
  --numParallelCollections=$THREADS \
  --numInsertionWorkersPerCollection=$THREADS
