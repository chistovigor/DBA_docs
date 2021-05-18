#!/bin/bash

. $HOME/.bash_profile

#set constants (the same for all servers)

export TERM=xterm
logs_dir=$ORACLE_DIAG
zabbix_server='10.243.12.20'
db_user='RDBMS_MONITORING'
db_pwd='!4QrAfZv'
send2zabbix="zabbix_sender -z $zabbix_server -s `uname -n` -k"
curr_month=`date '+%Y%m'`
current_year=`date '+%Y'`
sqlplus_header='set heading off feedback off termout off trimspool on serveroutput off'
atm_user='router/loopexamspit'

#script body

clear

#Zabbix metrics collection

if [ -n "$1" ]
# Test whether command-line argument is present (non-empty).
then
 echo `basename $0`: $1 argument given
 echo "`date '+%H:%M:%S %d.%m.%Y %a'`"
 case "$1" in
 "wait" )
  echo check Oracle DB wait statistics for "log file sync" event

# analyze Oracle DB wait statistics section

#check database status, exit if it is standby or instance unreachable

echo "exit" | sqlplus -L $db_user/$db_pwd | grep Connected > /dev/null
if [ $? -eq 0 ]
then
 echo "Database connection OK"
 echo
else
 echo "Unable to reach database"
 $send2zabbix total_wait_time -o 0 > /dev/null
 $send2zabbix waits -o 0 > /dev/null
 $send2zabbix avg_time_waited -o 0 > /dev/null
 exit
fi

sqlplus -S $db_user/$db_pwd  <<!
$sqlplus_header

set pagesize 1000
set linesize 200

column minute format A10
column event  format A15
column WAITS  format 999,999,999

spool $logs_dir/logfile_wait.log
select to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') "DATE" from dual;
  SELECT COUNT (COUNT (session_id)) waits,
         ROUND (SUM ( (SUM (time_waited) / 1000000)),4) total_wait_time,
         ROUND (((SUM ( (SUM (time_waited) / 1000000))) / COUNT (COUNT (session_id))),3) avg_time_waited
from v\$active_session_history
where event = 'log file sync' AND sample_time >= (SYSDATE - 1 / 1440)
GROUP BY session_id
/
spool off
!

wait_event=`tail -n-1 $logs_dir/logfile_wait.log`

waits=`echo $wait_event | cut -f1 -d' '`
total_wait_time=`echo $wait_event | cut -f2 -d' '`
avg_time_waited=`echo $wait_event | cut -f3 -d' '`

echo
echo -e wait_event = \\n $wait_event
echo
echo -e total_wait_time = \\n $total_wait_time
echo
echo -e waits = \\n $waits
echo
echo -e avg_time_waited = \\n $avg_time_waited

$send2zabbix total_wait_time -o "${total_wait_time}" > /dev/null
$send2zabbix waits -o "${waits}" > /dev/null
$send2zabbix avg_time_waited -o "${avg_time_waited}" > /dev/null

exit

# analyze Oracle DB wait statistics section end

  ;;
 "act_log" )
  echo check number of Oracle DB active log files

# check number of Oracle DB active log files section

#check database status, exit if it is standby or instance unreachable

echo "exit" | sqlplus -L $db_user/$db_pwd | grep Connected > /dev/null
if [ $? -eq 0 ]
then
 echo "Database connection OK"
 echo
else
 echo "Unable to reach database"
 $send2zabbix oracle_active_logs -o 0 > /dev/null
 exit
fi

oracle_active_logs=`sqlplus -S $db_user/$db_pwd<<!
$sqlplus_header
select count(1) from V\\$LOG where status = 'ACTIVE'
/
!`
#oracle_active_logs=`echo 'select count(1) from V$LOG where status = \'ACTIVE\';' | sqlplus -S $db_user/$db_pwd | tail -n-2`
echo "number of active online logs is" $oracle_active_logs
$send2zabbix oracle_active_logs -o $oracle_active_logs > /dev/null

exit

# check number of Oracle DB active log files section end

  ;;
 "max_log" )
  echo check the highest number of log archived

# check the highest number of log archived

max_archlog=`sqlplus -S / as sysdba<<!
$sqlplus_header
select SEQUENCE# from V\\$LOG_HISTORY where SEQUENCE# = (SELECT MAX(SEQUENCE#) FROM V\\$LOG_HISTORY)
/
!`

echo `uname -n` max_achlog ${max_archlog}

$send2zabbix max_archlog -o $max_archlog > /dev/null

exit

# check the highest number of log archived end

  ;;
 "ora_proc" )
  echo "count number of processes of oracle user (instance parameter prosesses) at OS level"

# count number of processes of oracle user (iinstance parameter prosesses) at OS level

$send2zabbix oracle_processes -o `ps alx | grep $ORACLE_SID | wc -l` > /dev/null

#zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k oracle_processes -o `ps alx | grep $ORACLE_SID | wc -l`

exit

# count number of processes of oracle user (iinstance parameter prosesses) at OS level

  ;;
 "transact" )
 echo "count number of uncompleted transactions in router.AB$curr_month table"

# count number of uncompleted transactions

#check database status, exit if it is standby or instance unreachable

echo "exit" | sqlplus -L $db_user/$db_pwd | grep Connected > /dev/null
if [ $? -eq 0 ]
then
 echo "Database connection OK"
 echo
else
 echo "Unable to reach database"
 $send2zabbix bad_trans_num -o 0 > /dev/null
 exit
fi

bad_trans_num=`sqlplus -S $atm_user <<EOF
$sqlplus_header
select count(1) from router.ab$curr_month
where SZDEVIN >= to_char(sysdate-1/1440,'YYYY-MM-DD HH24:MI:SS')
and lresult='-01'
/
EOF`
$send2zabbix bad_trans_num -o $bad_trans_num > /dev/null

# count number of uncompleted transactions end

exit
 ;;
 "bna" )
 echo "check the number of ATMs with BNA counters OFF (problems with Monincasso)"

# check the number of ATMs with BNA counters OFF (problems with Monincasso)

#check database status, exit if it is standby or instance unreachable

echo "exit" | sqlplus -L $db_user/$db_pwd | grep Connected > /dev/null
if [ $? -eq 0 ]
then
 echo "Database connection OK"
else
 echo "Unable to reach database"
 $send2zabbix bna_off_atm_num -o 0 > /dev/null
 exit
fi

bna_off_atm_num=`sqlplus -S $atm_user <<EOF
$sqlplus_header
SELECT count(1)
  FROM objdata AA, objlist b
 WHERE AA.lsection = 29 AND B.ROBJ = AA.ROBJ AND substr(AA.BDATA,10,1) <> '8' order by AA.BDATA
/
EOF`
echo ATMs with BNA off = $bna_off_atm_num
$send2zabbix bna_off_atm_num -o $bna_off_atm_num > /dev/null

# check the number of ATMs with BNA counters OFF (problems with Monincasso) end

exit
 ;;
 "atm2site" )
 echo check status of sending the data about active atms to remote site DB

# check status of sending the data about active atms to remote site DB

#check database status, exit if it is standby or instance unreachable

echo "exit" | sqlplus -L $db_user/$db_pwd | grep Connected > /dev/null
if [ $? -eq 0 ]
then
 echo "Database connection OK"
 echo
else
 echo "Unable to reach database"
 $send2zabbix atm2site_status -o 1 > /dev/null
 exit
fi

insert_status=`sqlplus -S $atm_user <<EOF
$sqlplus_header
SELECT insert_status
  FROM ATM_CTRL_TO_SITE_INSERT_LOG
 WHERE insert_date = (SELECT MAX (insert_date)
                        FROM ATM_CTRL_TO_SITE_INSERT_LOG
                       WHERE insert_date > SYSDATE - 1 / 24)
/
EOF`

echo insert_status = $insert_status

if [ $insert_status == SUCCESS ];
 then $send2zabbix atm2site_status -o 1 > /dev/null
  else $send2zabbix atm2site_status -o 0 > /dev/null
fi

# check status of sending the data about active atms to remote site DB end

exit
 ;;
 "ctrl_data" )
 echo check router schema size using datapump utility

# check router schema size using datapump utility

echo "exit" | sqlplus -L $db_user/$db_pwd | grep Connected > /dev/null
if [ $? -eq 0 ]
then
 echo "Database connection OK"
 echo
else
 echo "Unable to reach database"
 exit
fi

current_ctrl_data=`expdp $atm_user NOLOGFILE=Y ESTIMATE_ONLY=y EXCLUDE=TABLE:\"LIKE \'\%${current_year}\%\'\" 2>&1 | grep Total | grep '[MB]' | cut -f6 -d' '`

annual_ctrl_data=`expdp $atm_user NOLOGFILE=Y ESTIMATE_ONLY=y INCLUDE=TABLE:\"LIKE \'\%${curr_month}\'\" 2>&1 | grep Total | grep GB | cut -f6 -d' '`

previous_ctrl_data=`expdp $atm_user NOLOGFILE=Y ESTIMATE_ONLY=y EXCLUDE=TABLE:\"LIKE \'\%${curr_month}\'\" 2>&1 | grep Total | grep '[GB]' | cut -f6 -d' '`

$send2zabbix current_ctrl_data -o $current_ctrl_data > /dev/null
$send2zabbix annual_ctrl_data -o $annual_ctrl_data > /dev/null
$send2zabbix previous_ctrl_data -o $previous_ctrl_data > /dev/null

exit
 ;;
 * )
  echo wrong first argument given: $1
  echo "Usage: `basename $0` mandatory_argument"
  echo
  echo possible arguments:
  echo
  echo wait      - check Oracle DB wait statistics for "log file sync" event
  echo act_log   - check number of Oracle DB active log files 
  echo max_log   - check the highest number of log archived
  echo ora_proc  - "count number of processes of oracle user (instance parameter prosesses) at OS level" 
  echo transact  - count number of uncompleted transactions in router.AB$curr_month table
  echo bna       - "check the number of ATMs with BNA counters OFF (problems with Monincasso)"
  echo atm2site  - check status of sending the data about active atms to remote site DB
  echo ctrl_data - check router schema size using datapump utility 
  echo
  ;;
 esac
else
 echo "Usage: `basename $0` mandatory_argument"
 echo
 echo possible arguments:
 echo
 echo wait      - check Oracle DB wait statistics for "log file sync" event
 echo act_log   - check number of Oracle DB active log files
 echo max_log   - check the highest number of log archived
 echo ora_proc  - "count number of processes of oracle user (instance parameter prosesses) at OS level"
 echo transact  - count number of uncompleted transactions in router.AB$curr_month table
 echo bna       - "check the number of ATMs with BNA counters OFF (problems with Monincasso)"
 echo atm2site  - check status of sending the data about active atms to remote site DB
 echo ctrl_data - check router schema size using datapump utility
 echo
 exit    # Exit, if not specified on command-line.
fi

exit
