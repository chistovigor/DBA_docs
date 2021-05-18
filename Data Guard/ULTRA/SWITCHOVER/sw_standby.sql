spool sw_stabdby.log

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

