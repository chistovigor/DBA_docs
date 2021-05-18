Doc ID 1901113.1 - How to Collect Standard Information for Database Auditing

Be careful when doing any type of maintenance on the AUD$ or FGA_LOG$ tables that
might cause them to get locked or otherwise unavailable if you are currently auditing. I
have seen this happen on a database that is auditing logon/logoff activity and it quickly
causes a bottleneck as no one will be able to login. You should turn off auditing with the
NOAUDIT command before moving the table to another tablespace.

As of 11g, there is the DBMS_AUDIT_MGMT package that can be used to manage the
audit data. Here is a 6-step process than can be used to manage your audit data. This
will maintain 90 days worth of records in SYS.AUD$ as well as 90 days worth of OS
audit files in audit_file_dest.

Step 1: create a new tablespace

create tablespace AUDIT_DATA datafile '+DATA' size 2g
autoextend on;

Step 2: Move SYS.AUD$ to dedicated tablespace.

Note: This should be done during a slow period or you should turn off session auditing first

begin
DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_DB_STD,
AUDIT_TRAIL_LOCATION_VALUE => 'AUDIT_DATA');
end;
/

Step 3: Initialize the Cleanup process and set the Cleanup interval

begin
DBMS_AUDIT_MGMT.INIT_CLEANUP(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,
DEFAULT_CLEANUP_INTERVAL => 12 );
end;
/

Step 4: Set the archive timestamp to sysdate-90. This tells the clean-up job to delete everything older than 90 days.

begin
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
LAST_ARCHIVE_TIME => sysdate-90);
end;
/

begin
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,
LAST_ARCHIVE_TIME => sysdate-90);
end;
/

Step 5: Create the Purge job
 
begin
DBMS_AUDIT_MGMT.CREATE_PURGE_JOB (
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,
AUDIT_TRAIL_PURGE_INTERVAL => 12,
AUDIT_TRAIL_PURGE_NAME => 'AUDIT_TRAIL_PURGE',
USE_LAST_ARCH_TIMESTAMP => TRUE );
end;
/

Step 6: schedule a job to automatically advance the
last_archive_timestamp

grant execute on DBMS_AUDIT_MGMT to ardb_user;
grant audit_admin to ardb_user;

CREATE OR REPLACE procedure ARDB_USER.set_archive_retention (retention in number default 365) as
begin
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
last_archive_time => SYSDATE - retention);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
last_archive_time => SYSDATE - retention);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP (
AUDIT_TRAIL_TYPE  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD,
LAST_ARCHIVE_TIME => SYSDATE - retention);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,
LAST_ARCHIVE_TIME => SYSDATE - retention/8,
rac_instance_number => 1);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,
LAST_ARCHIVE_TIME => SYSDATE - retention/8,
rac_instance_number => 1);
end;
/

BEGIN
  SYS.DBMS_SCHEDULER.DROP_JOB
    (job_name  => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP');
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
      ,start_date      => TO_TIMESTAMP_TZ('2017/02/24 22:00:00.000000 +03:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'freq=daily'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'PLSQL_BLOCK'
      ,job_action      => 'BEGIN
SET_ARCHIVE_RETENTION;
END;'
      ,comments        => NULL
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_FULL);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'AUTO_DROP'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'RESTART_ON_RECOVERY'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'RESTART_ON_FAILURE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'STORE_OUTPUT'
     ,value     => TRUE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP');
END;
/

-- ENABLE UNIFIED AUDIT

--enable (shutdown DB first)

cd $ORACLE_HOME/rdbms/lib
make -f ins_rdbms.mk uniaud_on ioracle ORACLE_HOME=$ORACLE_HOME

--disable (shutdown DB first)

cd $ORACLE_HOME/rdbms/lib
make -f ins_rdbms.mk uniaud_off ioracle ORACLE_HOME=$ORACLE_HOME

-- set last archive timestamp for other types of audit

SELECT * FROM DBA_AUDIT_MGMT_LAST_ARCH_TS;
 
EXEC DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,SYSTIMESTAMP-365);
EXEC DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,ADD_MONTHS(SYSTIMESTAMP,-2),1);

--move audit in other TS (AUDIT_DATA)

BEGIN
DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION(
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_DB_STD,
audit_trail_location_value => 'AUDIT_DATA');
END;

BEGIN
DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION(
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
audit_trail_location_value => 'AUDIT_DATA');
END;

-- writes the unified audit trail records in the SGA queue to disk

exec DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL;

select DBMS_AUDIT_MGMT.GET_AUDIT_COMMIT_DELAY from dual;

--Step 3: Initialize the Cleanup process and set the Cleanup interval

begin
DBMS_AUDIT_MGMT.INIT_CLEANUP(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,
DEFAULT_CLEANUP_INTERVAL => 24 );
end;
/

--Step 4: Set the archive timestamp to sysdate-365*2. This tells the clean-up job to delete everything older than 2 years.

begin
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_DB_STD,
LAST_ARCHIVE_TIME => sysdate-365);
end;
/

begin
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
LAST_ARCHIVE_TIME => sysdate-365);
end;
/

begin
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,
LAST_ARCHIVE_TIME => ADD_MONTHS(sysdate,-2));
end;
/

--Step 5: Create the Purge job
 
begin
DBMS_AUDIT_MGMT.CREATE_PURGE_JOB (
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,
AUDIT_TRAIL_PURGE_INTERVAL => 24,
AUDIT_TRAIL_PURGE_NAME => 'AUDIT_TRAIL_PURGE',
USE_LAST_ARCH_TIMESTAMP => TRUE );
end;
/

--Step 6: schedule a job to automatically advance the last_archive_timestamp

grant execute on DBMS_AUDIT_MGMT to ardb_user;
grant audit_admin to ardb_user;

CREATE OR REPLACE procedure ARDB_USER.set_archive_retention (retention in number default 365) as
begin
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
last_archive_time => SYSDATE - retention);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
last_archive_time => SYSDATE - retention);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP (
AUDIT_TRAIL_TYPE  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD,
LAST_ARCHIVE_TIME => SYSDATE - retention);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,
LAST_ARCHIVE_TIME => SYSDATE - retention/8,
rac_instance_number => 1);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,
LAST_ARCHIVE_TIME => SYSDATE - retention/8,
rac_instance_number => 1);
end;
/

BEGIN
  SYS.DBMS_SCHEDULER.DROP_JOB
    (job_name  => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP');
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
      ,start_date      => TO_TIMESTAMP_TZ('2017/02/24 22:00:00.000000 +03:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'freq=daily'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'PLSQL_BLOCK'
      ,job_action      => 'BEGIN
SET_ARCHIVE_RETENTION;
END;'
      ,comments        => NULL
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_FULL);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'AUTO_DROP'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'RESTART_ON_RECOVERY'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'RESTART_ON_FAILURE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP'
     ,attribute => 'STORE_OUTPUT'
     ,value     => TRUE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'ARDB_USER.ADVANCE_ARCHIVE_TIMESTAMP');
END;
/
