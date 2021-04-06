set doc on

DOC
######################################################################
######################################################################
##
## 10g Sheduler info
##
## exec dbms_scheduler.disable('GATHER_STATS_JOB'); 
## exec dbms_scheduler.enable ('GATHER_STATS_JOB'); 
##
######################################################################
######################################################################
#

set doc off

col owner format a12
col job_name format a32
col schedule_name format a32
col program_name format a32
col job_creator format a15
col schedule_owner format a15
col enabled format a10
col state format a10
col start_date format a22
col end_date format a22
col repeat_interval format a60
col last_start_date format a22
col next_run_date format a22
col program_action format a25

select a.owner, 
       a.job_name, 
       --a.schedule_name,
       --a.program_name,
       a.job_creator,
       a.schedule_owner, 
       a.enabled,
       --a.state,
       --to_char( a.start_date, 'yyyy-mm-dd hh24:mi:ss') start_date,
       --to_char( a.end_date, 'yyyy-mm-dd hh24:mi:ss') end_date,
       to_char( a.last_start_date, 'yyyy-mm-dd hh24:mi:ss') last_start_date, 
       to_char( a.next_run_date, 'yyyy-mm-dd hh24:mi:ss') next_run_date,
       substr(a.repeat_interval,1,60) repeat_interval
from dba_scheduler_jobs a
/


set doc on

DOC
######################################################################
######################################################################
##
## 10g Sheduler windows info for Gather Stats
##
######################################################################
######################################################################
#

set doc off

col global_stats format a50

Select 'CASCADE = '||dbms_stats.GET_PREFS('CASCADE') as global_stats from dual
union all
Select 'DEGREE = '||dbms_stats.GET_PREFS('DEGREE') from dual
union all
Select 'ESTIMATE_PERCENT = '||dbms_stats.GET_PREFS('ESTIMATE_PERCENT') from dual
union all
Select 'METHOD_OPT = '||dbms_stats.GET_PREFS('METHOD_OPT') from dual
union all
Select 'NO_INVALIDATE = '||dbms_stats.GET_PREFS('NO_INVALIDATE') from dual
union all
Select 'GRANULARITY = '||dbms_stats.GET_PREFS('GRANULARITY') from dual
union all
Select 'PUBLISH = '||dbms_stats.GET_PREFS('PUBLISH') from dual
union all
Select 'INCREMENTAL = '||dbms_stats.GET_PREFS('INCREMENTAL') from dual
union all
Select 'STALE_PERCENT = '||dbms_stats.GET_PREFS('STALE_PERCENT') from dual
union all
select 'AUTOSTATS_TARGET = '||DBMS_STATS.GET_PREFS ('AUTOSTATS_TARGET') as AUTOSTATS_TARGET from dual;


col AUTOSTATS_TARGET format a20
col OPERATION_NAME   format a35
col CLIENT_NAME      format a35
select DBMS_STATS.GET_PREFS ('AUTOSTATS_TARGET') as AUTOSTATS_TARGET from dual;
select operation_name, status from dba_autotask_operation;
select client_name,    status from dba_autotask_client;


col WINDOW_GROUP_NAME for a30
col WINDOW_NAME for a20
col ENABLED for a8
col REPEAT_INTERVAL for a80
col DURATION for a20
col NEXT_START_DATE for a20
col RESOURCE_PLAN for a25

select m.WINDOW_GROUP_NAME
      ,m.WINDOW_NAME
      ,w.RESOURCE_PLAN 
      ,w.ENABLED
  from DBA_SCHEDULER_WINGROUP_MEMBERS m
      ,DBA_SCHEDULER_WINDOWS w
  where m.WINDOW_NAME=w.WINDOW_NAME
    and (WINDOW_GROUP_NAME='MAINTENANCE_WINDOW_GROUP' or w.ENABLED='TRUE')
  order by m.WINDOW_GROUP_NAME
;





set doc on

DOC
######################################################################
######################################################################
##
## 10g Sheduler logs
##
## Setup new log history
##
## exec DBMS_SCHEDULER.SET_SCHEDULER_ATTRIBUTE('log_history','14');
##
## You might also want to manually purge the log:
##        
## exec DBMS_SCHEDULER.PURGE_LOG( log_history => 5, which_log => 'JOB_LOG');              -- purger only job log
## exec DBMS_SCHEDULER.PURGE_LOG( log_history => 5, which_log => 'WINDOW_LOG');           -- purger only window log
## exec DBMS_SCHEDULER.PURGE_LOG( log_history => 5, which_log => 'JOB_AND_WINDOW_LOG');   -- purger all
## exec DBMS_SCHEDULER.PURGE_LOG( log_history => 5);                                      -- purger all
## exec DBMS_SCHEDULER.PURGE_LOG();     
######################################################################
######################################################################
#

set doc off

col run_duration format a20
col additional_info format a20
col job_name format a32


declare
 l_log_history varchar2(10);
begin
  DBMS_SCHEDULER.GET_SCHEDULER_ATTRIBUTE('log_history',l_log_history);
  dbms_output.put_line(''); 
  dbms_output.put_line('-----------------------------------------'); 
  dbms_output.put_line('log_history => ' || l_log_history || ' days'); 
  dbms_output.put_line('-----------------------------------------'); 
end;
/


select * from (
select to_char( log_date, 'yyyy-mm-dd hh24:mi:ss') log_date, owner, job_name, operation, status, row_number() over (order by log_date desc) rn
from dba_scheduler_job_log  
--where job_name in ('GATHER_STATS_JOB','FW_CHECK_JOB')
)
where rn<=25
/

select * from (
select to_char( log_date, 'yyyy-mm-dd hh24:mi:ss') log_date, 
       owner, 
       job_name, 
       status, 
       error#, 
       to_char( actual_start_date, 'yyyy-mm-dd hh24:mi:ss') actual_start_date, 
       run_duration, 
       additional_info,
       row_number() over (order by log_date desc) rn
from dba_scheduler_job_run_details  
--where job_name in ('GATHER_STATS_JOB','FW_CHECK_JOB')
)
where rn<=25
/



select * from v$scheduler_running_jobs
/
