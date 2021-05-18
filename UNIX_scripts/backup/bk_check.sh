#!/bin/bash

#Скрипт для мониторинга успешности бекапа (ещет ORA- в логе бекапа с одним исключением - ORA-19921)

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

#set variables

server_admins="iruacii2@raiffeisen.ru,irualys2@raiffeisen.ru,iruakgv8@raiffeisen.ru,iruatza7@raiffeisen.ru"
#server_admins="iruacii2@raiffeisen.ru,iruagov3@raiffeisen.ru,iruafaa1@raiffeisen.ru,iruamaah@raiffeisen.ru,iruakgd5@raiffeisen.ru"
BACKUP_PATH="/mnt/data1/backup"

#set constants (the same for all servers)

subject='oracle backup probably failed'
message='last successful backup was'
CURRENT_HOSTNAME=`uname -n`
zabbix_server='10.243.12.20'
backup_state=`cat ${BACKUP_PATH}/backup.log | grep -v ORA-19921 | grep ORA-`
table='V$RMAN_BACKUP_JOB_DETAILS'
db_status=`echo 'select DATABASE_ROLE from v$database;' | sqlplus -S / as sysdba | tail -n-2 | head -n+1`
last_backup=`echo "select to_char(max(END_TIME),'dd/mm/yy hh24:mi') from $table where INPUT_TYPE = 'DB FULL' and STATUS IN ('COMPLETED','COMPLETED WITH WARNINGS');" | sqlplus -S / as sysdba | tail -n-2 | head -n+1`

#execute script

echo "----------------------------------------"
echo "***** Hostname " `hostname` "******"
echo "***** Date " `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "----------------------------------------"

echo "current db status is" $db_status
echo "last successful backup" $last_backup
echo "0 - error"
echo "1 - ok"
echo "current state"

if [ -f ${BACKUP_PATH}/backup.log ]; then

        if [[ ${backup_state}  -eq 0 ]];then
                echo "1"
         else
                echo "0"
                mailx -s "`uname -n`: $subject" $server_admins <<!
$message $last_backup. current db status is $db_status
!
        fi
else

  echo "0"
  mailx -s "`uname -n`:  $subject" $server_admins <<!
$message $last_backup. current db status is $db_status
!
fi

echo "sending to zabbix"

if [ -f ${BACKUP_PATH}/backup.log ]; then
 if [[ ${backup_state}  -eq 0 ]];then
    zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k backup_status -o 1
   else
    zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k backup_status -o 0
   fi
else
zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k backup_status -o 0
 fi

rm -f ${BACKUP_PATH}/backup.log