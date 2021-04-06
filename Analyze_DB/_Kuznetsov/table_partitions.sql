--
-- Просмотр секционированных таблиц
-- и названий партиций у каждой таблицы
-- 
-- Кузнецов Г.В. 2003-09-25
--


DEFINE v_partTableOwner='MGP'

begin

for v_partTableName in (select distinct table_name
                        from   dba_tab_partitions 
                        where  table_owner = '&v_partTableOwner')
loop

   dbms_output.put_line('Table Name => ' || v_partTableName.table_name);


   for v_partName in (select partition_name
                      from   dba_tab_partitions 
                      where  table_owner = '&v_partTableOwner' and 
                             table_name  = v_partTableName.table_name)
   loop

     dbms_output.put_line('...Partition Name => ' || v_partName.partition_name);
   
   end loop;

end loop;
end;
/
