select y.sid,
       y.serial#,
       y.osuser,
       y.username,
       y.program sprogram,
       x.use_cpu,
       x.logic_reads,
       x.cons_gets,
       x.redo_retries,
       y.event
from (
      select sid, 
             sum(decode(b.name,'CPU used by this session' ,nvl(value,0))) as use_cpu,
             sum(decode(b.name,'session logical reads' ,nvl(value,0))) as logic_reads,
             sum(decode(b.name,'consistent gets' ,nvl(value,0))) as cons_gets,
             sum(decode(b.name,'redo buffer allocation retries' ,nvl(value,0))) as redo_retries
      from v$sesstat a join v$statname b using (statistic#)
      where b.name in ('session logical reads',
                       'consistent gets',
                       'CPU used by this session',
                       'redo buffer allocation retries')
      group by sid
      ) x join v$session y on (x.sid=y.sid)
order by 6 desc
/
