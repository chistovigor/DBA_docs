set -e

[ -f .env ] && source .env

SRC_HOST="${SRC_HOST:-localhost:27017}"
MONGO_USER="${MONGO_USER:-root}"
MONGO_PASS="${MONGO_PASS:-pass}"
AUTH_DB="${AUTH_DB:-admin}"

DONE_FILE=".done_dbs"
touch "$DONE_FILE"

# Get list of databases from source MongoDB (excluding internal ones)
databases=$(mongosh --quiet --host="$SRC_HOST" \
  --username="$MONGO_USER" \
  --password="$MONGO_PASS" \
  --authenticationDatabase="$AUTH_DB" \
  --eval 'db.adminCommand("listDatabases").databases
    .map(db => db.name)
    .filter(name => !["admin", "local", "config"].includes(name))
    .sort()
    .join("\n")')

# another example with like filter
#databases=$(mongosh --quiet --host="$SRC_HOST" \
#  --username="$SRC_USER" \
#  --password="$SRC_PASS" \
#  --authenticationDatabase="$AUTH_DB" \
#  --eval 'db.adminCommand("listDatabases").databases
#    .map(db => db.name)
#    .filter(name => !name.startsWith("mm"))
#    .filter(name => !["admin", "local", "config", "gamesdb"].includes(name))
#    .sort()
#    .join("\n")')
#

# Loop through each database and process if not already done
echo "$databases" | while read -r db; do
  if grep -Fxq "$db" "$DONE_FILE"; then
    echo ">>> Skipping already processed database: $db"
    continue
  fi

  echo "=== Dumping and restoring database: $db ==="
  if ./dump.sh "$db" && ./restore.sh "$db"; then
    echo "$db" >> "$DONE_FILE"
  else
    echo "!!! Failed processing $db"
    exit 1
  fi
done
