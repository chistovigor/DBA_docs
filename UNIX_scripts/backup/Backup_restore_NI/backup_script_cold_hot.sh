#!/bin/bash

#backup UAT DB script, created by Igor Chistov
#documentation available here: https://jira.network.ae/confluence/display/DBA/Rman+backup-restore#Rmanbackup-restore-uat_bk
#bitbucket version: https://bitbucket.org/network-international/infrastructure/src/master/BAU_scripts/Backup_restore/backup_script_cold_hot.sh

# crontab example cold (first number - minute, second number - hour, third number - day of months for start job)
# 00 17 22 * * $HOME/scripts/backup_script_cold_hot.sh way4db0 JIRA_EE-3106 8 >> $HOME/logs/backup_JIRA_EE-3106.log 2>&1

# crontab example hot (first number - minute, second number - hour, third number - day of months for start job)
# 00 17 22 * * $HOME/scripts/backup_script_cold_hot.sh way4db0 JIRA_EE-3106 8 hot >> $HOME/logs/backup_JIRA_EE-3107.log 2>&1

#hot (db MUST be in the archivelog mode)
#00 22 * * * $HOME/scripts/backup_script_cold_hot.sh w4sit17 SCHEDULED 8 hot 32 >> $HOME/logs/backup_w4sit17_SCHEDULED_`date +\%d\%m\%y_\%H_\%M`.log 2>&1

# crontab example scheduled with delete old backups
#00 18 * * 5 /rbackup/scripts/backup_script_cold_hot.sh way4db0 SCHEDULED 8 cold 6 >> $HOME/logs/backup_way4db0_SCHEDULED_`date +\%d\%m\%y_\%H_\%M`.log 2>&1

#variables common
export script_ver="3.1"
export timestamp=`date '+%d%m%y_%H_%M_%S'`
log_folder=$HOME/logs
os_ver=`uname -o | cut -d '/' -f 2`
script_name=`basename $0`
username=`whoami`
export NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS'

#variables specific to the given script
export ORACLE_SID=$1
export jira_task=$2
export parallel=$3
export mode=$4
export retention=$5
export common_folder=/rbackup
purge_command=`echo delete force noprompt backup completed before \"sysdate - $5\"`

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

function shrink_db {
echo shrink DB $1
sqlplus -s / as sysdba << EOF
set serveroutput on feedback off termout on
DECLARE
    V_RESIZE_SQL   VARCHAR2 (3900);
BEGIN
    FOR REC_DF
        IN (  SELECT    'alter database datafile '''
                     || A.FILE_NAME
                     || ''' resize '
                     || B.RESIZE_TO
                         AS RESIZE_SQL
                FROM DBA_DATA_FILES A,
                     (  SELECT FILE_ID,
                               MAX (  (BLOCK_ID + BLOCKS - 1 + 10)
                                    * (SELECT TO_NUMBER (VALUE)     AS BLOCK_SIZE
                                         FROM V\$PARAMETER
                                        WHERE NAME = 'db_block_size'))
                                   AS RESIZE_TO
                          FROM DBA_EXTENTS
                      GROUP BY FILE_ID) B
               WHERE A.FILE_ID = B.FILE_ID
            ORDER BY A.TABLESPACE_NAME, A.FILE_NAME)
    LOOP
        V_RESIZE_SQL := REC_DF.RESIZE_SQL;

        EXECUTE IMMEDIATE V_RESIZE_SQL;
    END LOOP;

    FOR REC_TEMP
        IN (SELECT 'alter tablespace ' || TABLESPACE_NAME || ' shrink space'
                       AS RESIZE_SQL
              FROM DBA_TABLESPACES
             WHERE CONTENTS = 'TEMPORARY' AND STATUS = 'ONLINE')
    LOOP
        V_RESIZE_SQL := REC_TEMP.RESIZE_SQL;

        EXECUTE IMMEDIATE V_RESIZE_SQL;
    END LOOP;
 EXCEPTION
    WHEN OTHERS
    THEN
        RAISE_APPLICATION_ERROR (
            -20999,
            ' ERROR while shrinking database, DB size may remains the same');
END;
/
EOF
echo shrink completed
}

#run script

echo script version is: $script_ver
echo
echo start time: $timestamp
echo variables given:
echo ORACLE_SID: $1
echo jira task: $2
echo parallel: $3
echo mode: $4
echo expiry period, days: $5 

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
echo variables given: >> $log_folder/$script_name.log
echo ORACLE_SID: $1 >> $log_folder/$script_name.log
echo jira task: $2 >> $log_folder/$script_name.log
echo parallel: $3 >> $log_folder/$script_name.log
echo mode: $4 >> $log_folder/$script_name.log
echo expiry period, days: $5 >> $log_folder/$script_name.log
if [ "$os_ver" == "Solaris" ];then
 echo its Solaris OS >> $log_folder/$script_name.log
else 
 echo its Linux OS >> $log_folder/$script_name.log
fi

echo "Make backup folder $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}"

mkdir $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}
if [ $? -eq 0 ]
 then
  echo "Make backup folder successfully"
 else
  echo "Cannot create backup folder, EXIT!"
 exit 3
fi

echo "Find ORACLE_HOME for source instance"
echo
find_ora_home
echo

shrink_db

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

if [ "${mode}" == hot ]; then
echo hot backup instance with rman
echo rman log: $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/backup_hot_${ORACLE_SID}_${timestamp}.log
if [ -n "$5" ];then
 retention=30
fi
#<<!
rman target / << EOF
spool log to $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/backup_hot_${ORACLE_SID}_${timestamp}.log
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF $retention DAYS;
SET COMPRESSION ALGORITHM 'MEDIUM';
CONFIGURE DEVICE TYPE DISK PARALLELISM $3 BACKUP TYPE TO COMPRESSED BACKUPSET;
backup incremental level 1 cumulative database tag INC_L1_DB_${timestamp} format '$common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/db_${ORACLE_SID}_${timestamp}_%U';
backup archivelog all tag ARCH_${timestamp} format '$common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/arch_${ORACLE_SID}_${timestamp}_%U' delete all input;
backup tag CTL_${ORACLE_SID}_${timestamp} current controlfile format '$common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/clt_${ORACLE_SID}_${timestamp}_%U';
crosscheck backup;
delete force noprompt obsolete;
spool log off
exit;
EOF
#!
else
echo shutdown instance for cold backup
echo rman log: $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/backup_${ORACLE_SID}_${timestamp}.log
#<<!
sqlplus -S / as sysdba <<EOF
 shutdown immediate;
 startup mount;
 exit;
EOF
echo backup instance with rman
rman target / << EOF
spool log to $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/backup_${ORACLE_SID}_${timestamp}.log
CONFIGURE RETENTION POLICY TO NONE;
SET COMPRESSION ALGORITHM 'MEDIUM';
CONFIGURE DEVICE TYPE DISK PARALLELISM $3 BACKUP TYPE TO COMPRESSED BACKUPSET;
backup full database tag FULL_DB_$timestamp format '$common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/db_${ORACLE_SID}_${timestamp}_%U';
backup tag CTL_${ORACLE_SID}_${timestamp} current controlfile format '$common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/clt_${ORACLE_SID}_${timestamp}_%U';
spool log off
exit;
EOF
echo startup instance after cold backup
sqlplus -S / as sysdba <<EOF
 alter database open;
 exit;
EOF
#!
fi

export backup_state=`cat $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/backup_*${ORACLE_SID}_${timestamp}.log | egrep 'ORA-|RMAN-' | wc -l`

if [[ ${backup_state} -eq 0 && -f $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/backup_${ORACLE_SID}_${timestamp}.log || -f $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/backup_hot_${ORACLE_SID}_${timestamp}.log ]];then
 echo backup completed successfully
 echo check folder $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/, format ${ORACLE_SID}_${timestamp}
 chmod -R 777 $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}
if [[ -n "$5" && "${mode}" != hot ]];then
 echo delete expired backups, older than $retention days
 echo rman log for that is: $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/clean_backup_${ORACLE_SID}_${timestamp}.log
rman target / << EOF
spool log to $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/clean_backup_${ORACLE_SID}_${timestamp}.log
$purge_command;
spool log off
exit;
EOF
 else
  if [ "${mode}" == hot ]; then
   echo "Retention will be in the HOT backup"
  else
   echo "retention (fifth) argument was not given to the script, after 4 weeks need to delete expired backups MANUALLY"
  fi
fi
 else
 echo backup completed with errors
 if [ "${mode}" == hot ]; then
 echo check log file $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/backup_hot_${ORACLE_SID}_${timestamp}.log
 else
 echo check log file $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}/backup_${ORACLE_SID}_${timestamp}.log
 fi
 chmod -R 777 $common_folder/${ORACLE_SID}_${timestamp}_${jira_task}
 echo end time: `date '+%d%m%y_%H_%M'`
 echo
 echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes
 exit 1
fi

echo end time: `date '+%d%m%y_%H_%M'`
echo
echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes
exit
