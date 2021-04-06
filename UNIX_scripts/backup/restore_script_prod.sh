#!/bin/bash

#preprod DB restoration script, created by Igor Chistov
#documentation available here: https://jira.network.ae/confluence/display/DBA/Rman+backup-restore#Rmanbackup-restore-pp_restore_from_prod
#bitbucket version: https://bitbucket.org/network-international/infrastructure/src/master/BAU_scripts/Backup_restore/restore_script_prod.sh
#possible pools for restoration (values for the NSR_RECOVER_POOL parameter in RMAN channel: DU site: Oracle/OracleADClone, AD site: OracleDR/OracleBSHClone)

# crontab example for way4 and datamart db (first number - minute, second number - hour, third number - day of months for start job)

#56 15 19 * * $HOME/scripts/restore_script_prod.sh way4db way4 "13-09-2019 11:00:30" /oracle/app/product/12.1.0/dbhome_1 unidbdomdr2 >> $HOME/logs/duplicate_JIRA-ADCB-1235.log 2>&1
#30 12 20 * * $HOME/scripts/restore_script_prod.sh way4dwhp dm "09-09-2019 11:00:30" /oracle/app/product/12.1.0/dbhome_1 unidmartb >> $HOME/logs/duplicate_JIRA-ADCB-1234.log 2>&1

# crontab example for non way4 database, 123456789 - source dbid, dbhostname - host of prod db

#30 12 20 * * $HOME/scripts/restore_script_prod.sh dbname 123456789 "09-09-2019 09:00:30" /oracle/app/product/12.1.0/dbhome_1 dbhostname >> $HOME/logs/duplicate_JIRA-ADCB-1234.log 2>&1

# command line run example for way4 and datamart db (remove hash from the beginning)

#nohup $HOME/scripts/restore_script_prod.sh way4dwhp dm "09-09-2019 11:00:30" /oracle/app/product/12.1.0/dbhome_1 unidbdomdr2 > $HOME/logs/duplicate_`date +%d%m%y_%H_%M`.log 2>&1 &
#nohup $HOME/scripts/restore_script_prod.sh way4db way4 "13-09-2019 11:00:30" /oracle/app/product/12.1.0/dbhome_1 unidmartb > $HOME/logs/duplicate_`date +%d%m%y_%H_%M`.log 2>&1 &

# command line run example for non way4 database, 123456789 - source dbid, dbhostname - host of prod db (remove hash from the beginning)

#nohup $HOME/scripts/restore_script_prod.sh dbname 123456789 "09-09-2019 09:00:30" /oracle/app/product/12.1.0/dbhome_1 dbhostname > $HOME/logs/duplicate_`date +%d%m%y_%H_%M`.log 2>&1 &

# command line run example for way4 database for TEST the restoration ONLY (remove hash from the beginning)

#nohup $HOME/scripts/restore_script_prod.sh way4db way4 "13-09-2019 11:00:30" /oracle/app/product/12.1.0/dbhome_1 unidbdomdr2 T >> $HOME/logs/test_duplicate_JIRA-ADCB-1235.log 2>&1

#variables common
export script_ver="5.6"
export timestamp=`date '+%d%m%y_%H_%M_%S'`
log_folder=$HOME/logs
os_ver=`uname -o | cut -d '/' -f 2`
script_name=`basename $0`
username=`whoami`
export NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS'

#variables specific to the given script
export ORACLE_SID=$1
export DESTINATION=$2
export RESTORE_TIMESTAMP=$3
export ORACLE_HOME=$4
export prod_db_host=$5
export ts_4_exclude_mask=$6
export run_mode=$7
export catalog_tns='rman_network/Rman123#@10.129.103.55:1526/catlog2'
export catalog_tns_2='rman_network/Rman123#@10.129.103.55:2019/catlogdb'
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib;
export restore_time="TO_DATE('$3','DD-MM-YYYY HH24:MI:SS')"
export num_cpu="$(("`kstat -m cpu_info | grep -w core_id | wc -l`/8"))"
export parallelism=$(($num_cpu*3/2))
sql_view1='v$asm_diskgroup'
sql_view2='v$parameter'
sql_view3='v$database'
syspwd='ni123456#'
#if (($num_cpu<=5))
#then
# export parallelism=$(($num_cpu*4))
#else
# export parallelism=$(($num_cpu*2))
#fi

#functions

function check_catalog {

if [ -d "$ORACLE_HOME" ];then
var1=`${ORACLE_HOME}/bin/tnsping | grep "TNS Ping Utility" | cut -f2 -d ":" | cut -f3 -d " "`
else
 destination DB oracle_home folder $ORACLE_HOME not exists exit
 exit 7
fi
rdbms_ver=`echo $var1 | cut -f1-2 -d "."`

if [[ "$rdbms_ver" == "12.1" || $rdbms_ver == "12.2" ]] ; then
 echo destination DB major release is $rdbms_ver so using 12c catalog
 else
 echo destination DB major release is $rdbms_ver so using 19c catalog
 export catalog_tns=$catalog_tns_2
fi

echo check database status, exit if instance unreachable
echo "exit" | rman catalog $catalog_tns | grep "connected to recovery catalog database" > /dev/null
if [ $? -eq 0 ]
then
 echo "recovery catalog database connection OK"
 echo
else
 echo "Unable to reach recovery catalog database, exit"
 exit 2
fi
}

function set_destination_id {
echo "set source (prod from catalog) DB ID"
echo second parameter is $DESTINATION
echo "fifth parameter (source db host) is $prod_db_host"
echo
export SBT_PARMS="SBT_PARMS=(NSR_SERVER=lnibkpprd1,NSR_CLIENT=$prod_db_host,NSR_RECOVER_POOL=OracleADClone)"
rman_channels=`for i in $(eval echo "{1..$parallelism}")
do
echo ALLOCATE AUXILIARY CHANNEL CH$i TYPE 'SBT_TAPE' PARMS \"$SBT_PARMS\"";"
done`
rman_channels_preview=`for i in $(eval echo "{1..$parallelism}")
do
echo ALLOCATE CHANNEL CH$i TYPE 'SBT_TAPE' PARMS \"$SBT_PARMS\"";"
done`
if [ -n $2 ];then
  case $DESTINATION in
   "way4" )
   echo source DB ID is: $DESTINATION, restore way4 db
   export DBID=274344000
   ;;
   "dm" )
   echo source DB ID is: $DESTINATION, restore datamart db
   export DBID=3659532475
  ;;
   * )
   echo source DB ID is: $DESTINATION, DB_ID must be given as second parameter
   export DBID=$DESTINATION
   ;;
  esac
 else
  echo "second parameter (way4, dm or destination DB ID) was not given, exit"
  exit 3
fi
}

function check_asm_space {
echo checking size in ASM for the DB restoration
recent_db_size=`sqlplus -s  $catalog_tns <<EOF
set pagesize 999 linesize 999 heading off feedback off
     SELECT ROUND (SUM (FILESIZE) * 1.02 / 1024 / 1024)  SIZE_MB
       FROM RC_BACKUP_DATAFILE_DETAILS
      WHERE (SESSION_KEY, DB_NAME) IN
                (SELECT SESSION_KEY, DB_NAME
                   FROM RC_RMAN_BACKUP_SUBJOB_DETAILS
                  WHERE     INPUT_TYPE LIKE 'DB%'
                        AND DB_KEY IN (SELECT DB_KEY
                                         FROM RC_DATABASE
                                        WHERE DBID = $DBID)
                        AND START_TIME BETWEEN  $restore_time - 1
                                           AND  $restore_time + 1)
                        AND TSNAME NOT LIKE '%${ts_4_exclude_mask}%'
   GROUP BY SESSION_KEY, DB_NAME
   ORDER BY 1 DESC FETCH FIRST 1 ROWS ONLY;
exit;
EOF`
export ORACLE_SID=$ORACLE_SID
db_open_mode=`sqlplus -s / as sysdba <<EOF
set pagesize 999 linesize 999 heading off feedback off serveroutput off termout off
select open_mode from $sql_view3;
exit;
EOF`
echo db_open_mode is $db_open_mode
if [[ `echo $db_open_mode` = `echo READ WRITE` ]]; then
 echo destination DB is already opened, do space estimation
else
 echo destination DB is not opened, starting in nomount mode for required space estimation
sqlplus -s '/ as sysdba' <<EOF
set pagesize 999 linesize 999 heading on feedback on serveroutput on termout on
startup nomount;
exit;
EOF
fi
asm_dg_size=`sqlplus -s / as sysdba <<EOF
set pagesize 999 linesize 999 heading off feedback off
select TOTAL_MB  from $sql_view1 where (name = (select replace(value,'+','') from $sql_view2 where NAME = 'db_create_file_dest')
or name||'/' = (select replace(value,'+','') from $sql_view2 where NAME = 'db_create_file_dest'));
exit;
EOF`
echo total size of recent DB backup for DB with id = $DBID, GB: $((recent_db_size/1024)), MB: $recent_db_size
if [ $((asm_dg_size/1024)) = 0 ]; then
echo cannot calculate space in the biggest ASM DG for the $ORACLE_SID db instance
echo or db_create_file_dest parameter NOT GIVEN in pfile of the $ORACLE_SID db instance
if [[ "$DESTINATION" = "way4" || "$DESTINATION" = "dm" ]]; then
 echo exit
 exit 6
else
 echo non w4/dm databases, igrore ASM check results
fi
else
echo total space in the biggest ASM DG for the $ORACLE_SID db instance, GB: $((asm_dg_size/1024)), MB: $asm_dg_size
fi
if
 [ $recent_db_size -gt $asm_dg_size ]; then
  if [[ "$DESTINATION" = "way4" || "$DESTINATION" = "dm" ]]; then
    echo total size of recent DB backup more than total space in the biggest ASM DG, exit
    exit 5
   else
    echo non w4/dm databases, igrore ASM check results
  fi
else
 echo enough ASM space for restore recent DB backup
 echo may proceed with the restoration
fi
}

function drop_aux_db {
echo oracle sid is $ORACLE_SID
db_open_mode=`sqlplus -s / as sysdba <<EOF
set pagesize 999 linesize 999 heading off feedback off serveroutput off termout off
select open_mode from $sql_view3;
exit;
EOF`
echo db_open_mode is $db_open_mode
if [[ `echo $db_open_mode` = `echo READ WRITE` ]]; then
 echo destination DB is opened, can be dropped
sqlplus -s '/ as sysdba' <<EOF
set pagesize 999 linesize 999 heading off feedback off serveroutput off termout off
prompt db name and open_mode
select name, open_mode from v\$database;
shutdown immediate;
startup mount exclusive restrict;
drop database;
exit;
EOF
else
 echo destination DB is not opened, can not be dropped
fi
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
rman catalog $catalog_tns AUXILIARY / <<EOF
set echo on
spool log to ${log_folder}/duplicate_${ORACLE_SID}_${timestamp}.log
run {
$rman_channels
 SET DBID $DBID;
 DUPLICATE TARGET DATABASE TO $ORACLE_SID UNTIL TIME "$restore_time" $ts_4_exclude NOFILENAMECHECK;
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
alter database disable block change tracking;
exit;
EOF
}

function preview_recovery {
echo validate the restoration possibility for the $ORACLE_SID DB instance up to $restore_time
echo preview recovery rman log: ${log_folder}/preview_${ORACLE_SID}_${timestamp}.log
export ORACLE_SID=$ORACLE_SID
sqlplus -s '/ as sysdba' <<EOF
shutdown immediate;
startup nomount;
exit;
EOF
echo using $parallelism parallel channels for the preview recovery as per lCPU available
rman target / catalog $catalog_tns <<EOF
set echo on
spool log to ${log_folder}/preview_${ORACLE_SID}_${timestamp}.log
SET DBID $DBID;
ALLOCATE CHANNEL for maintenance TYPE 'SBT_TAPE' PARMS "$SBT_PARMS";
crosscheck backup of archivelog time between "$restore_time-1/6" and "$restore_time+1/3";
run {
$rman_channels_preview
 SET DBID $DBID;
 set until time "$restore_time";
 restore database $ts_4_exclude preview;
}
spool log off
exit;
EOF
sqlplus -s '/ as sysdba' <<EOF
shutdown immediate;
startup;
exit;
EOF
}

function set_restore_time {
echo find closest restore time for available archivelogs backup for the source database
final_restore_time=`sqlplus -s $catalog_tns <<EOF
set pagesize 999 linesize 999 heading off feedback off
SELECT 'TO_DATE('''
              || TO_CHAR (END_TIME,
                          'DD-MM-YYYY HH24:MI:SS')
              || ''',''DD-MM-YYYY HH24:MI:SS'')'
       FROM RC_RMAN_BACKUP_SUBJOB_DETAILS
      WHERE     DB_NAME = (SELECT NAME
                             FROM RC_DATABASE
                            WHERE DBID = $DBID)
            AND END_TIME BETWEEN $restore_time - INTERVAL '2' HOUR
                             AND $restore_time + INTERVAL '2' HOUR
  ORDER BY   ABS ( $restore_time - END_TIME)
            * 24
            * 60
            * 60 ASC
FETCH FIRST 1 ROWS ONLY;
exit
EOF`
}

function reset_w4db_pwd {
export ORACLE_SID=$ORACLE_SID
echo reset sys password for the $ORACLE_SID DB instance
sqlplus -s '/ as sysdba' <<EOF
set serveroutput on feedback off
alter user sys identified by $syspwd;
DECLARE
    V_ADMIN_COUNT   NUMBER DEFAULT 0;
    V_ADMIN         VARCHAR2 (20) DEFAULT 'IGOR_OEM';
BEGIN
 DBMS_OUTPUT.ENABLE;
    SELECT COUNT (1)
      INTO V_ADMIN_COUNT
      FROM DBA_USERS
     WHERE USERNAME = V_ADMIN;

    IF V_ADMIN_COUNT = 0
    THEN
        DBMS_OUTPUT.PUT_LINE (
               'account '
            || V_ADMIN
            || ' must be created in the given DB post restoration');
    ELSE
        DBMS_OUTPUT.PUT_LINE('grant dba to ' || V_ADMIN);
        EXECUTE IMMEDIATE 'grant dba to ' || V_ADMIN;
    END IF;
END;
/
exit;
EOF
echo
}

function set_ts_for_exlude {
echo find tablespaces for be excluded during the restoration of backup of the source database
echo mask using for exclude: $ts_4_exclude_mask
ts_4_exclude=`sqlplus -s $catalog_tns <<EOF
set pagesize 999 linesize 999 heading off feedback off
SELECT CASE NVL (LISTAGG (TSNAME, ',') WITHIN GROUP (ORDER BY TSNAME), 'XXX')
           WHEN 'XXX'
           THEN
               ' '
           ELSE
                  'SKIP TABLESPACE '
               || LISTAGG (TSNAME, ',') WITHIN GROUP (ORDER BY TSNAME)
       END    AS TS_4_EXCLUDE  
       FROM (SELECT DISTINCT TSNAME
          FROM RC_BACKUP_DATAFILE_DETAILS
         WHERE     DB_KEY IN (SELECT DB_KEY
                                FROM RC_DATABASE
                               WHERE DBID = $DBID)
               AND TSNAME LIKE '%${ts_4_exclude_mask}%');
exit
EOF`
echo
echo the following TS exclude option will be used during the restoration:
echo $ts_4_exclude
echo
}


#run script

echo script version is: $script_ver
echo
echo start time: $timestamp
echo

if [ -n "$6" ];then
  echo "six parameter (tablespace name mask for exclude in destination) was given, using it: $ts_4_exclude_mask" 
 else
  echo "six parameter (tablespace name mask for exclude in destination) was not given, using default HSK_EXP"
  export ts_4_exclude_mask='HSK_EXP'
fi

echo
echo variables given
echo
echo 1, destination db                   : $1
echo 2, prod source                      : $2
echo 3, timestamp for restore try  : $3
echo 4, ORACLE_HOME                 : $4
echo 5, "prod db host name (used for NSR_CLIENT value) in SBT_PARMS": $5
echo 6, tablespace exclude mask: $ts_4_exclude_mask
echo 7, run mode: $7
echo numbers of lCPU for the server is $num_cpu

if [ "$os_ver" == "Solaris" ];then
 echo its Solaris OS
 else 
 echo its Linux OS
fi

mkdir -p $log_folder

echo write execution history into $log_folder/$script_name.log
echo ' ' >> $log_folder/$script_name.log
echo script "$0" >> $log_folder/$script_name.log
echo script version is: $script_ver >> $log_folder/$script_name.log
echo start time: $timestamp >> $log_folder/$script_name.log
echo >> $log_folder/$script_name.log
echo variables given >> $log_folder/$script_name.log
echo >> $log_folder/$script_name.log
echo 1, destination db                   : $1 >> $log_folder/$script_name.log
echo 2, prod source                      : $2 >> $log_folder/$script_name.log
echo 3, timestamp for restore try        : $3 >> $log_folder/$script_name.log
echo 4, ORACLE_HOME                 : $4 >> $log_folder/$script_name.log
echo 5, "prod db host name (used for NSR_CLIENT value) in SBT_PARMS": $5 >> $log_folder/$script_name.log
echo 6, tablespace exclude mask: $ts_4_exclude_mask >> $log_folder/$script_name.log
echo 7, run mode: $7 >> $log_folder/$script_name.log
echo numbers of lCPU for the server is $num_cpu >> $log_folder/$script_name.log
echo >> $log_folder/$script_name.log
if [ "$os_ver" == "Solaris" ];then
 echo its Solaris OS >> $log_folder/$script_name.log
else 
 echo its Linux OS >> $log_folder/$script_name.log
fi

if [ -n "$3" ];then
 echo given timestamp for restore try is: $restore_time
 echo
else
 echo "third parameter (destination restoration timestamp) was not given, exit"
 exit 4
fi

check_catalog
echo
set_destination_id
echo
check_asm_space
echo
echo rman channel params is: $SBT_PARMS
echo
set_ts_for_exlude
echo
preview_recovery
echo
set_restore_time
echo
if [[ $final_restore_time == *"TO_DATE"* ]]; then
 echo final restore time will be used for this restoration is: $final_restore_time
 echo initialy it was given: $restore_time
 restore_time=$final_restore_time
 export timestamp=`date '+%d%m%y_%H_%M_%S'`
 preview_recovery
else
 echo not changing restore time
fi

if [ -n "$7" ];then
  case $run_mode in
   "T" )
   echo run mode is $run_mode
   echo test restoration only, destination DB will be restarted, BUT will not be dropped
   export backup_state=`cat ${log_folder}/preview_${ORACLE_SID}_${timestamp}.log | tail +15 | egrep 'ORA-|RMAN-' | wc -l`
  ;;
   * )
   echo wrong mode given, valid options are:
   echo T - test restoration only, destination DB will be restarted, will not be dropped
   echo
   exit 7
   ;;
  esac
else
  echo "six parameter was not given, execution of script in normal mode"
  echo "Drop target database"
  echo
  drop_aux_db
  echo
  echo "Start the auxiliary (target) database in FORCE NOMOUNT mode"
  echo
  nomount_aux_db
  echo
  echo "Duplicate the source database until timestamp" $restore_time
  echo rman log: ${log_folder}/duplicate_${ORACLE_SID}_${timestamp}.log
  dup_aux_db
  echo
  echo "Restart the target database with pfile"
  echo
  restart_aux_db_pfile
  echo
  reset_w4db_pwd
  
  export backup_state=`cat ${log_folder}/duplicate_${ORACLE_SID}_${timestamp}.log | tail +15 | egrep 'ORA-|RMAN-' | wc -l`
fi

echo end time: `date '+%d%m%y_%H_%M'`
echo
echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes
echo

if [[ ${backup_state} -eq 0 ]];then
 echo restoration completed successfully
 if [ -n "$7" ];then
  echo rman log file ${log_folder}/preview_${ORACLE_SID}_${timestamp}.log
 else
  echo rman log file ${log_folder}/duplicate_${ORACLE_SID}_${timestamp}.log
  if [ -f $HOME/alert_${ORACLE_SID}.log ];then
   echo link to alertlog exists in the $HOME folder already
  else
   echo create link to alertlog $HOME folder
   ln -s /${ORACLE_SID}/diag/rdbms/${ORACLE_SID}/${ORACLE_SID}/trace/alert_${ORACLE_SID}.log $HOME/alert_${ORACLE_SID}.log
  fi
 fi
 exit 0
 else
 echo restoration completed with errors
 echo "check errors in the below rman log (25 last lines of the file):"
 if [ -n "$7" ];then
  echo rman log file ${log_folder}/preview_${ORACLE_SID}_${timestamp}.log
  tail -25 ${log_folder}/preview_${ORACLE_SID}_${timestamp}.log
 else 
  echo rman log file ${log_folder}/duplicate_${ORACLE_SID}_${timestamp}.log
  tail -25 ${log_folder}/duplicate_${ORACLE_SID}_${timestamp}.log
 fi
 exit 1
fi

exit
