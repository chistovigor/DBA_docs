#!/bin/bash

. $HOME/.bash_profile

#set variables

#test_run='PROMPT' #!!!comment this variable for perform real switchover at the primary-standby pair
sys_pwd='spotlight'
cut_host=5 #this variable depends from tnsnames.ora file records
#cut_host=5
server_admins="iruacii2@raiffeisen.ru,iruagov3@raiffeisen.ru,iruafaa1@raiffeisen.ru,iruakgd5@raiffeisen.ru"
#server_admins="iruacii2@raiffeisen.ru,irualys2@raiffeisen.ru,iruakgv8@raiffeisen.ru,iruatza7@raiffeisen.ru"

#set constants (the same for all servers)

# Regular Colors

Color_Off='\e[0m'       # Text Reset
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

primary_string='/#/!s/:N/:Y/g'

standby_string='/#/!s/:Y/:N/g'

sqlplus_header='set heading off feedback off termout off trimspool on'

db_status=`sqlplus -S / as sysdba <<EOF
$sqlplus_header
select DATABASE_ROLE from v\\$database;
EOF`

switchover_status=`sqlplus -S / as sysdba <<EOF
$sqlplus_header
select switchover_status from v\\$database;
EOF`

remote_instance=`sqlplus -S / as sysdba <<EOF
$sqlplus_header
select value from v\\$parameter where name = 'fal_server';
EOF`

remote_host=`tnsping $remote_instance | grep HOST -A0 | cut -f$cut_host -d'=' | cut -f1 -d')'`

log_dir=`pwd`

sqlstring='select SEQUENCE# from V$LOG_HISTORY where SEQUENCE# = (SELECT MAX(SEQUENCE#) FROM V$LOG_HISTORY);'

max_archlog_current=`echo $sqlstring | sqlplus -S / as sysdba | tail -n-2 | head -n+1`
max_archlog_remote=`echo $sqlstring | sqlplus -S sys/$sys_pwd@"$remote_instance" as sysdba | tail -n-2 | head -n+1`

#variables for testing !!!DO NOT UNCOMMENT

#switchover_status='SESSIONS ACTIVE'
#switchover_status='TO STANDBY'
#db_status='PHYSICAL STANDBY'
#db_status='PRIMARY'
#max_archlog_remote=149660

#script body

clear

if [ "$test_run" == "PROMPT" ]
 then
  echo -e "${Green}run script only in test mode"
  echo -e "${Color_Off}"
 else
  echo -e "${Red}Attention! run script in work mode!"
  echo -e "${Color_Off}"
fi

# FAILOVER SECTION

if [ "$1" == "FAILOWER" ]
 then
 if [[ `echo $db_status` == 'PHYSICAL STANDBY' ]]
  then
   echo -e "${Purple}perform FAILOWER from database located at `uname -n` server to database located at $remote_host server"
   echo -e "${Color_Off}"
   sqlplus -S / as sysdba <<EOF
   $sqlplus_header
   spool $log_dir/FAILOWER.log
   select to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') "DATE" from dual;
   $test_run ALTER DATABASE RECOVER MANAGED STANDBY DATABASE FINISH;
   $test_run ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;
   $test_run SHUTDOWN IMMEDIATE;
   $test_run STARTUP MOUNT;
   $test_run ALTER DATABASE OPEN;
   select to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') "DATE" from dual;
   PROMPT *** FAILOWER finished, PRIMARY DB is: ***
   set heading on
   set linesize 200
   column HOST_NAME      format a16
   column DB_UNIQUE_NAME format a15
   select NAME,DB_UNIQUE_NAME,DATABASE_ROLE,SWITCHOVER_STATUS,PROTECTION_MODE,PROTECTION_LEVEL,HOST_NAME from v\$database,v\$instance;
   spool off
   exit
EOF
  else
   echo -e "${Red}"
   echo db_status is $db_status at current host: `uname -n`, FAILOWER can be run only at PHYSICAL STANDBY database
   echo -e "${Color_Off}"
 fi
  exit
 else
  if [ "$#" -gt 0 ]
   then
    echo -e "${Yellow}the number of positional variables given is $#"
    echo -e "${Color_Off}"
    echo -e "${Red}script $0 was executed with the first positional variable = $1"
    echo !! to run the FAILOWER this variable must be = FAILOWER !!
    echo -e "${Color_Off}"
    exit
  else
   echo -e "${Yellow}no positional variables were given, run script in SWITCHOVER mode"
   echo -e "${Color_Off}"
  fi
fi

# FAILOVER SECTION END

echo -e "${Cyan}current host is \\n `uname -n`"
echo -e current time is \\n `date`
echo -e test run variable = \\n $test_run
echo -e current host db status is \\n $db_status
echo -e current host switchover status is \\n $switchover_status
echo -e current host maximum archivelog number is \\n $max_archlog_current
echo -e sqlplus logs will be written to \\n $log_dir
echo -e remote instance name is \\n $remote_instance
echo -e remote host is \\n $remote_host
echo -e remote host maximum archivelog number is \\n $max_archlog_remote
echo -e "${Color_Off}"

if [[ `echo $db_status` == PRIMARY ]]; then
  if [[ `echo $switchover_status` == 'SESSIONS ACTIVE' || `echo $switchover_status` == 'TO STANDBY' ]];then
   if [[ $[$max_archlog_current-$max_archlog_remote] == 0 ]];then
  echo -e "${Purple}perform switchover on primary database to standby role at host `uname -n`"
  echo -e "${Color_Off}"
  sqlplus -S / as sysdba <<EOF
  $sqlplus_header
  spool $log_dir/sw_primary2standby.log
  PROMPT *** switch primary DB to standby role ***
  select to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') "DATE" from dual;
  PROMPT *** db info before switchover ***
  set heading on
  set linesize 200
  column HOST_NAME      format a16
  column DB_UNIQUE_NAME format a15
  select NAME,DB_UNIQUE_NAME,DATABASE_ROLE,SWITCHOVER_STATUS,PROTECTION_MODE,PROTECTION_LEVEL,HOST_NAME from v\$database,v\$instance;
  set heading off
  PROMPT
  set serveroutput on
  $test_run ALTER SYSTEM ARCHIVE LOG CURRENT;
  $test_run ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;
  $test_run SHUTDOWN IMMEDIATE;
  connect / as sysdba;
  $test_run STARTUP NOMOUNT;
  $test_run ALTER DATABASE MOUNT STANDBY DATABASE;
  $test_run ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT;
  set serveroutput off
  PROMPT *** db info after switchover ***
  set heading on
  column HOST_NAME      format a16
  column DB_UNIQUE_NAME format a15
  select NAME,DB_UNIQUE_NAME,DATABASE_ROLE,SWITCHOVER_STATUS,PROTECTION_MODE,PROTECTION_LEVEL,HOST_NAME from v\$database,v\$instance;
  set heading off
  PROMPT *** finish switching at ***
  select to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') "DATE" from dual;
  spool off
EOF
  echo -e "${Purple}"
  echo perform switchover on standby database with unique name $remote_instance to primary role at host $remote_host
  echo -e "${Color_Off}"
  sqlplus -S sys/$sys_pwd@"$remote_instance" as sysdba <<EOF
  $sqlplus_header
  spool $log_dir/sw_standby2primary.log
  PROMPT *** switch standby DB to primary role ***
  select to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') "DATE" from dual;
  PROMPT *** db info before switchover ***
  set heading on
  set linesize 200
  column HOST_NAME      format a16
  column DB_UNIQUE_NAME format a15
  select NAME,DB_UNIQUE_NAME,DATABASE_ROLE,SWITCHOVER_STATUS,PROTECTION_MODE,PROTECTION_LEVEL,HOST_NAME from v\$database,v\$instance;
  set heading off
  PROMPT
  set serveroutput on
  $test_run ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;
  $test_run SHUTDOWN IMMEDIATE;
  $test_run STARTUP MOUNT;
  $test_run ALTER DATABASE OPEN;
  set serveroutput off
  PROMPT *** db info after switchover ***
  set heading on
  column HOST_NAME      format a16
  column DB_UNIQUE_NAME format a15
  select NAME,DB_UNIQUE_NAME,DATABASE_ROLE,SWITCHOVER_STATUS,PROTECTION_MODE,PROTECTION_LEVEL,HOST_NAME from v\$database,v\$instance;
  set heading off
  PROMPT *** finish switching at ***
  select to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') "DATE" from dual;
  spool off
EOF
  sed -n $standby_string /etc/oratab
  echo -e "${Red}"
  echo !!!run the following commands as `whoami` user on the server $remote_host
  echo "sed '$primary_string' /etc/oratab > /tmp/oratab"
  echo 'cat /tmp/oratab > /etc/oratab'
  echo !!!run the following commands as `whoami` user on this server
  echo "sed '$standby_string' /etc/oratab > /tmp/oratab"
  echo 'cat /tmp/oratab > /etc/oratab'
  echo -e "${Color_Off}"
   else
    echo -e "${Red}"
    echo log difference beetween primary and standby = $[$max_archlog_current-$max_archlog_remote] : switchower is not possible now!
		 echo -e "${Color_Off}"
   fi
  else
   echo -e "${Red}data transfer beetween databases is not complete: switchower is not possible now!"
   echo -e "${Color_Off}"
  fi
else
 echo -e "${Red}"
 echo current host DB status is $db_status for switchower run script 
 echo `pwd`/`basename $0` on the host $remote_host
 echo -e "${Color_Off}"
fi

exit

