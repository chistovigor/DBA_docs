set doc on

DOC
######################################################################
######################################################################
##
##
## Session Top Timed Events
##
######################################################################
######################################################################
#

set doc off



column program     format A35 truncated 
column top_events  format A90 truncated


with events as (
select sid,time,sys_connect_by_path(text,' + ') top_events
from (
select sid,e.event,sum(time) over (partition by sid) time,
dense_rank() over (partition by sid order by e.time desc) rank,
time/sum(time) over (partition by sid) pct,
count(*) over (partition by sid) cnt,
to_char(round(100*e.time/sum(e.time) over (partition by sid)))||'% '||e.event text
from
(
select sid,event event,total_waits waits,time_waited/100 time from v$session_event
union all
select sid,'CPU',null,value/100 from v$statname join v$sesstat using (statistic#)where name = 'CPU used by this session'
) e
where time > 0
) where rank=cnt
connect by prior rank=rank-1 and prior sid=sid start with rank=1
)
select sid,v$session.serial#,v$session.program,substr(top_events,4,instr(top_events||'+ 0%','+ 0%')-4) top_events,
 (block_gets+consistent_gets) logical_reads,round(pga_max_mem/1024) pga_kb
 from events join v$session using(sid) join v$sess_io using (sid) join v$process on (paddr=v$process.addr)
order by block_gets+consistent_gets desc
/
