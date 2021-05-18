BEGIN
  SYS.DBMS_SCHEDULER.DROP_JOB
    (job_name  => 'DBMAN.ATM_ALPHA_TO_SITE_JOB');
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'DBMAN.ATM_ALPHA_TO_SITE_JOB'
      ,start_date      => TO_TIMESTAMP_TZ('2014/02/27 17:00:00.308000 Europe/Moscow','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=DAILY;BYHOUR=1;BYMINUTE=0;BYSECOND=0'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'PLSQL_BLOCK'
      ,job_action      => 'begin
-- insert data into remote DB
 ATM_ALPHA_TO_SITE;
-- check insert status and send to zabbix (atm2site_status key name)
 ATM_ALPHA_TO_SITE_CHECK;
end;'
      ,comments        => 'daily insert data about active ATMs into remote DB using DBlink DBO'
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'DBMAN.ATM_ALPHA_TO_SITE_JOB'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'DBMAN.ATM_ALPHA_TO_SITE_JOB'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_FULL);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'DBMAN.ATM_ALPHA_TO_SITE_JOB'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'DBMAN.ATM_ALPHA_TO_SITE_JOB'
     ,attribute => 'MAX_RUNS');
  BEGIN
    SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
      ( name      => 'DBMAN.ATM_ALPHA_TO_SITE_JOB'
       ,attribute => 'STOP_ON_WINDOW_CLOSE'
       ,value     => FALSE);
  EXCEPTION
    -- could fail if program is of type EXECUTABLE...
    WHEN OTHERS THEN
      NULL;
  END;
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'DBMAN.ATM_ALPHA_TO_SITE_JOB'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'DBMAN.ATM_ALPHA_TO_SITE_JOB'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'DBMAN.ATM_ALPHA_TO_SITE_JOB'
     ,attribute => 'AUTO_DROP'
     ,value     => FALSE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'DBMAN.ATM_ALPHA_TO_SITE_JOB');
END;
/
