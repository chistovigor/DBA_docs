declare
  l_start number default dbms_utility.get_time; 
begin
dbms_output.put_line('RECOMPILE OBJECTS FOR : '||USER);
dbms_output.put_line('-');
for l_recompile in (select 'ALTER ' || object_type ||' '|| object_name || ' compile' as recompile_cmd
                     from user_objects 
                    where object_type in ('VIEW','TRIGGER','PROCEDURE','FUNCTION', 'PACKAGE', 'MATERIALIZED VIEW','SYNONYM', 'JAVA CLASS') 
                      and status = 'INVALID' 
                      and object_name not like '%BIN$%'
                    union
                    select 'ALTER PACKAGE '|| object_name || ' compile body'
                      from user_objects 
                     where object_type in ('PACKAGE BODY', 'SYNONYM') 
                       and status = 'INVALID'
                     union
                    select 'ALTER INDEX ' || index_name || ' rebuild'
                     from user_indexes 
                    where status = 'UNUSABLE')
loop
 dbms_output.put_line(l_recompile.recompile_cmd);
 begin
 execute immediate l_recompile.recompile_cmd;
 exception  
   when others then dbms_output.put_line ('...'||sqlerrm(sqlcode));
 end;
end loop;
dbms_output.put_line('-');
dbms_output.put_line ('Script work ' || round( (dbms_utility.get_time-l_start)/100, 2 ) || ' seconds' );
end;
/

