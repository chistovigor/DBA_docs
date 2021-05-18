----------------------------------------------------------------------------------------
--
-- File name:   phv2.sql
--
-- Purpose:     Displays data from v$sql along with phv2 (which is an extended plan hash
--              value that includes predicate information. 
--
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for four values.
--
--              sql_text: part of the text of a statement
--
--              sql_id: the sql_id of the statement 
--
--              phv: the plan_hash_value of a statement
--
--              phv2: the extended plan_hash_value of a statement
--
-- Note:        All parameters may be left blank
--
-- Description:
--
--              Based on a blog post by Randolf Giest.
-- http://oracle-randolf.blogspot.com/2009/07/planhashvalue-how-equal-and-stable-are_26.html
--
--              See kerryosborne.oracle-guy.com for additional information.
---------------------------------------------------------------------------------------
-- Kerry Osborne, 20-Jun-13
-- Based on script by Randolf Geist
-- must be run as user with privilege to create type

create or replace type ntt_varchar2 as table of varchar2(4000);
/

set verify off
set pagesize 999
col username format a13
col prog format a22
col sql_text format a40 trunc
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col execs format 9,999,999
col execs_per_sec format 999,999.99
col etime format 9,999,999.99
col avg_etime format 99,999.99999
col cpu format 9,999,999
col avg_cpu  format 99,999.99
col pio format 9,999,999
col avg_pio format 9,999,999
col lio format 9,999,999
col avg_lio format 9,999,999,999

select * from (
select s.sql_id, s.child_number, s.plan_hash_value phv, the_hash phv2,
executions execs,
rows_processed ,
-- executions/((sysdate-to_date(first_load_time,'YYYY-MM-DD/HH24:MI:SS'))*(24*60*60)) execs_per_sec,
-- elapsed_time/1000000 etime,
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime,
-- cpu_time/1000000 cpu,
(cpu_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_cpu,
-- disk_reads pio,
disk_reads/decode(nvl(executions,0),0,1,executions) avg_pio,
-- buffer_gets lio,
buffer_gets/decode(nvl(executions,0),0,1,executions) avg_lio,
sql_text
from v$sql s, 
(select * from (
select
          sql_id
--        , plan_hash_value
        , child_number
        , the_hash
from (
    select
              sql_id
            , plan_hash_value
            , child_number
            , ora_hash(cast(collect(to_char(hash_path_row, 'TM')) as ntt_varchar2)) as the_hash
    from (
      select
                sql_id
              , plan_hash_value
              , child_number
              , hash_path_row
      from (
        select
                  sql_id
                , plan_hash_value
                , child_number
                , id
                , dense_rank() over (order by sql_id, plan_hash_value, child_number) as rnk
                , ora_hash(
                  operation
                  || '-' || ora_hash(access_predicates)
                  || '-' || ora_hash(filter_predicates)
                  ) as hash_path_row
        from (
          select
                  *
          from
                  v$sql_plan 
        )
      )
    )
    group by
              sql_id
            , plan_hash_value
            , child_number
  )
) ) p
where upper(sql_text) like upper(nvl(q'[&sql_text]',sql_text))
and s.sql_id like nvl('&sql_id',s.sql_id)
-- uncomment the next line to eliminate 0 execs
-- and s.executions > 0
and p.sql_id = s.sql_id
and p.child_number = s.child_number
)
where phv like nvl('&phv',phv)
and phv2 like nvl('&phv2',phv2)
order by 1,2
/
