--
-- Текущая группа у пользователя
--
column username format a15
column osuser   format a25
select sid, 
       serial#, 
       username, 
       osuser,
       resource_consumer_group 
from v$session 
where type='USER' 
  and username is not null
order by resource_consumer_group, username
/

--
-- Распределение процессорного времени м-у группами
--
column group_name format a30
select name as group_name,
       active_sessions,
       current_pqs_active,
       trim(to_char((consumed_cpu_time/sum_cpu_time)*100,'900D00')||' %') pct_use
from (
select name,
       active_sessions,
       current_pqs_active,       
       consumed_cpu_time,
       sum(consumed_cpu_time) over () as sum_cpu_time
from v$rsrc_consumer_group
)
order by round((consumed_cpu_time/sum_cpu_time)*100) desc
/

