#!/bin/bash

#скрипт для копирования от имени rsync (запускать в crontab для пользователя root)

echo "-----------------------------------------"
echo "***** Begin" `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "-----------------------------------------"

remote_server=s-msk08-ultra-la
rsync_target="/mnt/data1/backup/"
rsync_destination="/mnt/data2/remote_backup/"
db_status=`cat ${rsync_destination}db_status`

echo "current DB status is" ${db_status}

if [ ${db_status} == PRIMARY ]
 then echo "rsync -varlp --progress --bwlimit=20000 --delete --exclude "db_status" ${rsync_target} rsync@${remote_server}:${rsync_destination}" | su - rsync
 else echo "not copy"
fi

echo "----------------------------------------"
echo "***** End  " `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "----------------------------------------"