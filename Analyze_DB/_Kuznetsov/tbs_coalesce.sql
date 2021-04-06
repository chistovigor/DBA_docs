--
-- Дефрагментация табличных пространст
-- 
--

spool tbs_coalesce1.log

select 'ALTER TABLESPACE ' || tablespace_name || ' COALESCE;'
from dba_tablespaces
where contents='PERMANENT'
/

spool off

@tbs_coalesce1.log
host erase tbs_coalesce1.log
