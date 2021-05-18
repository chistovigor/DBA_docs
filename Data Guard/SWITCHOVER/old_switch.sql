[oracle@s-msk08-atmdb01 /usr/local/bin/scripts/SWITCHOVER]$ cat sw_primary2standby.sh
#!/bin/bash
echo SQLplus started at `date`
sqlplus / as sysdba < sw_primary2standby.sql
[oracle@s-msk08-atmdb01 /usr/local/bin/scripts/SWITCHOVER]$ cat sw_primary2standby.sql
spool sw_primary2standby.log

set linesize 300
column HOST_NAME format a15
column STARTUP_TIME format a15
column DESTINATION format a20

PROMPT *** current DB instance info ***

select INSTANCE_NAME,HOST_NAME,STARTUP_TIME,DATABASE_STATUS,INSTANCE_ROLE from v$instance;

select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;

SELECT DESTINATION, STATUS, ARCHIVED_THREAD#, ARCHIVED_SEQ# FROM V$ARCHIVE_DEST_STATUS
 WHERE STATUS <> 'DEFERRED' AND STATUS <> 'INACTIVE';

PROMPT *** shutdown current primary DB ***

ALTER SYSTEM ARCHIVE LOG CURRENT;

ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;

SHUTDOWN IMMEDIATE;

PROMPT *** connect to the primary DB and open it as standby ***

connect / as sysdba;

STARTUP NOMOUNT;

ALTER DATABASE MOUNT STANDBY DATABASE;

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

PROMPT *** current DB instance info after switchover ***

select INSTANCE_NAME,HOST_NAME,STARTUP_TIME,DATABASE_STATUS,INSTANCE_ROLE from v$instance;

select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;

SELECT DESTINATION, STATUS, ARCHIVED_THREAD#, ARCHIVED_SEQ# FROM V$ARCHIVE_DEST_STATUS
 WHERE STATUS <> 'DEFERRED' AND STATUS <> 'INACTIVE';

spool off

exit

[oracle@s-msk08-atmdb01 /usr/local/bin/scripts/SWITCHOVER]$ cat sw_standby2primary.sh
#!/bin/bash
echo SQLplus started at `date`
sqlplus / as sysdba < sw_standby2primary.sql
[oracle@s-msk08-atmdb01 /usr/local/bin/scripts/SWITCHOVER]$ cat sw_standby2primary.sql
spool sw_stabdby2primary.log

set linesize 300
column HOST_NAME format a15
column STARTUP_TIME format a15
column DESTINATION format a20

PROMPT *** current DB instance info ***

select INSTANCE_NAME,HOST_NAME,STARTUP_TIME,DATABASE_STATUS,INSTANCE_ROLE from v$instance;

select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;

SELECT DESTINATION, STATUS, ARCHIVED_THREAD#, ARCHIVED_SEQ# FROM V$ARCHIVE_DEST_STATUS
 WHERE STATUS <> 'DEFERRED' AND STATUS <> 'INACTIVE';

PROMPT *** shutdown current standby DB ***

ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;

SHUTDOWN IMMEDIATE;

PROMPT *** open the standby DB as primary ***

STARTUP MOUNT;

ALTER DATABASE OPEN;

PROMPT *** current DB instance info after switchover ***

select INSTANCE_NAME,HOST_NAME,STARTUP_TIME,DATABASE_STATUS,INSTANCE_ROLE from v$instance;

select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;

SELECT DESTINATION, STATUS, ARCHIVED_THREAD#, ARCHIVED_SEQ# FROM V$ARCHIVE_DEST_STATUS
 WHERE STATUS <> 'DEFERRED' AND STATUS <> 'INACTIVE';

spool off

exit
