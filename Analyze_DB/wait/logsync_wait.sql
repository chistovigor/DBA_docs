SELECT *  FROM v$active_session_history
 WHERE event = 'log file sync' AND sample_time >= (SYSDATE - 1 / 1440 * 600);
 
 SELECT count(session_id), session_id, (SUM (time_waited) / 1000000)  FROM v$active_session_history
 WHERE event = 'log file sync' AND sample_time >= (SYSDATE - 1 / 1440) group by session_id;
 
 текущий запрос
 
  SELECT SUM (COUNT (session_id)) waits,
         SUM (AVG (time_waited) / 1000000) total_wait_time,
         round(SUM (AVG (time_waited) / 1000000) / SUM (COUNT (session_id))) avg_time_waited
    FROM v$active_session_history
   WHERE event = 'log file sync' AND sample_time >= (SYSDATE - 1 / 1440)
GROUP BY session_id;


старый запрос

set pagesize 1000
set linesize 200
column minute format A10
column event  format A15
column WAITS  format 999,999,999

select to_char(sample_time,'Mondd_hh24mi') minute, event,
round(sum(time_waited)/1000000) TOTAL_WAIT_TIME , count(*) WAITS,
round(avg(time_waited)/1000000) AVG_TIME_WAITED
from v$active_session_history
where event = 'log file sync'
group by to_char(sample_time,'Mondd_hh24mi'), event
having avg(time_waited)/1000000 > 90 and count(*) > 30
order by 1,2;