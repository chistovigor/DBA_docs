alter session set NLS_DATE_FORMAT      = "YYYY-MON-DD HH24:MI:SS";
alter session set NLS_TIMESTAMP_FORMAT = "YYYY-MON-DD HH24:MI:SS";
alter session set NLS_DATE_LANGUAGE    = "AMERICAN";


column begin_interval_time format a22
column end_interval_time format a22
column startup_time format a22
column retention format a22
column snap_interval format a22

select * from dba_hist_wr_control
/
select *
from (
select snap_id, 
       startup_time,
       begin_interval_time, 
       end_interval_time, 
       row_number() over (order by snap_id desc) rn 
from dba_hist_snapshot
)
where rn<=14
order by snap_id
/

set doc on

DOC
#######################################################################################
##
## Display the ADDM report
##
#######################################################################################
##
## set long 100000
## select dbms_advisor.get_task_report('ADDM:1864048043_1_835') as report from dual;
##
#######################################################################################
#

set doc off


select *
from (
select task_id, created, advisor_name, task_name, row_number() over (order by task_id desc) rn 
from (
select distinct f.task_id, t.created, t.advisor_name, f.task_name
from  dba_advisor_findings f 
 join dba_advisor_tasks    t on (f.task_id=t.task_id)
 join dba_advisor_log      l on (l.task_id=t.task_id)
where l.status='COMPLETED'
)
)
where rn<=14
order by task_id
/


