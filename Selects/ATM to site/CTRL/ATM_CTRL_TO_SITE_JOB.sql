BEGIN
sys.dbms_scheduler.create_job(
job_name => '"ROUTER"."ATM_CTRL_TO_SITE_JOB"',
job_type => 'PLSQL_BLOCK',
job_action => 'begin
 ATM_CTRL_TO_SITE;
end;',
repeat_interval => 'FREQ=MINUTELY;INTERVAL=30',
start_date => systimestamp at time zone 'Europe/Moscow',
job_class => 'DEFAULT_JOB_CLASS',
comments => 'daily insert data about active ATMs into remote DB using DBlink DBO',
auto_drop => FALSE,
enabled => FALSE);
sys.dbms_scheduler.set_attribute( name => '"ROUTER"."ATM_CTRL_TO_SITE_JOB"', attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_FULL);
sys.dbms_scheduler.enable( '"ROUTER"."ATM_CTRL_TO_SITE_JOB"' );
END;