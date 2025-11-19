#!/bin/sh

# crontab entry:
#*/30 * * * * /home/mbackup/bin/mongo_backup.sh >/tmp/mongo_backup/mongo_backup.log 2>&1

MONGO_PORT=27017
BACKUP_PREFIX_DIR=/home/mbackup/mongo

export LANG=en_GB.UTF-8
export XZ_OPT=-1

HOST=$(hostname -s)
AWS_BIN="$(which aws) --quiet"
MONGODUMP="$(which mongodump) -j 1"
S3_URL="s3://abiit1xbet/Backup"
DATE_NOW=$(date +%F-%H:%M)

BACKUP_DIR=$BACKUP_PREFIX_DIR/$DATE_NOW

mkdir -p $BACKUP_DIR

cd $BACKUP_DIR

for db in TotoBot Raschet ; do
        $MONGODUMP --port=$MONGO_PORT --username admin --password "kMfoQZBGy3g4KCHoKiMd7rHBf" --authenticationDatabase "admin" --db=$db --gzip --archive=$BACKUP_DIR/$db.archive.gz && \
                $AWS_BIN s3 cp --storage-class STANDARD_IA $BACKUP_DIR/$db.archive.gz $S3_URL/$HOST/MongoDB/$DATE_NOW/
done

rm -rf $BACKUP_DIR