
select event,
       total_waits,
       time_waited*10 tw_ms,
       average_wait*10 aw_ms,
       max_wait*10 mw_ms
from v$session_event
where sid=&sess_id;
