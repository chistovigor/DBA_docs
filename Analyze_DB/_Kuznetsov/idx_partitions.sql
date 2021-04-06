--
-- Просмотр секционированных таблиц
-- и названий партиций у каждой таблицы
-- 
-- Кузнецов Г.В. 2003-09-25
--


DEFINE v_partIndexOwner='MGP'

begin

for v_partIndexName in (select distinct index_name
                        from   dba_ind_partitions 
                        where  index_owner = '&v_partIndexOwner')
loop

   dbms_output.put_line('index Name => ' || v_partindexName.index_name);


   for v_partName in (select partition_name
                      from   dba_ind_partitions 
                      where  index_owner = '&v_partIndexOwner' and 
                             index_name  = v_partIndexName.index_name)
   loop

     dbms_output.put_line('...Partition Name => ' || v_partName.partition_name);
   
   end loop;

end loop;
end;
/
