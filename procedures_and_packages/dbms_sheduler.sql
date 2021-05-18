BEGIN
sys.dbms_scheduler.set_attribute( name => '"SYS"."SQLSCRIPT_20140214_TABLE"', attribute => 'job_action', value => ' begin
execute immediate ''alter table "VSMC3DS"."DDDSPROC_TRNATTR_INFO_ARC" shrink space'';
 end; ');
sys.dbms_scheduler.set_attribute( name => '"SYS"."SQLSCRIPT_20140214_TABLE"', attribute => 'start_date', value => to_timestamp_tz('2014-02-14 04:30:00 +4:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'));
sys.dbms_scheduler.set_attribute( name => '"SYS"."SQLSCRIPT_20140214_TABLE"', attribute => 'comments', value => 'DDDSPROC_TRNATTR_INFO_ARC');
sys.dbms_scheduler.set_attribute( name => '"SYS"."SQLSCRIPT_20140214_TABLE"', attribute => 'raise_events', value => dbms_scheduler.job_started + dbms_scheduler.job_succeeded + dbms_scheduler.job_failed);
sys.dbms_scheduler.enable( '"SYS"."SQLSCRIPT_20140214_TABLE"' );
END;