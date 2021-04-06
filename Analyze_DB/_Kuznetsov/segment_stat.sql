select owner, object_type, object_name, ss.value as logical_reads
from (
select ts#, 
       obj#, 
       statistic_name, 
       value, 
       row_number() over (order by value desc) rn  
from v$segstat where statistic_name='logical reads'
) ss,
dba_objects oo
where oo.object_id=ss.obj# 
  and ss.rn<41
  and owner!='SYS'
order by ss.value desc
/
