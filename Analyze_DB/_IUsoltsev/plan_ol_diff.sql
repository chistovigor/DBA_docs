--
-- SQL Plan Outline Hints Differences [for pointed Query block only]
-- Usage: SQL> @plan_ol_diff 6r6sanrs05550 3541904711        6r6sanrs05550 2970372553        [SEL$A7C6D689]
--                           ^sql_id1      ^plan_hash_value1 ^sql_id2      ^plan_hash_value2  ^query_block_name
-- by Igor Usoltsev
--

set feedback on heading on timi off pages 500 lines 500 echo off  VERIFY OFF

col sqlid_&&1_plh_&&2 for a100
col sqlid_&&3_plh_&&4 for a100

with
plh1 as (select substr(extractvalue(value(d), '/hint'), 1, 200) as sqlid_&&1_plh_&&2
  from xmltable('/*/outline_data/hint' passing
                (select xmltype(other_xml) as xmlval
                   from dba_hist_sql_plan
                  where sql_id = '&&1'
                    and plan_hash_value = nvl('&&2',0)
                    and other_xml is not null)) d
         union
         select substr(extractvalue(value(d), '/hint'), 1, 200)
  from xmltable('/*/outline_data/hint' passing
                (select xmltype(other_xml) as xmlval
                   from v$sql_plan
                  where sql_id = '&&1'
                    and plan_hash_value = nvl('&&2',0)
                    and other_xml is not null
                    and child_number = (select min(child_number) from v$sql_plan where sql_id = '&&1' and plan_hash_value = nvl('&&2',0)))) d),
plh2 as (select substr(extractvalue(value(d), '/hint'), 1, 200) as sqlid_&&3_plh_&&4
  from xmltable('/*/outline_data/hint' passing
                (select xmltype(other_xml) as xmlval
                   from dba_hist_sql_plan
                  where sql_id = '&&3'
                    and plan_hash_value = nvl('&&4',0)
                    and other_xml is not null)) d
         union
         select substr(extractvalue(value(d), '/hint'), 1, 200)
  from xmltable('/*/outline_data/hint' passing
                (select xmltype(other_xml) as xmlval
                   from v$sql_plan
                  where sql_id = '&&3'
                    and plan_hash_value = nvl('&&4',0)
                    and other_xml is not null
                    and child_number = (select min(child_number) from v$sql_plan where sql_id = '&&3' and plan_hash_value = nvl('&&4',0)))) d)
select * from plh1 full join plh2 on plh1.sqlid_&&1_plh_&&2 = plh2.sqlid_&&3_plh_&&4
  where --not (plh1.plh_&&2 || plh2.plh_&&3 like 'INDEX%'        or -- may be useful to exclude a lot of non-principal hints
              --     plh1.plh_&&2 || plh2.plh_&&3 like 'NLJ_BATCHING%' or -- --//--
              --     plh1.plh_&&2 || plh2.plh_&&3 like 'OUTLINE%')        -- --//--
              --and  
                     plh1.sqlid_&&1_plh_&&2 || plh2.sqlid_&&3_plh_&&4 like '%' || '&&5' || '%'
minus
select * from plh1 join plh2 on plh1.sqlid_&&1_plh_&&2 = plh2.sqlid_&&3_plh_&&4
/

set feedback on VERIFY ON timi on