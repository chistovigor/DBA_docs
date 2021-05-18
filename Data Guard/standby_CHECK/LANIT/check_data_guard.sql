SPOOL check_data_guard.log

PROMPT *** instance at server 10.243.12.45 current status ***

connect sys/spotlight@LANIT_LIVE as sysdba;

column STARTUP_TIME   format A25
column INSTANCE_NAME  format A10
column HOST_NAME      format A16
column STARTED        format A25
column DESTINATION    format A35
column CHANGE_TIME    format A25

select INSTANCE_NAME,HOST_NAME,to_char(STARTUP_TIME,'dd/mm/yyyy hh24:mi:ss') as STARTED,STATUS from v$instance;

select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;

SELECT DESTINATION, STATUS, ARCHIVED_THREAD#, ARCHIVED_SEQ# FROM V$ARCHIVE_DEST_STATUS
 WHERE STATUS <> 'DEFERRED' AND STATUS <> 'INACTIVE';

PROMPT *** archived logs ***

column first_time  format A25

select to_char(first_time,'dd/mm/yyyy hh24:mi:ss') as CHANGE_TIME,SEQUENCE# from V$LOG_HISTORY where SEQUENCE# = (SELECT MAX(SEQUENCE#) FROM V$LOG_HISTORY);

PROMPT *** instance at server 10.243.112.45 current status ***

connect sys/spotlight@LANIT_STB as sysdba;

select INSTANCE_NAME,HOST_NAME,to_char(STARTUP_TIME,'dd/mm/yyyy hh24:mi:ss') as STARTED,STATUS from v$instance;

select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;

SELECT DESTINATION, STATUS, ARCHIVED_THREAD#, ARCHIVED_SEQ# FROM V$ARCHIVE_DEST_STATUS
 WHERE STATUS <> 'DEFERRED' AND STATUS <> 'INACTIVE';

PROMPT *** archived logs ***

select to_char(first_time,'dd/mm/yyyy hh24:mi:ss') as CHANGE_TIME,SEQUENCE# from V$LOG_HISTORY where SEQUENCE# = (SELECT MAX(SEQUENCE#) FROM V$LOG_HISTORY);

SPOOL OFF

exit;
