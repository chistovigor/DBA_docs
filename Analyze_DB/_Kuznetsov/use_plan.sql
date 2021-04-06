--
-- Содержимое Library Cache
--

--column sql_text format a40
column explainplan format a100

break on username
break on sql_text

select p.username, 
       l.sql_text, 
       lpad(' ',4*(level-2))||operation||' '||options||' '||object_name EXPLAINPLAN
from (
       select s.username, p.address, p.hash_value, p.operation, p.options, p.object_name, p.id, p.parent_id
       from v$sql_plan p, v$session s
       where (p.address = s.sql_address) and 
             (p.hash_value = s.sql_hash_value) and 
             (s.username not in ('SYS','SYSTEM'))
      ) p, v$sql l
where (l.address = p.address) and 
      (l.hash_value = p.hash_value)
start with id=0
connect by prior id = parent_id
/

