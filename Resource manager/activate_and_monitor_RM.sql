--To switch between active plans, use the command:
ALTER SYSTEM SET resource_manager_plan='APPLICATIONS_PLAN' SCOPE=BOTH SID='*';
--To disable resource manager, specify a null plan:
ALTER SYSTEM SET resource_manager_plan=''  SCOPE=BOTH SID='*';

/*
Maintenance Windows

By default, the "default_maintenance_plan" resource plan is enabled during the maintenance window. If you did not create a resource plan for your database, the "default_maintenance_plan" provides effective management of automated maintenance tasks. 

Once you create a resource plan for your database, Oracle recommends that

Your resource plan contains a directive for maintenance tasks. You should create the maintenance task directive for the "ora$autotask_sub_plan" subplan in 11g and for the "ora$autotask" consumer group in 12c.  Outside of the maintenance windows, automated tasks do not run and this allocation will be reallocated to the other consumer groups.
You enable a single resource plan both during and outside the maintenance windows.  Enable the resource plan using the "resource_manager_plan" parameter.  Then, disable the default_maintenance_plan from the maintenance windows, using the script below.  Your resource plan will then be used both during and outside the maintenance windows.
*/ 

begin 

dbms_scheduler.set_attribute_null( 
  name => 'SUNDAY_WINDOW', 
  attribute => 'APPLICATIONS_PLAN'); 

dbms_scheduler.set_attribute_null( 
  name => 'MONDAY_WINDOW', 
  attribute => 'APPLICATIONS_PLAN'); 

dbms_scheduler.set_attribute_null( 
  name => 'TUESDAY_WINDOW', 
  attribute => 'APPLICATIONS_PLAN'); 

dbms_scheduler.set_attribute_null( 
  name => 'WEDNESDAY_WINDOW', 
  attribute => 'APPLICATIONS_PLAN'); 

dbms_scheduler.set_attribute_null( 
  name => 'THURSDAY_WINDOW', 
  attribute => 'APPLICATIONS_PLAN'); 

dbms_scheduler.set_attribute_null( 
  name => 'FRIDAY_WINDOW', 
  attribute => 'APPLICATIONS_PLAN'); 

dbms_scheduler.set_attribute_null( 
  name => 'SATURDAY_WINDOW', 
  attribute => 'APPLICATIONS_PLAN'); 

end; 
/

-- verify whether the option is available (Oracle Resource manager is only available in the Enterprise Edition)

SELECT VALUE
  FROM v$option
 WHERE parameter = 'Database resource manager';

--Monitor Current Resource Plan

SELECT *
  FROM v$rsrc_plan
 WHERE is_top_plan = 'TRUE';

--See the current resource plan for a non-CDB or PDB for 11.2+ (for PDBs, execute from the PDB's container):

SELECT group_or_subplan,
       mgmt_p1,
       mgmt_p2,
       mgmt_p3,
       mgmt_p4,
       mgmt_p5,
       mgmt_p6,
       mgmt_p7,
       mgmt_p8,
       max_utilization_limit
  FROM dba_rsrc_plan_directives
 WHERE plan = (SELECT name
                 FROM v$rsrc_plan
                WHERE is_top_plan = 'TRUE');

--Monitor CPU Usage and Waits by Consumer Group

  SELECT TO_CHAR (m.begin_time, 'HH:MI') time,
         m.consumer_group_name,
         m.cpu_consumed_time / 60000 avg_running_sessions,
         m.cpu_wait_time / 60000 avg_waiting_sessions,
           d.mgmt_p1
         * (SELECT VALUE
              FROM v$parameter
             WHERE name = 'cpu_count')
         / 100
            allocation
    FROM v$rsrcmgrmetric_history m, dba_rsrc_plan_directives d, v$rsrc_plan p
   WHERE m.consumer_group_name = d.group_or_subplan AND p.name = d.plan
ORDER BY m.begin_time, m.consumer_group_name;

-- timings for wait event 'resmgr:cpu quantum' on a user-basis

  SELECT s.username,
         se.event,
         SUM (total_waits) total_waits,
         SUM (time_waited) total_time_waited,
         ROUND (AVG (average_wait), 3) avg_wait
    FROM v$session_event se, v$session s
   WHERE se.event = 'resmgr:cpu quantum' AND se.sid = s.sid
GROUP BY s.username, se.event
ORDER BY 4 DESC, 5 DESC, 3 DESC;

--Monitor CPU Usage and Waits by Pluggable Database (12c+)

  SELECT TO_CHAR (begin_time, 'HH24:MI'),
         name,
         SUM (avg_running_sessions) avg_running_sessions,
         SUM (avg_waiting_sessions) avg_waiting_sessions
    FROM v$rsrcmgrmetric_history m, v$pdbs p
   WHERE m.con_id = p.con_id
GROUP BY begin_time, m.con_id, name
ORDER BY begin_time;