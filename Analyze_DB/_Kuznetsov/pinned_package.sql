select owner, name, type, sharable_mem, loads, kept, executions, locks, pins  
from v$db_object_cache  
where type in ('PROCEDURE','PACKAGE BODY', 'PACKAGE', 'FUNCTION', 'TRIGGER') and kept = 'YES'
order by owner, name
/
