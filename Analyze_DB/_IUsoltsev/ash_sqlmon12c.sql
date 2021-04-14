--
-- SQL Plan Statistics from ASH (including recursive queries and PL/SQL)
-- Usage: SQL> @ash_sqlmon12c &sql_id [&plan_hash_value | &FULL_PLAN_HASH_VALUE] [&sql_exec_id]
-- 

set feedback off heading on timi off pages 500 lines 500 echo off  VERIFY OFF

col PLAN_OPERATION for a170
col WAIT_PROFILE for a200
col LAST_PLSQL for a45
col ID for 9999
col OBJECT_OWNER for a12
col OBJECT_NAME for a30
col QBLOCK_NAME for a15

with plan_hashs as
  (select p.sql_id,
          p.plan_hash_value,
          to_number(extractvalue(h.column_value, '/info')) full_plan_hash_value
     from dba_hist_sql_plan p,
          table(xmlsequence(extract(xmltype(p.other_xml), '/other_xml/info'))) h
    where p.other_xml is not null
      and sql_id = '&1'
      and NVL(plan_hash_value, 0) = nvl('&2', NVL(plan_hash_value, 0))
      and extractvalue(h.column_value, '/info/@type') = 'plan_hash_full'
   union
   select distinct sql_id, plan_hash_value, full_plan_hash_value
     from gv$sql_plan
    where sql_id = '&1'
      and NVL(plan_hash_value, 0) = nvl('&2', NVL(plan_hash_value, 0)))
--select * from plan_hashs
, ash0 as (select/*+ materialize*/ * from ash_20150416)--dba_hist_active_sess_history where snap_id >= 62804)-- Gv$active_session_history)
, sid_time as -- List of sessions and their start/stop times
   (select nvl(qc_session_id, session_id) as qc_session_id,
           session_id,
           session_serial#,
           sh.sql_id,
           min(sample_time)               as MIN_SQL_EXEC_TIME,
           max(sample_time)               as MAX_SQL_EXEC_TIME
      from ash0 sh, plan_hashs ph
     where sh.sql_id = ph.sql_id
       and (NVL(sql_plan_hash_value, 0) = nvl(ph.plan_hash_value, NVL(sql_plan_hash_value, 0))
            or
            NVL(sql_full_plan_hash_value, 0) = nvl(ph.full_plan_hash_value, NVL(sql_full_plan_hash_value, 0)))
       and NVL(sql_exec_id, 0) = nvl('&3', NVL(sql_exec_id, 0))
     group by nvl(qc_session_id, session_id), session_id, session_serial#, sh.sql_id, sql_plan_hash_value, sql_exec_id)
, ash as (                               -- ASH part, consisting of direct SQL exec ONLy
  select count(distinct sh.session_id||sh.session_serial#) as SID_COUNT,
         0 as plsql_entry_object_id,     -- important for recrsv queries only
         0 as plsql_entry_subprogram_id, -- --//--
         sh.sql_id,
         NVL2(sql_exec_id,1,null) as SQL_EXEC_ID,
         nvl(sql_full_plan_hash_value, 0)                    as SQL_FULL_PLAN_HASH_VALUE,
         nvl(sql_plan_line_id, 0)                            as SQL_PLAN_LINE_ID,
         decode(session_state,'WAITING',event,session_state) as EVENT,
         count(*)                                            as WAIT_COUNT,
         min(sample_time)                                    as MIN_SAMPLE_TIME,
         max(sample_time)                                    as MAX_SAMPLE_TIME
    from ash0 sh, plan_hashs ph
   where  sh.sql_id                   = ph.sql_id                                -- direct SQL exec ONLY
     and (NVL(sql_plan_hash_value, 0) = nvl(ph.plan_hash_value, NVL(sql_plan_hash_value, 0))
          or
          NVL(sql_full_plan_hash_value, 0) = nvl(ph.full_plan_hash_value, NVL(sql_full_plan_hash_value, 0)))
     and  NVL(sh.sql_exec_id, 0) = nvl('&3', NVL(sh.sql_exec_id, 0))
   group by sh.sql_id, NVL2(sql_exec_id,1,null), nvl(sql_full_plan_hash_value, 0), nvl(sql_plan_line_id, 0), decode(session_state,'WAITING',event,session_state))
--select * from ash
, ash_stat as ( -- direct SQL exec stats
select  sql_id,
        SQL_EXEC_ID,
        sql_full_plan_hash_value,
        sql_plan_line_id,
        sum(WAIT_COUNT) as ASH_ROWS,
        rtrim(xmlagg(xmlelement(s, EVENT || '(' || WAIT_COUNT, '); ').extract('//text()') order by WAIT_COUNT desc)--.getclobval ()
                                                                                                                   ,'; ') as WAIT_PROFILE,
        max(SID_COUNT)-1 as PX_COUNT,
        max(MAX_SAMPLE_TIME) as MAX_SAMPLE_TIME
from ash
group by sql_id,
         sql_exec_id,
         sql_full_plan_hash_value,
         sql_plan_line_id)
, ash_recrsv as ( -- ASH part, consisting of indirect / recursive SQLs execs ONLy
  select count(distinct sh.session_id||sh.session_serial#) as SID_COUNT,
         decode(sh.sql_id, sid_time.sql_id, 0, sh.plsql_entry_object_id)     as plsql_entry_object_id,    -- for recrsv queries only
         decode(sh.sql_id, sid_time.sql_id, 0, sh.plsql_entry_subprogram_id) as plsql_entry_subprogram_id,-- --//--
         sh.sql_id,
         nvl(sql_plan_hash_value, 0)                         as SQL_PLAN_HASH_VALUE,
         nvl(sql_plan_line_id, 0)                            as SQL_PLAN_LINE_ID,
         decode(session_state,'WAITING',event,session_state) as EVENT,
         count(*)                                            as WAIT_COUNT,
         min(sample_time)                                    as MIN_SAMPLE_TIME,
         max(sample_time)                                    as MAX_SAMPLE_TIME
    from ash0 sh, sid_time
   where ((sh.top_level_sql_id = sid_time.sql_id and sh.sql_id != sid_time.sql_id or sh.sql_id is null) and-- recursive SQLs
          sh.session_id       = sid_time.session_id and
          sh.session_serial#  = sid_time.session_serial# and
          nvl(sh.qc_session_id, sh.session_id) = sid_time.qc_session_id and
          sh.sample_time between sid_time.MIN_SQL_EXEC_TIME and sid_time.MAX_SQL_EXEC_TIME)
   group by sh.sql_id, nvl(sql_plan_hash_value, 0), nvl(sql_plan_line_id, 0), decode(session_state,'WAITING',event,session_state),
            decode(sh.sql_id, sid_time.sql_id, 0, sh.plsql_entry_object_id),
            decode(sh.sql_id, sid_time.sql_id, 0, sh.plsql_entry_subprogram_id))
, ash_stat_recrsv as ( -- recursive SQLs stats
select  ash.plsql_entry_object_id,
        ash.plsql_entry_subprogram_id,
        ash.sql_id,
        sql_plan_hash_value,
        sql_plan_line_id,
        sum(WAIT_COUNT) as ASH_ROWS,
        rtrim(xmlagg(xmlelement(s, EVENT || '(' ||WAIT_COUNT, '); ').extract('//text()') order by WAIT_COUNT desc)--.getclobval ()
                                                                                                                  ,'; ') as WAIT_PROFILE,
        max(SID_COUNT)-1 as PX_COUNT,
        max(MAX_SAMPLE_TIME) as MAX_SAMPLE_TIME
from ash_recrsv ash --join sid_time on ash.sql_id <> sid_time.sql_id or ash.sql_id is null
group by ash.plsql_entry_object_id,
         ash.plsql_entry_subprogram_id,
         ash.sql_id,
         sql_plan_hash_value,
         sql_plan_line_id)
, pt as( -- Plan Tables for all excuted SQLs (direct+recursive)
select   sql_id,
         plan_hash_value,
         id,
         operation,
         options,
         object_owner,
         object_name,
         qblock_name,
         nvl(parent_id, -1) as parent_id
    from dba_hist_sql_plan
   where (sql_id, plan_hash_value) in (select sql_id, plan_hash_value from plan_hashs union select sql_id, sql_plan_hash_value from ash_recrsv)
  union                                          -- for plans not in dba_hist_sql_plan yet
  select distinct 
         sql_id,
         plan_hash_value,
         id,
         operation,
         options,
         object_owner,
         object_name,
         qblock_name,
         nvl(parent_id, -1) as parent_id
    from gv$sql_plan
   where (sql_id, plan_hash_value) in (select sql_id, plan_hash_value from plan_hashs union select sql_id, sql_plan_hash_value from ash_recrsv)
  union                                          -- for plans not in dba_hist_sql_plan not v$sql_plan (read-only standby for example)
  select distinct 
         sql_id,
         sql_full_plan_hash_value as plan_hash_value,
         sql_plan_line_id         as id,
         sql_plan_operation       as operation,
         sql_plan_options         as options,
         owner                    as object_owner,
         object_name,
         ''                       as qblock_name,
         -2                       as parent_id
    from ash0 left join dba_objects on current_obj# = object_id
   where (sql_id, sql_plan_hash_value) in     (select sql_id, plan_hash_value from plan_hashs  union     select sql_id, sql_plan_hash_value from ash_recrsv)
     and (sql_id, sql_plan_hash_value) not in (select sql_id, plan_hash_value from gv$sql_plan union all select sql_id, plan_hash_value from dba_hist_sql_plan)
     and (sql_id, sql_full_plan_hash_value) not in (select sql_id, full_plan_hash_value from plan_hashs))
--select * from pt
select 'Hard Parse' as LAST_PLSQL, -- the hard parse phase, sql plan does not exists yet, full_plan_hash_value = 0
       sql_id,
       0 as plan_hash_value,
       sql_full_plan_hash_value as full_plan_hash_value,
       ash_stat.sql_plan_line_id as ID,
       'sql_plan_hash_value = 0' as PLAN_OPERATION,
       null as object_owner,
       null as object_name,
       null as QBLOCK_NAME,
       ash_stat.PX_COUNT as PX,
       ash_stat.ASH_ROWS,
       ash_stat.WAIT_PROFILE
  from ash_stat
 where sql_full_plan_hash_value = 0
UNION ALL
select 'Soft Parse' as LAST_PLSQL, -- the soft parse phase, sql plan exists but execution didn't start yet, sql_exec_id is null
       ash_stat.sql_id,              
       plan_hash_value,
       sql_full_plan_hash_value as full_plan_hash_value,
       ash_stat.sql_plan_line_id as ID,
       'sql_plan_hash_value > 0; sql_exec_id is null' as PLAN_OPERATION,
       null as object_owner,
       null as object_name,
       null as QBLOCK_NAME,
       ash_stat.PX_COUNT as PX,
       ash_stat.ASH_ROWS,
       ash_stat.WAIT_PROFILE
  from ash_stat join plan_hashs on (ash_stat.sql_id = plan_hashs.sql_id and sql_full_plan_hash_value = full_plan_hash_value)
 where sql_full_plan_hash_value > 0
   and sql_exec_id is null
UNION ALL
SELECT 'Main Query w/o saved plan'       -- direct SQL which plan not in gv$sql_plan, dba_hist_sql_plan (ro-standby)
                                                                 as LAST_PLSQL,
       pt.sql_id                                                 as SQL_ID,
       pt.plan_hash_value                                        as plan_hash_value,
       ash_stat.sql_full_plan_hash_value                         as full_plan_hash_value,
       pt.id,
       lpad(' ', id) || pt.operation || ' ' || pt.options        as PLAN_OPERATION,
       pt.object_owner,
       pt.object_name,
       pt.qblock_name,
       ash_stat.PX_COUNT                                         as PX,
       ash_stat.ASH_ROWS,
       ash_stat.WAIT_PROFILE
  FROM pt
  left join ash_stat
  on --pt.parent_id       = -2 and
     pt.id              = NVL(ash_stat.sql_plan_line_id,0) and
     pt.sql_id          = ash_stat.sql_id and
     pt.plan_hash_value = ash_stat.sql_full_plan_hash_value and          -- sql_plan_hash_value > 0
     ash_stat.sql_exec_id is not null
  where pt.parent_id       = -2
UNION ALL
SELECT case when pt.id =0 then 'Main Query' -- direct SQL plan+stats
            when ash_stat.MAX_SAMPLE_TIME > sysdate - 10/86400 then '>>>'
            when ash_stat.MAX_SAMPLE_TIME > sysdate - 30/86400 then '>> '
            when ash_stat.MAX_SAMPLE_TIME > sysdate - 60/86400 then '>  '
            else '   ' end as LAST_PLSQL,
       decode(pt.id, 0, pt.sql_id, null) as SQL_ID,
       decode(pt.id, 0, pt.plan_hash_value, null) as plan_hash_value,
       ash_stat.sql_full_plan_hash_value          as full_plan_hash_value,
       pt.id,
       lpad(' ', 2 * level) || pt.operation || ' ' || pt.options as PLAN_OPERATION,
       pt.object_owner,
       pt.object_name,
       pt.qblock_name,
       ash_stat.PX_COUNT as PX,
       ash_stat.ASH_ROWS,
       ash_stat.WAIT_PROFILE
  FROM pt
  left join plan_hashs on pt.sql_id = plan_hashs.sql_id and pt.plan_hash_value = plan_hashs.plan_hash_value
  left join ash_stat
  on pt.id              = NVL(ash_stat.sql_plan_line_id,0) and
     pt.sql_id          = ash_stat.sql_id and
--     pt.plan_hash_value = plan_hashs.plan_hash_value
     plan_hashs.full_plan_hash_value = ash_stat.sql_full_plan_hash_value         -- sql_plan_hash_value > 0
     and ash_stat.sql_exec_id is not null
  where pt.sql_id in (select sql_id from ash_stat)
CONNECT BY PRIOR pt.id = pt.parent_id
       and PRIOR pt.sql_id = pt.sql_id
       and PRIOR pt.plan_hash_value = pt.plan_hash_value
 START WITH pt.id = 0
UNION ALL
SELECT decode(pt.id, 0, p.object_name||'.'||p.procedure_name, null) as LAST_PLSQL, -- recursive SQLs plan+stats
       decode(pt.id, 0, pt.sql_id, null) as SQL_ID,
       decode(pt.id, 0, pt.plan_hash_value, null) as plan_hash_value,
       0                                          as full_plan_hash_value,
       pt.id,
       lpad(' ', 2 * level) || pt.operation || ' ' || pt.options as PLAN_OPERATION,
       pt.object_owner,
       pt.object_name,
       pt.qblock_name,
       ash_stat.PX_COUNT as PX,
       ash_stat.ASH_ROWS,
       ash_stat.WAIT_PROFILE
  FROM pt
  left join ash_stat_recrsv ash_stat
  on pt.id              = NVL(ash_stat.sql_plan_line_id,0) and
     pt.sql_id          = ash_stat.sql_id and
    (pt.plan_hash_value = ash_stat.sql_plan_hash_value or ash_stat.sql_plan_hash_value = 0)
  left join dba_procedures p on ash_stat.plsql_entry_object_id     = p.object_id and
                                ash_stat.plsql_entry_subprogram_id = p.subprogram_id
  where pt.sql_id in (select sql_id from ash_stat_recrsv)
CONNECT BY PRIOR pt.id = pt.parent_id
       and PRIOR pt.sql_id = pt.sql_id
       and PRIOR pt.plan_hash_value = pt.plan_hash_value
 START WITH pt.id = 0
UNION ALL
select 'Recurs.waits' as LAST_PLSQL, -- non-identified SQL (PL/SQL?) exec stats
       '',
       0 as plan_hash_value,
       0 as full_plan_hash_value,
       ash_stat.sql_plan_line_id,
       'sql_id is null and plsql[_entry]_object_id is null' as PLAN_OPERATION,
       null,
       null,
       null,
       ash_stat.PX_COUNT as PX,
       ash_stat.ASH_ROWS,
       ash_stat.WAIT_PROFILE
  from ash_stat_recrsv ash_stat
 where sql_id is null
   and ash_stat.plsql_entry_object_id is null
UNION ALL
select 'PL/SQL' as LAST_PLSQL, -- non-identified SQL (PL/SQL?) exec stats
       '',
       0 as plan_hash_value,
       0 as full_plan_hash_value,
       ash_stat.sql_plan_line_id,
       p.owner ||' '|| p.object_name||'.'||p.procedure_name as PLAN_OPERATION,
       null,
       null,
       null,
       ash_stat.PX_COUNT as PX,
       ash_stat.ASH_ROWS,
       ash_stat.WAIT_PROFILE
  from ash_stat_recrsv ash_stat
  join dba_procedures p on ash_stat.plsql_entry_object_id     = p.object_id and
                                ash_stat.plsql_entry_subprogram_id = p.subprogram_id
 where sql_id is null
UNION ALL
select 'SQL Summary' as LAST_PLSQL, -- SQL_ID Summary
       '',
       0 as plan_hash_value,
       0 as full_plan_hash_value,
       0 as sql_plan_line_id,
       'ASH fixed ' || count(distinct sql_exec_id) || ' execs from ' || count(distinct session_id || ' ' || session_serial#) || ' sessions' as PLAN_OPERATION,
       null,
       null,
       null,
       null as PX,
       count(*) as ASH_ROWS,
       ' ash rows were fixed from ' || to_char(min(SAMPLE_TIME),'dd.mm.yyyy hh24:mi:ss') || ' to ' || to_char(max(SAMPLE_TIME),'dd.mm.yyyy hh24:mi:ss') as WAIT_PROFILE
  from ash0
   where sql_id              = '&&1' and                                -- direct SQL exec ONLY
         sql_plan_hash_value = nvl('&&2', sql_plan_hash_value) and
         NVL(sql_exec_id, 0) = nvl('&&3', NVL(sql_exec_id, 0))
/
set feedback on VERIFY ON timi on

PX MAX_TEMP_SPACE_ALLOCATED

-- О совпадениях

SQL> select sql_id,
  2         full_plan_hash_value,
  3         count(distinct plan_hash_value),
  4         count(*),
  5         LISTAGG(plan_hash_value, ',') WITHIN GROUP (order by plan_hash_value) as PLAN_HASH_LIST
  6    from (select sql_id,
  7                 plan_hash_value,
  8                 to_number(extractvalue(h.column_value, '/info')) full_plan_hash_value
  9            from dba_hist_sql_plan p,
 10                 table(xmlsequence(extract(xmltype(p.other_xml), '/other_xml/info'))) h
 11           where p.other_xml is not null
 12             and extractvalue(h.column_value, '/info/@type') = 'plan_hash_full')
 13   group by sql_id, full_plan_hash_value
 14  having count(distinct plan_hash_value) > 4
 15  order by count(distinct plan_hash_value) desc
 16  /
 
SQL_ID        FULL_PLAN_HASH_VALUE COUNT(DISTINCTPLAN_HASH_VALUE)   COUNT(*) PLAN_HASH_LIST
------------- -------------------- ------------------------------ ---------- --------------------------------------------------------------------------------
53udf0y3k4tkm           3173768908                              8          8 242661878,567349935,704174539,1266720733,2178880220,2806803537,3207530628,359864
fppuw3hpvww2d           2070120408                              7          7 363831330,603602111,1593187514,2364717202,2565895282,2686078735,2965941106
884wy85654py1           4111569919                              7          7 632112415,3257032814,3449243395,3467070348,3469961931,3730707917,3763053651
9s7ppf88qzx2w           1516698366                              6          6 1095282520,1564643292,1756571155,2161287090,2791644918,3961689734
a5nwc1nwxjpmh            407421903                              6          6 3317491535,3628546442,3782059718,4149682373,4203819802,4273419042
4ha4pfb431k5v           3674894058                              6          6 861745801,1435753241,1912618290,2199889814,4008985739,4270850754
4ha4pfb431k5v           2729140098                              6          6 1030693118,1731743139,1738402836,3056206088,3732642245,4099024930
02k6prrffdr54           3653126161                              6          6 334410100,902791824,1944964648,2669300723,3143287778,4009938966
10ccs3aa90fc6            407421903                              6          6 3006981924,3363727614,3782059718,4149682373,4203819802,4273419042
b7gtn71dk4ut8           2386332138                              6          6 1845915547,2610702767,2719337989,3177510604,4167655921,4286743485
b7gtn71dk4ut8           2829664871                              5          5 275492446,764010603,1489835709,2541871809,4258633208
cpfv23w913trx           2784763366                              5          5 1224732786,1997835415,3176308798,3426013877,3508941378
fntpmbttdcgfj            327716455                              5          5 1083514619,1201644573,1390612806,2040136504,4141714670
fntpmbttdcgfj           1303933722                              5          5 1572935291,3381111307,3503179831,3582550733,3978335371
a5nwc1nwxjpmh           1766635739                              5          5 335996886,1041797932,2146114333,2795393169,3960095911

select sql_id,
       plan_hash_value,
       count(distinct full_plan_hash_value)
  from (select sql_id,
               plan_hash_value,
               to_number(extractvalue(h.column_value, '/info')) full_plan_hash_value
          from dba_hist_sql_plan p,
               table(xmlsequence(extract(xmltype(p.other_xml), '/other_xml/info'))) h
         where p.other_xml is not null
           and extractvalue(h.column_value, '/info/@type') = 'plan_hash_full')
 group by sql_id, plan_hash_value
having count(distinct full_plan_hash_value) > 1
-- no rows

SQL> select inst_id,
  2         sql_id,
  3         full_plan_hash_value,
  4         count(distinct plan_hash_value),
  5         LISTAGG(plan_hash_value, ',') WITHIN GROUP (order by plan_hash_value) as PLAN_HASH_LIST
  6    from (select distinct inst_id, sql_id, full_plan_hash_value, plan_hash_value from gv$sql_plan)
  7   group by inst_id, sql_id, full_plan_hash_value
  8  having count(distinct plan_hash_value) > 2
  9  order by count(distinct plan_hash_value) desc
 10  /
 
   INST_ID SQL_ID        FULL_PLAN_HASH_VALUE COUNT(DISTINCTPLAN_HASH_VALUE) PLAN_HASH_LIST
---------- ------------- -------------------- ------------------------------ --------------------------------------------------------------------------------
         1 bqzutt5g7maz0           4040663917                              4 1161615702,1193961320,2244495289,3933111579
         2 bqzutt5g7maz0           4040663917                              4 1161615702,1193961320,2244495289,3933111579
         1 ggs42kf3c7qvn           2501163308                              3 574588468,2229534300,2629104085
         2 f5qvh0dfqv85j           2596262501                              3 839643910,3162305992,3927587791
         2 444hd16rf3pt9           1605847311                              3 873928828,1296956512,2645098960
         2 dnva0wk053j6f           3185355170                              3 1355470901,1585977942,3318143204
         1 dnva0wk053j6f           3185355170                              3 1355470901,3318143204,3903187040
         1 b04zs0wnq7jfb           3811075032                              3 3390740177,3519528342,4218227563
         2 2b24jn81d8x64           2589525303                              3 809607029,1803426806,4182285060
--????

select sql_id,
       plan_hash_value,
       count(distinct full_plan_hash_value)
  from (select sql_id,
               plan_hash_value,
               to_number(extractvalue(h.column_value, '/info')) full_plan_hash_value
          from gv$sql_plan p,
               table(xmlsequence(extract(xmltype(p.other_xml), '/other_xml/info'))) h
         where p.other_xml is not null
           and extractvalue(h.column_value, '/info/@type') = 'plan_hash_full')
 group by sql_id, plan_hash_value
having count(distinct full_plan_hash_value) > 1
