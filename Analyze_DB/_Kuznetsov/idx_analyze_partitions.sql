--
-- Просмотр секционированных Индексов
-- и анализ индексов в партициях для престройки
-- 
-- Кузнецов Г.В. 2003-09-25
--

set serveroutput on size 1000000

spool idx_analyze_partitions.log

declare
  
  v_partIndexOwner varchar2(30) :='MGP';
  l_start number default dbms_utility.get_time;

begin

for v_partIndexName in (select distinct index_name
                        from   dba_ind_partitions 
                        where  index_owner = v_partIndexOwner)
loop

   dbms_output.put_line('index Name => '||v_partIndexOwner||'.'|| v_partindexName.index_name);


   for v_partName in (select partition_name
                      from   dba_ind_partitions 
                      where  index_owner = v_partIndexOwner and 
                             index_name  = v_partIndexName.index_name)
   loop

       execute immediate 'analyze index ' ||v_partIndexOwner||'.'|| v_partindexName.index_name || ' partition(' ||v_partName.partition_name||') validate structure';
       
       for v_partIndexStat in (select name, 
                                      partition_name, 
                                      lf_rows, 
                                      del_lf_rows, 
                                      round(del_lf_rows*100/decode(lf_rows,0,1,lf_rows),3) as pct_del_lf_rows,
                                      ( case
                                        when round(del_lf_rows*100/decode(lf_rows,0,1,lf_rows),3) <= 30 then 'VALID'
                                        when round(del_lf_rows*100/decode(lf_rows,0,1,lf_rows),3) >  30 then 'REBUILD'
                                        else 'NO STATUS'
                                        end ) as status
                                from index_stats)
        loop

           dbms_output.put_line('.....Partition => '||v_partIndexStat.partition_name||' Status => '||v_partIndexStat.status);
           
           if v_partIndexStat.status='REBUILD' then
            dbms_output.put_line('.............. => PCT_DEL_LEAF_ROWS => '||to_char(v_partIndexStat.pct_del_lf_rows,'00D000'));
            dbms_output.put_line('.............. => ALTER INDEX ' || v_partIndexOwner||'.'|| v_partindexName.index_name ||' REBUILD partition '||v_partName.partition_name ||';');
           end if;

        end loop;
       
   end loop;

end loop;

dbms_output.put_line ('Script works ' || round( (dbms_utility.get_time-l_start)/100, 2 ) || ' seconds...' );

end;
/

spool off
exit


