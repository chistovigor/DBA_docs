#!/bin/bash

CURRENT_HOSTNAME=s-msk00-ultra-lb
BACKUP_PATH="/mnt/data1/backup"
SCRIPT_DIR="/usr/local/bin/scripts/check_backup"
backup_state=`cat ${BACKUP_PATH}/backup.log | grep -v ORA-19921 | grep ORA-`
last_backup=`sqlplus / as sysdba < ${SCRIPT_DIR}/last_backup.sql | awk '(NR == 12)'`

echo "last successful backup" ${last_backup}
echo "0 - error"
echo "1 - ok"
echo "current state"

if [ -f ${BACKUP_PATH}/backup.log ]; then

 	if [[ ${backup_state}  -eq 0 ]];then
    		echo "1"
   	 else
    		echo "0"
                mailx -s "`uname -n` : oracle backup probably FAILED." "iruacii2@raiffeisen.ru" <<!
"last successful backup was ${last_backup}"
!
   	fi
else

  echo "0"
  mailx -s "`uname -n` : oracle backup probably FAILED." "iruacii2@raiffeisen.ru" <<!
"last successful backup was ${last_backup}"
!
fi

echo "sending to zabbix"

if [ -f ${BACKUP_PATH}/backup.log ]; then
 if [[ ${backup_state}  -eq 0 ]];then
    zabbix_sender -z 10.243.12.20 -s "${CURRENT_HOSTNAME}" -k backup_status -o 1
   else
    zabbix_sender -z 10.243.12.20 -s "${CURRENT_HOSTNAME}" -k backup_status -o 0
   fi
else
zabbix_sender -z 10.243.12.20 -s "${CURRENT_HOSTNAME}" -k backup_status -o 0
 fi

rm -f ${BACKUP_PATH}/backup.log

echo "----------------------------------------"
echo "***** Hostname " `hostname` "******"
echo "***** Date " `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "----------------------------------------"
