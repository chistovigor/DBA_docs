prompt ##########################################
prompt # Note 34576.1
prompt # Note 22908.1
prompt ##########################################


alter session set optimizer_mode=rule;

column name format A32 truncate heading "LATCH NAME"
column pid heading "HOLDER PID" 

select *
from (
select c.name,a.addr,a.gets,a.misses,a.sleeps,a.immediate_gets,a.immediate_misses,b.pid,row_number() over (order by a.sleeps desc ) rn
from v$latch a, v$latchholder b, v$latchname c
where a.addr = b.laddr(+)
and a.latch# = c.latch#
order by a.sleeps desc
)
where rn<21
/
