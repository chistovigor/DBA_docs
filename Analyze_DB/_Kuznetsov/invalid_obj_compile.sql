set serveroutput on size 1000000
set head off
spool inv.lst

begin
for v_x in (select 'ALTER ' || object_type ||' '|| object_name || ' compile;' sql_compile
            from user_objects 
            where object_type in ('VIEW','TRIGGER','PROCEDURE','FUNCTION') 
             and status = 'INVALID'
             order by object_type desc, object_name)
loop
 dbms_output.put_line(v_x.sql_compile);
 -- dbms_output.put_line('show errors;');
end loop;

for v_x in (select 'ALTER ' || object_type ||' '|| object_name || ' compile;' sql_compile
            from user_objects 
            where object_type in ('PACKAGE') 
             and status = 'INVALID'
             order by object_name)
loop
 dbms_output.put_line(v_x.sql_compile);
 -- dbms_output.put_line('show errors;');
end loop;


for v_x in (select 'ALTER PACKAGE '|| object_name || ' compile BODY;'  sql_compile
            from user_objects 
           where object_type in ('PACKAGE BODY') 
             and status = 'INVALID'
             order by object_name)
loop
 dbms_output.put_line(v_x.sql_compile);
 -- dbms_output.put_line('show errors;');
end loop;
end;
/

spool off;
@inv.lst
