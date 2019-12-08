#!/bin/bash

#preprod DB restoration script, ver 1.4, created by Igor Chistov

#variables

export script_ver="1.4"
export catalog_tns=\"rman_network/Rman123#@10.129.103.55:1526/catlog2\"
export ORACLE_SID=$1
export DESTINATION=$2
export RESTORE_TIMESTAMP=$3
export ORACLE_HOME=$4
export prod_db_host=$5
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib;
export logdir=$HOME/logs
export NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI'
export timestamp=`date '+%d%m%y_%H_%M'`
export scripts_folder=$HOME/scripts
export restore_time="TO_DATE('$3','DD-MM-YYYY HH24:MI')"

# crontab example for way4 and datamart db (first number - minute, second number - hour, third number - day of months for start job)

#56 15 19 * * $HOME/scripts/restore_script_prod.sh way4db way4 "13-09-2019 11:00" /oracle/app/product/12.1.0/dbhome_1 unidbdomdr2 >> $HOME/logs/duplicate_JIRA-ADCB-1235.log 2>&1
#30 12 20 * * $HOME/scripts/restore_script_prod.sh way4dwhp dm "09-09-2019 11:00" /oracle/app/product/12.1.0/dbhome_1 unidmartb >> $HOME/logs/duplicate_JIRA-ADCB-1234.log 2>&1

# crontab example for non way4 database, 123456789 - source dbid, dbhostname - host of prod db

#30 12 20 * * $HOME/scripts/restore_script_prod.sh dbname 123456789 "09-09-2019 09:00" /oracle/app/product/12.1.0/dbhome_1 dbhostname >> $HOME/logs/duplicate_JIRA-ADCB-1234.log 2>&1

# command line run example for way4 and datamart db (remove hash from the beginning)

#nohup $HOME/scripts/restore_script_prod.sh way4dwhp dm "09-09-2019 11:00" /oracle/app/product/12.1.0/dbhome_1 unidbdomdr2 > $HOME/logs/duplicate_`date +%d%m%y_%H_%M`.log 2>&1 &
#nohup $HOME/scripts/restore_script_prod.sh way4db way4 "13-09-2019 11:00" /oracle/app/product/12.1.0/dbhome_1 unidmartb > $HOME/logs/duplicate_`date +%d%m%y_%H_%M`.log 2>&1 &

# command line run example for non way4 database, 123456789 - source dbid, dbhostname - host of prod db (remove hash from the beginning)

#nohup $HOME/scripts/restore_script_prod.sh dbname 123456789 "09-09-2019 09:00" /oracle/app/product/12.1.0/dbhome_1 dbhostname > $HOME/logs/duplicate_`date +%d%m%y_%H_%M`.log 2>&1 &

#functions

function check_catalog {
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
rman catalog $catalog_tns AUXILIARY / <<EOF
set echo on
spool log to ${logdir}/duplicate_${ORACLE_SID}_${timestamp}.log
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
 SET DBID $DBID;
 DUPLICATE TARGET DATABASE TO $ORACLE_SID UNTIL TIME "$restore_time" NOFILENAMECHECK;
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

#run script

echo script version is: $script_ver
echo
echo start time: $timestamp
echo

if [ -n "$3" ];then
        echo restore database until time $restore_time
 echo
 else
  echo "third parameter (destination restoration timestamp) was not given, exit"
  exit 4
fi

check_catalog
echo
set_destination_id
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
echo "Duplicate the source database until timestamp" $3
echo rman log: ${logdir}/duplicate_${ORACLE_SID}_${timestamp}.log
dup_aux_db
echo
echo "Restart the target database with pfile"
echo
restart_aux_db_pfile
echo

export backup_state=`cat ${logdir}/duplicate_${ORACLE_SID}_${timestamp}.log | tail +15 | egrep 'ORA-|RMAN-' | wc -l`

echo end time: `date '+%d%m%y_%H_%M'`
echo
echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes
echo

if [[ ${backup_state} -eq 0 ]];then
 echo restoration completed successfully
 echo rman log file ${logdir}/duplicate_${ORACLE_SID}_${timestamp}.log
 if [ -f $HOME/alert_${ORACLE_SID}.log ];then
  echo link to alertlog exists in the $HOME folder already
 else
  echo create link to alertlog $HOME folder
  ln -s /${ORACLE_SID}/diag/rdbms/${ORACLE_SID}/${ORACLE_SID}/trace/alert_${ORACLE_SID}.log $HOME/alert_${ORACLE_SID}.log
 fi
 exit 0
 else
 echo restoration completed with errors
 echo check rman log file ${logdir}/duplicate_${ORACLE_SID}_${timestamp}.log
 exit 1
fi

exit
