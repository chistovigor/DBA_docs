#!/bin/bash

#change init parameters set for w4/dm db script, created by Igor Chistov
#documentation available here: https://jira.network.ae/confluence/pages/viewpage.action?pageId=104244264
#bitbucket version: https://bitbucket.org/network-international/infrastructure/src/master/BAU_scripts/Other/master_parameters.sh

#variables common
export script_ver="2.4"
export timestamp=`date '+%d%m%y_%H_%M_%S'`
log_folder=$HOME/logs
os_ver=`uname -o | cut -d '/' -f 2`
script_name=`basename $0`
username=`whoami`
export NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS'

#variables specific to the given script
export v_positional_var1=$1
export v_positional_var2=$2
v_master_versions="1235"
sql_view1='v$parameter'
dblist=(`ps -ef | grep pmon | grep $username | grep -v grep  | cut -d '_' -f 3`)

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

export ORACLE_HOME_STRING=`pwdx $PROC_INFO | cut -f2 -d':'`
if [ -z "$ORACLE_HOME_STRING" ]; then
#clear
echo wrong SID or INSTANCE not running or owned by different user ! exit
exit $?
fi

unset ORACLE_HOME
unset _
export ORACLE_HOME=`echo ${ORACLE_HOME_STRING/\/dbs/}`
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
#echo ORACLE_HOME is $ORACLE_HOME
}

function restart_db_pfile {
cp $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora.$timestamp 2>/dev/null
rm -rf $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora
sqlplus -s '/ as sysdba' <<EOF
shutdown immediate;
startup open;
exit;
EOF
}

function check_masterfile_version {
echo results of checking masterfile $1.ora:
 if [ ! -e $ORACLE_HOME/dbs/$1.ora ]; then
  echo "there is no masterfile $ORACLE_HOME/dbs/$1.ora at the server, update $ORACLE_HOME/dbs/$1.ora masterfile from the cloud"
  mv /tmp/$username/$1.ora $ORACLE_HOME/dbs/$1.ora
 else
  if [ `diff /tmp/$username/$1.ora $ORACLE_HOME/dbs/$1.ora | wc -l` -gt 0 ]; then
   echo "masterfile in cloud different than at the server, update $ORACLE_HOME/dbs/$1.ora masterfile from the cloud"
   mv /tmp/$username/$1.ora $ORACLE_HOME/dbs/$1.ora
  else
   echo file $ORACLE_HOME/dbs/$1.ora already exists and the same like file in cloud repository
  fi
 fi
}

function check_ofa_instance {
echo
echo results of checking DB instance $1:
echo
export ORACLE_SID=$1
find_ora_home
 echo "run mode (second positional parameter) was not given, run script in check mode"
ctlfile=`sqlplus -S / as sysdba <<!
set heading off linesize 150 pagesize 150 serveroutput on feedback off
col value for a150
select value from $sql_view1 where name = 'control_files';
exit
!`
v_ctlfile="/${ORACLE_SID}/control/control01.ctl"
 if [[ `echo $ctlfile` == `echo $v_ctlfile` ]]
  then
   echo 'instance as per OFA, checking init parameters used'
    if [ `ls -alth $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora 2>/dev/null | wc -l` -gt 0 ]; then
     echo "spfile (!) $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora exists, next restart it will be used as the parameter file"
    else
     ls -alth $ORACLE_HOME/dbs/*$ORACLE_SID*.ora*
     echo "FULL contents of this instance parameter file:"
     cat $ORACLE_HOME/dbs/init$ORACLE_SID.ora
     echo
      if [ `cat $ORACLE_HOME/dbs/init$ORACLE_SID.ora | grep -v '^$' | grep -v "#" | grep -v $ORACLE_SID | grep -v '$ORACLE_SID' | grep "v[$v_master_versions]" | wc -l` -eq 0 ]; then
       echo "NONE of existing common parameter files v($v_master_versions) are used, it is ok for non w4/dm 12.1 instance"
       else
        echo "ONE of existing common parameter files v($v_master_versions) currently used"
      fi
    fi
  else
   echo 'instance not as per OFA, move to OFA first!'
 fi
}

#execution steps

echo script version is: $script_ver
echo
echo start time: $timestamp
echo
echo variables given:
echo 1, instance name: $1
echo 2, mode: $2

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
echo 1, instance name: $1 >> $log_folder/$script_name.log
echo 2, mode: $2 >> $log_folder/$script_name.log
if [ "$os_ver" == "Solaris" ];then
 echo its Solaris OS >> $log_folder/$script_name.log
else 
 echo its Linux OS >> $log_folder/$script_name.log
fi

echo

if [ -n "$1" ];then
 echo instance name is $v_positional_var1
 echo
 export db_prefix=${v_positional_var1:0:2}
 if [[ "$db_prefix" = "w4"||"$db_prefix" = "dm" || "$db_prefix" = "pi" ]]; then
 echo "its way4 or dmart db, way4/dm masterfiles may be used"
  else
   echo "non way4/dm db, non way4/dm masterfies ONLY used"
  #exit 2
 fi
else
 echo "instance name (first positional parameter) was not given, check all DBs running from the given user"
for i in "${dblist[@]}" 
do
export ORACLE_SID=$i
check_ofa_instance $ORACLE_SID
done
exit 0
fi

export ORACLE_SID=$1
find_ora_home

if [ -n "$2" ];then
 echo "run mode (second positional parameter)" is $v_positional_var2
  case "$v_positional_var2" in
   "v3" )
   check_masterfile_version "master_pfile_v3"
   echo init file $ORACLE_HOME/dbs/init$ORACLE_SID.ora contents BEFORE change:
   cat $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   cp $ORACLE_HOME/dbs/init$ORACLE_SID.ora $ORACLE_HOME/dbs/init$ORACLE_SID.ora.$timestamp
   sed "s/instance_name/${ORACLE_SID}/g" /tmp/$username/init_w4dm_uat_instance.ora > $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   echo >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   restart_db_pfile
   ;;
   "w4v1" )
   check_masterfile_version "master_pfile_v1"
   echo init file $ORACLE_HOME/dbs/init$ORACLE_SID.ora contents BEFORE change:
   cat $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   cp $ORACLE_HOME/dbs/init$ORACLE_SID.ora $ORACLE_HOME/dbs/init$ORACLE_SID.ora.$timestamp
   sed "s/instance_name/${ORACLE_SID}/g" /tmp/$username/init_w4instance.ora > $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   echo >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   restart_db_pfile
   ;;
   "w4v2" )
   check_masterfile_version "master_pfile_v2"
   echo init file $ORACLE_HOME/dbs/init$ORACLE_SID.ora contents BEFORE change:
   cat $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   cp $ORACLE_HOME/dbs/init$ORACLE_SID.ora $ORACLE_HOME/dbs/init$ORACLE_SID.ora.$timestamp
   sed "s/instance_name/${ORACLE_SID}/g" /tmp/$username/init_w4instance.ora > $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   sed -i 's/master_pfile_v1/master_pfile_v2/g' $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   echo >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   restart_db_pfile
   ;;
   "dmv1" )
   check_masterfile_version "master_pfile_dm_v1"
   echo init file $ORACLE_HOME/dbs/init$ORACLE_SID.ora contents BEFORE change:
   cat $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   cp $ORACLE_HOME/dbs/init$ORACLE_SID.ora $ORACLE_HOME/dbs/init$ORACLE_SID.ora.$timestamp
   sed "s/instance_name/${ORACLE_SID}/g" /tmp/$username/init_dminstance.ora > $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   echo >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   restart_db_pfile
   ;;
   "dmv2" )
   check_masterfile_version "master_pfile_dm_v2"
   echo init file $ORACLE_HOME/dbs/init$ORACLE_SID.ora contents BEFORE change:
   cat $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   cp $ORACLE_HOME/dbs/init$ORACLE_SID.ora $ORACLE_HOME/dbs/init$ORACLE_SID.ora.$timestamp
   sed "s/instance_name/${ORACLE_SID}/g" /tmp/$username/init_dminstance.ora > $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   sed -i 's/master_pfile_dm_v1/master_pfile_dm_v2/g' $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   echo >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
   restart_db_pfile
   ;;
   "check")
    echo "instance name (first positional parameter) was given, run in masterfiles sync mode for its ORACLE_HOME"
    check_masterfile_version "master_pfile_v1"
    check_masterfile_version "master_pfile_v2"
    check_masterfile_version "master_pfile_dm_v1"
    check_masterfile_version "master_pfile_dm_v2"
    check_masterfile_version "master_pfile_v3"
    check_masterfile_version "master_pfile_v5"
    check_masterfile_version "master_pfile_12_1_v1"
    check_masterfile_version "master_pfile_12_2_v1"
    check_masterfile_version "master_pfile_18c_v1"
    check_masterfile_version "master_pfile_19c_v1"
    echo
    echo masterfiles sync completed, exit
    exit 0
   ;;
   * )
  echo wrong second positional parameter was given: $v_positional_var2
  echo
  echo possible second positional parameters:
  echo
  echo v3    - "change parameters for the given instance to COMMON v3 w4/dm parameters"
  echo w4v1  - change parameters for the given instance to way4 v1 parameters
  echo w4v2  - change parameters for the given instance to way4 v2 parameters
  echo dmv1  - change parameters for the given instance to datamart v1 parameters
  echo dmv2  - change parameters for the given instance to datamart v2 parameters
  echo check - run in masterfiles sync mode for ORACLE_HOME of the given instance
  exit 4
   ;;
  esac
else
 check_ofa_instance $ORACLE_SID
fi

echo end time: `date '+%d%m%y_%H_%M_%S'`
echo end time: `date '+%d%m%y_%H_%M_%S'` >> $log_folder/$script_name.log
echo
echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes
echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes >> $log_folder/$script_name.log

exit 
