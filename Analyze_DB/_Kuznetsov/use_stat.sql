col last_analyze format a12
col object_type format a15

select owner, 
       object_type, 
       min(last_analyzed), 
       max(last_analyzed) 
from dba_tab_statistics 
group by owner, object_type 
order by owner, object_type
/


select owner,
       to_char(last_analyze,'YYYY-MON-DD') last_analyze,
       object_count
from (
select owner, 
       trunc(last_analyzed) last_analyze,
       count(object_type) object_count
from dba_tab_statistics 
where owner not in ('SYS','SYSTEM','SYSMAN','XDB','WMSYS')
group by owner, trunc(last_analyzed)
order by owner, trunc(last_analyzed)
)
/


Prompt ##################################################
Prompt # Who is locked
Prompt ##################################################
Prompt # dbms_stats.UNLOCK_TABLE_STATS('OWNER','TABLE');
Prompt # dbms_stats.gather_table_stats(ownname => USER, tabname => 'S_CONTACT_BU'   , granularity => 'ALL', estimate_percent => 100, method_opt => 'FOR ALL COLUMNS SIZE 1', degree => 4, cascade => TRUE ); 
Prompt # dbms_stats.gather_index_stats(ownname => USER, indname => 'S_CONTACT_BU_M2', granularity => 'ALL', estimate_percent => 100);
Prompt # dbms_stats.LOCK_TABLE_STATS('OWNER','TABLE');
Prompt ##################################################

SELECT owner, table_name, stattype_locked
FROM dba_tab_statistics
WHERE stattype_locked is not null
order by owner, table_name
/


