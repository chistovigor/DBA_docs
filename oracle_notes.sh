Install Instant Client

1) unzip instantclient-basic
2) Set PATH to the instantclient-basic location
3) Set TNS_ADMIN to the instantclient-basic location, place tnsnames.ora here

Latest Oracle SW distributives should be downloaded from

https://edelivery.oracle.com/

Install sql loader linux

Install Oracle Instant Client (from zip archives), unzip and link as described at:
http://www.oracle.com/technetwork/database/features/instant-client/index-097480.html

Create Oracle Environment Variables

export ORACLE_HOME=/usr/lib/oracle/11.2/client64
export PATH=$PATH:$ORACLE_HOME/bin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export TNS_ADMIN=$ORACLE_HOME/network/admin

scp sqlldr,tnsping from db_server, scp * from rdbms/mesg and network/mesg to client folder

Add databases to $ORACLE_HOME/network/admin/tnsnames.ora file of client host

Istall oracle database in silent mode:

./runInstaller -silent -debug -force \
oracle.install.option=INSTALL_DB_SWONLY \
UNIX_GROUP_NAME=oinstall \
ORACLE_HOME=/refresh/app/oracle/product/18.3 \
ORACLE_BASE=/refresh/app/oracle \
oracle.install.db.InstallEdition=EE \
oracle.install.db.DBA_GROUP=dba \
oracle.install.db.OPER_GROUP=dba \
oracle.install.db.OSBACKUPDBA_GROUP=dba \
oracle.install.db.OSDGDBA_GROUP=dba \
oracle.install.db.OSKMDBA_GROUP=dba \
oracle.install.db.OSRACDBA_GROUP=dba \
DECLINE_SECURITY_UPDATES=true

Create/delete DB with dbca in silent mode:

--ASM

dbca -silent -createDatabase \
-templateName General_Purpose.dbc \
-gdbname dwhlmdsp -sid dwhlmdsp -responseFile NO_VALUE \
-characterSet AL32UTF8 \
-sysPassword "passw0rd$" \
-systemPassword "passw0rd$" \
-DBSNMPPASSWORD welcome1 \
-createAsContainerDatabase false \
-databaseType MULTIPURPOSE \
-automaticMemoryManagement false \
-STORAGETYPE ASM \
-DISKGROUPNAME DATAC2 \
-RECOVERYGROUPNAME RECOC2 \
-redoLogFileSize 4096 \
-INITPARAMS "sga_max_size=30G,sga_target=30G,pga_aggregate_limit=15G,pga_aggregate_target=10G"
-ignorePreReqs

--FS

dbca -silent -createDatabase \
-templateName General_Purpose.dbc \
-gdbname jordbill -sid jordbill -responseFile NO_VALUE \
-characterSet AL32UTF8 \
-sysPassword "passw0rd$" \
-systemPassword "passw0rd$" \
-DBSNMPPASSWORD "Dubai2019#" \
-createAsContainerDatabase false \
-databaseType MULTIPURPOSE \
-automaticMemoryManagement false \
-STORAGETYPE FS \
-datafileDestination /jordbill/datafile \
-redoLogFileSize 1024 \
-INITPARAMS "sga_max_size=3G,sga_target=3G,pga_aggregate_limit=4G,pga_aggregate_target=2G,open_cursors=1200,session_cached_cursors=400,cursor_sharing=force"
-ignorePreReqs

dbca -silent -deleteDatabase -sourceDB dwhlmdsp -sysDBAUserName sys -sysDBAPassword "passw0rd$"

Lastest patches for Oracle Products:

Patch Set Updates for Oracle Products (Doc ID 854428.1)

Check Database Audit Vault option

ON, if query (from the owner of RDBMS_HOME) will return (file)

ar -tv $ORACLE_HOME/rdbms/lib/libknlopt.a | grep kzvndv.o

OFF, if query (from the owner of RDBMS_HOME) will NOT return (file)

ar -tv $ORACLE_HOME/rdbms/lib/libknlopt.a | grep kzvidv.o

See additional info about it and other options in Doc ID 948061.1

Turn on FLASHBACK (at a database level):

startup mount; --не нужно с 11gR2 (БД может быть открыта)
ALTER DATABASE FLASHBACK ON;
-- проверка
select flashback_on from v$database;
alter database open;

Analyze OS processes when DB hangs (Doc ID 986640.1)

sqlplus -prelim / as sysdba

oradebug setmypid
oradebug unlimit
oradebug dump systemstate 266
oradebug hanganalyze 3
oradebug TRACEFILE_NAME
/opt/oracle/app/oracle/diag/rdbms/ultradb_s_msk_p_ultradb01/ULTRADB/trace/ULTRADB_ora_14040.trc
SQL> exit

для процесса:

SQL> oradebug setmypid
Statement processed.
SQL> oradebug unlimit
Statement processed.
SQL> oradebug dump systemstate 13903
Statement processed.
SQL> oradebug TRACEFILE_NAME
/opt/oracle/app/oracle/diag/rdbms/ultradb_s_msk_p_ultradb01/ULTRADB/trace/ULTRADB_ora_14391.trc
SQL> exit

here 13903 - prosess identifier from the output of: ps -aux | grep oracle

DB connection using tnsnames.ora and jdbs.thin driver

1) Add when running java tns_admin parameter (add the tnsnames.ora location here)
When using TNSNames with the JDBC Thin driver, you must set the oracle.net.tns_admin property to the directory that contains your tnsnames.ora file.

java -Doracle.net.tns_admin=%ORACLE_HOME%\network\admin

2) Add a connect string (db_name - any descriptor from tnsnames.ora)
jdbc:oracle:thin:@db_name

Example for jasperreports-server:

Set TNS_ADMIN for JAVA in a file

/usr/oracle/jasperreports-server-cp-5.5.0/apache-tomcat/bin/setenv.sh

add the following string

JAVA_OPTS="-Doracle.net.tns_admin=/opt/oracle/app/oracle/product/11.2.0/client_1/network/admin $JAVA_OPTS "

Turn off a LISTENER logging

vim listener.ora

DIAG_ADR_ENABLED=off
LOGGING_listener=off
TRACE_FILELEN_listener=1024

oraInventory location:

cat /etc/oraInst.loc


Installation of Oracle Grid/RAC 11.2.0.4 on RHEL 7 or Oracle Linux 7
Some days ago, I had to install Oracle 11.2.0.4 on Red Hat Linux 7 and Grid Infrastructure for a standalone server. What I expected to be a quick task turned to be trickier than expected. Here outlined are the steps for the installation.

Red Hat Linux 7 and Oracle Linux 7 have important changes that impact on the installation process of Grid Infrastructure and Oracle RDBMS 11.2.0.4.
Let's do a review of the new details on the installation process.

Those steps have been done in a single instance environment. Perhaps you'd need some modification for RAC. Check Support Note 1951613.1 for details.

Prerequirements:
First, download from Oracle Support the newest version of OPatch. (download patch number 6880880, it always contain the most up to date version of OPatch)
Download patches  19404309, 18370031 y 19692824.
OUI says complains if the package pdksh is not installed on the system, but this package is not needed (Bug 19947777).
So, you can safely ignore this prerequisite when the OUI complains about it (mark 'Ignore All', provided you fulfill all the other prerequirements), or if you are sure 
that all the prerequirements are fullfilled, you can run the OUI as: ./runInstaller -ignorePrereq  (that will not run the prerequirements check).
Package compat-libstdc++-33 is needed to avoid problems when patching (BUG 22477834), but is no longer available in the RHEL 7 DVD. You can download it from Red Hat or from
the public Oracle repository http://public-yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm


1. Before starting the installation of Grid Infrastructure, apply patch 19404309:
   - Uncompress the installation zipped files (both RDBMS ad GRID) in a staging area (we'll use in  that case /SOFT):
    [TST][myoraserv].oracle > unzip p13390677_112040_Linux-x86-64_1of7.zip -d /SOFT
   [TST][myoraserv].oracle > unzip p13390677_112040_Linux-x86-64_2of7.zip -d /SOFT
   [TST][myoraserv].oracle > unzip p13390677_112040_Linux-x86-64_3of7.zip -d /SOFT

   - Uncompress patch  19404309
       unzip p19404309_112040_Linux-x86-64.zip -d /SOFT
          

   - Apply patch:
        For the database installation files:
    [TST][myoraserv].oracle:SOFT > cd b19404309
   [TST][myoraserv].oracle:b19404309 >
   [TST][myoraserv].oracle:b19404309 > cp database/cvu_prereq.xml /SOFT/database/stage/cvu
   [TST][myoraserv].oracle:b19404309 >

        For the grid infrastructure installation files:
        [TST][myoraserv].oragrid:b19404309 > cp grid/cvu_prereq.xml /SOFT/grid/stage/cvu
        [TST][myoraserv].oragrid:b19404309 >
    Also, if you have downloaded the installation files for the client or the examples, do the same. (check README from patch)

  -  Delete the patch installation directory:
    [TST][myoraserv].oracle:b19404309 > cd ..
    [TST][myoraserv].oracle:SOFT > rm -rf b19404309

2. We start to install GI as usual. The moment the OUI shows the screen asking to run root.sh and orainstroot.sh, BEFORE running them,
   we must install patch 18370031. Once finalized patch installation, we continue the setup process as usual.
   If we choose to install the software only, without performing the configuration, the patch must be installed once the setup ends, but before start the config process.
  
   So, we run the runInstaller.sh as usual and , when the screen asking us to run root.sh appears, from another terminal window, we install the patch.

   First, we update OPatch: (in our case, GRID_HOME is /opt/grid)
    [TST][myoraserv].oracle > cd /opt/grid
    [TST][myoraserv].grid >mv OPatch OPatch_OLD
    [TST][myoraserv].grid > cd /SOFT
    [TST][myoraserv].SOFT > unzip p6880880_112000_Linux-x86-64.zip -d /opt/grid
  We install patch 18370031
    [TST][myoraserv].SOFT > mkdir patch
    [TST][myoraserv].SOFT > unzip p18370031_112040_Linux-x86-64.zip -d patch
    [TST][myoraserv].SOFT > cd /opt/grid/OPatch
    [TST][myoraserv].OPatch > ./opatch napply -oh /opt/grid -local /SOFT/patch/18370031  (CHECK IT IF ARE DOING A MULTINODE SETUP)

    Applying interim patch '18370031' to OH '/opt/grid'

    Patching component oracle.crs, 11.2.0.4.0...
    Patch 18370031 successfully applied.
    Log file location: /opt/grid/cfgtoollogs/opatch/opatch2017-01-31_14-24-24PM_1.log

    OPatch succeeded.

       [TST][myoraserv].oragrid:OPatch >


   Now, we run orainstroot.sh and root.sh and proceed as usual.

    LOCAL ADD MODE
    Creating OCR keys for user 'oragrid', privgrp 'oinstall'..
    Operation successful.
    LOCAL ONLY MODE
    Successfully accumulated necessary OCR keys.
    Creating OCR keys for user 'root', privgrp 'root'..
    Operation successful.
    CRS-4664: Node myoraserv successfully pinned.
    Adding Clusterware entries to oracle-ohasd.service

    myoraserv     2017/01/31 14:27:11     /opt/grid/cdata/myoraserv/backup_20170131_142711.olr
    Successfully configured Oracle Grid Infrastructure for a Standalone Server
    [TST][myoraserv].root:grid >

3. Now, we install the RDBMS

  If we haven't  applied patch 19404309, we do it now following the previously listed steps.

  As oracle user, we start the installation process as usual, running the OUI.

  Approximately at 86% of the setup process, appears an error screen reading:

      Error in invoking target 'agent nmhs' of makefile '/opt/oracle/product/11.2.0.4/sysman/lib/ins_emagent.mk'. 
      See '/opt/oracle/oraInventory/logs/installActions2017-01-31_03-08-38PM.log' for details.
  We have the option to continue with the setup. So, we continue and once the setup ends, we install patch 19692824.

  First, we verify the version of perl. Must be 5.00503 or higher.

  We update OPatch the same way we did previously, but in the ORACLE_HOME of the RDBMS.

  then,  we unzip the patch

     [TST][myoraserv].grid > cd /SOFT
     [TST][myoraserv].SOFT > unzip p19692824_112040_Linux-x86-64.zip -d patch
  We check that all the Oracle services running from this ORACLE_HOME are stopped (database, agents, console, listener, etc)

  Now, we apply the patch:

    [TST][myoraserv].SOFT > cd /SOFT/patch/19692824
    [TST][myoraserv].19692824 > $ORACLE_HOME/OPatch/opatch apply
 At the end of the process, appear some warnings:

    /opt/oracle/product/11.2.0.4/sysman/lib/ins_emagent.mk:113: warning: overriding recipe for target `nmosudo'
    /opt/oracle/product/11.2.0.4/sysman/lib/ins_emagent.mk:52: warning: ignoring old recipe for target `nmosudo'
    /opt/oracle/product/11.2.0.4/sysman/lib/ins_emagent.mk:113: warning: overriding recipe for target `nmosudo'
    /opt/oracle/product/11.2.0.4/sysman/lib/ins_emagent.mk:52: warning: ignoring old recipe for target `nmosudo'
    /opt/oracle/product/11.2.0.4/sysman/lib/ins_emagent.mk:113: warning: overriding recipe for target `nmosudo'
    /opt/oracle/product/11.2.0.4/sysman/lib/ins_emagent.mk:52: warning: ignoring old recipe for target `nmosudo'
    /opt/oracle/product/11.2.0.4/sysman/lib/ins_emagent.mk:113: warning: overriding recipe for target `nmosudo'
    /opt/oracle/product/11.2.0.4/sysman/lib/ins_emagent.mk:52: warning: ignoring old recipe for target `nmosudo'
    /bin/ld: warning: -z lazyload ignored.
    /bin/ld: warning: -z nolazyload ignored.


        OPatch found the word "warning" in the stderr of the make command.
    Please look at this stderr. You can re-run this make command.
    Stderr output:
    ins_emagent.mk:113: warning: overriding recipe for target `nmosudo'
    ins_emagent.mk:52: warning: ignoring old recipe for target `nmosudo'
    /opt/oracle/product/11.2.0.4/sysman/lib/ins_emagent.mk:113: warning: overriding recipe for target `nmosudo'
    /opt/oracle/product/11.2.0.4/sysman/lib/ins_emagent.mk:52: warning: ignoring old recipe for target `nmosudo'
According to support note 1562458.1, those warnings can be safely ignored

Finally, as root, we run:

$ORACLE_HOME/root.sh


References:

- Installation walk-through - Oracle Grid/RAC 11.2.0.4 on Oracle Linux 7 (Doc ID 1951613.1)
- README of patches
- Bug 19947777
- Bug 22477834
- Relinking the DB Control 11.2.0.3 Agent Displays a Warning Message "overriding commands for target 'nmosudo'" (Doc ID 1562458.1)

Creation of DB_LINK working without a tnsnames.ora file

Connect descriptor from a tnsnames.ora

DBOTST1 =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = s-msk-t-dbo-db1 )(PORT = 1521))
    )
    (CONNECT_DATA = (SERVER = DEDICATED)(SERVICE_NAME = DBOTST1_S_MSK_T_DBO_DB1))
  )
  
Create link DB_LINK from the descriptor above ( //host:port/service_name или [//]host[:port][/service_name][:server][/instance_name] ):

create public DATABASE LINK DBOTST2 CONNECT TO "ATM" IDENTIFIED BY "ATM_to_testCMS120056" USING '//s-msk-t-dbo-db1:1521/DBOTST1_S_MSK_T_DBO_DB1';

or

DROP PUBLIC DATABASE LINK "WEBDB_A.RAIFFEISEN.RU";

CREATE PUBLIC DATABASE LINK "WEBDB_A.RAIFFEISEN.RU"
 CONNECT TO PROXY3DS
 IDENTIFIED BY "Passw0rd"
 USING '(DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.102.194)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = WEBDB)
    )
  )';

Show current time in a sqlplus

set time on

Backup status

select
SESSION_KEY, INPUT_TYPE, STATUS,
to_char(START_TIME,'mm/dd/yy hh24:mi') start_time,
to_char(END_TIME,'mm/dd/yy hh24:mi') end_time,
round((end_time-start_time)*1440,2) "Minutes"
from V$RMAN_BACKUP_JOB_DETAILS
order by session_key desc;

Last successfull physical backup

select to_char(max(END_TIME),'dd/mm/yy hh24:mi') LAST_BACKUP from V$RMAN_BACKUP_JOB_DETAILS where INPUT_TYPE = 'DB FULL' and STATUS IN ('COMPLETED',;

Run sqlplus query from bash (pick 14 row from the result and compare it with a text)

db_status=`echo 'select DATABASE_ROLE from v$database;' | sqlplus / as sysdba | awk '(NR == 14)'`

if [ ${db_status} == PRIMARY ]

 then echo "copy"
 else echo "not copy"
 
Select from RDBMS dictionary in bash
 
echo -e set heading off \\n set feedback off \\n set termout off \\n set trimspool on \\n "select to_char(max(END_TIME),'dd/mm/yy hh24:mi') from V\$RMAN_BACKUP_JOB_DETAILS" \\n " where INPUT_TYPE = 'DB FULL' and STATUS IN ('COMPLETED','COMPLETED WITH WARNINGS');" | sqlplus / as sysdba | awk '(NR == 12)'

Turn off sqlplus output in the UNIX terminal (only ERROR messages will be outputed!):

sqlplus -S / as sysdba << SQL | grep -E "^ORA-|^ERROR"

<enter any sqlplus commands here>

SQL

or

sqlplus -S / as sysdba
<enter any sqlplus commands here>

Select from views in sqlplus in silent mode

table='V$RMAN_BACKUP_JOB_DETAILS'
last_backup=`echo "select to_char(max(END_TIME),'dd/mm/yy hh24:mi') from $table where INPUT_TYPE = 'DB FULL' and STATUS IN ('COMPLETED','COMPLETED WITH WARNINGS');" | sqlplus -S sys/spotlight@$ORACLE_SID as sysdba | awk '(NR == 4)'`

echo -e set heading off trimspool off termout off feedback off \\n "select to_char(max(END_TIME),'dd/mm/yy hh24:mi') from V\$RMAN_BACKUP_JOB_DETAILS where INPUT_TYPE = 'DB FULL' and STATUS IN ('COMPLETED','COMPLETED WITH WARNINGS');" | sqlplus -S / as sysdba

Change symbols in a file (change latest :Y with :N, except rows containing #)

sed -n '/#/!s/:Y/:N/g' /etc/oratab

Find rows (in awk) and symbols (in cut) with the given numbers:

awk 'NR == 58' | cut -c21-

Output only a result of a sql query from sqlplus (views with $ should be used with \ symbol before $):

echo -e set heading off trimspool off termout off feedback off \\n "select to_char(max(END_TIME),'dd/mm/yy hh24:mi') from V\$RMAN_BACKUP_JOB_DETAILS where INPUT_TYPE = 'DB FULL' and STATUS IN ('COMPLETED','COMPLETED WITH WARNINGS');" | sqlplus -S / as sysdba | tail -n-1

Max archivelog number monitoring:

#!/bin/bash

export ORACLE_SID=`env | grep ORACLE_SID | cut -c12-`
export ORACLE_HOME=`env | grep ORACLE_HOME | cut -c13-`
export PATH=$PATH:$HOME/bin:$ORACLE_HOME/bin
CURRENT_HOSTNAME=`uname -n`
sqlstring='select SEQUENCE# from V$LOG_HISTORY where SEQUENCE# = (SELECT MAX(SEQUENCE#) FROM V$LOG_HISTORY);'
max_archlog=`echo $sqlstring | sqlplus -S / as sysdba | tail -n-2 | head -n+1`

echo `uname -n` max_achlog
echo $max_archlog
echo `date`

zabbix_sender -z 10.243.12.20 -s "${CURRENT_HOSTNAME}" -k max_archlog -o "${max_archlog}"

Turn the dg_broker OFF

alter system set dg_broker_start=FALSE scope =BOTH;

Set environment variables in crontab

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
#!/bin/bash
. $HOME/.bash_profile

Turn on session tracing (trace files will be placed in DIAGNOSTIC_DEST or USER_DUMP_DEST)

ALTER SESSION SET SQL_TRACE=TRUE;

Run sql script from bash shell:

echo -e set heading off feedback off termout off trimspool on \\n'text2' \\n'text3'

echo -e set heading off feedback off termout off trimspool on \\n"select value from v\$parameter where name = 'db_unique_name';" | sqlplus -S / as sysdba

See alertlog

echo "select value from v\$parameter where name = 'background_dump_dest';" | sqlplus -S / as sysdba | tail -n-2 | head -n+1 | tail -f alert_*

echo "select value from v\$parameter where name = 'background_dump_dest';" | sqlplus -S / as sysdba | tail -n-2 | head -n+1 | tail -f alert_* | grep ORA

using select from a database:
    
  SELECT AE.*
    FROM V$DIAG_ALERT_EXT AE
   WHERE     AE.COMPONENT_ID LIKE '%rdbms%'
         AND AE.ORIGINATING_TIMESTAMP BETWEEN TO_DATE ('29.08.2018 6:44:45',
                                                       'DD.MM.YYYY HH24:MI:SS')
                                          AND TO_DATE ('29.08.2018 6:59:45',
                                                       'DD.MM.YYYY HH24:MI:SS')
ORDER BY 1;

--example of rman periodical restore (and recover) checking script:

rman target sys/$db_pass <<!
SELECT CAST(TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS') AS VARCHAR2(30)) AS CROSSCHECK_STEP_1 FROM DUAL;
CROSSCHECK BACKUP;
REPORT OBSOLETE;
LIST EXPIRED BACKUP;
SELECT CAST(TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS') AS VARCHAR2(30)) AS DELETE_STEP_2 FROM DUAL;
DELETE NOPROMPT OBSOLETE;
DELETE NOPROMPT EXPIRED BACKUP;
DELETE NOPROMPT ARCHIVELOG ALL BACKED UP 1 TIMES TO 'SBT_TAPE';
DELETE NOPROMPT BACKUP OF ARCHIVELOG UNTIL TIME 'SYSDATE-5';
DELETE NOPROMPT ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-5';
DELETE NOPROMPT BACKUP OF CONTROLFILE COMPLETED BEFORE 'SYSDATE-7';
SELECT CAST(TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS') AS VARCHAR2(30)) AS RESTORE_STEP_3 FROM DUAL;
# see SR 3-15869076511, Doc ID 1554636.1, the restore preview will list all backups required for the entire restore and recovery operation
RESTORE DATABASE PREVIEW;
SELECT CAST(TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS') AS VARCHAR2(30)) AS SUMMARY_STEP_4 FROM DUAL;
LIST BACKUP SUMMARY;
exit
!


Set Rman backup pieces size and location:

CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/mnt/data1/backup/%Y%M%D/BACKUP_%Y%M%D_%s_%U.BCK' MAXPIECESIZE 4 G;

Disks monitoring

mount (show mounted points)
cat /etc/fstab - show disks for mount at system startup
nmon - d (compare current and maximum i/o speed)
hdparm -tT /dev/mapper/vg_data2-data2 (where /dev/mapper/vg_data2-data2 - disk/device for check)
look at "Timing buffered disk reads:"

Parameters
Setup ONLY ONE from it (rest must be 0 !)
log_checkpoint_interval - do a checkpoint using redo logs filling (in OS blocks, for UNIX block usualy = 512 bytes)
depends from a online log size (for checkpointing 2 times per log it should be (log size in bytes)/512/2
checkpoint frequency depends from a intensity of writes in a redo logs
log_checkpoint_timeout - perform a checkpoint using timeout (every n second)
FAST_START_MTTR_TARGET - required recovery time after a instance crash (in seconds) - checkpoint frequency will be choosed automatically according to that parameter
SETUP archive_lag_target=0 to avoid the error in RDBMS up to 10.2.0.5 (including 10.2.0.5)

Rus several sql commands from shell

#!/bin/bash

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

sqlplus / as sysdba <<!
set linesize 200
set pagesize 1000

spool startup_standby.log

prompt *** start standby database ***

STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

prompt *** db_info ***

SELECT MAX(SEQUENCE#),thread# FROM V$LOG_HISTORY group by thread#;

select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;

column DESTINATION format a40
SELECT DESTINATION, STATUS, ARCHIVED_THREAD#, ARCHIVED_SEQ# FROM V$ARCHIVE_DEST_STATUS
 WHERE STATUS <> 'DEFERRED' AND STATUS <> 'INACTIVE';
 
select to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') "DATE" from dual;

spool off
exit;
!

echo "----------------------------------------"
echo "***** Hostname " `hostname` "******"
echo "***** Date " `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "----------------------------------------"

exit

Execute shitchover when using PHYSICAL STANDBY

[oracle@s-msk00-ultra-lb SWITCHOVER]$ cat switchover.sh

#!/bin/bash

. $HOME/.bash_profile
. $HOME/.bashrc

#set variables

test_run='PROMPT' #!!!comment this variable for perform real switchover at the primary-standby pair

sys_pwd='trjvthc'
cut_host=5  #this variable depends from tnsnames.ora file records
#cut_host=6
#server_admins="iruacii2@raiffeisen.ru,iruagov3@raiffeisen.ru,iruafaa1@raiffeisen.ru,iruakgd5@raiffeisen.ru"
server_admins="iruacii2@raiffeisen.ru,irualys2@raiffeisen.ru,iruakgv8@raiffeisen.ru,iruatza7@raiffeisen.ru"

#set constants (the same for all servers)

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
#switchover_status='NOT ALLOWED'
#db_status='PRIMARY'
#max_archlog_remote=221870

#script body

if [ "$test_run" == "PROMPT" ]
 then echo -e run script only in test mode
 else echo -e attention! run script in work mode!
fi

echo -e current host is \\n `uname -n`
echo -e current time is \\n `date`
echo -e test run variable = \\n $test_run
echo -e current host db status is \\n $db_status
echo -e current host switchover status is \\n $switchover_status
echo -e current host maximum archivelog number is \\n $max_archlog_current
echo -e sqlplus logs will be written to \\n $log_dir
echo -e remote instance name is \\n $remote_instance
echo -e remote host is \\n $remote_host
echo -e remote host maximum archivelog number is \\n $max_archlog_remote

if [[ `echo $db_status` == PRIMARY ]]; then
  if [[ `echo $switchover_status` == 'SESSIONS ACTIVE' || `echo $switchover_status` == 'TO STANDBY' ]];then
   if [[ $[$max_archlog_current-$max_archlog_remote] == 0 ]];then
  echo perform switchover on primary database to standby role at host `uname -n`
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
  $test_run ALTER SYSTEM ARCHIVE LOG CURRENT;
  $test_run ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;
  $test_run SHUTDOWN IMMEDIATE;
  connect / as sysdba;
  $test_run STARTUP NOMOUNT;
  $test_run ALTER DATABASE MOUNT STANDBY DATABASE;
  $test_run ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT;
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
  echo perform switchover on standby database with unique name $remote_instance to primary role at host $remote_host
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
  $test_run ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;
  $test_run SHUTDOWN IMMEDIATE;
  $test_run STARTUP MOUNT;
  $test_run ALTER DATABASE OPEN;
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
  echo !!!run the following commands as `whoami` user on the server $remote_host
  vim sta	
   else
    echo log difference beetween primary and standby = $[$max_archlog_current-$max_archlog_remote] : switchower is not possible now!
   fi
  else
   echo data transfer beetween databases is not complete: switchower is not possible now!
  fi
else
echo current host DB status is $db_status for switchower run file $log_dir/switch.sh on the host $remote_host
fi

exit

  
Check on commit waits caused by writing in online logs

#!/bin/bash

. $HOME/.bash_profile
. $HOME/.bashrc

#set constants (the same for all servers)

logs_dir='/var/logs/oracle'

wait_event=`sqlplus -S / as sysdba <<!
set heading off feedback off termout off trimspool on

set pagesize 1000
set linesize 200

column minute format A10
column event  format A15
column WAITS  format 999,999,999

select to_char(sample_time,'Mondd_hh24mi') minute, event,
round(sum(time_waited)/1000) TOTAL_WAIT_TIME , count(*) WAITS,
round(avg(time_waited)/1000) AVG_TIME_WAITED
from v\\$active_session_history
where event = 'log file sync'
group by to_char(sample_time,'Mondd_hh24mi'), event
having avg(time_waited)/1000 > 100 and sum(time_waited)/1000 > 100
order by 1,2
/
!`

last_wait_event=`tail -n-1 $logs_dir/logfile_wait.log`

echo -e last_wait_event = \\n $last_wait_event
echo
echo -e wait_event = \\n $wait_event


if [[ `echo $wait_event | tail -n-1` == `echo $last_wait_event` ]]; then
 echo "last wait event didn't change during last 2 mins"
 else $wait_event > $logs_dir/logfile_wait.log
fi

exit

Select data from ONLY one partition (see part. name):

select * from CURR.TRADELOG_BASE partition (ORDLOG_102015_PART);

Import in 11g as sysdba

imp userid="'/ as SYSDBA'" file=/mnt/oracle/backup/dump/other_dumps/atmmonitor/EXP_atmmonitor_CL2010.dmp LOG=/usr/local/bin/scripts/create_db/import/imp_atmmonitor_CL2010.log ignore=y fromuser=atmmonitor touser=atmmonitor

See current status of a export/import jobs executing (dpump), those jobs may be also controlled via it (imp_VSMC3DS_test - JOB_NAME):

impdp system/ultrasystem attach=imp_VSMC3DS_test

Import> status

Unload datapump dumps into sql file:

impdp / sqlfile=test.sql

Waits because of logs switches (logs were archived at the same disk):

[oracle@s-msk08-atmdb01 /usr/local/bin/scripts/logfile_wait]$ cat logfile_wait.sh
#!/bin/bash

. $HOME/.bash_profile
. $HOME/.bashrc

#set constants (the same for all servers)

CURRENT_HOSTNAME=`uname -n`

logs_dir='/var/logs/oracle'

zabbix_server='10.243.12.20'

echo `date '+%a %d.%m.%Y-%H:%M:%S'` > $logs_dir/logfile_wait.log

sqlplus -S / as sysdba <<!
set heading off feedback off termout off trimspool on serveroutput off

set pagesize 1000
set linesize 200

column minute format A10
column event  format A15
column WAITS  format 999,999,999

spool $logs_dir/logfile_wait.log
select to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') "DATE" from dual;
  SELECT COUNT (COUNT (session_id)) waits,
         ROUND (SUM ( (SUM (time_waited) / 1000000))) total_wait_time,
         ROUND (((SUM ( (SUM (time_waited) / 1000000))) / COUNT (COUNT (session_id))),2) avg_time_waited
from v\$active_session_history
where event = 'log file sync' AND sample_time >= (SYSDATE - 1 / 1440)
GROUP BY session_id
/
spool off
!

wait_event=`tail -n-1 $logs_dir/logfile_wait.log`

waits=`echo $wait_event | cut -f1 -d' '`
total_wait_time=`echo $wait_event | cut -f2 -d' '`
avg_time_waited=`echo $wait_event | cut -f3 -d' '`

echo
echo -e wait_event = \\n $wait_event
echo
echo -e total_wait_time = \\n $total_wait_time
echo
echo -e waits = \\n $waits
echo
echo -e avg_time_waited = \\n $avg_time_waited

zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k total_wait_time -o "${total_wait_time}"

zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k waits -o "${waits}"

zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k avg_time_waited -o "${avg_time_waited}"

exit

HEX to VARCHAR2 conversion ( ASCII )

HEX string '41544D47524F555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'

SELECT UTL_RAW.cast_to_varchar2 (
          HEXTORAW (
             '41544D47524F555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'))
          AS res
  FROM DUAL


For ignoring an ampersand (&) in sqlplus:

set define off

Turn OFF/ON pl/sql procedures output:

in sqlplus

SET TERMOUT ON
SET SERVEROUTPUT ON

in begin end;/ block

dbms_output.enable;

Count rows from several tables in a cycle:

SET TERMOUT ON
SET SERVEROUTPUT ON

/* Formatted on 03.12.2013 13:03:06 (QP5 v5.163.1008.3004) */
DECLARE
   current_month   VARCHAR2 (9);
   count_var       NUMBER;
   sqlst           VARCHAR2 (500);
BEGIN
   DBMS_OUTPUT.enable;

   SELECT TO_CHAR (ADD_MONTHS (SYSDATE, -4), 'YYYYMM')
     INTO current_month
     FROM DUAL;

   DBMS_OUTPUT.put_line ('current_month = ' || current_month);

   FOR rec
      IN (SELECT DISTINCT
                 'select count(1) from ' || owner || '.' || table_name AS cmd
            FROM dba_tables
           WHERE     owner IN ('ROUTER', 'ATMMONITOR')
                 AND table_name LIKE '%20%'
                 AND SUBSTR (table_name, 3, 6) = current_month)
   LOOP
      DBMS_OUTPUT.put_line ('execute statement ' || rec.cmd);

      EXECUTE IMMEDIATE rec.cmd INTO count_var;

      DBMS_OUTPUT.put_line ('total rows ' || count_var);
   END LOOP;
END;
/


For avoid additioanl caching when writing into online logs setup the following parameter (and restart an instance)

filesystemio_options=SETALL


Backup 10g

#!/bin/bash

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

#server_admins="iruacii2@raiffeisen.ru,irualys2@raiffeisen.ru,iruakgv8@raiffeisen.ru,iruatza7@raiffeisen.ru"
server_admins="iruacii2@raiffeisen.ru,iruagov3@raiffeisen.ru,iruafaa1@raiffeisen.ru,iruamaah@raiffeisen.ru,iruakgd5@raiffeisen.ru"
BACKUP_PATH="/mnt/data_fc/backup"
subject='oracle backup probably failed'
message='last successful backup was'
db_status_file_dir="/mnt/data_p400/remote_backup"
table='V$RMAN_BACKUP_JOB_DETAILS'
db_status=`echo 'select DATABASE_ROLE from v$database;' | sqlplus -S / as sysdba | tail -n-2 | head -n+1`
last_backup=`echo "select to_char(max(END_TIME),'dd/mm/yy hh24:mi') from $table where INPUT_TYPE = 'DB FULL' and STATUS IN ('COMPLETED','COMPLETED WITH WARNINGS');" | sqlplus -S / as sysdba | tail -n-2 | head -n+1`

echo "-----------------------------------------"
echo "***** Begin" `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "-----------------------------------------"

name=`date +%Y%m%d`

#0)check db_status

echo "current db status is" $db_status
echo "last successful backup" ${last_backup}

rm -f ${db_status_file_dir}/db_status

echo ${db_status} > ${db_status_file_dir}/db_status

#1)backup

cd ${BACKUP_PATH}
mkdir ${name}

if [[ `echo $db_status` == PRIMARY ]]; then
rman target / log=${BACKUP_PATH}/${name}/backup.log<<!
RUN
{
 BACKUP AS COMPRESSED BACKUPSET DATABASE PLUS ARCHIVELOG NOT BACKED UP 1 TIMES DELETE ALL INPUT SKIP INACCESSIBLE;
 DELETE FORCE NOPROMPT OBSOLETE;
 CROSSCHECK BACKUP;
 SQL "ALTER SYSTEM ARCHIVE LOG CURRENT";
 sql "alter database backup controlfile to trace as ''${BACKUP_PATH}/${name}/control_norstlogs_${name}.sql'' reuse noresetlogs";
 sql "alter database backup controlfile to trace as ''${BACKUP_PATH}/${name}/control_rstlogs_${name}.sql'' reuse resetlogs";
}
EXIT;
!
else
rman target / log=${BACKUP_PATH}/${name}/backup.log<<!
RUN
{
 BACKUP AS COMPRESSED BACKUPSET DATABASE PLUS ARCHIVELOG NOT BACKED UP 1 TIMES DELETE ALL INPUT SKIP INACCESSIBLE;
 DELETE FORCE NOPROMPT OBSOLETE;
 CROSSCHECK BACKUP;
 sql "alter database backup controlfile to trace as ''${BACKUP_PATH}/${name}/control_norstlogs_${name}.sql'' reuse noresetlogs";
 sql "alter database backup controlfile to trace as ''${BACKUP_PATH}/${name}/control_rstlogs_${name}.sql'' reuse resetlogs";
}
EXIT;
!
fi

echo "Done!" `date '+%a %d.%m.%Y-%H:%M:%S'`

#2)Check backup

tail -n 40 ${BACKUP_PATH}/${name}/backup.log | grep "objects"
   if [ $? -eq 0 ]
                then
echo "backup correct"

                else
                mailx -s "`uname -n`: $subject" $server_admins <<!
$message $last_backup. current db status is $db_status
!

     fi

cp -f ${BACKUP_PATH}/${name}/backup.log ${BACKUP_PATH}

echo "----------------------------------------"
echo "***** End  " `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "----------------------------------------"


Rman settings configure in controlfile from sqlplus:

-- Configure snapshot controlfile filename
EXECUTE SYS.DBMS_BACKUP_RESTORE.CFILESETSNAPSHOTNAME('/mnt/data/oracle/backup/CONTRL.SNP');
-- Configure RMAN configuration record 1
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('DEVICE TYPE','DISK PARALLELISM 8 BACKUP TYPE TO COMPRESSED BACKUPSET');
-- Configure RMAN configuration record 2
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('CONTROLFILE AUTOBACKUP','ON');
-- Configure RMAN configuration record 3
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('CHANNEL','DEVICE TYPE DISK FORMAT   ''/mnt/data_fc/backup/%Y%M%D/BACKUP_%Y%M%D_%U.BCK'' MAXPIECESIZE 4 G');
-- Configure RMAN configuration record 4
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE','DISK TO ''/mnt/data_fc/backup/%Y%M%D/CTL_AUTO_%F.BCK''');
-- Configure RMAN configuration record 5
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('RETENTION POLICY','TO RECOVERY WINDOW OF 1 DAYS');

Total and current users connections in DB:

SELECT NAME, VALUE FROM v$sysstat WHERE NAME LIKE '%logon%';

Show current user in sqlplus

select lower(sys_context('USERENV','SESSION_USER')) from dual;

-- session info (DB, SID, service, AD user, software, DB host)

set linesize 250 pagesize 10000
col DB_SERVER for a15
col DATABASE_ROLE for a15
col SERVICE for a10
col DB_USER for a10
col SID for a10
col CLIENT_HOST for a20
col OS_USER for a20
col CLIENT_SOFT for a30
col AD_USER for a15
col AUTH for a10
col IDENTIFICATION for a15

SELECT SYS_CONTEXT('USERENV', 'SERVER_HOST') DB_SERVER,
  SYS_CONTEXT('USERENV', 'DATABASE_ROLE') DATABASE_ROLE,
  SYS_CONTEXT('USERENV', 'SERVICE_NAME') SERVICE,
  SYS_CONTEXT('USERENV', 'CURRENT_USER') DB_USER,
  SYS_CONTEXT('USERENV', 'SID') SID,
  SYS_CONTEXT('USERENV', 'HOST') CLIENT_HOST,
  sys_context('USERENV', 'OS_USER') OS_USER,
  SYS_CONTEXT('USERENV', 'MODULE') CLIENT_SOFT,
  SYS_CONTEXT('USERENV', 'ENTERPRISE_IDENTITY') AD_USER,
  SYS_CONTEXT('USERENV', 'AUTHENTICATION_METHOD') AUTH,
  SYS_CONTEXT('USERENV', 'IDENTIFICATION_TYPE') IDENTIFICATION
FROM dual;

stop dataPUMP job immediately

[Ctrl-c]
Export> KILL_JOB
..or..
Export> STOP_JOB=IMMEDIATE
Are you sure you wish to stop this job ([yes]/no): yes

Delete DB

rman target /

SHUTDOWN IMMEDIATE;
STARTUP FORCE MOUNT;
SQL 'ALTER SYSTEM ENABLE RESTRICTED SESSION';
DROP DATABASE INCLUDING BACKUPS NOPROMPT;

Move controlfiles

sho parameter control_files
alter system set control_files='/u01/oradata/dbfiles/ULTRADB/control01.ctl','/u01/oradata/fast_recovery_area/ULTRADB/control02.ctl','/u01/oradata/fast_recovery_area/ULTRADB/control03.ctl' scope=spfile;
shutdown immediate;
host cp /u01/oradata/fast_recovery_area/ULTRADB/control02.ctl /u01/oradata/fast_recovery_area/ULTRADB/control03.ctl
startup;
sho parameter control_files

Delete rows from a table in cycle (commit every 100 rows)

/* Formatted on 06.02.2014 13:54:03 (QP5 v5.163.1008.3004) */
DECLARE
   max_id      NUMBER;
   v_counter   NUMBER := 0;
BEGIN
   SELECT MAX (ID)
     INTO max_id
     FROM DDDSPROC_TRANSACT_INFO_ARC
    WHERE TRUNC (TRANSDATE) < TRUNC (ADD_MONTHS (SYSDATE, -24));

   FOR i IN 1 .. ROUND (max_id / 100) + 1
   LOOP
      DELETE FROM DDDSPROC_TRANSACT_INFO_ARC
            WHERE ID < max_id AND ROWNUM < 100;
      v_counter := v_counter + SQL%ROWCOUNT;
      COMMIT;
   END LOOP;

   DBMS_OUTPUT.put_line (v_counter || ' rows deleted');
END;

Each row variant:

BEGIN
   FOR Rec_T IN (SELECT ID, ROWNUM
                   FROM DDDSPROC_TRANSACT_INFO_ARC
                  WHERE ID < (select max(ID) from DDDSPROC_TRANSACT_INFO_ARC where TRUNC(TRANSDATE) < TRUNC(ADD_MONTHS(SYSDATE, -24))))
   LOOP
      DELETE FROM DDDSPROC_TRANSACT_INFO_ARC;
      IF MOD (Rec_T.ROWNUM, 100) = 0
      THEN
         COMMIT;
      END IF;
   END LOOP;
END;

Gather table stats:

EXEC DBMS_STATS.GATHER_TABLE_STATS ('tctdbs', 'AUTHORIZATIONS');

Gather histograms (for given columns):

EXEC DBMS_STATS.GATHER_TABLE_STATS(ownname=>'TCTDBS', tabname=>'ACQUIRERLOG', METHOD_OPT=>'FOR COLUMNS SIZE AUTO EDCFLAG EDCSERNO I041_POS_ID');

To simulate Oracle Database 11g behavior, which is necessary to create a height-based histogram, set estimate_percent to a nondefault value. If you specify a nondefault percentage, then the database creates frequency or height-balanced histograms.
For example, enter the following command:

--height-balanced

BEGIN  DBMS_STATS.GATHER_TABLE_STATS ( 
    ownname          => 'SH'
,   tabname          => 'COUNTRIES'
,   method_opt       => 'FOR COLUMNS COUNTRY_SUBREGION_ID SIZE 254' --for frequency less values
,   estimate_percent => 100 
);
END;

Gather partition stats:

EXEC DBMS_STATS.GATHER_TABLE_STATS ('CBMIRROR','TRADES_BASE', 'EQ_TRADES_BASE_P_20160727', GRANULARITY => 'PARTITION'); 

Lock partition stats:

EXEC DBMS_STATS.LOCK_PARTITION_STATS(ownname=>'CBMIRROR',tabname=>'TRADES_BASE',partname=>'EQ_TRADES_BASE_P_20051107');

delete (given) hystograms:

EXEC DBMS_STATS.delete_column_stats(ownname=>'TCTDBS', tabname=>'ACQUIRERLOG', COLNAME=>'EDCFLAG');
EXEC DBMS_STATS.delete_column_stats(ownname=>'TCTDBS', tabname=>'ACQUIRERLOG', COLNAME=>'I039_RESP_CD');
--EXEC DBMS_STATS.delete_column_stats(ownname=>'TCTDBS', tabname=>'ACQUIRERLOG', COLNAME=>'I041_POS_ID');

Incremental statistics gathering (on partitioned table after ETL):

begin

-- set table preferences

DBMS_STATS.SET_TABLE_PREFS
(
OWNNAME => 'TCTDBS',
TABNAME => 'ACQUIRERLOG',
PNAME   => 'INCREMENTAL',
PVALUE  => 'TRUE'
);
DBMS_STATS.SET_TABLE_PREFS
(
OWNNAME => 'TCTDBS',
TABNAME => 'ACQUIRERLOG',
PNAME   => 'PUBLISH',
PVALUE  => 'TRUE'
);

-- incremental statistics gathering

SYS.DBMS_STATS.GATHER_TABLE_STATS
(
OWNNAME          => 'TCTDBS',
TABNAME          => 'ACQUIRERLOG',
ESTIMATE_PERCENT => DBMS_STATS.AUTO_SAMPLE_SIZE,
METHOD_OPT       => 'FOR ALL COLUMNS SIZE AUTO',
DEGREE           => DBMS_STATS.AUTO_DEGREE,
GRANULARITY      => 'AUTO',
CASCADE          => DBMS_STATS.AUTO_CASCADE,
NO_INVALIDATE    =>DBMS_STATS.AUTO_INVALIDATE
);
end;

--Incremental statistics gathering
 
 http://www.toadworld.com/platforms/oracle/w/wiki/11434.sophisticated-incremental-statistics-gathering-feature-in-12c
 
  -- Turn off Automatic Dynamic Sampling during Adaptive Query Optimization (Doc ID 2002108.1)
 
execute immediate 'alter session set optimizer_dynamic_sampling=0';
Disable for all tables:
select /*+ dynamic_sampling(0) */ ...
Disable for a specific table:
SELECT /*+ dynamic_sampling(<tab/alias name> 0) */
 
  -- Gather stale statistics for the given schema
 
set timing on
EXEC DBMS_STATS.GATHER_SCHEMA_STATS(OWNNAME => 'BL',ESTIMATE_PERCENT => DBMS_STATS.AUTO_SAMPLE_SIZE,METHOD_OPT => 'FOR ALL COLUMNS SIZE REPEAT',GRANULARITY => 'AUTO',DEGREE => 8,CASCADE => TRUE,OPTIONS => 'GATHER STALE',NO_INVALIDATE => FALSE);

-- Setup GRANULARITY parameter for a table with incremental statistics:

exec DBMS_STATS.SET_TABLE_PREFS('CURR','ORDERS_BASE','GRANULARITY','APPROX_GLOBAL AND PARTITION');

-- FInd stale objects (in terms of statistics)

DECLARE
   MYSTALEOBJS   DBMS_STATS.OBJECTTAB;
BEGIN
   -- check whether there is any stale objects
   DBMS_STATS.GATHER_SCHEMA_STATS (OWNNAME   => 'FORTS_CLEARING',
                                   OPTIONS   => 'LIST STALE',
                                   OBJLIST   => MYSTALEOBJS);

   FOR I IN 1 .. MYSTALEOBJS.COUNT
   LOOP
      IF MYSTALEOBJS (I).OBJNAME NOT LIKE '%\_LM' ESCAPE '\'
      THEN
         DBMS_OUTPUT.PUT_LINE ('object:' || MYSTALEOBJS (I).OBJNAME);
         DBMS_OUTPUT.PUT_LINE ('partition:' || MYSTALEOBJS (I).PARTNAME);
      ELSE
         NULL;
      END IF;
   END LOOP;
END;
/


-- See stale columns data for schema (may be added into manual statistics gathering script after)

  SELECT *
    FROM DBA_TAB_STATISTICS
   WHERE OWNER LIKE 'SPUR_DAY%' AND STALE_STATS <> 'NO'
ORDER BY OWNER,PARTITION_NAME;

See hystograms:

select column_name,histogram from user_tab_columns;

SELECT column_name, histogram
    FROM user_tab_columns
   WHERE TABLE_NAME = 'ACQUIRERLOG' AND histogram <> 'NONE'
ORDER BY 2, 1;

See the report of statistics gathering in HTML format:

--For procedures over period

SET LINES 200 PAGES 0
SET LONG 100000
COLUMN REPORT FORMAT A200
VARIABLE my_report CLOB;

BEGIN
  :my_report := DBMS_STATS.REPORT_STATS_OPERATIONS (
     since        => SYSDATE-1
,    until        => SYSDATE 
,    detail_level => 'TYPICAL' 
,    format       => 'HTML'      
);
END;
/

print my_report

-- for ONE procedure (OPID could be taken from the list above)

SET LINES 200 PAGES 0
SET LONG 100000
COLUMN REPORT FORMAT A200
VARIABLE my_report CLOB;

BEGIN
  :my_report :=DBMS_STATS.REPORT_SINGLE_STATS_OPERATION (
     OPID    => 23474
,    FORMAT  => 'HTML'
);
END;

print my_report

Hint for setting cardinality (number of rows returned by the query block):

/*+ CARDINALITY (qb_alias, 10) */


Add hint for using the index emp_department_ix on employees table:

SELECT /*+ INDEX (employees emp_department_ix)*/ employee_id, department_id FROM employees WHERE department_id > 50;

Add paralles execution + index hints

SELECT /*+ PARALLEL INDEX(AUTHORIZATIONS LTIMESTAMP_I) */

Add hint for using several indexes (optimizer will be choose which one) on AUTHORIZATIONS table

 /*+ INDEX_COMBINE (AUTHORIZATIONS) */


Hint using example for indexed columns of a select block (INDEX_RS_DESC):
 
UPDATE /*+ INDEX_RS_DESC(@"SEL$DA9F4B51" "TRADES_BASE"@"SEL$1" ("TRADES_BASE"."TRADENO" "TRADES_BASE"."BUYSELL")) */ trades SET Status = :Status, ReportNo = :ReportNo, Confirmed = :Confirmed, ConfirmReport = :ConfirmReport, ConfirmTime = :ConfirmTime, ClearingType = :ClearingType, CompVal = :CompVal, SettleTime = :SettleTime, AmendDate = :AmendDate, ClearingTime = :ClearingTime, PenaltyValue = :PenaltyValue, ClearingFirmID = :ClearingFirmID, ClearingBankAccID = :ClearingBankAccID WHERE TradeNo = :TradeNo AND BuySell = :BuySell;
 
Add hint with session parameter settings (including hidden parameters):
 
Set OPTIMIZER_FEATURES_ENABLE = '11.2.0.4' in init.ora or as hint to SQL ie /*+ OPTIMIZER_FEATURES_ENABLE('11.2.0.4') */
Set _OPTIMIZER_UNNEST_SCALAR_SQ = FALSE in init.ora or as hint to SQL ie /*+ OPT_PARAM('_OPTIMIZER_UNNEST_SCALAR_SQ' 'FALSE') */
ALTER SESSION SET OPTIMIZER_USE_INVISIBLE_INDEXES=TRUE;

--possible vaues for OPTIMIZER_FEATURES_ENABLE: 11.2.0.4, 11.2.0.1, 10.2.0.4, 9.2.0

Turn BLOOM filter off

/*+ OPT_PARAM('_bloom_filter_enabled' 'FALSE') */

Turn INMEMORY OFF at the query level

/*+ opt_param('inmemory_query' 'disable') */

Turn fix for the given bug on in hint:

/*+ OPT_PARAM('_fix_control' '16391176:1') */
for several fixes:
SELECT /*+ OPT_PARAM('_fix_control' '6377505:OFF 6006300:OFF') */ *

with alter session/system:

ALTER SESSION SET "_fix_control"='6377505:0';
ALTER system SET "_fix_control"='31310771:1','20636003:0';

check this:

select bugno, value ,sql_feature, description from v$session_fix_control 
      where bugno in (31310771,20636003);
select bugno, value ,sql_feature, description from v$system_fix_control 
      where bugno in (31310771,20636003);

-- list of bugfixes (inly form sys in 12.1):

execute dbms_optim_bundle.getBugsforBundle('201020');

--check how to add in pfile:

exec dbms_optim_bundle.enable_optim_fixes('ON', 'INITORA');

https://oracle-base.com/articles/misc/granular-control-of-optimizer-features-using-fix-control

Turn Automatic Dynamic Sampling OFF (reliable)

/*+ OPT_PARAM('optimizer_dynamic_sampling' 0) */ or alter session set OPTIMIZER_DYNAMIC_SAMPLING=0;

Parallel index rebuilding in nologging mode:

alter index test_idx rebuild nologging parallel 4;

For Exadata:
After setup a session parameter
alter session set "_serial_direct_read" = TRUE; (see https://blog.tanelpoder.com/2013/05/29/forcing-smart-scans-on-exadata-is-_serial_direct_read-parameter-safe-to-use-in-production)
and adding hints for avoid indexes usage:
  /*+
      BEGIN_OUTLINE_DATA
      OUTLINE_LEAF(@"SEL$2")
      OUTLINE_LEAF(@"SEL$3")
      FULL("ORDERS_BASE"@"SEL$2")
      FULL("ORDERS"@"SEL$3")
      END_OUTLINE_DATA
  */

Will be full table scan and SMART SCAN will be in use:

Changing parameter OPTIMIZER_INDEX_COST_ADJ in a session will not lead to a significant performance improvement
indexes will be still used in plans even when OPTIMIZER_INDEX_COST_ADJ=1000 (1000 is tha maximum)

Parallel FULL SCAN execution

SELECT
        /*+ PARALLEL(A) FULL(A) */
        SOURCE                                  ,
        I002_NUMBER                             ,
        I004_AMT_TRXN                           ,
        I049_CUR_TRXN                           ,
FROM    AUTHORIZATIONS A

Hint for execute the given part of a query first:

/*+ QB_NAME(subq1) */

/*+ LEADING(b t a i v) NO_UNNEST(@subq1) index(v CARDXUI01)  FULL(t) PARALLEL(t) */

Hint for select from subselect with the given number (example):

/*+
OUTLINE_LEAF(@"SEL$5")
NO_INDEX("ORDERS_BASE"@"SEL$5" ) */
SEL$5 - It is select with number 5 where ORDERS_BASE table used numbering is taking into account all the selections in the nested representations

-- Select sql at a remote DB first (aa), transfer its results to a local DB thereafter

SELECT DECODE (COUNT (*), 0, 0, 1)
  FROM (SELECT /*+ NO_QUERY_TRANSFORMATION DRIVING_SITE(aa) */
              *
          FROM FUTDEAL_BASE@CBMIRROR_PUB AA,
               (SELECT FORTS_JAVA.GET_SESS_ID (TRUNC (SYSDATE - 1)) B
                  FROM DUAL@CBMIRROR_PUB BB) BB
         WHERE SESS_ID >= BB.B AND ROWNUM <= 2);

Index usage monitoring

ALTER INDEX index MONITORING USAGE;

information will be added into V$OBJECT_USAGE view

Index usage monitoring OFF:

ALTER INDEX index NOMONITORING USAGE;

Script for full everyday physical backup:

run {
allocate channel oem_disk_backup device type disk;
recover copy of database with tag 'ORA_OEM_LEVEL_0';
backup incremental level 1 cumulative  copies=1 for recover of copy with tag 'ORA_OEM_LEVEL_0' database;
}

Script for full everyday physical backup including archivelogs:

backup incremental level 1 cumulative device type disk filesperset = 900 tag '%TAG' database;
recover copy of database;
backup device type disk filesperset = 900 tag '%TAG' archivelog all not backed up delete all input;
run {
allocate channel oem_backup_disk1 type disk format 'G:\Backup\%Y%M%D\%U' maxpiecesize 1000 G;
allocate channel oem_backup_disk2 type disk format 'G:\Backup\%Y%M%D\%U' maxpiecesize 1000 G;
backup filesperset = 900 tag '%TAG' current controlfile;
release channel oem_backup_disk1;
release channel oem_backup_disk2;
}
allocate channel for maintenance type disk;
delete noprompt obsolete device type disk;
release channel;

Check the backup validity at a disk/tape (add VALIDATE after backup)

BACKUP VALIDATE ...

See current DB limits

select * from v$resource_limit;

select * from v$parameter;

Count current processes in a DB

ps alx | grep $ORACLE_SID | wc -l

Estimate DB schemas size (no files will be created, estimation only)

expdp router/loopexamspit NOLOGFILE=y ESTIMATE_ONLY=y

In UNIX shell:

expdp router/loopexamspit NOLOGFILE=Y ESTIMATE_ONLY=y INCLUDE=TABLE:\"LIKE \'\%`date '+%Y%m'`\'\" 2>&1 | grep Total | grep GB | cut -f6 -d' '

if statistics if fresh the followig result will be more precisely:

expdp router/loopexamspit NOLOGFILE=y ESTIMATE_ONLY=y ESTIMATE=STATISTICS

Turn only plans output

in TOAD: Ctrl+E

set autotrace traceonly explain

or

explain plan for 
select *

-- script for xplain table creation

@$ORACLE_HOME/rdbms/admin/utlxpls.sql;

after explain plan exucution for plan output see:

select * from table(dbms_xplan.display);

!!! IN Oracle 12c Adaptive Query Optimization mechanism may change a plan at execution pahse so DBMS_XPLAN.DISPLAY_CURSOR should be used to show current plan:

To see all of the operations in an adaptive plan, including the positions of the statistics collectors use:

select * from table(DBMS_XPLAN.DISPLAY_CURSOR(format=>'+adaptive'));
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL,TO_NUMBER(NULL),'ADVANCED RUNSTATS_LAST'));
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('1x8t2q10mt7ak',0,'ADVANCED'));

-- hint for gather execution statistics for query (additional stats will be in a plan):

/*+ GATHER_PLAN_STATISTICS */

select * from table(DBMS_XPLAN.DISPLAY_CURSOR(NULL,NULL,'ALLSTATS LAST'));

-- see execuiton plan along with execution progress for the given sql_id

select level l,pm.plan_line_id id
      ,lpad(' ', 2 * (level - 1))||pm.plan_operation||' '||pm.plan_options operation
      ,/*pm.plan_object_owner||'.'||*/pm.plan_object_name||' '||pm.plan_object_type object_name
      ,pm.plan_partition_start part_start,pm.plan_partition_stop part_stop
      ,pm.plan_cpu_cost cpu,pm.plan_io_cost io,pm.plan_temp_space temp_space
      ,pm.starts
      ,pm.output_rows
      ,pm.io_interconnect_bytes  io_i_bytes
      ,pm.physical_read_requests  phy_r_requests
      ,pm.physical_read_bytes  phy_r_bytes  
      ,pm.physical_write_requests  phy_w_requests  
      ,pm.physical_write_bytes  phy_w_bytes  
      ,pm.workarea_mem  wa_mem  
      ,pm.workarea_tempseg  wa_tempseg  
      ,pm.first_change_time fct
      ,pm.last_change_time  lct
      ,pm.sql_exec_start    strt
  from v$sql_plan_monitor pm
start with pm.plan_line_id = 0 and pm.sql_id = '92pg3c341gb3y' 
connect by prior pm.plan_line_id = pm.plan_parent_id and prior pm.sql_id = pm.sql_id and
           prior pm.key = pm.key;

When TEMP is using intensively for sorting the folloving actions may be helpful:

alter session set workarea_size_policy=MANUAL;
alter session set SORT_AREA_SIZE=800000000;

example

begin
EXECUTE IMMEDIATE 'alter session set workarea_size_policy=MANUAL';
EXECUTE IMMEDIATE 'alter session set SORT_AREA_SIZE=800000000';
EXECUTE IMMEDIATE 'alter index "VSMC3DS"."DDDSPROCTRNATTRINFOARC_IDX1" rebuild online';
EXECUTE IMMEDIATE 'alter index "VSMC3DS"."DDDSPROCTRNATTRINFOARC_IDX2" rebuild online';
EXECUTE IMMEDIATE 'alter index "VSMC3DS"."DDDSPROCFLAGSARC_IDX1" rebuild online';
EXECUTE IMMEDIATE 'alter index "VSMC3DS"."DDDSPROCFLAGSARC_IDX2" rebuild online';
--EXECUTE IMMEDIATE 'alter index "VSMC3DS"."DDDSPROCTRNATTRINFOARC_PK" shrink space';
end;
 

This will increase PGA and decrease TEMP usage for sorting
 
 Parallel query calibration (!!! DO NOT use when DB is working !!!)
 
 DECLARE
  lat  INTEGER;
  iops INTEGER;
  mbps INTEGER;
BEGIN
  DBMS_RESOURCE_MANAGER.CALIBRATE_IO(
      1 /* # of disks */
      , 10 /* maximum tolerable latency in milliseconds */
      , iops /* I/O rate per second */
      , mbps /* throughput, MB per second */
      , lat  /* actual latency in milliseconds */
  );
  DBMS_OUTPUT.PUT_LINE('max_iops = ' || iops);
  DBMS_OUTPUT.PUT_LINE('latency  = ' || lat);
  DBMS_OUTPUT.PUT_LINE('max_mbps = ' || mbps);
END;
/

select * from dba_rsrc_io_calibrate;

select status from V$IO_CALIBRATION_STATUS;

EXEC DBMS_STATS.GATHER_TABLE_STATS ('db_user', 'user_table');

EXEC DBMS_STATS.GATHER_TABLE_STATS ('tctdbs', 'AUTHORIZATIONS');

sqlplus output from a terminal without blank rows

set echo off heading off feedback off termout off trims on trim on linesize 130 tab off newpage 0 pagesize 0 wrap off
set echo on --commands output in a ternimal

Create a procedure returning cursor (there is not neccessary to declare output fields types)

CREATE OR REPLACE PROCEDURE p_return_cursor (c_OUT OUT sys_refcursor)

is

-- variables declaration

begin

-- procedure code for filling result_table

OPEN c_OUT FOR select * from result_table;

end;

/


Execute the procedure from the example above:

CREATE OR REPLACE PROCEDURE run_p_return_cursor

is

v_cursor_1 SYS_REFCURSOR;
-- variables declaration
v_1 VARCHAR2(100);
v_2 VARCHAR2(100);
-- and so on

begin

p_return_cursor (c_OUT => v_cursor_1);

 LOOP 
  FETCH v_cursor_1.field_1 INTO v_1;
  FETCH v_cursor_1.field_2 INTO v_2;
  -- and so on
  EXIT WHEN v_cursor_1%NOTFOUND;
  DBMS_OUTPUT.PUT_LINE(v_1);
  DBMS_OUTPUT.PUT_LINE(v_2);
  -- and so on
 END LOOP;
 CLOSE v_cursor_1;
end;
/


Runs this procedure from a anonymus plsql block:

DECLARE

v_cursor_1 SYS_REFCURSOR;

BEGIN
p_return_cursor (c_OUT => v_cursor_1);
END;
/

Ignoring ampersand - & in sqlplus (for example when insert literal symbol & into a table)

set define off;

Determine a time of the latest insert of a row into a table

Here latest row of a table in a WHERE condition

SELECT SCN_TO_TIMESTAMP(ORA_ROWSCN),ORA_ROWSCN FROM  vsmc3ds.TM_TRANSACT_INFO WHERE refid = 59162255;
  
OR determine a time of the latest DML on a table

SELECT MAX (ORA_ROWSCN), SCN_TO_TIMESTAMP (MAX (ORA_ROWSCN)) FROM altair.TRX_YAK;

  
JOIN 


for include the rows which is not exists in a b table add (+) for a table where there may be not rows satisfied predicate conditions:

select * from table1 a,table2 b where a.field1 = b.field1(+)


Rows concatenation when groupping (set own delimeter - ;)

SELECT
   field1,
   LISTAGG(field2, '; ') WITHIN GROUP (ORDER BY field3)
FROM tbl
GROUP BY field1;

Example:

SELECT 'BACKUP TAG RO_TS_ FILESPERSET 1 TABLESPACE '||LISTAGG (TABLESPACE_NAME, ',') WITHIN GROUP (ORDER BY TABLESPACE_NAME) ||';'
           TSNAMES
  FROM DBA_TABLESPACES
 WHERE STATUS = 'READ ONLY' ORDER BY TABLESPACE_NAME;
 
select nvl(listagg(tablespace_name,',') within group (order by tablespace_name),'XXX') as ts_4_exclude from dba_tablespaces where tablespace_name like '%HSK_EXP%'  ;

or (may return CLOB fields while previuos query cannot)

SELECT
   field1,
   CONCAT(field2)
FROM tbl
GROUP BY field1;

Gather traces for Oracle support (225598.1):

-- for analyzing optimizer (when tracing the same sql again they must be changed - for example add space - in order to hard parce appeared again !!!)

alter session set max_dump_file_size = unlimited;
ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';
alter session set tracefile_identifier='mytracefile';
alter system set events '10053 trace name context off';

-- tracing an execution for tkprof 
see EVENT: 10046 "enable SQL statement tracing (including binds/waits)" (Doc ID 21154.1)

ALTER SESSION SET EVENTS '10046 trace name context forever, level 1';
alter session set tracefile_identifier='mytracefile';
alter SESSION set events '10046 trace name context off';

--do tracing for both parce and execute:

alter session set timed_statistics = true;
alter session set statistics_level=ALL;
alter session set max_dump_file_size=UNLIMITED;
alter session set tracefile_identifier='10046_10053';
alter session set events '10046 trace name context forever, level 12';
alter session set events '10053 trace name context forever, level 1';
--run sql_id
alter SESSION set events '10046 trace name context off';
alter SESSION set events '10053 trace name context off';


--example of tracing in sqlplus:

alter session set current_schema = OWS;
alter session set timed_statistics = true;
alter session set statistics_level = ALL;
alter session set max_dump_file_size = UNLIMITED;
alter session set tracefile_identifier='10046_10053_B02';
alter session set events '10046 trace name context forever, level 12';
alter session set events '10053 trace name context forever, level 1';

variable B4 NUMBER;
variable B1 VARCHAR2(1);
variable B2 VARCHAR2(1);
variable B3 VARCHAR2(1);
exec :B4:= 95656187;
exec :B3:='P';
exec :B2:='S';
exec :B1:='T';
---!!! NOTE: if date is required declaration MUST be as varchar, see example:
variable B5 VARCHAR2(40);
exec :B5:=sysdate;

SELECT NEW_SCHEME FROM USAGE_ACTION WHERE ACNT_CONTRACT__ID = :B4 AND NEW_SCHEME IS NOT NULL AND POSTING_STATUS IN (:B3 , :B2 , :B1 ) ORDER BY ID DESC;

alter SESSION set events '10046 trace name context off';
alter SESSION set events '10053 trace name context off';
exit


--tracing for particular SQL_ID only:

alter system set events 'sql_trace[sql: <sql_id> | <sql_id> | <sql_id> ]'; 
alter system set events 'sql_trace[sql: <sql_id> ] off';

--tracing particular SQL_ID execution (trace every execution of the SQL statement):

ALTER SYSTEM SET events 'sql_trace [sql:<SQL_ID>] {occurence: end_after <number_of_traces>} wait=true, bind=true, plan_stat=all_executions';

To disable:

ALTER SYSTEM SET events 'sql_trace [sql:<SQL_ID>] off';

How to Collect Standard Diagnostic Information Using SQLT for SQL Issues (Doc ID 1683772.1)

A convenient way to use tkprof is to create a batch file in the folder where you retrieve the .trc traces files. 
The batch file (for example tkprof.bat) should contain:

Tkprof.exe %1 %1.tkprf Explain=%2 Table=%3.tun_plan_table Sort=(ExeEla,FchEla)

Simply run this batch file by providing the following arguments:

%1 - the name of the *.trc trace file;
%2 - the TNS connect string to the database with the credentials of the <app_user> user;
%3 - the username of <app_user>
Example: tkprof.bat mytraces.trc app_user/app_password@mytns app_user

The generated trace file will be placed in the same folder and will have the name "mytraces.trc.tkprf"

-- tracing the given error (ORA-08103 for example)
alter session set events '8103 trace name errorstack level 5';
alter session set tracefile_identifier='trace_8103';
alter session set events '8103 trace name context off';

after sqlt setup run from the name of application user (runs problem sql) for analyzing:

cd scripts/sqlt
-- MIN_MAX_select_not_use_INDEX_SS_1.sql - в этом файле sql для анализа
START run/sqltxecute.sql input/MIN_MAX_select_not_use_INDEX_SS_1.sql

please do the following action plan and provide the generated trace file.

-- IF SQLT not working use SQL Tuning Health-Check Script (SQLHC) (Doc ID 1366133.1) 

alter session set max_dump_file_size=unlimited; 
alter session set db_file_multiblock_read_count=1; 
alter session set events 'immediate trace name trace_buffer_on level 1048576'; 
alter session set events '10200 trace name context forever, level 1'; 
alter session set events '8103 trace name errorstack level 3'; 
alter session set events '10236 trace name context forever, level 1'; 
alter session set tracefile_identifier='ORA8103'; 

run the query that produces the error ORA-8103 
eg. analyze table validate structure cascade; 
alter session set events 'immediate trace name trace_buffer_off'; 
exit 

Identify the trace with the form of <sid>_ora_<pid>_ORA8103.trc 

Turn on tracing

alter system set events '8103  trace name context off';

ALTER SYSTEM SET EVENT='8103 trace name errorstack level 5' COMMENT='Debug tracing of control and rollback' SCOPE=SPFILE SID='*'; 

To remove all events, use:

ALTER SYSTEM RESET EVENT SCOPE=SPFILE SID='*';

Select symbol code (used for example in sqlldr)

SELECT ASCII(' ') from dual;

Select symbol using its code

SELECT CHR(32) from dual;

Select results output in one row using CLOB

SELECT wmsys.wm_concat (chr(10) || chr (13) || 'Мерчант: ' || n.merchantid  || ' ***** ' 
|| '№ Терминала: ' || n.terminalid || ' ***** ' 
|| 'Валюта перевода: ' || decode(c.name,
                                  'Russian rubles','RUB',
                                  'Euro','Euro',
                                  'United States dollar','USD',
                                  c.name) || ' ***** ' 
|| 'П/С получателя: ' || p.name || ' ***** ' 
||'МСС: ' || b.mcc || ' ***** ' 
|| 'Тип перевода: ' || decode(t.id,
                              '2', 'Внешний перевод',
                              '1', 'Внутрений перевод')) as R2C
                                                       
FROM vmt_merchants n,
       vmt_map m,
       vmt_currencies c,
       vmt_acqid a,
       vmt_transfertype t,
       vmt_ps p,
       vmt_mcc b
WHERE  n.id = m.id
       AND m.currency = c.num
       AND m.transfertype = t.id
       AND a.id = m.acquirerid
       AND a.pstype = p.id
       AND m.mcc = b.id
	   
TEMP usage monitoring

/* Formatted on 19/01/2015 18:39:57 (QP5 v5.227.12220.39754) */
  SELECT S.sid || ',' || S.serial# sid_serial,
         S.username,
         S.osuser,
         P.spid,
         S.module,
         P.program,
         SUM (T.blocks) * TBS.block_size / 1024 / 1024 mb_used,
         T.tablespace,
         COUNT (*) statements
    FROM v$sort_usage T,
         v$session S,
         dba_tablespaces TBS,
         v$process P
   WHERE     T.session_addr = S.saddr
         AND S.paddr = P.addr
         AND T.tablespace = TBS.tablespace_name
GROUP BY S.sid,
         S.serial#,
         S.username,
         S.osuser,
         P.spid,
         S.module,
         P.program,
         TBS.block_size,
         T.tablespace
ORDER BY mb_used desc,sid_serial;

Error messages when executing a program

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/error_stack.sql
-- Author       : Tim Hall
-- Description  : Displays contents of the error stack.
-- Call Syntax  : @error_stack
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  v_stack  VARCHAR2(2000);
BEGIN
  v_stack := Dbms_Utility.Format_Error_Stack;
  Dbms_Output.Put_Line(v_stack);
END;
/

Determine the length of actions (total time execution of action)

select * from V$TIMER -- microseconds here, to obtain seconds number must be divided by 1000

Date format in session

alter session set NLS_DATE_FORMAT='DD.MM.YYYY';

Example of unloading a field with number into CSV (in the example below numberx is a field with number)

SELECT    cnum|| ';'|| cost|| ';'|| '="'|| TRIM (numberx)|| '"'|| ';'|| EXPIRYDATE AS metlf FROM v_metlife

Physical backup with incremental update execution (during the third execution all necessary copies will be created and will continue to update)

RMAN

RUN
{
RECOVER COPY OF DATABASE WITH TAG 'incr_update';
BACKUP INCREMENTAL LEVEL 1 FOR RECOVER OF COPY WITH TAG 'incr_update' DATABASE;
}

Поиск идентификатора процесса в ОС по SID (SID из v$session)
Find pid in OS using SID from v$session

SELECT a.sid,b.spid FROM v$session a, v$process b WHERE a.paddr = b.addr and A.SID = 803 order by 1;

либо по SERIAL#:
or using SERIAL#:

SELECT a.sid,b.spid FROM v$session a, v$process b WHERE a.paddr = b.addr and A.SERIAL# = 66342 order by 1;

-- запуск ADDM (сценарий addmrpt.sql)
-- run ADDM (script addmrpt.sql)

DBMS_ADDM (три режима - экземпляр ,БД, частичный) - представления DBA_ADVISOR_*
DBMS_ADDM (there are three modes - instance ,database, partial) - DBA_ADVISOR_* views

-- создание снимка AWR
-- AWR snapshot creation

exec dbms_workload_repository.create_snapshot;

-- просмотр отчета
-- see the AWR report

SET LONG 1000000 PAGESIZE 0
SELECT DBMS_ADDM.GET_REPORT(:taskname) from dual;

-- Просмотр baselines для конкретного sql_id (их может не быть)
-- See baselines for the exact sql_id (it may not exists)

SELECT PLAN_TABLE_OUTPUT
FROM   V$SQL s, DBA_SQL_PLAN_BASELINES b, 
       TABLE(
         DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE(b.sql_handle,b.plan_name,'basic') 
       ) t
WHERE  s.EXACT_MATCHING_SIGNATURE=b.SIGNATURE
AND    b.PLAN_NAME=s.SQL_PLAN_BASELINE
AND    s.SQL_ID='31d96zzzpcys9';

-- просмотр плана выполнения
-- see execution plan

select /*+ gather_plan_statistics */ ... from ... ;
select * from table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));

-- план выполнения из AWR
-- execution plan from AWR

set linesize 200
set pagesize 10000
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR('&sql_id'));

  SELECT id,
         parent_id,
         DEPTH,
         position,
         operation,
         object_name,
         object_type,
         options,
         cost,
         other_tag,
         distribution
    FROM V_$SQL_PLAN
   WHERE SQL_ID = '9tmrxbjcnk2z8' AND CHILD_NUMBER = 0
ORDER BY ID

-- включение трассировки во время выполнения запросов
-- turn on tracing during the sql execution

SET AUTOTRACE ON EXPLAIN	--The AUTOTRACE report shows only the optimizer execution path.
SET AUTOTRACE ON STATISTICS	--The AUTOTRACE report shows only the SQL statement execution statistics.
SET AUTOTRACE TRACEONLY --optimizer execution path and execution statistics (in TOAD fetch data!)
SET AUTOTRACE ON -- Enables all options, fetch data


-- пример выборки данных из курсора в тип (выборка нескольких строк)
-- select data from a cursor example (few rows)

DECLARE
   V_I041_POS_ID      VARCHAR2 (8);
   v_cursor           SYS_REFCURSOR;
   v_AUTHORIZATIONS   AUTHORIZATIONS%ROWTYPE;
BEGIN
   V_I041_POS_ID := '00008017';

   IF V_I041_POS_ID IS NOT NULL
   THEN
      OPEN v_cursor FOR
         SELECT *
           FROM AUTHORIZATIONS a
          WHERE A.I041_POS_ID = V_I041_POS_ID;

      LOOP
         FETCH v_cursor INTO v_AUTHORIZATIONS;

         DBMS_OUTPUT.PUT_LINE (
               v_AUTHORIZATIONS.LTIMESTAMP
            || ' '
            || v_AUTHORIZATIONS.i002_number);
         EXIT WHEN v_cursor%NOTFOUND;
      END LOOP;

      CLOSE v_cursor;
   END IF;
END;

-- выборка текущего TIMESTAMP
-- select current timestamp

select to_char(systimestamp,'YYYY-MM-DD HH24:MI:SS.FF') as b_date from dual;

--convert sysdate to timestamp with TZ /timestamp_tz
SELECT from_tz(CAST (SYSDATE AS TIMESTAMP), '+04:00') tz FROM dual;

-- трассировка сессии
-- session tracing

exec DBMS_MONITOR.SESSION_TRACE_ENABLE(SID,SERIAL,TRUE,TRUE);
exec DBMS_MONITOR.SESSION_TRACE_ENABLE(SESSION_ID=>1391,SERIAL_NUM=>27435,WAITS=>TRUE,BINDS=>TRUE,PLAN_STAT=>'all_executions');

трейс будет в diagnostic_dest/diag/rdbms/instance_name/db_name/trace/<имя процесса>.trc
trace will be placed into diagnostic_dest/diag/rdbms/instance_name/db_name/trace/<process name>.trc
select tracefile from v$process where addr = (select PADDR from v$session where sid = 4215 and serial# = 20110);
(select tracefile from v$process where pid=11;)

exec DBMS_MONITOR.SESSION_TRACE_DISABLE(SID,SERIAL);
exec DBMS_MONITOR.SESSION_TRACE_DISABLE(SESSION_ID=>1391,SERIAL_NUM=>27435);

--add tracing in PL SQL code
declare
...
V_TRACE_MOMENT     VARCHAR2(14);
begin
SELECT TO_CHAR(SYSDATE,'hh24_mi') INTO V_TRACE_SUFF FROM DUAL;
EXECUTE IMMEDIATE 'ALTER SESSION SET MAX_DUMP_FILE_SIZE = UNLIMITED';
EXECUTE IMMEDIATE 'ALTER SESSION SET TRACEFILE_IDENTIFIER = "SE_ONLINE_'||V_TRACE_MOMENT||'"';
DBMS_MONITOR.SESSION_TRACE_ENABLE (BINDS => TRUE, PLAN_STAT => 'all_executions');

--code ...

DBMS_MONITOR.SESSION_TRACE_DISABLE;

-- определение имени трейса текущей сессии
-- determine the name of a trace for current session

SELECT s.sid,
       s.serial#,
       pa.value || '/' || LOWER(SYS_CONTEXT('userenv','instance_name')) ||    
       '_ora_' || p.spid || '.trc' AS trace_file
FROM   v$session s,
       v$process p,
       v$parameter pa
WHERE  pa.name = 'user_dump_dest'
AND    s.paddr = p.addr
AND    s.audsid = SYS_CONTEXT('USERENV', 'SESSIONID');

-- включение трассировки всех сессий определенного приложения
-- turn on tracing of all sessions for the given application

begin
select 'exec dbms_monitor.session_trace_enable('||SID||','||SERIAL#||',TRUE,TRUE);' from v$session where USERNAME = 'ROUTER' and PROGRAM = 'monitor24.exe';
end;

-- отключение трассировки всех сессий определенного приложения
-- turn off tracing of all sessions for the given application

begin
select 'exec dbms_monitor.session_trace_disable('||SID||','||SERIAL#||');' from v$session where USERNAME = 'ROUTER' and PROGRAM = 'monitor24.exe';
end;

-- аггрегация полученных трейсов в один файл для одного модуля
-- aggregate all traces for one module into one file 

trcsess output=monitor24.trc module=monitor24.exe
trcsess output=spur1_ora_341066_SE_ONLINE_15_22_all.trc service=DWH_PRIM spur1*SE_ONLINE_15_22.trc

анализ полученного файла на предмет sql в нем (monitor24.ins - код для вставки всех sql в таблицу для их выборки их БД, monitor24.rec - все sql в файле)
analyzing the file for a sql into it (monitor24.ins - sql for insert all sql into table in DB, monitor24.rec - all sql in the file)

tkprof monitor24.trc monitor24.out waits=yes sort=userid insert=monitor24.ins aggregate=yes sys=no RECORD=monitor24.rec

Interpreting Raw SQL_TRACE output (Doc ID 39817.1)

разница между значениями времени вида tim=5106904379704 в трейсе tkprof измеряется в мксек (10E-6 секунды),
то есть для подсчета времени выполнения в секундах нужно разницу между tim= в начале в в конце операции поделить на 1000000
difference between the time values like tim=5106904379704 in a raw trace in microseconds (10E-6 of seconds)
so in order to count the execution time in seconds a difference between starting tim= and ending tim= must be divided by 1000000

in tracefile like that 

EXEC #18446744071369617520:c=1417389,e=1417388,p=0,cr=0,cu=0,mis=0,r=0,dep=2,og=1,plh=2102979022,tim=6219666325521 

tim=6219666325521 - time when this action is finished NOT STARTED (!) 
and 
e=1417388 - time (in microseonds) taken for this action to complete 

-- выбор переменных привязки (в примере - первой и второй переменной) для конкретного выражения
-- select bind variables (in the example below - for the first and for the second variables) for the given sql_id

SELECT DBMS_SQLTUNE.extract_bind (bind_data, 1).value_string,
       DBMS_SQLTUNE.extract_bind (bind_data, 2).value_string
  FROM v$sql s
 WHERE S.SQL_ID = '8bzr6uz9bf335';
 
 SELECT *
  FROM v$sql s, v$sql_bind_capture b
 WHERE S.SQL_ID = B.SQL_ID AND S.SQL_ID = '8bzr6uz9bf335';
 
 -- если переменные не захватываются, проверяем интервал захвата (по умолчанию - 15 минут = 900 секунд)
 -- еще один параметр - _xpl_peeked_binds_log_size
 -- if a binds is not captured check capture interval (15 minutes = 900 seconds by default)
 -- and another parameter - _xpl_peeked_binds_log_size
 
 SELECT nam.ksppinm NAME, val.KSPPSTVL VALUE
    FROM x$ksppi nam, x$ksppsv val
   WHERE     nam.indx = val.indx
         AND nam.ksppinm LIKE '%_cursor_bind_capture_interval%'
ORDER BY 1;

-- изменяем его (в секундах)
-- change it (in seconds)

alter system set "_cursor_bind_capture_interval"=10

Запуск отчета ash из sqlplus:
Run AWR report from sqlplus:

set linesize 300

SELECT dbid FROM v$database; -- первый параметр --first parameter
SELECT inst_id FROM gv$instance; -- второй параметр --second parameter

SELECT *
  FROM TABLE (DBMS_WORKLOAD_REPOSITORY.ash_report_html (418194992,
                                                        1,
                                                        SYSDATE - 30/24/60,
                                                        SYSDATE - 10/24/60));
														
Создание снепшота для отчета awr вручную:
Create snapshot manualy:

exec dbms_workload_repository.create_snapshot;

Создание BASELINE
Create BASELINE

  DBMS_WORKLOAD_REPOSITORY.create_baseline(
    start_snap_id => 182436,
    end_snap_id   => 182445,
    baseline_name => 'bl_18feb_load_testing',
    expiration    => 700);

  DBMS_WORKLOAD_REPOSITORY.create_baseline(
    start_time    => TO_DATE('09-JUL-2008 17:00', 'DD-MON-YYYY HH24:MI'),
    end_time      => TO_DATE('09-JUL-2008 18:00', 'DD-MON-YYYY HH24:MI'),
    baseline_name => 'test2_bl',
    expiration    => NULL);
	
Запуск SQL tuning advisor для произвольного sql:
Run SQL tuning advisor for the given sql:

DECLARE
   L_SQL                VARCHAR2 (32000);
   L_SQL_TUNE_TASK_ID   VARCHAR2 (32000);
BEGIN
   L_SQL :=
      'select count(1)
from
(select "COMPVAL","ISONLINE","ISSTABILISER","SETTLETIME","ASP","TRADENO","BUYSELL","CURRENCYID","TRADEDATE","TRADETIME","TYP","STATUS","CONFIRMED","SETTLED","ORDERNO","SECURITYID","BOARDID","FIRMID","CLEARINGFIRMID","CPFIRMID","TRDACCID","CPTRDACCID","PRICE","QUANTITY","BALANCE","QTYSHORT","VAL","ACCINT","AMOUNT","VAL2","ACCINT2","PAID","SETTLECODE","DUEDATE","SETTLEDATE","CUSTODIANID","COMMISSION","EXHCOMM","ITSCOMM","CLRCOMM","RPRTCOMM","TAX","BANKACCID","BANKID","AMENDDATE","AMENDTIME","YIELD","EXCHANGEID","LINKEDTRADE","PERIOD","NETCASHFL","TRADESESSION","SESSIONNO","REPORATE","PRICE2","REFUNDRATE","REPOTRADENO","COMEXEMPT","REPORTNO","USAGECASH","CLIENTCODEID","CLEARINGTYPE","CONFIRMREPORT","CONFIRMTIME","AUCTNO","INSERTDATE","UPDATEDATE","USERID","BROKERREF","MATCHREF","EXTREF","USEREXCHANGEID","ORDERTYPE","ISMARKETMAKER","ISADDRESSED","ADDSESSION","TRADEMICROSECONDS","PARENTTRADENO","DISCOUNT","REPOVALUE","REPO2VALUE","PRICE1","BASEPRICE","SYSTEMREF","CLEARINGBANKACCID","CLEARINGTIME"
from CURR.TRADES_BASE
where TRADEDATE=:D1 minus
select "COMPVAL","ISONLINE","ISSTABILISER","SETTLETIME","ASP","TRADENO","BUYSELL","CURRENCYID","TRADEDATE","TRADETIME","TYP","STATUS","CONFIRMED","SETTLED","ORDERNO","SECURITYID","BOARDID","FIRMID","CLEARINGFIRMID","CPFIRMID","TRDACCID","CPTRDACCID","PRICE","QUANTITY","BALANCE","QTYSHORT","VAL","ACCINT","AMOUNT","VAL2","ACCINT2","PAID","SETTLECODE","DUEDATE","SETTLEDATE","CUSTODIANID","COMMISSION","EXHCOMM","ITSCOMM","CLRCOMM","RPRTCOMM","TAX","BANKACCID","BANKID","AMENDDATE","AMENDTIME","YIELD","EXCHANGEID","LINKEDTRADE","PERIOD","NETCASHFL","TRADESESSION","SESSIONNO","REPORATE","PRICE2","REFUNDRATE","REPOTRADENO","COMEXEMPT","REPORTNO","USAGECASH","CLIENTCODEID","CLEARINGTYPE","CONFIRMREPORT","CONFIRMTIME","AUCTNO","INSERTDATE","UPDATEDATE","USERID","BROKERREF","MATCHREF","EXTREF","USEREXCHANGEID","ORDERTYPE","ISMARKETMAKER","ISADDRESSED","ADDSESSION","TRADEMICROSECONDS","PARENTTRADENO","DISCOUNT","REPOVALUE","REPO2VALUE","PRICE1","BASEPRICE","SYSTEMREF","CLEARINGBANKACCID","CLEARINGTIME"
from CBMIRROR.CURR_TRADES_BASE@CBMIRROR_PUB
where TRADEDATE=:D2)';

   L_SQL_TUNE_TASK_ID :=
      DBMS_SQLTUNE.CREATE_TUNING_TASK (
         SQL_TEXT      => L_SQL,
         USER_NAME     => 'EQ',
         SCOPE         => DBMS_SQLTUNE.SCOPE_COMPREHENSIVE,
         TIME_LIMIT    => 600,
         TASK_NAME     => 'account_task_4',
         DESCRIPTION   => 'Tuning task for an account.');
   DBMS_OUTPUT.PUT_LINE ('l_sql_tune_task_id: ' || L_SQL_TUNE_TASK_ID);
END;
/

-- для SQL_ID

DECLARE
   L_SQL                VARCHAR2 (32000);
   L_SQL_TUNE_TASK_ID   VARCHAR2 (32000);
BEGIN
   L_SQL :='3wtykknt1j0zb';

   L_SQL_TUNE_TASK_ID :=
      DBMS_SQLTUNE.CREATE_TUNING_TASK (
         SQL_ID      => L_SQL,
         TIME_LIMIT    => 600,
         TASK_NAME     => 'sqltune_'||L_SQL);
   DBMS_OUTPUT.PUT_LINE ('l_sql_tune_task_id: ' || L_SQL_TUNE_TASK_ID);
END;
/

BEGIN
DBMS_SQLTUNE.execute_tuning_task(task_name => 'sqltune_'||L_SQL);
END;
/

SELECT task_name, status FROM dba_advisor_log WHERE owner = 'EQ' ;

SELECT DBMS_SQLTUNE.report_tuning_task('account_task_4') AS recommendations FROM dual;

--auto tasks job names prefixes

ORA$AT_SA_SPC_SY_nnn is for Space Advisor tasks
ORA$AT_OS_OPT_SY_nnn is for CBO stats collection tasks
ORA$AT_SQ_SQL_SW_nnn is for SQL Tuning Advisor tasks

Анализ архива с информацией os watcher (OSwatcher) black box (oswbb) :
Archive with os watcher black box (oswbb) analyzing:

-- в автоматическом режиме:
-- automatic mode
java -jar oswbba.jar -i C:\temp\archive -A
-- с возможностью выбора опций
-- options may be choosed
java -jar oswbba.jar -i C:\temp\archive

--for particular interval (faster analysis when you have a lot of files in history):
java -jar oswbba.jar -i /grid/OSwatcher/oswbb/output -b Feb 09 00:00:00 2021 -e Feb 16 10:00:00 2021 -s
java -jar oswbba.jar -i /u01/OSwatcher/oswbb/archive -b Jun 11 23:00:00 2020 -e Jun 18 09:00:00 2020 -s

--run in bg:
cd /grid/OSwatcher/oswbb
nohup java -jar oswbba.jar -i /grid/OSwatcher/oswbb/output -b Feb 14 00:00:00 2021 -e Feb 16 13:00:00 2021 -s >> analysis_`date +%Y%m%d_%H%M%S`.log 2>&1 &

SQL Monitoring (отчеты по sql, которые есть в мониториге)
SQL Monitoring (reports for sql exists in monitoring)

В виде текста:
As text:
SELECT DBMS_SQLTUNE.REPORT_SQL_MONITOR_LIST () TEXT_LINE FROM DUAL;
SELECT DBMS_SQLTUNE.REPORT_SQL_MONITOR () TEXT_LINE FROM DUAL;
В виде HTML:
As HTML:
SELECT DBMS_SQLTUNE.REPORT_SQL_MONITOR_LIST (type=>'HTML') TEXT_LINE FROM DUAL;
SELECT DBMS_SQLTUNE.REPORT_SQL_MONITOR (type=>'HTML') TEXT_LINE FROM DUAL;

SET trimspool ON
SET TRIM      ON
SET pages    0
SET linesize 32767
SET LONG    1000000
SET longchunksize 1000000
 
spool sqlmon_active.html
 
SELECT dbms_sqltune.Report_sql_monitor(SQL_ID=>'&sql_id', TYPE=>'active')
FROM   dual;
 
spool OFF

-- monitoring SQL execution:

https://sqlmaria.com/2017/08/01/getting-the-most-out-of-oracle-sql-monitor/

By default, a SQL statement that either runs in parallel or has consumed at least 5 seconds of combined CPU and I/O time in a single execution will be monitored.
you can lower or increase the default threshold of 5 seconds by setting the underscore parameter 
_sqlmon_threshold
However, you should be aware that any increase might mean the monitored executions will age out of the SQL Monitor buffer faster.

It is also possible to force monitoring to occur for any SQL statement by simply adding the MONITOR hint to the statement.

SELECT /*+ MONITOR */ col1, col2, col3

you can still force monitoring to occur by setting the event "sql_monitor" with a list of SQL_IDs for the statements you want to monitor at the system level:
ALTER SYSTEM SET EVENTS 'sql_monitor [sql: 5hc07qvt8v737|sql: 9ht3ba3arrzt3] force=true';

By default, Oracle limits the number of SQL statements that will be monitored to 20 X CPU_COUNT. 
You can increase this limit by setting the underscore parameter
_sqlmon_max_plan 
but be aware this will increase the amount of memory used by SQL Monitor in the Shared_Pool and may result in SQL Monitoring information being aged out of the memory faster.
SQL Monitor will only monitor a SQL statement if the execution plan has less than 300 lines. If you know your execution plans are much larger than that, you can set the underscore parameter 
_sqlmon_max_planlines
 to increase this limit. Again, this will increase the amount of memory used by SQL Monitor in the Shared_Pool.
 In Oracle Database 12c SQL Monitor reports are persisted in the data dictionary table DBA_HIST_REPORTS. By default, Oracle will retain SQL Monitor reports for 8 days (or AWR retention policy).
 
 -- select report from history:
 
SELECT report_id rid FROM dba_hist_reports
WHERE dbid = 1954845848 AND component_name = 'sqlmonitor'
AND report_name = 'main' AND period_start_time BETWEEN
To_date('27/07/2017 11:00:00','DD/MM/YYYY HH:MI:SS') AND To_date('27/07/2017 11:15:00','DD/MM/YYYY HH:MI:SS')
AND key1 = 'cvn84bcx7xgp3';
 
get HTML monior report:

SET echo ON
SET trimspool ON
SET TRIM ON
SET pages 0
SET linesize 32767
SET LONG 10000000
SET longchunksize 1000000
spool old_sqlmon.html
 
SELECT dbms_auto_report.Report_repository_detail(rid=>42, TYPE=>'active')
FROM dual;
spool OFF 

 Поиск части кода внутри БД:
Search for SOURCE into db:

SELECT * FROM ALL_SOURCE WHERE UPPER(text) LIKE UPPER('%what I am searching for%') ORDER BY type, name, line;

Анализ CHAINED ROWS
CHA

INED ROWS analysis

Создание таблицы для хранения результатов анализа с помощью скрипта utlchain.sql в ?/rdbms/admin
Create table using utlchain.sql script (into ?/rdbms/admin)
Анализ: analyze table EQ.ORDERS_BASE partition (EQ_ORDERS_BASE_P_20090801) list chained rows; (без партиций: analyze table EQ.ORDERS_BASE list chained rows)
Analyzing: analyze table EQ.ORDERS_BASE partition (EQ_ORDERS_BASE_P_20090801) list chained rows; (without partitions: analyze table EQ.ORDERS_BASE list chained rows)
Результаты: select * from chained_rows;
Results: select * from chained_rows;
И в столбце CHAIN_CNT представлений dba_tables и dba_tab_partitions (после сбора ститистики!)
And in the column CHAIN_CNT of views dba_tables and dba_tab_partitions (after stats gathering!)
Описание: http://www.akadia.com/services/ora_chained_rows.html
See description: http://www.akadia.com/services/ora_chained_rows.html
														
--Oracle12c 

При подключении sqlplus / as sysdba по умолчанию подключаемся к CDB$ROOT (SHOW CON_NAME в sqlplus покажет контейнер)
When connect sqlplus / as sysdba by default CDB$ROOT container will be used (SHOW CON_NAME in sqlplus show the current container)
(http://docs.oracle.com/database/121/CNCPT/cdblogic.htm#CNCPT89459)

для того, чтобы подключиться любой из к PDB БД внутри контейнера, нужно выбрать к какой (БД с PDB <> CDB$ROOT):
In order to connect into any PDB DB into container you must set required container name (DB with PDB <> CDB$ROOT):

column name format a20
SELECT NAME, PDB FROM V$SERVICES ORDER BY PDB, NAME;

ALTER SESSION SET CONTAINER = SPUR_P1;

Для подключения к PDB по умолчанию нужно в tnsnames добавить сервис, ассоциированный в этой БД (из селекта ранее) и назначить для ORACLE_SID этот сервис
For connect into PDB by default the service associated with the db must by added into tnsnames (see previuos select results) and link ORACLE_SID with this service

Можно также использовать переменную TWO_TASK для подключения к нужной БД из tnsnames.
TWO_TASK variable also may be used for connect to the given DB from tnsnames.

grant alter given procedures to user

https://asktom.oracle.com/pls/apex/f?p=100:11:0::::P11_QUESTION_ID:1464266200346504994

При ошибке с insufficient privileges и невозможности выдать привилегии с GRANT OPTION от SYS нужно последовательно выдавать привилегии c GRANT OPTION от схем, в которых находятся объекты
When insufficient privileges error appeared when priviledges with GRANT OPTION gived from SYS it may be fixed by consistently granting a priviledges as problematic objects owners

Оценка размера индекса:
Estimate index size:

DECLARE
   U_BYTE   NUMBER;
   A_BYTE   NUMBER;
BEGIN
   DBMS_SPACE.CREATE_INDEX_COST (
      'CREATE UNIQUE INDEX FORTS.UIDX_FUT_ORDLOG ON FORTS.FUT_ORDLOG (SESS_ID, NUMB_ORDER, DAT_TIME, MSEC, REST_KOL) LOCAL',
      U_BYTE,
      A_BYTE);
   DBMS_OUTPUT.PUT_LINE ('Allocated ~ '||A_BYTE/1024/1024/1024 ||' MB');
   DBMS_OUTPUT.PUT_LINE ('');
   DBMS_OUTPUT.PUT_LINE ('Used ~ '|| U_BYTE/1024/1024/1024 ||' MB');
END;

Оценка потенциального размера партиции таблицы с учетом компресии:
Estimate a potential size of table partitions with compression:

DECLARE
   V_SCRATCHTBSNAME   VARCHAR2 (60) DEFAULT 'SMALL_TABLES_DATA';
   V_OWNNAME          VARCHAR2 (60) DEFAULT 'FORTS_AR';
   V_OBJNAME          VARCHAR2 (60) DEFAULT 'FUT_ORDLOG_2016';
   V_SUBOBJNAME       VARCHAR2 (60) DEFAULT 'FUT_ORDLOG_TEMP_5023';
   V_COMPTYPE         NUMBER DEFAULT DBMS_COMPRESSION.COMP_ARCHIVE_HIGH; --DBMS_COMPRESSION Constants - Compression Types
   V_SUBSET_NUMROWS   NUMBER DEFAULT 1000000;
   V_BLKCNT_CMP       PLS_INTEGER;
   V_BLKCNT_UNCMP     PLS_INTEGER;
   V_ROW_CMP          PLS_INTEGER;
   V_ROW_UNCMP        PLS_INTEGER;
   V_CMP_RATIO        NUMBER;
   V_COMPTYPE_STR     VARCHAR2 (60);
BEGIN
   DBMS_COMPRESSION.GET_COMPRESSION_RATIO (
      SCRATCHTBSNAME   => V_SCRATCHTBSNAME,
      OWNNAME          => V_OWNNAME,
      OBJNAME          => V_OBJNAME,
      SUBOBJNAME       => V_SUBOBJNAME,
      COMPTYPE         => V_COMPTYPE,
      BLKCNT_CMP       => V_BLKCNT_CMP,
      BLKCNT_UNCMP     => V_BLKCNT_UNCMP,
      ROW_CMP          => V_ROW_CMP,
      ROW_UNCMP        => V_ROW_UNCMP,
      CMP_RATIO        => V_CMP_RATIO,
      COMPTYPE_STR     => V_COMPTYPE_STR,
      SUBSET_NUMROWS   => V_SUBSET_NUMROWS);

   DBMS_OUTPUT.PUT_LINE (
         'Number of blocks used by compressed sample of the table: '
      || V_BLKCNT_CMP);
   DBMS_OUTPUT.PUT_LINE ('');
   DBMS_OUTPUT.PUT_LINE (
         'Number of blocks used by uncompressed sample of the table: '
      || V_BLKCNT_UNCMP);
   DBMS_OUTPUT.PUT_LINE ('');
   DBMS_OUTPUT.PUT_LINE (
         'Number of rows in a block in compressed sample of the table: '
      || V_ROW_CMP);
   DBMS_OUTPUT.PUT_LINE ('');
   DBMS_OUTPUT.PUT_LINE (
         'Number of rows in a block in uncompressed sample of the table: '
      || V_ROW_UNCMP);
   DBMS_OUTPUT.PUT_LINE ('');
   DBMS_OUTPUT.PUT_LINE (
         'Compression ratio, blkcnt_uncmp divided by blkcnt_cmp: '
      || V_CMP_RATIO);
   DBMS_OUTPUT.PUT_LINE ('');
   DBMS_OUTPUT.PUT_LINE (
      'Compression type was used for evaluation: ' || V_COMPTYPE_STR);
END;

--Oracle Undo Block Experiment

http://ivenxu.com/2014/01/05/oracle-undo-block-experiment/

-- логирование DDL операций (Enterprise опция), allow the tracking of all ddls in the alert log
-- DDL operation logging (Enterprise option) allow the tracking of all ddls in the alert log

ALTER SYSTEM SET enable_ddl_logging=TRUE

(trace will be in <diagostic_dest>/rdbms/<sid>/<dbname>/log/ddl_$ORACLE_SID.log)
 
 
--настройка аудита:
-- audit setup 
https://oracle-base.com/articles/10g/auditing-10gr2б
https://oracle-base.com/articles/12c/auditing-enhancements-12cr1

-- Сбор диагностики системы с помощью RDA (Doc ID 314422.1):
-- Gather RDA diagnosis (Doc ID 314422.1):

./rda.sh -vCRP -e DFT/N_SQL_TIMEOUT=120,DFT/N_ATTEMPTS=25 -p Maa_Exa_Assessment

-- Keep objects in SHARED_POOL ("Database Objects/Large Objects not Pinned" section of RDA report)

-- find candidates for keep

  SELECT OWNER || '.' || NAME "ObjectName",
         TYPE,
         SHARABLE_MEM,
         LOADS,
         EXECUTIONS,
         KEPT,
         'exec DBMS_SHARED_POOL.KEEP('''||OWNER || '.' || NAME||''');' "Keep PLSQL"
    FROM V$DB_OBJECT_CACHE
   WHERE     TYPE IN ('TRIGGER',
                      'PROCEDURE',
                      'PACKAGE BODY',
                      'PACKAGE')
         AND EXECUTIONS > 0
ORDER BY EXECUTIONS DESC, LOADS DESC, SHARABLE_MEM DESC;

1) create package DBMS_SHARED_POOL:

sqlplus / as sysdba
@?/rdbms/admin/dbmspool.sql;
2) keep procedure/function example:

exec DBMS_SHARED_POOL.KEEP('LOADER_MARKETS_DBL.IN_REQUEST_DEPENDENCES');
3) check objects kept:

select * from v$db_object_cache where kept='YES' and owner <> 'SYS' order by 1,2;

--flush particular cursor from the shared pool:
https://oracle-base.com/articles/misc/purge-the-shared-pool

SELECT sql_id,
       address,
       hash_value,
       sql_text
FROM   v$sqlarea
WHERE  sql_text LIKE 'SELECT empno FROM emp WHERE job%';

EXEC sys.DBMS_SHARED_POOL.purge('000000010182AE70,1862304678', 'C'); --'ADDRESS,HASH_VALUE'

-- MOVE партиции и автоматическая перестройка индексов по ней
-- move partitions and rebuild indexes automaticaly
  
  ALTER TABLE EQ.ORDERS_BASE MOVE PARTITION EQ_ORDERS_BASE_P_20150604 UPDATE INDEXES PARALLEL;
  
  -- PARALLEL_DEGREE_POLICY 
  
  Если задать MANUAL (по умолчанию в 11g), то параллельность контролируется в sql (PARALLEL 8),
  При AUTO или ADAPTIVE (12c) задание параллельности внутри sql может не приводить в паралл. выполнению
  
  If MANUAL (default in 11g) parallelism controlled in sql (PARALLEL 8)
  If AUTO or ADAPTIVE (12c) set parallelism into sql may not lead to parallel execution
  
  !!! db_big_table_cache_percent_target работает только при AUTO или ADAPTIVE
  !!! db_big_table_cache_percent_target works only when AUTO or ADAPTIVE
  
-- force query with particular prallelism

alter session force parallel query parallel 34;
select /*+parallel(ua 34)*/ ...
  
Правильные параметры монтирования NFS для Oracle (решает проблему ORA-27054 при использовании datapump)
MOS Doc ID 359515.1
Correct parameters when using NFS mounts for Oracle (solve problem ORA-27054 when using datapump), see MOS Doc ID 359515.1
  
в Linux
in Linux
mount -o rw,rsize=32768,wsize=32768,hard,nointr,bg,nfsvers=3,tcp,actimeo=0,timeo=600
  
в HP-UX
in HP-UX
mount -o remount,rw,bg,hard,rsize=32768,wsize=32768,vers=3,nointr,timeo=600,proto=tcp,suid,forcedirectio

Сжатие таблицы с LOB после удаления/изменения размера строк в LOB (BLOB,CLOB) столбцах
Table compression after delete/change rows size in LOB (BLOB,CLOB)

ALTER TABLE prot.INP_FILE_BODY MODIFY LOB(FILE_BODY) (SHRINK SPACE);

--move lob column data into different tablespace:

ALTER TABLE STG_ETL.ADCB_LULU_EMBOSS_FILE2IDEMIA MOVE LOB (APPLDATANOTIFICATION) STORE AS SECUREFILE  (NOCOMPRESS TABLESPACE STG_ETL);

-- Сбор диагностики:
-- Diagnistic gathering:

Весь стек: RDA (Doc ID 314422.1), пример запуска: ./rda.sh -vCRP -e DFT/N_SQL_TIMEOUT=120,DFT/N_ATTEMPTS=25 -p Maa_Exa_Assessment
All stack: RDA (Doc ID 314422.1), example: ./rda.sh -vCRP -e DFT/N_SQL_TIMEOUT=120,DFT/N_ATTEMPTS=25 -p Maa_Exa_Assessment
Кластерный стек (Clusterware): TFA diagcollect  (Doc ID 289690.1) и (Doc ID 1513912.2), пример запуска за период: 
Clusterware: TFA diagcollect  (Doc ID 289690.1) и (Doc ID 1513912.2), example for period: 
$GI_HOME/tfa/bin/tfactl diagcollect -from "Aug/11/2016 01:50:00" -to "Aug/11/2016 02:00:00"
Инциденты: adrci (Doc ID 443529.1)
Incidents: adrci (Doc ID 443529.1)

-- Недокументированные параметры и их текущие значения в БД
-- Undocumented parameters and its current values in DB

  SELECT A.KSPPINM PARAM,
         B.KSPPSTVL SESSIONVAL,
         C.KSPPSTVL INSTANCEVAL,
         A.KSPPDESC DESCR
    FROM X$KSPPI A, X$KSPPCV B, X$KSPPSV C
   WHERE     A.INDX = B.INDX
         AND A.INDX = C.INDX
         AND A.KSPPINM LIKE '/_%' ESCAPE '/'
ORDER BY 1;

-- для выражений с литералами (вместо переменных привязки)
-- for sqls with literals (instead of binds)

Disabling bind peeking
alter session set "_OPTIM_PEEK_USER_BINDS"= FALSE;

-- анализ истории Sql и сессий
-- sql history and ASH analysis

DBA_HIST_ACTIVE_SESS_HISTORY,DBA_HIST_SQLSTAT,DBA_HIST_SQLTEXT

-- трассировка подключения к БД через OVD
-- tracing connection into DB over OVD

connect / as sysdba
alter system set events '28033 trace name context forever, level 9';
connect teus1/qwerty_1
connect / as sysdba
alter system set events '28033 trace name context off';

-- Устранение ожидания log file sync/log file parallel write
-- reduce log file sync/log file parallel write waits

-- динамически
-- dynamicaly
alter system set "_use_adaptive_log_file_sync"=FALSE scope=both;
alter system set "_undo_autotune"=FALSE scope=both;

-- статически
-- staticaly
alter system set "_high_priority_processes"='LMS*|LGWR|VKTM' scope=spfile;
alter system set filesystemio_options = SETALL scope=spfile;

-- если ничего не помогло, то меняем COMMIT_LOGGING,COMMIT_WAIT
-- if nothing helped change COMMIT_LOGGING,COMMIT_WAIT parameters

-- включение statistic aggregation для конкретного модуля: 
-- statistic aggregation for the given module

exec DBMS_MONITOR.serv_mod_act_stat_enable('spur','SQL Loader Conventional Path Load');

-- пользователи в привилегиями на определенные схемы
-- users with priviledges for given schemas

SELECT DISTINCT GRANTEE
  FROM DBA_TAB_PRIVS
 WHERE     OWNER IN ('INTERNALDM', 'INTERNALREP')
       AND GRANTEE NOT IN (SELECT ROLE
                             FROM DBA_ROLES)
UNION
SELECT DISTINCT GRANTEE
  FROM DBA_ROLE_PRIVS
 WHERE GRANTED_ROLE IN
          (SELECT DISTINCT GRANTEE
             FROM DBA_TAB_PRIVS
            WHERE     OWNER IN ('INTERNALDM', 'INTERNALREP')
                  AND GRANTEE IN (SELECT ROLE
                                    FROM DBA_ROLES))
ORDER BY 1;

-- привилегии (права) для отдельного пользователя
-- priviledges for the given user
-- объектные
-- object

SELECT OWNER,
       TABLE_NAME,
       TYPE,
       PRIVILEGE,
       GRANTABLE,
       HIERARCHY,
       CASE GRANTEE
          WHEN 'G_VLASOVSV' THEN 'DIRECT'
          ELSE 'VIA ROLE ' || GRANTEE
       END
          GRANT_WAS_GIVEN
  FROM DBA_TAB_PRIVS
 WHERE GRANTEE = 'G_VLASOVSV'
UNION
SELECT OWNER,
       TABLE_NAME,
       TYPE,
       PRIVILEGE,
       GRANTABLE,
       HIERARCHY,
       CASE GRANTEE
          WHEN 'G_VLASOVSV' THEN 'DIRECT'
          ELSE 'VIA ROLE ' || GRANTEE
       END
  FROM DBA_TAB_PRIVS
 WHERE GRANTEE IN (SELECT DISTINCT GRANTED_ROLE
                     FROM DBA_ROLE_PRIVS
                    WHERE GRANTEE = 'G_VLASOVSV')
ORDER BY 7, 1, 2, 3;

-- системные
-- system
SELECT PRIVILEGE,
       ADMIN_OPTION,
       CASE GRANTEE
          WHEN 'G_VLASOVSV' THEN 'DIRECT'
          ELSE 'VIA ROLE ' || GRANTEE
       END
          GRANT_WAS_GIVEN
  FROM DBA_SYS_PRIVS
 WHERE GRANTEE = 'G_VLASOVSV'
UNION
SELECT PRIVILEGE,
       ADMIN_OPTION,
       CASE GRANTEE
          WHEN 'G_VLASOVSV' THEN 'DIRECT'
          ELSE 'VIA ROLE ' || GRANTEE
       END
  FROM DBA_SYS_PRIVS
 WHERE GRANTEE IN (SELECT DISTINCT GRANTED_ROLE
                     FROM DBA_ROLE_PRIVS
                    WHERE GRANTEE = 'G_VLASOVSV')
ORDER BY 3, 1;

-- Убить PSEUDO|KILLED сессии БД (select * from v$session where STATUS = 'KILLED' order by LOGON_TIME;)
-- kill PSEUDO|KILLED sessions into 

  SELECT PID,
         SPID,
         PNAME,
         PROGRAM
    FROM V$PROCESS
   WHERE     ADDR NOT IN (SELECT PADDR
                            FROM V$SESSION)
         AND PNAME IS NULL
         AND PID <> 1
ORDER BY 2;

--выполнить в ОС
-- execute in OS

  SELECT 'kill -9 ' || SPID
    FROM V$PROCESS
   WHERE     ADDR NOT IN (SELECT PADDR
                            FROM V$SESSION)
         AND PNAME IS NULL
         AND PID <> 1
ORDER BY 1;

-- Использование DRCP (Doc ID 1501987.1)
-- use DRCP (Doc ID 1501987.1)

1) Изменение параметров пула по умолчанию (если требуется):
1) Use default pool parameters:

execute dbms_connection_pool.configure_pool(
pool_name => 'SYS_DEFAULT_CONNECTION_POOL',
minsize => 4,
maxsize => 40,
incrsize => 2,
session_cached_cursors => 20,
inactivity_timeout => 300,
max_think_time => 600,
max_use_session => 500000,
max_lifetime_session => 86400);

или (для одного параметра)
or (for one parameter)

execute dbms_connection_pool.alter_param(
pool_name => 'SYS_DEFAULT_CONNECTION_POOL',
param_name => 'MAX_THINK_TIME',
param_value => '1200');

сброс параметров по умолчанию
restore default parameters

EXECUTE DBMS_CONNECTION_POOL.RESTORE_DEFAULTS();

2) Старт пула:
2) Pool start:

execute dbms_connection_pool.start_pool(); 

3) Стоп пула:
3) Pool stop:

execute dbms_connection_pool.stop_pool(); 

4) Настройки на стороне клиентов:
4) Client side setup:

myhost.dom.com:1521/sales:POOLED
or
(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp) (HOST=myhost.dom.com)
(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=sales)
(SERVER=POOLED)))

5) Представления словаря: DBA_CPOOL_INFO,V$CPOOL_STATS,V$CPOOL_CC_STATS,V$CPOOL_CONN_INFO,V$PROCESS,V$SESSION
5) views for pooling: DBA_CPOOL_INFO,V$CPOOL_STATS,V$CPOOL_CC_STATS,V$CPOOL_CONN_INFO,V$PROCESS,V$SESSION

-- создание SQL-testcase (тесткейса)
-- SQL-testcase creation

How to Create a SQL-testcase Using the DBMS_SQLDIAG Package [Video] (Doc ID 727863.1)

-- исправление ошибки: ORA-04023: Невозможно проверить подлинность  - перекомпилировать затронутые view
-- fix error ORA-04023: - recompile effected views

-- sql result output in HTML:

set markup html on spool on 
SPOOL UNDO_INFO.HTML 
set pagesize 200 
set echo on 

select * from some_table;
--
--

spool off 
set markup html off spool off 

-- проверка sql с помощью SQL Tuning Health-Check Script (SQLHC) (Doc ID 1366133.1)
-- sql check with SQL Tuning Health-Check Script (SQLHC) (Doc ID 1366133.1)

sqlplus / as sysdba

@?/rdbms/admin/sqlhc T <sql_id>

-- replace ampersand (&) in sql scripts

replace & with '||chr(38)||'


Проблема с ORA-27125 при перезапуске остановленного ранее экземпляра БД должна решиться после вот такого изменения (от root):
ORA-27125 when start stopped instance will be solved after executing (as root):

После увеличения параметра 
Increase the parameter

echo 1002 > /proc/sys/vm/hugetlb_shm_group

При импорте матаданных для того, чтобы партиции большего размера НЕ занимали место необходимо изменить параметр:
When imports metadata partitions will not occupy space if the following parameter will be set:

alter system set "_partition_large_extents" = false scope=memory sid = '*';

Выполнение трассировки команды rman (RMAN: Quick Debugging Guide (Doc ID 1198753.1)):
rman commands tracing (RMAN: Quick Debugging Guide (Doc ID 1198753.1)):

nohup rman target / debug trace=/home/oracle/logs/backup_full_db.trc log=/home/oracle/logs/backup_full_db.log cmdfile=/home/oracle/scripts/backup_full_db.rman &

rman debug all trace=srdc_rman_dup_debug_<date>.trc log=srdc_rman_dup_output_<date>.log

Выполнение трассировки вызовов функций oracle:
Tracing call of oracle internal functions:

perf record -g -e cpu-clock -p PID sleep 60 - Эта команда создает файлик perf.data. В зависимоти от его размера подберите длительность sleeр, если он будет слишком большой
perf record -g -e cpu-clock -p PID sleep 60 - This will create the file perf.data. Change sleep if that file is too big

Создание отчета по собранному трейсу: perf report -nv -i perf.data.2 > perf.data.2.report177603
Create the report for gathered trace: perf report -nv -i perf.data.2 > perf.data.2.report177603

ltrace --dl -fo /tmp/dbms_audit_mgmt.trc -p 74907

-- Query with Analytic Windowing Function, Such as ROW_NUMBER OVER PARTITION BY, is Slower in Release 12.1.0.2 (Doc ID 2118138.1)

add /*+ OPT_PARAM('_fix_control' '14826303:OFF') */ hint (see Doc)

Аббревиатуры для чтения 10053 трассировки (optimizer trace)
Abbreviations for 10053 trace reading (optimizer trace)

Legend
The following abbreviations are used by optimizer trace.
CBQT - cost-based query transformation
JPPD - join predicate push-down
OJPPD - old-style (non-cost-based) JPPD
FPD - filter push-down
PM - predicate move-around
CVM - complex view merging
SPJ - select-project-join
SJC - set join conversion
SU - subquery unnesting
OBYE - order by elimination
OST - old style star transformation
ST - new (cbqt) star transformation
CNT - count(col) to count(*) transformation
JE - Join Elimination
JF - join factorization
CBY - connect by
SLP - select list pruning
DP - distinct placement
VT - vector transformation
qb - query block
LB - leaf blocks
DK - distinct keys
LB/K - average number of leaf blocks per key
DB/K - average number of data blocks per key
CLUF - clustering factor
NDV - number of distinct values
Resp - response cost
Card - cardinality
Resc - resource cost
NL - nested loops (join)
SM - sort merge (join)
HA - hash (join)
CPUSPEED - CPU Speed
IOTFRSPEED - I/O transfer speed
IOSEEKTIM - I/O seek time
SREADTIM - average single block read time
MREADTIM - average multiblock read time
MBRC - average multiblock read count
MAXTHR - maximum I/O system throughput
SLAVETHR - average slave I/O throughput
dmeth - distribution method
  1: no partitioning required
  2: value partitioned
  4: right is random (round-robin)
  128: left is random (round-robin)
  8: broadcast right and partition left
  16: broadcast left and partition right
  32: partition left using partitioning of right
  64: partition right using partitioning of left
  256: run the join in serial
  0: invalid distribution method
sel - selectivity
ptn - partition
AP - adaptive plans

Interpreting Raw SQL_TRACE output (Doc ID 39817.1) - for 10046 trace

-- Решение проблем с остановкой/запуском экземпляра, когда shutdown не проходит
-- Solve a problms with instance startup after incorrect shutdown/crash

Startup fail with ORA-29701 & ORA-29702 after the DB crash. (Doc ID 2160481.1)

Identify and clean the orphan shared memory segments and processes from the previously failed instance.

(1) Collect the strace output of the sqlplus session that trying to start the instance.

# strace -fTtt -o /tmp/sql.out sqlplus "/ as sysdba"
(2) Look for the distinct shmid's that oracle process is trying to attach. Compare the size of the shared memory segments and ensure that they match with the SGA of the instance.

Eg:
# egrep shmat /tmp/sql.out

130255  12:39:18.491819  shmat(1903722764, 0, 0) = 0x7ff1a1e00000
130255  12:39:18.491998  shmat(1903722764, 0x4d60000000, 0) = 0x4d60000000
130255  12:39:18.492042  shmat(1903657226, 0x80000000, 0) = 0x80000000
130255  12:39:18.492360  shmat(1903689995, 0x4d40000000, 0) = 0x4d40000000
130255  12:39:18.492422  shmat(1903624457, 0x60000000, 0) = 0x60000000

# ipcs -m

key        shmid      owner  perms  bytes        nattch  status
0xd796c744 1903722764 oracle 640    2097152      1
0x00000000 1903657226 oracle 640    329638739968 9
0x00000000 1903689995 oracle 640    144703488    1
0x00000000 1903624457 oracle 640    8388608      1

(3) Ensure that there no live processes attached to the orphan memory segments.

# lsof | grep SYSV > SYSV_refs.out
# egrep <shmid> SYSV_refs.out
# ps -elf | grep <pid from lsof>
(4) If there are no processes attached, we can safely remove the orphan shared memory segments. Once the shared memory segments from the previous instances are cleaned up, we shouldn't see ORA-29701 anymore.

# ipcrm -m <shmid>

либо выполняем для проблемного экземпляра БД:
or execute for the problem db instance:
sysresv -i

# work with bind variables from sqlplus

variable B1 NUMBER;
variable B2 VARCHAR2(32);
variable B3 VARCHAR2(32);
variable B4 VARCHAR2(32);
exec :B1:=11487609;
exec :B2:='A';
exec :B3:='Y';
exec :B4:='01/02/2019 00:00:00';
select :B1,TO_DATE(:B4,'dd/mm/yyyy hh24:mi:ss') as result from dual;

# AWR info and size

sho parameter statistic_level

$ORACLE_HOME/rdbms/admin/awrinfo.sql
--estimate awr size
utlsyxsz.sql

modify AWR settings:
execute dbms_workload_repository.modify_snapshot_settings(interval => 60,retention => 1576800);

# How to Recreate a Controlfile (Doc ID 735106.1) - if DB is not mounted also

# select object DDL from sqlplus :
spo v.sql
set long 200000 pages 0 lines 131 feedback off
select dbms_metadata.get_ddl('PROCEDURE','CUST_ACNT_NUMBER','OWS') from dual;
spo off

#find ORACLE_HOME for INSTANCE on linux (in this example instance_name is irisdbdr)

pwdx `ps -ef | grep pmon | grep irisdbdr | cut -f4 -d' '` | cut -f2 -d':'

# parallelism related instance parameters (for way4 the same values for all in Solaris):

parallel_min_servers
parallel_max_servers
parallel_threads_per_cpu --4 for M8 CPU
parallel_servers_target

#Oracle Forms and Reports 12c (12.2.1) Installation on Oracle Linux 6 and 7

# OL6 and OL7
yum install binutils -y
yum install compat-libcap1 -y
yum install compat-libstdc++-33 -y
yum install compat-libstdc++-33.i686 -y
yum install gcc -y
yum install gcc-c++ -y
yum install glibc -y
yum install glibc.i686 -y
yum install glibc-devel -y
yum install glibc-devel.i686 -y
yum install libaio -y
yum install libaio-devel -y
yum install libgcc -y
yum install libgcc.i686 -y
yum install libstdc++ -y
yum install libstdc++.i686 -y
yum install libstdc++-devel -y
yum install ksh -y
yum install make -y
yum install sysstat -y

# OL6 Only
yum install libXext.i686 -y
yum install libXtst.i686 -y
yum install openmotif -y
yum install openmotif22 -y

# OL7 Only
yum install ocfs2-tools -y
yum install motif -y
yum install motif-devel -y
yum install numactl -y
yum install numactl-devel -y

https://oracle-base.com/articles/12c/weblogic-installation-on-oracle-linux-6-and-7-1221 --weblogic
https://oracle-base.com/articles/12c/oracle-forms-and-reports-12c-installation-on-oracle-linux-6-and-7 --forms and reports
https://oracle-base.com/articles/12c/weblogic-repository-configuration-utility-1221 --connect to repository

-- clone existing oracle home (new location is /u01/app/oracle/product/12.1.0/dbhome_1):

export ORACLE_HOME=/oracle/app/product/12.1.0/dbhome_1
cd $ORACLE_HOME/oui/bin
./runInstaller -clone -silent -ignorePreReq ORACLE_HOME="/u01/app/oracle/product/12.1.0/dbhome_1" ORACLE_HOME_NAME="dbhome_12gR2" ORACLE_BASE="/u01/app/oracle" OSDBA_GROUP=dba OSOPER_GROUP=oinstall 

--reduce concurrency (cursor pin S, cursor: pins S wait for X)

use alternative mutex wait scheme, parameter:
*._mutex_wait_scheme=1 

-- ENABLE SSL FOR Oracle Db connections

easy: https://oracle-base.com/articles/misc/native-network-encryption-for-database-connections

in sqlnet.ora:

--client
SQLNET.ENCRYPTION_CLIENT=REQUIRED
SQLNET.ENCRYPTION_TYPES_CLIENT=(AES256)

--server
SQLNET.ENCRYPTION_SERVER=REQUESTED
SQLNET.ENCRYPTION_TYPES_SERVER=(AES256)

with sertificates:
https://oracle-base.com/articles/misc/configure-tcpip-with-ssl-and-tls-for-database-connections 

--configuration with encryption of ONE particular client ONLY (Doc ID 76629.1):

If we want to force encryption from a client, while not affecting any other connections to the server,
we would add the following to the client "sqlnet.ora" file.
The server does not need to be altered as the default settings (ACCEPTED and no named encryption algorithm)
will allow it to successfully negotiate a connection.

--client
SQLNET.ENCRYPTION_CLIENT=REQUIRED

If we would prefer clients to use encrypted connections to the server, but will accept non-encrypted connections,
we would add the following to the server side "sqlnet.ora".

--server
SQLNET.ENCRYPTION_SERVER=REQUESTED

-- ADD additionaly (to resolve TNS-12592 error in listener log)
--client
SQLNET.SEND_TIMEOUT=600

-- Find biggest dfference between 2 rows in of the same table example (100 rows with biggest difference)

     SELECT QUEUERECORDID,
              LEAD (QUEUERECORDID, 1, 0) OVER (ORDER BY QUEUERECORDID)
            - QUEUERECORDID    AS DEFFERENCE
       FROM DPUSER.PAYMENTFACTQUEUEPERSIST
   ORDER BY   LEAD (QUEUERECORDID, 1, 0) OVER (ORDER BY QUEUERECORDID)
            - QUEUERECORDID DESC
FETCH FIRST 100 ROWS ONLY;


-- calculate date difference using interval:

select sysdate - interval '3' minute from dual;

-- RAC

Best Practices and Recommendations for RAC databases with SGA size over 100GB (Doc ID 1619155.1)

--necessary Oracle parameters for RAC for decrease interconnect related events:

_gc_override_force_cr FALSE   
_gc_override_force_cr FALSE
_gc_persistent_read_mostly FALSE   
_gc_read_mostly_locking FALSE
_clusterwide_global_transactions FALSE   
_cr_grant_local_role TRUE
_high_priority_processes LMS*|LGWR|LM*|LG*|LCK0|GCR*|CKPT|DBRM|RMS0|CR*|RMV*|LM*|LCK0|CKPT|DBRM|RMS0|LGWR|CR*|RS0*|RS1*|RS2*

private interconnect OsWatcher private.net file example (names are from /etc/hosts of one RAC node, node 2):

	
Node 1 have 2 private interconnect IPs:

xx.59.169.40 unidbdomdr1-1-priv
xx.59.179.40 unidbdomdr1-2-priv

Node 2 have 2 private interconnect IPs:

xx.59.169.41 unidbdomdr2-1-priv
xx.59.179.41 unidbdomdr2-2-priv

Node 1:
grid@unidbdomdr1:/grid/OSwatcher/oswbb$ cat private.net
echo "zzz ***"`date`
traceroute -s xx.59.169.40 -r -F xx.59.169.41 1472
traceroute -s xx.59.179.40 -r -F xx.59.179.41 1472
rm locks/lock.file

Node 2:
grid@unidbdomdr2:/grid/OSwatcher/oswbb$ cat private.net
echo "zzz ***"`date`
traceroute -s xx.59.169.41 -r -F xx.59.169.40 1472
traceroute -s xx.59.179.41 -r -F xx.59.179.40 1472
rm locks/lock.file

--Using the PL/SQL Hierarchical Profiler
The profiler reports the dynamic execution profile of a PL/SQL program organized by function calls, and accounts for SQL and PL/SQL execution times separately. 
No special source or compile-time preparation is required; any PL/SQL program can be profiled.

by sys:
CREATE DIRECTORY PLSHPROF_DIR as '/private/plshprof/results';
GRANT READ, WRITE ON DIRECTORY PLSHPROF_DIR TO OWS_A;

Add before and after DB activity launch point (menu item)
DBMS_HPROF.START_PROFILING('PLSHPROF_DIR', 'test.trc');
DBMS_HPROF.STOP_PROFILING;

--example
begin DBMS_HPROF.start_profiling( location=>'PROFILER_DIR', filename=>'profiler'||sys_context('USERENV', 'SID')||'.txt'); end;
begin DBMS_HPROF.stop_profiling;end;

Run db activity for analysis

By oracle on server side:
% cd target_directory
% plshprof -output html_root_filename profiler_output_filename

--How to identify table fragmentation and remove it: https://blog.yannickjaquier.com/oracle/table-fragmentation-identification.html

--analyze segment fragmentation using temporary table in the DB:

drop table opt_segments_stats;
create table opt_segments_stats (
    stat_date                   date,
    owner                       varchar2(255),
    segment_name                varchar2(255),
    segment_type                varchar2(255),
    partition_name              varchar2(255),
    tablespace_name             varchar2(255),
    unformatted_blocks          number,
    unformatted_bytes           number,
    fs1_blocks                  number,
    fs1_bytes                   number,
    fs2_blocks                  number,
    fs2_bytes                   number,
    fs3_blocks                  number,
    fs3_bytes                   number,
    fs4_blocks                  number,
    fs4_bytes                   number,
    full_blocks                 number,
    full_bytes                  number,
    total_blocks                number,
    total_bytes                 number,
    unused_blocks               number,
    unused_bytes                number,
    last_used_extent_file_id    number,
    last_used_extent_block_id   number,
    last_used_block             number,
    segment_fragmentation       number
);

-- fragmentation stats collection

declare
    segstat     opt_segments_stats  %rowtype;
begin
    segstat.stat_date := sysdate;
    segstat.owner := 'OWS';
    
    for rec in(
        select
            segment_name,
            partition_name,
            segment_type,
            tablespace_name
        from dba_segments
        where owner = segstat.owner
            and (segment_type like 'TABLE%'
            or segment_type like 'INDEX%')
            and extents > 1
        order by bytes desc
    ) loop
        segstat.segment_name := rec.segment_name;
        segstat.partition_name := rec.partition_name;
        segstat.segment_type := rec.segment_type;
        segstat.tablespace_name := rec.tablespace_name;
        
        dbms_space.space_usage(
            segstat.owner,
            segstat.segment_name,
            segstat.segment_type,
            segstat.unformatted_blocks,
            segstat.unformatted_bytes,
            segstat.fs1_blocks,
            segstat.fs1_bytes,
            segstat.fs2_blocks,
            segstat.fs2_bytes,
            segstat.fs3_blocks,
            segstat.fs3_bytes,
            segstat.fs4_blocks,
            segstat.fs4_bytes,
            segstat.full_blocks,
            segstat.full_bytes,
            segstat.partition_name
        );
        
        dbms_space.unused_space(
            segstat.owner,
            segstat.segment_name,
            segstat.segment_type,
            segstat.total_blocks,
            segstat.total_bytes,
            segstat.unused_blocks,
            segstat.unused_bytes,
            segstat.last_used_extent_file_id,
            segstat.last_used_extent_block_id,
            segstat.last_used_block,
            segstat.partition_name
        );
        
        segstat.segment_fragmentation := round((segstat.fs4_blocks*0.875 + segstat.fs3_blocks*0.625 + segstat.fs2_blocks*0.375 + 
            segstat.fs1_blocks*0.125 + segstat.unformatted_blocks) / segstat.total_blocks * 100, 2);
        
        insert into opt_segments_stats values segstat;
        
        commit;
    end loop;
end;
/


--see results

select stat_date, owner, segment_name, segment_type, partition_name, tablespace_name, round(total_bytes/1024/1024/1024, 2) gb, segment_fragmentation
from opt_segments_stats
where segment_type like 'TABLE%'
order by stat_date desc, gb desc
;


-- instance consolidation in one server (enable instance caging) Doc ID 1362445.1:

ALTER SYSTEM SET CPU_COUNT = 4;
--for 11g the only 2 plans may be used: DEFAULT_PLAN or DEFAULT_MAINTENANCE_PLAN

alter system set resource_manager_plan = 'default_plan'; --*.resource_manager_plan='default_plan'

select name from v$rsrc_plan where is_top_plan = 'TRUE' and cpu_managed ='ON';

--Monitoring Throttling
select begin_time, consumer_group_name, cpu_consumed_time, cpu_wait_time from v$rsrcmgrmetric_history order by begin_time;
select to_char(begin_time, 'HH24:MI') time, sum(avg_running_sessions) avg_running_sessions, sum(avg_waiting_sessions) avg_waiting_sessions from v$rsrcmgrmetric_history group by begin_time order by begin_time;

--Information for resolve/troubleshoot patches conflicts

1) download latest TFA Support Tools Bundle (See Doc:1594347.1) and generate output using the command:
2) $TFA_HOME/bin/tfactl diagcollect -srdc dbdatapatch

-- JAVA / JDBC official information

https://www.oracle.com/database/technologies/faq-jdbc.html (see What are the Oracle JDBC releases Vs JDK versions?)

-- convert raw TIMESTAMP as HEXDUMP to date:

select to_timestamp(
        to_char( to_number( substr( p_str, 1, 2 ), 'xx' ) - 100, 'fm00' ) ||
        to_char( to_number( substr( p_str, 3, 2 ), 'xx' ) - 100, 'fm00' ) ||
        to_char( to_number( substr( p_str, 5, 2 ), 'xx' ), 'fm00' ) ||
        to_char( to_number( substr( p_str, 7, 2 ), 'xx' ), 'fm00' ) ||
        to_char( to_number( substr( p_str,9, 2 ), 'xx' )-1, 'fm00' ) ||
        to_char( to_number( substr( p_str,11, 2 ), 'xx' )-1, 'fm00' ) ||
        to_char( to_number( substr( p_str,13, 2 ), 'xx' )-1, 'fm00' ), 'yyyymmddhh24miss' )
from (select '&raw_timestamp' p_str from dual);

-- dimp data block into the trace file 

oradebug setmypid
alter system dump datafile 691 block 64180 ;
oradebug tracefile_name

-- setup for prevent remastering for particular physical object in the database

Get the OBJECT_ID for the required_object object from dba_objects.
Run below query and provide the output (check before and AFTER remastering):

select * from v$gcspfmaster_info where object_id=<object id for DOC object>

manually remaster an object with oradebug command:

sqlplus "/as sysdba"
SQL> oradebug setmypid
SQL> oradebug lkdebug -m pkey <object_id> <instance_id>

-- rman dupicate DB into particular folder:
in run block before restoration:
SET NEWNAME FOR DATABASE TO '/w4merppdb/%b'; 

--Upgrade To Oracle 19c Using Newly Introduced AutoUpgrade.jar

-- insert random % (percent) of rows from one table into another table

set timing on echo on feedback on
alter session force parallel DML;
insert /*+ APPEND PARALLEL(8) */ into XLS_ADMIN.TC_TXN_STG_1 select /*+ PARALLEL(8) */ * from XLS_ADMIN.TC_TXN sample(5);
commit;
alter session disable parallel DML;

-- parameters for OFA (common in masterfile):

DB files:    DB_CREATE_FILE_DEST and DB_CREATE_ONLINE_LOG_DEST_1
Archivelogs: DB_RECOVERY_FILE_DEST 

--SRDC - Required Diagnostic Data Collection for ORA-01578 (Doc ID 1671531.1)

tfactl diagcollect -srdc ora1578

-- How to Analyze an ORA-12801 (Doc ID 1187823.1), ORA-12801: error signaled in parallel query server P001

ALTER SYSTEM SET EVENTS '10397 trace name context forever, level 1';

-- multitenant connections for oracle DB (from 12.1):

https://oracle-base.com/articles/12c/multitenant-connecting-to-cdb-and-pdb-12cr1

-- show all pdbs
show pdbs

-- current contaiers in the DB

col pdb for A30
SELECT CON_ID,name, pdb FROM   v$services order by 1;

-- show current container

SHOW CON_NAME
--or
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') FROM   dual;

--set container

ALTER SESSION SET CONTAINER=bwpdb; --pdb1

--open PDB after CDB restart:

ALTER database open;
--or
alter pluggable database all open;
--for save state after open 
alter pluggable database all save state;
--check saved states
select con_name, state from dba_pdb_saved_states;

-- tnsnames.ora connection to the container DB example

SQL> CONN system/password@pdb1

The connection using a TNS alias requires an entry in the "$ORACLE_HOME/network/admin/tnsnames.ora" file, such as the one shown below.
PDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ol6-121.localdomain)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = pdb1)
    )
  )
  
--JDBC Connections to PDBs
--It has already been mentioned that you must connect to a PDB using a service. This means that by default many JDBC connect strings will be broken. 
--Valid JDBC connect strings for Oracle use the following format.

# Syntax
jdbc:oracle:thin:@[HOST][:PORT]:SID
jdbc:oracle:thin:@[HOST][:PORT]/SERVICE
# Example
jdbc:oracle:thin:@ol6-121:1521:pdb1
jdbc:oracle:thin:@ol6-121:1521/pdb1

When attempting to connect to a PDB using the SID format, you will receive the following error.
ORA-12505, TNS:listener does not currently know of SID given in connect descriptor
Ideally, you would correct the connect string to use services instead of SIDs, but if that is a problem the USE_SID_AS_SERVICE_listener_name listener parameter can be used.
Edit the "$ORACLE_HOME/network/admin/listener.ora" file, adding the following entry, with the "listener" name matching that used by your listener.
USE_SID_AS_SERVICE_listener=on
Reload or restart the listener.
$ lsnrctl reload

-- data guard manager utility
--connect as sys without password
dgmgrl / 

--check data guard apply/transport gap
--https://franckpachot.medium.com/where-to-check-data-guard-gap-e1ccadc8f41
--You must always check when the value was calculated (TIME_COMPUTED) and may add this to gap to estimate the gap from the current time

select name||' '||value ||' '|| unit ||' computed at '||time_computed from v$dataguard_stats;

--config transparent TNS services for primary/standby:

1) add local listener for each DB
*.local_listener='(ADDRESS=(PROTOCOL=TCP)(HOST=xx.2xx.100.52)(PORT=1561))'
2) add DB in CW (if was not added before)
3) configure services for both DB (primary/standby) for both roles:

primary side example:
srvctl add service -d way4dwhp -service way4dwhp_primary -role PRIMARY 
srvctl add service -d way4dwhp -service way4dwhp_standby -role PHYSICAL_STANDBY

Standby side example:
srvctl add service -d way4dwhpSTBY -service way4dwhp_primary -role PRIMARY
srvctl add service -d way4dwhpSTBY -service way4dwhp_standby -role PHYSICAL_STANDBY

4) TNS descriptor look like this (for each service)

way4dwhp_standby =
  (DESCRIPTION =
     (ADDRESS_LIST =
       (FAILOVER = ON)
       (LOAD_BALANCE = OFF)
       (ADDRESS = (PROTOCOL = TCP)(HOST = xx.2xx.100.52)(PORT = 1561))
       (ADDRESS = (PROTOCOL = TCP)(HOST = xx.1xx.100.52)(PORT = 1561))
     )
    (CONNECT_DATA =
       (SERVICE_NAME = way4dwhp_standby)
    )
  )
  
-- DOP downgrade reasons (doc ID for tracing is 444164.1):

SELECT
  indx
  ,qksxareasons
FROM
  x$qksxa_reason
WHERE
  qksxareasons like '%DOP downgrade%';

--find in AWR for particular SQL_ID  
  
 select SID,sql_id,sql_exec_id, sql_exec_start,
    case otherstat_2_value
    when 350 then 'DOP downgrade due to adaptive DOP'
    when 351 then 'DOP downgrade due to resource manager max DOP'
    when 352 then 'DOP downgrade due to insufficient number of processes'
    when 353 then 'DOP downgrade because slaves failed to join'
    end reason_for_downgrade
   from GV$SQL_PLAN_MONITOR
   where sql_id = '3f3f4gfzdwwe'
     and plan_operation='PX COORDINATOR'
     and  otherstat_2_id=59
   order by sql_exec_id;

350 DOP downgrade due to adaptive DOP
351 DOP downgrade due to resource manager max DOP
352 DOP downgrade due to insufficient number of processes
353 DOP downgrade because slaves failed to join

Optimizer environment parameter views are based on fixed table views
V$SYS_OPTIMIZER_ENV	X$QKSCESYS
V$SES_OPTIMIZER_ENV	X$QKSCESES
V$SQL_OPTIMIZER_ENV	X$KQLFSQCE
--list unsupported optimizer parameters (internal sys view):

SELECT pname_qkscesyrow,PVALUE_QKSCESYROW,FID_QKSCESYROW FROM x$qkscesys WHERE SUBSTR (pname_qkscesyrow,1,1) = '_' ORDER BY 1;

-- ASM instance related activities

discover mounted DG stats (for GI owner, ASM instance profile)

asmcmd lsdg -g --discovery

--mount ASM DG in force mode (to find missing disks when the error ORA-15040 appeared while mounting the ASM DG)

sqlplus / as sysasm
alter diskgroup W4PRF01_DATA_DG mount force;

--now we can query all the disks of this diskgroup that are either available or unavailable

select name,path,state,header_status from v$asm_disk where group_number=0;


