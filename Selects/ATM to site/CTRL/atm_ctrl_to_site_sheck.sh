#!/bin/bash

. $HOME/.bash_profile
. $HOME/.bashrc

#set constants (the same for all servers)

CURRENT_HOSTNAME=`uname -n`

zabbix_server='10.243.12.20'

zabbix_key_name='atm2site_status'

logs_dir='/var/logs/oracle'

sqlplus_header='set heading off feedback off termout off trimspool on'

v_status='SUCCESS'

db_status=`sqlplus -S / as sysdba <<EOF
$sqlplus_header
select DATABASE_ROLE from v\\$database;
EOF`

# script body

#echo $db_status

if [[ `echo $db_status` == PRIMARY ]]; then
insert_status=`sqlplus -S router/loopexamspit <<EOF
$sqlplus_header
SELECT insert_status
  FROM ATM_CTRL_TO_SITE_INSERT_LOG
 WHERE insert_date = (SELECT MAX (insert_date)
                        FROM ATM_CTRL_TO_SITE_INSERT_LOG
                       WHERE insert_date > SYSDATE - 1 / 24)
/
EOF`
#echo $insert_status
 if [ $insert_status == SUCCESS ]; then
  zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k $zabbix_key_name -o 1
  else zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k $zabbix_key_name -o 0
 fi
else
echo db_status is $db_status - check ATM_CTRL_TO_SITE_INSERT_LOG in olny PRIMARY DB
zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k $zabbix_key_name -o 1
exit
fi

exit