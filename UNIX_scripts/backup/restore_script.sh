#!/bin/bash

#duplicate UAT DB script, created by Igor Chistov
#documentation available here: https://jira.network.ae/confluence/display/DBA/Rman+backup-restore#Rmanbackup-restore-uat_restore
#bitbucket version: https://bitbucket.org/network-international/infrastructure/src/master/BAU_scripts/Backup_restore/restore_script.sh.sh

# crontab example (first number - minute, second number - hour, third number - day of months for start job)

#31 12 27 * * $HOME/scripts/restore_script.sh w4uat49 /irisvat_temp/W4UAT49_Rmancbkp_Jan27 10 /ora12c/app/product/12.1.0/dbhome_1 >> $HOME/logs/duplicate_JIRA_MAF-3397.log 2>&1

# Restore DROPPED database example (!!! run ONLY if destination DB was DROPPED !!!)

#31 12 27 * * $HOME/scripts/restore_script.sh w4uat49 /irisvat_temp/W4UAT49_Rmancbkp_Jan27 10 /ora12c/app/product/12.1.0/dbhome_1 Y >> $HOME/logs/duplicate_JIRA_MAF-3397.log 2>&1

# command line run example (remove hash from the beginning) with prebackup

#nohup /rbackup/scripts/restore_script.sh w4uat /irisvat_temp/Rmancbkp_Jan27 10 /ora12c/app/product/12.1.0/dbhome_1 > $HOME/logs/duplicate_`date +%d%m%y_%H_%M`.log 2>&1 &

#variables common
export script_ver="2.3"
export timestamp=`date '+%d%m%y_%H_%M_%S'`
log_folder=$HOME/logs
os_ver=`uname -o | cut -d '/' -f 2`
script_name=`basename $0`
username=`whoami`
export NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS'

#variables specific to the given script
export ORACLE_SID=$1
export backup_folder=$2
export PARALLEL=$3
export ORACLE_HOME=$4
export RESTORE_DROPPED=$5
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib;
export scripts_folder=$HOME/scripts
export common_folder=/rbackup
export db_prefix=${ORACLE_SID:0:2}
export syspwd='ni123456#'

#functions

function drop_aux_db {
export ORACLE_SID=$ORACLE_SID
sqlplus -s '/ as sysdba' <<EOF
set pagesize 999 linesize 999 heading off feedback off
prompt db name and open_mode
select name, open_mode from v\$database;
shutdown immediate;
startup mount exclusive restrict;
drop database;
exit;
EOF
}

function nomount_aux_db {
export ORACLE_SID=$ORACLE_SID
rman target / <<EOF
startup force nomount pfile='$ORACLE_HOME/dbs/init${ORACLE_SID}.ora';
exit;
EOF
}

function dup_aux_db {
export ORACLE_SID=$ORACLE_SID
rman AUXILIARY / <<EOF
spool log to ${log_folder}/duplicate_${ORACLE_SID}_${timestamp}.log
CONFIGURE DEVICE TYPE DISK PARALLELISM $PARALLEL BACKUP TYPE TO BACKUPSET;
duplicate database to $ORACLE_SID backup location '${backup_folder}' NOFILENAMECHECK;
spool log off
exit;
EOF
}

function restart_aux_db_pfile {
export ORACLE_SID=$ORACLE_SID
sqlplus -s '/ as sysdba' <<EOF
!rm $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora
shutdown immediate;
startup;
exit;
EOF
}

function find_ora_home {
export ORACLE_SID=$ORACLE_SID
export PROC_INFO=`ps -ef | grep pmon | grep $ORACLE_SID | awk '{print $2}'`

if [ `ps -ef | grep pmon | grep $ORACLE_SID | wc -l` -gt 1 ]; then
#clear
echo more than 1 pmon process for INSTANCE is running ! exit
echo `ps -ef | grep pmon | grep $ORACLE_SID`
exit 2
fi

echo PROC_INFO $PROC_INFO
export ORACLE_HOME_STRING=`pwdx $PROC_INFO | cut -f2 -d':'`
echo ORACLE_HOME_STRING $ORACLE_HOME_STRING
if [ -z "$ORACLE_HOME_STRING" ]; then
#clear
echo wrong SID or INSTANCE not running ! exit
exit $?
fi

unset ORACLE_HOME
unset _
export ORACLE_HOME=`echo ${ORACLE_HOME_STRING/\/dbs/}`
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
echo ORACLE_HOME is $ORACLE_HOME
echo rman is `which rman`
echo sqlplus is `which sqlplus`
}

function backup_aux_db {
echo "Find ORACLE_HOME for source instance"
echo
find_ora_home
echo
$scripts_folder/backup_script_cold_hot.sh $ORACLE_SID auto 8
if [ $? -eq 0 ]
 then
  echo Backup of the instance ${ORACLE_SID} was successfull, folder $common_folder/${ORACLE_SID}_${timestamp}_auto/
 else
 if [ "$RESTORE_DROPPED" = "Y" ]; then
   echo restore DROPPED database
 else
   echo "wrong restoration variable given (must be Y)"
   echo or Backup of the instance ${ORACLE_SID} not successfull, EXIT!
  exit 4
 fi
fi
}

function reset_w4db_pwd {
export ORACLE_SID=$ORACLE_SID
sqlplus -s '/ as sysdba' <<EOF
alter user sys identified by $syspwd;
exit;
EOF
}

#run script

echo script version is: $script_ver
echo
echo start time: $timestamp

echo rman log: ${log_folder}/duplicate_${ORACLE_SID}_${timestamp}.log

sqlplus -s / as sysdba << EOF
set serveroutput on feedback off
declare
v_size1 number;
v_size2 number;
v_db_size number;
begin
dbms_output.enable;
select round(sum(bytes)/1024/1024/1024) into v_size1 from dba_data_files;
select round(sum(bytes)/1024/1024/1024) into v_size2 from dba_temp_files;
v_db_size:=v_size1+v_size2;
dbms_output.put_line('TOTAL TARGET DB+TEMP FILES SIZE: '||v_db_size||'GB');
select round(sum(bytes)/1024/1024/1024/3.5) into v_size1 from dba_segments;
dbms_output.put_line('APPROX TARGET BACKUP SIZE WITH COMPRESSION WILL BE: '||v_size1||'GB');
end;
/
EOF

echo
if [ -n "$5" ];then
  if [ "$RESTORE_DROPPED" = "Y" ]; then
   echo "Y fifth parameter was given, DO not backup target database"
  else
   echo "wrong fifth restoration variable given (must be Y), EXIT!"
   exit 5
  fi
 else
  echo "fifth parameter was not given, Autobackup target database"
  backup_aux_db
fi
echo
echo "Drop target database"
echo
drop_aux_db
echo
echo "Start the auxiliary (target) database in FORCE NOMOUNT mode"
echo
nomount_aux_db
echo
echo "Duplicate the source database"
echo
dup_aux_db
echo
echo "Restart the target database with pfile"
echo
restart_aux_db_pfile
echo
if [[ "$db_prefix" = "w4"||"$db_prefix" = "dm" ]]; then
 echo "its way4 or dmart db, reset sys password"
 reset_w4db_pwd
  else
  echo "non way4/dm db"
fi

export backup_state=`cat ${log_folder}/duplicate_${ORACLE_SID}_${timestamp}.log | tail +15 | egrep 'ORA-|RMAN-' | wc -l`

echo end time: `date '+%d%m%y_%H_%M'`
echo
echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes
echo

if [[ ${backup_state} -eq 0 ]];then
 echo restoration completed successfully
 echo check folder ${log_folder}/, format ${ORACLE_SID}_${timestamp}
 if [ -f $HOME/alert_${ORACLE_SID}.log ];then
  echo link to alertlog exists in the $HOME folder already
 else 
  echo create link to alertlog $HOME folder
  ln -s /${ORACLE_SID}/diag/rdbms/${ORACLE_SID}/${ORACLE_SID}/trace/alert_${ORACLE_SID}.log $HOME/alert_${ORACLE_SID}.log
 fi
 exit 0
 else
 echo restoration completed with errors
 echo check log file ${log_folder}/duplicate_${ORACLE_SID}_${timestamp}.log
 exit 1
fi

exit 
