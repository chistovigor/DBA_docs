set doc on

DOC
######################################################################
######################################################################
## How Much CPU are We Spending Parsing?
######################################################################
######################################################################
#

set doc off


column parsing heading 'Parsing|(seconds)'
column total_cpu heading 'Total CPU|(seconds)'
column waiting heading 'Read Consistency|Wait (seconds)'
column pct_parsing heading 'Percent|Parsing'
select total_CPU,parse_CPU parsing, parse_elapsed-parse_CPU
waiting,trunc(100*parse_elapsed/total_CPU,2) pct_parsing

select total_CPU,
       parse_CPU parsing,
       parse_elapsed-parse_CPU waiting,
       trunc(100*parse_elapsed/total_CPU,2) pct_parsing
from
(select value/100 total_CPU from v$sysstat where name = 'CPU used by this session'),
(select value/100 parse_CPU from v$sysstat where name = 'parse time cpu'),
(select value/100 parse_elapsed from v$sysstat where name = 'parse time elapsed')
/

set doc on

DOC
######################################################################
######################################################################
## Open Cursors
######################################################################
######################################################################
#

set doc off

column value format 999,999,999

select name,to_number(value) value 
from v$parameter where name in ('open_cursors','session_cached_cursors')
/

select b.sid, 
       a.username, 
       b.value open_cursors,
       sum(b.value) over() all_open_cursors
from v$session a,
     v$sesstat b,
     v$statname c
where c.name in ('opened cursors current')
  and b.statistic# = c.statistic#
  and a.sid = b.sid
  and a.service_name not in ('SYS$BACKGROUND')
  and b.value >0
  order by 1
/


set doc on

DOC
######################################################################
######################################################################
## How often we are finding the cursor in the session cache
######################################################################
######################################################################
#

set doc off



select a.sid,
       c.serial#,
       c.username,
       a.parse_cnt,
       b.cache_cnt,
       trunc(b.cache_cnt/a.parse_cnt*100,2) pct
from
 (select a.sid,a.value parse_cnt from v$sesstat a, v$statname b where a.statistic#=b.statistic# and b.name = 'parse count (total)' and value >0) a,
 (select a.sid,a.value cache_cnt from v$sesstat a, v$statname b where a.statistic#=b.statistic# and b.name = 'session cursor cache hits') b,
 v$session c
where a.sid=b.sid
  and a.sid=c.sid
  and c.service_name not in ('SYS$BACKGROUND')
order by 6 desc
/


set doc on


DOC
######################################################################
######################################################################
##
## Now we can check the code that is being run 
## to see if it passes the "identical" test
## -------------------------------------------------------------------
##
## select a.parsing_user_id,a.parse_calls,a.executions,b.sql_text||'<'
## from v$sqlarea a, v$sqltext b
## where a.parse_calls >= a.executions
## and a.executions > 10
## and a.parsing_user_id > 0
## and a.address = b.address
## and a.hash_value = b.hash_value
## order by 1,2,3,a.address,a.hash_value,b.piece;
## 
######################################################################
######################################################################
#

set doc off
