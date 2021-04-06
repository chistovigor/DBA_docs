/*

Wait Model Improvements
A number of views have been updated and added to improve the wait model. The updated views include:

    * V$EVENT_NAME
    * V$SESSION
    * V$SESSION_WAIT

The new views include:

    * V$ACTIVE_SESSION_HISTORY
    * V$SESSION_WAIT_HISTORY
    * V$SESS_TIME_MODEL
    * V$SYS_TIME_MODEL
    * V$SYSTEM_WAIT_CLASS
    * V$SESSION_WAIT_CLASS
    * V$EVENT_HISTOGRAM
    * V$FILE_HISTOGRAM
    * V$TEMP_HISTOGRAM

*/


col EVENT format a57
col WAIT_CLASS format a20


select wait_class#, 
       wait_class, 
       time_waited, 
       round(time_waited/100/60,2) time_waited_min,
       round(time_waited/100/60/60,2) time_waited_hour,
       round(time_waited/100/60/60/24,0) time_waited_day       
from v$system_wait_class 
order by time_waited;

select event, time_waited, time_waited_micro, wait_class#, wait_class from v$system_event a where a.wait_class='Other' order by time_waited;
select event, time_waited, time_waited_micro, wait_class#, wait_class from v$system_event a where a.wait_class='Application' order by time_waited;
select event, time_waited, time_waited_micro, wait_class#, wait_class from v$system_event a where a.wait_class='Configuration' order by time_waited;
select event, time_waited, time_waited_micro, wait_class#, wait_class from v$system_event a where a.wait_class='Concurrency' order by time_waited;
select event, time_waited, time_waited_micro, wait_class#, wait_class from v$system_event a where a.wait_class='Commit' order by time_waited;
select event, time_waited, time_waited_micro, wait_class#, wait_class from v$system_event a where a.wait_class='Idle' order by time_waited;
select event, time_waited, time_waited_micro, wait_class#, wait_class from v$system_event a where a.wait_class='Network' order by time_waited;
select event, time_waited, time_waited_micro, wait_class#, wait_class from v$system_event a where a.wait_class='User I/O' order by time_waited;
select event, time_waited, time_waited_micro, wait_class#, wait_class from v$system_event a where a.wait_class='System I/O' order by time_waited;

