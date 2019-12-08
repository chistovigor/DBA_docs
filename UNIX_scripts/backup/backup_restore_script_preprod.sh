#!/bin/bash

#backup/restore preprod DB script, ver 1.2, created by Igor Chistov, Rajavardhan Reddy

#variables

export script_ver="1.2"
export catalog_server="10.129.115.44:4420/ppctldb"
export ORACLE_SID=$1
export jira_task=$2
export mode=$3
export host_name=`hostname`
export catalog_db="sys/ni123456@$catalog_server as sysdba"
export catalog_tns=\"${host_name}_${jira_task}/${host_name}_${jira_task}@$catalog_server\"
export timestamp=`date '+%d%m%y_%H_%M'`
export logdir=$HOME/logs/
export NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI'
export SBT_PARMS="SBT_PARMS=(NSR_SERVER=lnibkpprd1,NSR_CLIENT=$host_name,NSR_RECOVER_POOL=Oracle)"

# crontab example backup (first number - minute, second number - hour, third number - day of months for start job)
# 00 17 22 * * $HOME/scripts/preprod_backup_restore.sh way4db0 JIRA_EE3106 backup >> $HOME/logs/backup_JIRA_EE-3106.log 2>&1

# crontab example restore
# 30 09 22 * * $HOME/scripts/preprod_backup_restore.sh way4db0 JIRA_EE3106 restore >> $HOME/logs/restore_JIRA_EE-3106.log 2>&1

# crontab example backup weekly
#00 18 * * 5 /rbackup/scripts/preprod_backup_restore.sh way4db0 SCHEDULED backup >> $HOME/logs/backup_way4db0_SCHEDULED_`date +\%d\%m\%y_\%H_\%M`.log 2>&1

# command line run example (remove hash from the beginning)
#nohup $HOME/scripts/preprod_backup_restore.sh way4db0 JIRA_EE3106 backup >> $HOME/logs/backup_JIRA_EE-3106.log 2>&1


#functions

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

function create_catalog {
echo create catalog user ${host_name}_${jira_task} and catlog for DB $ORACLE_SID
sqlplus -s $catalog_db << EOF
set serveroutput on feedback off
 create user ${host_name}_${jira_task} identified by ${host_name}_${jira_task};
 grant recovery_catalog_owner to ${host_name}_${jira_task};
 grant unlimited tablespace to  ${host_name}_${jira_task};
exit;
EOF
rman catalog ${host_name}_${jira_task}/${host_name}_${jira_task}@$catalog_server <<EOF
create catalog;
exit;
EOF
}

function check_catalog {
echo check database status, exit if instance unreachable
echo "exit" | rman catalog $catalog_tns | grep "connected to recovery catalog database" > /dev/null
if [ $? -eq 0 ]
then
 echo "recovery catalog database connection OK"
 echo
export catloguser=`sqlplus -s  $catalog_db << EOF
set  heading off feedback off termout off trim off
select username from dba_users where username like '%${jira_task}';
EOF`
export DBID=`sqlplus -s  $catalog_db << EOF
set heading off feedback off termout off trim off
select DBID from ${catloguser}.rc_database;
EOF`
echo DBID for the database $ORACLE_SID and recovery catalog owner ${host_name}_${jira_task} is $DBID
else
 echo "Unable to reach recovery catalog database, exit"
 exit 2
fi
}

function register_catalog {
echo register DB in recovery catalog
rman target / catalog ${host_name}_${jira_task}/${host_name}_${jira_task}@$catalog_server <<EOF
register database;
exit;
EOF
}

function cold_backup {
echo shutdown instance for cold backup
sqlplus -S / as sysdba <<EOF
 shutdown immediate;
 startup mount;
 exit;
EOF
echo Backup the source database using {$host_name}_{$jira_task} user as catalog owner
rman target / catalog $catalog_tns << EOF
spool log to ${logdir}/${ORACLE_SID}_${timestamp}_${jira_task}.log
run{
 ALLOCATE CHANNEL CH1  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH2  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH3  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH4  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH5  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH6  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH7  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH8  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH9  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH10 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH11 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH12 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH13 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH14 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH15 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH16 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH17 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH18 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH19 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE CHANNEL CH20 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 BACKUP INCREMENTAL LEVEL 0 FILESPERSET 20 FORMAT '%d_%u_%s_%p' DATABASE INCLUDE CURRENT CONTROLFILE;
}
exit;
EOF
echo startup instance after cold backup
sqlplus -S / as sysdba <<EOF
 alter database open;
 exit;
EOF
}

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
echo $ORACLE_SID
export host_name=`echo $catloguser | cut -d '_' -f 1`
echo " Database restoring from host :"$host_name "DB Name "$ORACLE_SID "DBID" $DBID

export SBT_PARMS="SBT_PARMS=(NSR_SERVER=lnibkpprd1,NSR_CLIENT=$host_name,NSR_RECOVER_POOL=Oracle)"
rman catalog $catalog_tns AUXILIARY / <<EOF
set echo on
spool log to ${logdir}/${ORACLE_SID}_${timestamp}_${jira_task}.log
run {
 ALLOCATE AUXILIARY CHANNEL CH1  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH2  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH3  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH4  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH5  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH6  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH7  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH8  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH9  TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH10 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH11 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH12 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH13 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH14 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH15 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH16 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH17 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH18 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH19 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 ALLOCATE AUXILIARY CHANNEL CH20 TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
 SET DBID=$DBID;
 DUPLICATE TARGET DATABASE TO $ORACLE_SID NOFILENAMECHECK;
}
spool log off
exit;
EOF
}

function restart_aux_db_pfile {
export ORACLE_SID=$ORACLE_SID
sqlplus -s '/ as sysdba' <<EOF
!rm $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora
shutdown immediate;
startup mount;
alter database noarchivelog;
alter database open;
exit;
EOF
}

function check_db_size {
echo source DB backup size estimate
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
dbms_output.put_line('TOTAL DB+TEMP FILES SIZE: '||v_db_size||'GB');
select round(sum(bytes)/1024/1024/1024/3.5) into v_size1 from dba_segments;
dbms_output.put_line('APPROX BACKUP SIZE WITH COMPRESSION WILL BE: '||v_size1||'GB');
end;
/
EOF
}


#run script

echo script version is: $script_ver
echo
echo start time: $timestamp
echo variables given:
echo ORACLE_SID: $1
echo jira task: $2
echo mode: $3
echo User for recovery catalog: {$host_name}_{$jira_task}

echo Find ORACLE_HOME for source instance
echo
find_ora_home
echo

echo rman log: ${logdir}/${ORACLE_SID}_${timestamp}_${jira_task}.log

if [ -n $3 ];then
  case $3 in
   "backup" )
   echo backup mode execution start
   echo
   create_catalog
   echo
   register_catalog
   echo
   check_catalog
   echo
   check_db_size
   echo
   cold_backup
   echo
   ;;
   "restore" )
   echo restore mode execution start
   echo
   check_catalog
   echo
   echo
   echo rman channel params is: $SBT_PARMS
   echo
   echo "Drop target database"
   echo
   drop_aux_db
   echo
   echo "Start the auxiliary (target) database in FORCE NOMOUNT mode"
   echo
   nomount_aux_db
   echo
   echo Duplicate the source database using {$host_name}_{$2} user as catalog owner
   dup_aux_db
   echo
   echo restart the target database with pfile
   echo
   restart_aux_db_pfile
   echo
  ;;
   * )
   echo "second parameter must be backup or restore, exit"
   exit 2
   ;;
  esac
 else
  echo "second parameter (backup or restore) was not given, exit"
  exit 3
fi

export backup_state=`cat ${logdir}/${ORACLE_SID}_${timestamp}_${jira_task}.log | egrep 'ORA-|RMAN-' | wc -l`

if [[ ${backup_state} -eq 0 && -f ${logdir}/${ORACLE_SID}_${timestamp}_${jira_task}.log ]];then
 echo "backup/restore completed successfully"
 else
 echo "backup/restore completed with errors"
 echo check log file ${logdir}/${ORACLE_SID}_${timestamp}_${jira_task}.log
 echo end time: `date '+%d%m%y_%H_%M'`
 echo
 echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes
 exit 1
fi

echo end time: `date '+%d%m%y_%H_%M'`
echo
echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes
exit



 
