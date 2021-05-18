#!/bin/bash

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

#set variables

patch_dir=$1
patch_prereq=`opatch prereq CheckConflictAgainstOHWithDetail -ph $patch_dir | grep checkConflictAgainstOHWithDetail`
db_status=`echo 'select DATABASE_ROLE from v$database;' | sqlplus -S / as sysdba | tail -n-2 | head -n+1`

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


#run script

clear

if [ -n "$1" ] # Test whether command-line argument is present (non-empty).
then
 echo -e "${Purple}"
 echo `basename $0`: $1 argument given
 echo -e "${Cyan}"
 echo $patch_dir directory was used as PSU directory
 echo -e "${Color_Off}"
else
 echo -e "${Red}"
 echo "Usage: `basename $0` mandatory_argument (directory of unpacked PSU files with patchmd.xml file)"
 echo -e "${Color_Off}"
 exit    # Exit, if not specified on command-line.
fi
if [[ $patch_prereq == 'Prereq "checkConflictAgainstOHWithDetail" passed.' ]]; #Test CPU conflicts
then
 echo start `date`
 if [ "${db_status}" == PRIMARY ]
  then
   echo before apply patchset at primary DB
   echo "1) run script /usr/local/bin/scripts/restart_standby_server/before_restart.sh at primary server"
   echo "2) run script `basename $0` at standby server"
   echo -e "${Purple}"
   echo "scripts 1 and 2 were executed or you are not using standby database? (y|n)"
   echo -e "${Color_Off}"
   read scripts_run
    echo user answered $scripts_run
    echo
    if [ $scripts_run == y ]
     then
      echo apply patchset at primary DB server
      echo
      emctl stop dbconsole
      lsnrctl stop
      echo 'shutdown immediate;' | sqlplus -S / as sysdba
      cd $patch_dir
      opatch apply
      cd $ORACLE_HOME/rdbms/admin # applying CPU at the oracle database
sqlplus -S / as sysdba <<!
STARTUP;
@catbundle.sql psu apply;
@utlrp;
PROMPT
PROMPT APPLIED PATCHES IN DB
set linesize 200
column ACTION format a10
column ACTION_TIME format a30
column BUNDLE_SERIES format a15
column COMMENTS format a20
column ID format 999
column NAMESPACE format a10
column VERSION format a10
select  * from REGISTRY\$HISTORY order by 1;
PROMPT DB COMPONENTS
set linesize 150
set wrap off
column COMP_NAME format a30
column VERSION   format a15
column status    format a8
column modified  format a20
column SCHEMA    format a10
column procedure format a25

select COMP_NAME,version,status,modified,schema,procedure from DBA_REGISTRY;
quit
!
      echo
      lsnrctl start
      emctl start dbconsole
      echo -e "${Purple}"
      echo patchset at primary DB server applied
      echo "run script /usr/local/bin/scripts/start_standby/start_standby.sh at standby server"
      echo -e "${Color_Off}"
      echo end `date`
      exit
    else
     echo -e "${Red}"
     echo scripts 1 and 2 were not executed and you are using standby database
     echo patching is not allowed
     echo -e "${Color_Off}"
     exit
    fi
  else
   echo applying patchset at standby DB
   echo
   lsnrctl stop
   emctl stop dbconsole
   echo 'shutdown immediate;' | sqlplus -S / as sysdba
   cd $patch_dir
   opatch apply
   lsnrctl start
   emctl start dbconsole
   echo
   echo patchset at standby DB server applied
   echo last patches in $ORACLE_HOME
   opatch lsinventory -bugs_fixed | grep MOLECULE | head
   echo -e "${Purple}" 
   echo "1) run script `basename $0` at primary server"
   echo "2) run script start_standby.sh at standby server"
   echo -e "${Color_Off}"
   echo end `date`
   exit
 fi
 else
  echo -e "${Red}"
  echo checkConflictAgainstOHWithDetail NOT passed - cannot apply patchset
  echo -e "${Color_Off}"
fi

exit