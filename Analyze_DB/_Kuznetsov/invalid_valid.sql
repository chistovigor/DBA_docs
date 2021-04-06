--	This is to compile all invalid objects in the schema.
--	Special intelligence build 
set head off;
set feedback off;
spool inv.lst;
select 'ALTER ' || object_type ||' "'|| object_name || '" compile;'
from user_objects 
where object_type in ('VIEW','TRIGGER','PROCEDURE','FUNCTION', 'PACKAGE', 'MATERIALIZED VIEW','SYNONYM', 'JAVA CLASS') 
  and status = 'VALID' 
  and object_name not like '%BIN$%'
  and object_name in (select name from USER_PLSQL_OBJECT_SETTINGS where PLSQL_OPTIMIZE_LEVEL!=1)
order by object_type desc;
select 'ALTER INDEX ' || index_name || ' rebuild;'
from user_indexes 
where status = 'UNUSABLE';
spool off;
@inv.lst;
spool inv.lst;
select 'ALTER PACKAGE '|| object_name || ' compile body;'
from user_objects 
where object_type in ('PACKAGE BODY', 'SYNONYM') 
  and status = 'VALID'
  and object_name in (select name from USER_PLSQL_OBJECT_SETTINGS where PLSQL_OPTIMIZE_LEVEL!=1)
order by object_type desc;
spool off;
@inv.lst;
set head on;
set feedback on;

select nvl(object_type,'_TOTAL_NUMBER_') object_type, 
       status, 
       count(1) number_obj 
from user_objects 
where status='INVALID' 
group by cube(object_type) , status 
order by 1
/
