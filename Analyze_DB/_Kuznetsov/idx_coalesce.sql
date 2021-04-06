--
-- Дефрагментация индексов
--

spool idx_coalesce1.log

select 'ALTER INDEX ' || owner || '.' || index_name || ' COALESCE;'
from all_indexes 
where index_type in ('NORMAL','BITMAP') and
      table_type = 'TABLE' and 
      partitioned = 'NO' and
      owner in ('MGP')
order by 1
/

spool off

@idx_coalesce1.log
host erase idx_coalesce1.log
 