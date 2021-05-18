#!/bin/bash

. $HOME/.bash_profile

dump_dir='/mnt/oracle/temp/data_pump'
user_pwd='infoware'
enc_user='INFOWARE_ENC'
today=`date '+%d%m%y'`
parallelism=`nproc`
filesize='1500K'

# test USER
unenc_user='INFOWARE_TST'

# work USER !!!
#unenc_user='INFOWARE'

enc_tables='ANNUAL_TABLE_ENC'
unenc_tables='ANNUAL_TABLE'
enc_indexes='ANNUAL_INDEX_ENC'
unenc_indexes='ANNUAL_INDEX'

#script body

cd $dump_dir

clear

case "$2" in
"") parallelism=$((parallelism/2));;
[0-9]) parallelism=$2;;
*) echo "Usage: `basename $0` ENC|UNENC parallelism_value";
exit;;
esac

if [ -n "$1" ]
# Test whether command-line argument is present (non-empty).
then
 case "$1" in
 "ENC" )
  echo start `date`
  echo $1 argument given
  echo move user data from unencrypted to encrypted TS
  ;;
 "UNENC" )
  echo start `date`
  echo $1 argument given
  echo move user data from encrypted to unencrypted TS
  ;;
 * )
  echo 
  echo wrong first argument given: $1
  echo USE command-line argument ENC to move user data from unencrypted to encrypted TS
  echo OR UNENC to move user data from encrypted to unencrypted TS
  echo
  ;;
 esac
else
 echo
 echo USE command-line argument:
 echo
 echo first, mandatory:
 echo ENC   
 echo to move user data from unencrypted to encrypted TS
 echo UNENC
 echo to move user data from encrypted to unencrypted TS
 echo
 echo second, optional:
 echo number - parallelism value for datapump utility, default is CPU_number/2
 echo
 exit    # Exit, if not specified on command-line.
fi

case "$1" in

"ENC" )

sqlplus -S / as sysdba <<script

set termout off trimspool on
spool recreate_enc_user_${enc_user}_${today}.log

select to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') "DATE" from dual;

PROMPT *** RECREATE USER $enc_user ***

DROP USER $enc_user CASCADE;

CREATE USER $enc_user
  IDENTIFIED BY $user_pwd
  DEFAULT TABLESPACE $enc_tables
  TEMPORARY TABLESPACE TEMP1
  PROFILE APPLICATION
  ACCOUNT UNLOCK;
  -- 23 System Privileges for $enc_user 
  GRANT ALTER ANY TABLE TO $enc_user;
  GRANT CREATE ANY DIRECTORY TO $enc_user;
  GRANT CREATE ANY INDEX TO $enc_user;
  GRANT CREATE ANY JOB TO $enc_user;
  GRANT CREATE ANY TABLE TO $enc_user;
  GRANT CREATE ANY TRIGGER TO $enc_user;
  GRANT CREATE CLUSTER TO $enc_user;
  GRANT CREATE INDEXTYPE TO $enc_user;
  GRANT CREATE OPERATOR TO $enc_user;
  GRANT CREATE PROCEDURE TO $enc_user;
  GRANT CREATE SEQUENCE TO $enc_user;
  GRANT CREATE SESSION TO $enc_user;
  GRANT CREATE SYNONYM TO $enc_user;
  GRANT CREATE TABLE TO $enc_user;
  GRANT CREATE TRIGGER TO $enc_user;
  GRANT CREATE TYPE TO $enc_user;
  GRANT CREATE VIEW TO $enc_user;
  GRANT DROP ANY DIRECTORY TO $enc_user;
  GRANT DROP ANY TABLE TO $enc_user;
  GRANT GRANT ANY ROLE TO $enc_user;
  GRANT LOCK ANY TABLE TO $enc_user;
  GRANT SELECT ANY TABLE TO $enc_user;
  GRANT UNLIMITED TABLESPACE TO $enc_user;
  -- 15 Object Privileges for $enc_user 
    GRANT READ, WRITE ON DIRECTORY SYS.DATA_PUMP_DIR TO $enc_user;
    GRANT SELECT ON SYS.DBA_DATA_FILES TO $enc_user;
    GRANT SELECT ON SYS.DBA_OBJECTS TO $enc_user;
    GRANT SELECT ON SYS.DBA_TAB_COLUMNS TO $enc_user;
    GRANT EXECUTE ON SYS.DBMS_ALERT TO $enc_user;
    GRANT EXECUTE ON SYS.DBMS_LOB TO $enc_user;
    GRANT EXECUTE ON SYS.DBMS_REDEFINITION TO $enc_user;
    GRANT SELECT ON SYS.USER$ TO $enc_user WITH GRANT OPTION;
    GRANT EXECUTE ON SYS.UTL_FILE TO $enc_user;
    GRANT SELECT ON SYS.V_\$INSTANCE TO $enc_user;
    GRANT SELECT ON SYS.V_\$LOCKED_OBJECT TO $enc_user WITH GRANT OPTION;
    GRANT SELECT ON SYS.V_\$PROCESS TO $enc_user WITH GRANT OPTION;
    GRANT SELECT ON SYS.V_\$SESSION TO $enc_user WITH GRANT OPTION;
    GRANT SELECT ON SYS.V_\$SESSTAT TO $enc_user;
    GRANT SELECT ON SYS.V_\$STATNAME TO $enc_user;

spool off
exit
script

echo export unencrypdted data into $parallelism files EXP_${unenc_user}_${today}_*.DMP parallelism=$parallelism

expdp $unenc_user/$user_pwd DUMPFILE=EXP_${unenc_user}_${today}_%U.DMP DIRECTORY=DATA_PUMP_DIR LOGFILE=EXP_${unenc_user}_${today}.LOG SCHEMAS=$unenc_user COMPRESSION=ALL REUSE_DUMPFILES=Y PARALLEL=$parallelism METRICS=YES SILENT=ALL filesize=$filesize

echo import unencrypdted data into encrypdted DB schema $enc_user, place data into tablespaces $enc_tables and $enc_indexes

impdp $enc_user/$user_pwd DUMPFILE=EXP_${unenc_user}_${today}_%U.DMP LOGFILE=IMP_${enc_user}_${today}.LOG DIRECTORY=DATA_PUMP_DIR REMAP_SCHEMA=$unenc_user:$enc_user METRICS=YES PARALLEL=$parallelism REMAP_TABLESPACE=$unenc_tables:$enc_tables,$unenc_indexes:$enc_indexes,CORE:$enc_tables,CORE_INDEX:$enc_indexes SILENT=ALL

echo export encrypdted data into $parallelism files EXP_${enc_user}_${today}_*.DMP parallelism=$parallelism

expdp $enc_user/$user_pwd DUMPFILE=EXP_${enc_user}_${today}_%U.DMP DIRECTORY=DATA_PUMP_DIR LOGFILE=EXP_${enc_user}_${today}.LOG SCHEMAS=$enc_user COMPRESSION=ALL REUSE_DUMPFILES=Y PARALLEL=$parallelism METRICS=YES SILENT=ALL filesize=$filesize

zip dpump_${today}.zip -9 -m *${today}* -x imp_*

echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes
echo
echo finish `date`
;;

"UNENC" )

sqlplus -S / as sysdba <<script

set termout off trimspool on
spool recreate_unenc_user_${unenc_user}_${today}.log

select to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') "DATE" from dual;

PROMPT *** RECREATE USER $unenc_user ***

DROP USER $unenc_user CASCADE;

CREATE USER $unenc_user
  IDENTIFIED BY $user_pwd
  DEFAULT TABLESPACE $unenc_tables
  TEMPORARY TABLESPACE TEMP1
  PROFILE APPLICATION
  ACCOUNT UNLOCK;
  -- 2 Roles for $unenc_user 
  GRANT CONNECT TO $unenc_user;
  GRANT SELECT_CATALOG_ROLE TO $unenc_user;
  ALTER USER $unenc_user DEFAULT ROLE ALL;
  -- 22 System Privileges for $unenc_user
  GRANT ALTER ANY TABLE TO $unenc_user;
  GRANT CREATE ANY DIRECTORY TO $unenc_user;
  GRANT CREATE ANY INDEX TO $unenc_user;
  GRANT CREATE ANY JOB TO $unenc_user;
  GRANT CREATE ANY TABLE TO $unenc_user;
  GRANT CREATE ANY TRIGGER TO $unenc_user;
  GRANT CREATE CLUSTER TO $unenc_user;
  GRANT CREATE INDEXTYPE TO $unenc_user;
  GRANT CREATE OPERATOR TO $unenc_user;
  GRANT CREATE PROCEDURE TO $unenc_user;
  GRANT CREATE SEQUENCE TO $unenc_user;
  GRANT CREATE SYNONYM TO $unenc_user;
  GRANT CREATE TABLE TO $unenc_user;
  GRANT CREATE TRIGGER TO $unenc_user;
  GRANT CREATE TYPE TO $unenc_user;
  GRANT CREATE VIEW TO $unenc_user;
  GRANT DROP ANY DIRECTORY TO $unenc_user;
  GRANT DROP ANY TABLE TO $unenc_user;
  GRANT GRANT ANY ROLE TO $unenc_user;
  GRANT LOCK ANY TABLE TO $unenc_user;
  GRANT SELECT ANY TABLE TO $unenc_user;
  GRANT UNLIMITED TABLESPACE TO $unenc_user;
  -- 16 Object Privileges for $unenc_user
    GRANT READ, WRITE ON DIRECTORY SYS.DATA_PUMP_DIR TO $unenc_user;
    GRANT SELECT ON SYS.DBA_DATA_FILES TO $unenc_user;
    GRANT SELECT ON SYS.DBA_OBJECTS TO $unenc_user;
    GRANT SELECT ON SYS.DBA_TAB_COLUMNS TO $unenc_user;
    GRANT EXECUTE ON SYS.DBMS_ALERT TO $unenc_user;
    GRANT EXECUTE ON SYS.DBMS_LOB TO $unenc_user;
    GRANT EXECUTE ON SYS.DBMS_REDEFINITION TO $unenc_user;
    GRANT SELECT ON SYS.USER$ TO $unenc_user WITH GRANT OPTION;
    GRANT EXECUTE ON SYS.UTL_FILE TO $unenc_user;
    GRANT SELECT ON SYS.V_\$INSTANCE TO $unenc_user;
    GRANT SELECT ON SYS.V_\$LOCKED_OBJECT TO $unenc_user WITH GRANT OPTION;
    GRANT SELECT ON SYS.V_\$PROCESS TO $unenc_user WITH GRANT OPTION;
    GRANT SELECT ON SYS.V_\$SESSION TO $unenc_user WITH GRANT OPTION;
    GRANT SELECT ON SYS.V_\$SESSTAT TO $unenc_user;
    GRANT SELECT ON SYS.V_\$STATNAME TO $unenc_user;
    GRANT EXECUTE, READ, WRITE ON DIRECTORY SYS.WORK TO $unenc_user WITH GRANT OPTION;
spool off
exit
script

echo export encrypdted data into $parallelism files EXP_${enc_user}_${today}_*.DMP parallelism=$parallelism

expdp $enc_user/$user_pwd DUMPFILE=EXP_${enc_user}_${today}_%U.DMP DIRECTORY=DATA_PUMP_DIR LOGFILE=EXP_${enc_user}_${today}.LOG SCHEMAS=$enc_user COMPRESSION=ALL REUSE_DUMPFILES=Y PARALLEL=$parallelism METRICS=YES SILENT=ALL filesize=$filesize

echo import exported data into unencrypdted DB schema $unenc_user, place data into tablespaces $unenc_tables and $unenc_indexes

impdp $unenc_user/$user_pwd DUMPFILE=EXP_${enc_user}_${today}_%U.DMP LOGFILE=IMP_${enc_user}_${today}.LOG DIRECTORY=DATA_PUMP_DIR REMAP_SCHEMA=$enc_user:$unenc_user METRICS=YES PARALLEL=$parallelism REMAP_TABLESPACE=$enc_tables:$unenc_tables,$enc_indexes:$unenc_indexes SILENT=ALL

echo export unencrypdted data into $parallelism files EXP_${unenc_user}_${today}_*.DMP parallelism=$parallelism

expdp $unenc_user/$user_pwd DUMPFILE=EXP_${unenc_user}_${today}_%U.DMP DIRECTORY=DATA_PUMP_DIR LOGFILE=EXP_${unenc_user}_${today}.LOG SCHEMAS=$unenc_user COMPRESSION=ALL REUSE_DUMPFILES=Y PARALLEL=$parallelism METRICS=YES SILENT=ALL filesize=$filesize

zip dpump_${today}.zip -9 -m *${today}* -x imp_*

echo script finished in $SECONDS seconds or $(($SECONDS/60)) minutes
echo
echo finish `date`
;;
esac

exit