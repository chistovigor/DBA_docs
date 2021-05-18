#!/bin/bash

#Проверка репликации каждый 2 часа
#00 */2 * * * /usr/local/bin/scripts/check_replication.sh >> /var/logs/check_replication.log 2>&1

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

CURRENT_HOSTNAME=`uname -n`
zabbix_server='10.243.12.20'
sqlstring='select SEQUENCE# from V$LOG_HISTORY where SEQUENCE# = (SELECT MAX(SEQUENCE#) FROM V$LOG_HISTORY);'
max_archlog=`echo $sqlstring | sqlplus -S / as sysdba | tail -n-2 | head -n+1`

echo `date`
echo `uname -n` max_achlog $max_archlog

zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k max_archlog -o "${max_archlog}"