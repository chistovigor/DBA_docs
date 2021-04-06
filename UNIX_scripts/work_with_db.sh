#!/bin/bash

#change memory/datapatch/shutdown/startup DB script, created by Igor Chistov
#documentation available here: https://jira.network.ae/confluence/display/DBA/Execute+tasks+for+multiple+databases+on+server
#bitbucket version: https://bitbucket.org/network-international/infrastructure/src/master/BAU_scripts/Other/work_with_db.sh

#Running modes:

#1) Check only, shows size of current SGA/PGA, init files for instances, SQL for change memory to required sizes
#./work_with_db.sh

#RAM ONLY:
#./work_with_db.sh | grep '+'

#2) Prepare command for backup current spfiles (ONLY spfiles, NOT pfiles) - will show commands for backup current spfiles with sysdate suffix (for example spfilew4uat57.ora.20181128):
#./work_with_db.sh | grep cp > backup_spfiles.log && cat backup_spfiles.log

#3) Execute memory changes in spfile (ONLY spfile, for pfile do it manually) for all instances at host running from given ORACLE_HOME with prefixes given (see parameters, do spfiles backup before!)
#./work_with_db.sh Y

#4) Checking RAM + spfiles for all DBs from the user
#./work_with_db.sh | /usr/xpg4/bin/grep -F -e 'cp' -e '+'

#5) Check rdbms owner and parameters for particular DB instance (use database name as single parameter)
#./work_with_db.sh w4uat42

#Run in datapatch mode (MUST BE 2 positional variables)

#Check only
#./work_with_db.sh P /ora12c/app/product/12.1.0/dbhome_1

#Execute datapatch
#./work_with_db.sh Y /ora12c/app/product/12.1.0/dbhome_1
#nohup example:
#nohup /rbackup/scripts/work_with_db.sh Y /oracle/app/product/12.1.0/dbhome_1 >> $HOME/logs/datapatch_`date +%d%m%y_%H_%M`.log 2>&1 &

#Run in SHUTDOWN mode (MUST BE 2 positional variables)

#Check only
#./work_with_db.sh SEE /ora12c/app/product/12.1.0/dbhome_1

#Shutdown all databases/listeners
#./work_with_db.sh SH /ora12c/app/product/12.1.0/dbhome_1

#Run in STARTUP mode (MUST BE 2 positional variables)
#./work_with_db.sh ST /ora12c/app/product/12.1.0/dbhome_1

#variables common
export script_ver="4.6"
export timestamp=`date '+%d%m%y_%H_%M_%S'`
log_folder=$HOME/logs
os_ver=`uname -o | cut -d '/' -f 2`
script_name=`basename $0`
username=`whoami`
export NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS'

#variables specific to the given script
export v_positional_var1=$1
script_proc=`ps -ef | grep $script_name | grep -v mkdir | grep -v grep | wc -l`
dblist=(`ps -ef | grep pmon | grep $username | grep -v grep  | cut -d '_' -f 3`)
sga_size=6G
pga_size=6G

#functions

function find_ora_home {
export ORACLE_SID=$ORACLE_SID
export PROC_INFO=`ps -ef | grep pmon | grep "$ORACLE_SID$" | awk '{print $2}'`

if [ `ps -ef | grep pmon | grep "$ORACLE_SID$" | wc -l` -gt 1 ]; then
#clear
echo more than 1 pmon process for INSTANCE is running ! exit
echo `ps -ef | grep pmon | grep "$ORACLE_SID$"`
exit 2
fi

export ORACLE_HOME_STRING=`pwdx $PROC_INFO | cut -f2 -d':'`
if [ -z "$ORACLE_HOME_STRING" ]; then
#clear
echo wrong SID or INSTANCE not running or NOT owned by $username user, run this script from a different user at the same server ! exit
exit $?
fi

unset ORACLE_HOME
unset _
export ORACLE_HOME=`echo ${ORACLE_HOME_STRING/\/dbs/}`
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
}

function check_instance_parameters {
find_ora_home

$ORACLE_HOME/bin/sqlplus -S / as sysdba <<!
set heading off linesize 300 pagesize 10000 serveroutput on feedback off
col command for a300
col name for a24
col DISPLAY_VALUE for a10

select '+'||name name,DISPLAY_VALUE from v\$parameter where name in 
('sga_target','sga_max_size','pga_aggregate_target','pga_aggregate_limit') order by name;
select 'cp '||value||' '||value||'.'||to_char(sysdate,'yyyymmdd') command 
from v\$parameter where name = 'spfile' and value is not null;
prompt 
declare
v_spfile VARCHAR2(4000);
v_spfile_cp VARCHAR2(4000);
v_db_name VARCHAR2(20);
v_resize VARCHAR2(1):='$1';
v_pga NUMBER;
v_sga NUMBER;
v_total_ram NUMBER;
begin
dbms_output.enable;
select lower(value) into v_db_name from v\$parameter where name = 'db_unique_name';
SELECT ROUND (SUM (VALUE) / 1024 / 1024) into v_sga FROM V\$SGA;
SELECT ROUND (SUM (PGA_MAX_MEM) / 1024 / 1024) into v_pga FROM V\$PROCESS;
select v_sga+v_pga into v_total_ram from dual;
dbms_output.put_line('current TOTAL SGA (MB): '||v_sga);
dbms_output.put_line('current TOTAL MAX PGA (MB): '||v_pga);
dbms_output.put_line('+ TOTAL RAM for the db '||v_db_name|| ' (MB): '||v_total_ram);
select value into v_spfile from v\$parameter where name = 'spfile';
if v_spfile like '%/%' then 
dbms_output.put_line('prompt spfile used for db '||v_db_name);
IF v_resize = 'Y' THEN
dbms_output.put_line('memory resize');
 execute immediate 'alter system set sga_target = $sga_size scope = spfile sid = ''*''';
 execute immediate 'alter system set sga_max_size = $sga_size scope = spfile sid = ''*''';
 execute immediate 'alter system set pga_aggregate_target = $pga_size scope = spfile sid = ''*''';
 execute immediate 'alter system set pga_aggregate_limit = $pga_size scope = spfile sid = ''*''';
ELSE
--dbms_output.put_line('alter system set sga_target = $sga_size scope = spfile sid = ''*'';');
--dbms_output.put_line('alter system set sga_max_size = $sga_size scope = spfile sid = ''*'';');
--dbms_output.put_line('alter system set pga_aggregate_target = $pga_size scope = spfile sid = ''*'';');
--dbms_output.put_line('alter system set pga_aggregate_limit = $pga_size scope = spfile sid = ''*'';');
dbms_output.put_line('');
END IF;
else
dbms_output.put_line('pfile used for db '||v_db_name||', set parameter MANUALLY ');
end if;
end;
/
exit
!
echo ORACLE_HOME is :$ORACLE_HOME
}

function fix_datapatch_issue_01 {
sqlplus -s / as sysdba <<!
alter system set nls_length_semantics=byte;
drop type sys.oracle_loader;
drop type sys.oracle_datapump;
@?/rdbms/admin/dpload.sql;
@?/rdbms/admin/utlrp.sql;
exit
!
}

function set_semantics_char {
sqlplus -s / as sysdba <<!
alter system set nls_length_semantics=char;
exit
!
}



#execution steps

echo script name is: $script_name
echo script version is: $script_ver
echo
echo start time: $timestamp
echo variables given:
echo "mode (1st positional variable)": $1
echo "ORACLE_HOME (2nd positional variable)": $2
home_prefix=`echo $2 | sed -e 's/[\/&]/\_/g'`
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
echo variables given:  >> $log_folder/$script_name.log
echo "mode (1st positional variable)": $1  >> $log_folder/$script_name.log
echo "ORACLE_HOME (2nd positional variable)": $2  >> $log_folder/$script_name.log
echo running $script_name instances: $script_proc 
ps -ef | grep $script_name | grep -v mkdir | grep -v grep
if [ "$os_ver" == "Solaris" ];then
 echo its Solaris OS >> $log_folder/$script_name.log
  if [ $((script_proc)) -gt 2 ];then
   echo script $script_name is running already, only one execution is possible at the same time, EXIT
   exit 4
  fi
 else 
 echo its Linux OS >> $log_folder/$script_name.log
  if [ $((script_proc)) -gt 3 ];then
   echo script $script_name is running already, only one execution is possible at the same time, EXIT
   exit 4
  fi
fi

echo


if [ -n "$2" ]; then
 echo +run script in Datapatch/Shutdown/Startup mode
  case "$1" in
   "Y" )
   ;;
   "P" )
   ;;
   "Y01" )
   ;;
   "SEE" )
    export ORACLE_HOME=$2
    echo "+installed patches in the above ORACLE_HOME:"
    $2/OPatch/opatch lspatches | grep -v "OPatch succeeded."
	rm ~/${username}_db_list$home_prefix
	rm ~/${username}_lsnr_list$home_prefix
    echo +list all listeners from the given ORACLE_HOME
     lsnrlist=(`ps -eo args | grep $ORACLE_HOME | grep lsnr | grep -v grep | cut -f2 -d' '`)
	 for i in "${lsnrlist[@]}"
	 do
	  echo $i
	  echo $i >> ~/${username}_lsnr_list$home_prefix
	 done
	echo +list all databases from the given ORACLE_HOME
   ;;
   "SH" )
    echo setting ORACLE_HOME to $2
    export ORACLE_HOME=$2
   	rm ~/${username}_db_list$home_prefix
	rm ~/${username}_lsnr_list$home_prefix
    echo SHUTDOWN all listeners from the given ORACLE_HOME
    lsnrlist=(`ps -eo 'args' | grep $ORACLE_HOME | grep lsnr | grep -v grep | cut -f2 -d' '`)
	 for i in "${lsnrlist[@]}" 
	 do
	  echo $i >> ~/${username}_lsnr_list$home_prefix
	  $ORACLE_HOME/bin/lsnrctl stop $i
	 done
   ;;
   "ST" )
   export ORACLE_HOME=$2
   if [[ -f ~/${username}_db_list$home_prefix && -f ~/${username}_lsnr_list$home_prefix ]];then
    echo startup all databases and listeners were running from the $2 ORACLE_HOME
     db_start_list=(`cat ~/${username}_db_list$home_prefix`)
     lsnr_start_list=(`cat ~/${username}_lsnr_list$home_prefix`)
     for i in "${db_start_list[@]}"
      do
       echo
       echo start_db $i
	   export ORACLE_SID=$i
$ORACLE_HOME/bin/sqlplus -S / as sysdba <<!
set heading off linesize 300 pagesize 10000 serveroutput on feedback off
startup;
exit
!
      done
	 echo
     for i in "${lsnr_start_list[@]}"
      do
       echo start_listener $i
        $ORACLE_HOME/bin/lsnrctl start $i
      done
	mv ~/${username}_db_list$home_prefix ~/${username}_db_list${home_prefix}_$timestamp
    mv ~/${username}_lsnr_list$home_prefix ~/${username}_lsnr_list${home_prefix}_$timestamp
   else
    echo there is no file ~/${username}_db_list$home_prefix or ~/${username}_lsnr_list$home_prefix, script WAS NOT executed in SH mode before ST mode
	echo for the $ORACLE_HOME owned by $username
	exit 6
   fi   
   ;;
    * )
  echo wrong first argument given: $1
  echo
  echo possible first arguments when ORACLE_HOME given as second:
  echo
  echo Y   - run datapatch for all databases from the ORACLE_HOME $2
  echo Y01 - run datapatch in the issue 01 correct mode for all databases from the ORACLE_HOME $2
  echo P   - run datapatch in -prereq mode ONLY for all databases from the ORACLE_HOME $2
  echo SEE - Just list all databases/listeners from the ORACLE_HOME $2
  echo SH  - SHUTDOWN all databases/listeners from the ORACLE_HOME $2
  echo "ST  - STARTUP all databases/listeners were running before from the ORACLE_HOME ${2} (run this script in SH mode MANDATORY)"
  exit 5
   ;;
  esac
else
 if [ "$v_positional_var1" = "Y" ]; then
  echo run script in Memory check mode
 else
  if [ -n "$1" ]; then 
   echo find oracle rdbms owner for the DB instance $1
   echo "use below username in bamboo automated script for the given db instance"
   ps -eO user,comm | grep pmon | grep $1
   echo find ORACLE_HOME and parameters for the DB instance $1
   export ORACLE_SID=$1
   check_instance_parameters
   exit 0
  fi
 fi
fi

echo
echo all DBs in the server
echo
ps -ef | grep pmon | grep -v grep
echo
 
for i in "${dblist[@]}" 
do

export ORACLE_SID=$i
find_ora_home

if [ -n "$2" ]; then
 if [ "{$ORACLE_HOME}" == "{$2}" ]; then
  case "$1" in
  "Y" )
   echo run datapatch for DB $i
  $ORACLE_HOME/OPatch/datapatch
  ;;
  "Y01" )
   echo run datapatch in the issue 01 correct mode for DB $i
  fix_datapatch_issue_01 
  $ORACLE_HOME/OPatch/datapatch
  set_semantics_char
  ;;
  "P" )
   echo run datapatch in -prereq mode ONLY for DB $i
  $ORACLE_HOME/OPatch/datapatch -prereq 
  ;;
  "SEE" )
   echo $i
   echo $i >> ~/${username}_db_list$home_prefix
  ;;
  "SH" )
   echo $i >> ~/${username}_db_list$home_prefix
   echo shutdown database $ORACLE_SID from the given ORACLE_HOME
sqlplus -S / as sysdba <<!
set heading off linesize 300 pagesize 10000 serveroutput on feedback off
alter session set nls_date_format = 'dd-mm-yyyy hh24:mi:ss';
select sysdate from dual;
shutdown immediate;
exit
!
  ;;
  "ST" )

  ;;
   * )
  echo wrong first argument given: $1
  echo
  echo possible first arguments when ORACLE_HOME given as second:
  echo
  echo Y   - run datapatch for all databases from the ORACLE_HOME $2
  echo Y01 - run datapatch in the issue 01 correct mode for all databases from the ORACLE_HOME $2
  echo P   - run datapatch in -prereq mode ONLY for all databases from the ORACLE_HOME $2
  echo SEE - Just list all databases/listeners from the ORACLE_HOME $2
  echo SH  - SHUTDOWN all databases/listeners from the ORACLE_HOME $2
  echo "ST  - STARTUP all databases/listeners were running before from the ORACLE_HOME ${2} (run this script in SH mode MANDATORY)"
  exit 7
  ;;
  esac
 fi
else

echo
echo '+'database $i
check_instance_parameters
fi
done

echo end time: `date '+%d%m%y_%H_%M_%S'`
echo end time: `date '+%d%m%y_%H_%M_%S'` >> $log_folder/$script_name.log
echo
echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes
echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes >> $log_folder/$script_name.log

exit

