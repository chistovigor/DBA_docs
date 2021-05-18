#!/bin/bash

. $HOME/.bash_profile

#set variables

parallelism=`nproc`

#prod ATMDB server
#remote_db='LANIT'

#test ATMDB server
#remote_db='LANIT_TEST'

#new prod ATMDB server
#remote_db='CTRLDB'

#set constants

today=`date '+%d%m%y'`
curr_month=`date '+%Y%m'`
curr_year=`date '+%Y'`
imp_schema='router'
router_pwd='loopexamspit'
db_release=`echo exit | sqlplus -L router/$router_pwd | grep 'SQL>' | cut -f10 -d' '| grep 1`
enc_tables='ANNUAL_DATAENC'
enc_indexes='ANNUAL_INDEXENC'
unenc_tables='ANNUAL_TABLE'
unenc_indexes='ANNUAL_INDEX'

#script body

clear

if [ -n "$1" ]
# Test whether command-line argument is present (non-empty).
then
 echo Local Database release at server `uname -n` is $db_release
 echo start `date`
echo $1 argument given
 case "$1" in
 "small" )
  echo import all data except all *YYYYMM tables parallel $parallelism
  echo
  if [ "$db_release" == "10.2.0.5.0" ]
  then 
   echo
   echo backup all data from OLD DB except all *YYYYMM tables into dumpfiles router_small_${today}_old*.dmp
   expdp $imp_schema/$router_pwd schemas=router EXCLUDE=TABLE:\"LIKE \'__201%\'\" DIRECTORY=DATA_PUMP_DIR logfile=router_small_${today}_old.log DUMPFILE=router_small_${today}_old%U.dmp JOB_NAME=exp_router_small_old_$(today) METRICS=YES PARALLEL=$parallelism CONTENT=ALL
   echo
   echo for import data back into OLD DB run the following command:
   echo
   echo impdp $imp_schema/$router_pwd DIRECTORY=DATA_PUMP_DIR logfile=imp_back_router_small_${today}_old.log DUMPFILE=router_small_${today}_old%U.dmp JOB_NAME=imp_back_router_small_old METRICS=YES PARALLEL=$parallelism CONTENT=ALL table_exists_action=REPLACE
   echo
   echo import data back from NEW db into OLD:
   echo import tables from $enc_tables into $unenc_tables, indexes from $enc_indexes into $unenc_indexes
   echo
   impdp $imp_schema/$router_pwd schemas=router EXCLUDE=TABLE:\"LIKE \'__201%\'\",DB_LINK:\"NOT LIKE \'%DBO%\'\",TRIGGER,SYNONYM:\"NOT LIKE \'%ATM%\'\",SEQUENCE NETWORK_LINK=$remote_db logfile=DATA_PUMP_DIR:router_small_$today.log JOB_NAME=imp_router_small_$today METRICS=YES PARALLEL=$parallelism REMAP_TABLESPACE=$enc_tables:$unenc_tables,$enc_indexes:$unenc_indexes,USERS:CORE table_exists_action=REPLACE
  else 
   echo import data from OLD db into NEW:
   echo import tables from $unenc_tables into $enc_tables, indexes from $unenc_indexes into $enc_indexes
   echo
   impdp $imp_schema/$router_pwd schemas=router EXCLUDE=TABLE:\"LIKE \'__201%\'\",DB_LINK:\"NOT LIKE \'%DBO%\'\",TRIGGER,SYNONYM:\"NOT LIKE \'%ATM%\'\",SEQUENCE NETWORK_LINK=$remote_db logfile=DATA_PUMP_DIR:router_small_$today.log JOB_NAME=imp_router_small_$today METRICS=YES PARALLEL=$parallelism REMAP_TABLESPACE=$unenc_tables:$enc_tables,$unenc_indexes:$enc_indexes,USERS:CORE table_exists_action=REPLACE
  fi
  echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes
  echo
  echo finish `date`
  ;;
 "month" )
  echo import *$curr_month tables only parallel $parallelism
  echo
  if [ "$db_release" == "10.2.0.5.0" ]
   then
    echo import data back from NEW db into OLD: 
    echo import tables from $enc_tables into $unenc_tables, indexes from $enc_indexes into $unenc_indexes
    echo
    impdp $imp_schema/$router_pwd INCLUDE=TABLE:\"LIKE \'__$curr_month\'\" NETWORK_LINK=$remote_db logfile=DATA_PUMP_DIR:router_month_$today.log JOB_NAME=imp_router_month_$today METRICS=YES PARALLEL=$parallelism REMAP_TABLESPACE=$enc_tables:$unenc_tables,$enc_indexes:$unenc_indexes,USERS:CORE table_exists_action=REPLACE
  else 
   echo import data from OLD db into NEW:
   echo import tables from $unenc_tables into $enc_tables, indexes from $unenc_indexes into $enc_indexes
   echo
   impdp $imp_schema/$router_pwd INCLUDE=TABLE:\"LIKE \'__$curr_month\'\" NETWORK_LINK=$remote_db logfile=DATA_PUMP_DIR:router_month_$today.log JOB_NAME=imp_router_month_$today METRICS=YES PARALLEL=$parallelism REMAP_TABLESPACE=$unenc_tables:$enc_tables,$unenc_indexes:$enc_indexes,USERS:CORE table_exists_action=REPLACE
  fi
  echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes
  echo
  echo finish `date`
  ;;
 "annual" )
  echo import all *YYYYMM tables except *$curr_month tables parallel $parallelism
  echo
   if [ "$db_release" == "10.2.0.5.0" ]
   then
    echo
    echo import all *YYYYMM tables except *$curr_month tables will take much time! Are you sure? "Y|N"
    read accept_import
     if [ $accept_import == Y ]; then
      echo import data back from NEW db into OLD:
      echo import tables from $enc_tables into $unenc_tables, indexes from $enc_indexes into $unenc_indexes
      echo
      impdp $imp_schema/$router_pwd INCLUDE=TABLE:\"LIKE \'__$curr_year%\'\",TABLE:\"NOT LIKE \'__$curr_month\'\" NETWORK_LINK=$remote_db logfile=DATA_PUMP_DIR:router_month_$today.log JOB_NAME=imp_router_month_$today METRICS=YES PARALLEL=$parallelism REMAP_TABLESPACE=$enc_tables:$unenc_tables,$enc_indexes:$unenc_indexes,USERS:CORE table_exists_action=REPLACE
      else echo user answered $accept_import, cancel import, for import Y answer should be given
     fi
   else
    echo import tables from $unenc_tables into $enc_tables, indexes from $unenc_indexes into $enc_indexes
    echo
    impdp $imp_schema/$router_pwd INCLUDE=TABLE:\"LIKE \'__$curr_year%\'\",TABLE:\"NOT LIKE \'__$curr_month\'\" NETWORK_LINK=$remote_db logfile=DATA_PUMP_DIR:router_month_$today.log JOB_NAME=imp_router_month_$today METRICS=YES PARALLEL=$parallelism REMAP_TABLESPACE=$unenc_tables:$enc_tables,$unenc_indexes:$enc_indexes,USERS:CORE table_exists_action=REPLACE
  fi
  echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes
  echo
  echo finish `date`
  ;;
 * )
  echo wrong first argument given: $1
  echo
  echo "Usage: `basename $0` small|month|annual";
  echo
  echo small  - import all data except all *YYYYMM tables
  echo month  - import *$curr_month tables only
  echo annual - import all *YYYYMM tables except *$curr_month tables
  echo
  ;;
 esac
else
  echo "Usage: `basename $0` small|month|annual";
  echo
  echo small  - import all data except all *YYYYMM tables
  echo month  - import *$curr_month tables only
  echo annual - import all *YYYYMM tables except *$curr_month tables
  echo
 exit    # Exit, if not specified on command-line.
fi

exit