
----------------------------------------------------------------------------------------
--
-- File name:   unstable_phv2.sql
--
-- Purpose:     Attempts to find SQL statements with predicate instability.
--
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for two values, both of which can be left blank.
--
--              min_stddev: the minimum "normalized" standard deviation between plans
--                          (the default is 2)
--
--              min_etime:  only include statements that have an avg. etime > this value
--                          (the default is .1 second)
--
-- Notes:       This script compares statements in the cursor cache and attempts to 
--              identify statements which have differrences in the predicate section 
--              of the plans and that have signficant differences in average elapsed
--              times between them. cursors that have 0 executions are eliminated
--              from consideration. You may wish to modify this script to look at those
--              cursors as well in the case of long running statements that have not 
--              been canceled prior to completeion.
--
-- See http://kerryosborne.oracle-guy.com/2008/10/unstable-plans/ for more info.
---------------------------------------------------------------------------------------

col execs for 999,999,999
col min_etime for 999,999.99
col max_etime for 999,999.99
col avg_etime for 999,999.999
col avg_lio for 999,999,999.9
col norm_stddev for 999,999.9999
col begin_interval_time for a30
col node for 99999
break on plan_hash_value on startup_time skip 1
-- Kerry Osborne, 20-Jun-13
-- Based on script by Randolf Geist
-- must be run as user with privilege to create type

create or replace type ntt_varchar2 as table of varchar2(4000);
/

with sqls as (
select distinct sql_id from (
select
          sql_id
        , plan_hash_value phv
        , child_number
        , phv2
        , case when plan_hash_value = next_plan_hash_value and phv2 != next_phv2 then 'DIFF!' end as are_hashs_diff
from (
  select
            sql_id
          , plan_hash_value
          , child_number
          , phv2
          , lead(plan_hash_value, 1) over (partition by sql_id, plan_hash_value order by child_number) as next_plan_hash_value
          , lead(phv2, 1) over (partition by sql_id, plan_hash_value order by child_number) as next_phv2
  from (
    select
              sql_id
            , plan_hash_value
            , child_number
            , ora_hash(cast(collect(to_char(hash_path_row, 'TM')) as ntt_varchar2)) as phv2
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
)
) where are_hashs_diff is not null),
plans as (
    select
              sql_id
            , plan_hash_value phv
            , child_number
            , ora_hash(cast(collect(to_char(hash_path_row, 'TM')) as ntt_varchar2)) as phv2
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
select * from (
select sql_id, sum(execs), min(avg_etime) min_etime, max(avg_etime) max_etime, stddev_etime/min(avg_etime) norm_stddev
from (
select sql_id, phv2, execs, avg_etime,
stddev(avg_etime) over (partition by sql_id) stddev_etime 
from (
select s.sql_id, p.phv, p.phv2,
sum(nvl(executions,0)) execs,
(sum(elapsed_time)/decode(sum(nvl(executions,0)),0,1,sum(executions))/1000000) avg_etime,
sum((buffer_gets/decode(nvl(buffer_gets,0),0,1,executions))) avg_lio
from v$sql s, sqls ss, plans p
where s.sql_id = ss.sql_id
and s.sql_id = p.sql_id
and s.child_number = p.child_number
and s.plan_hash_value = p.phv
and elapsed_time > 0
and executions > 0 -- ignore incomplete? executions
group by s.sql_id, p.phv, p.phv2
)
)
group by sql_id, stddev_etime
)
where norm_stddev > nvl(to_number('&min_stddev'),2)
and max_etime > nvl(to_number('&min_etime'),.1)
order by norm_stddev
/
