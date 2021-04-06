--
-- Check SPM baseline existance for exact SQL_ID
-- Usage: SQL> @bsline_check 4y4bvy7bhkqbn
--
 
 
col sql_handle for a30
col plan_name  for a30
 
select sql_handle, plan_name
  from dba_sql_plan_baselines bl, gv$sqlarea sa
 where dbms_lob.compare(bl.sql_text, sa.sql_fulltext) = 0
   and sa.sql_id = '&&1'
union
select sql_handle, plan_name
  from dba_sql_plan_baselines bl, dba_hist_sqltext sa
 where dbms_lob.compare(bl.sql_text, sa.sql_text) = 0
   and sa.sql_id = '&&1'
/

