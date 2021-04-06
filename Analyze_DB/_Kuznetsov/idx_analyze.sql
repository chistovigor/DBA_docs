begin

for l_index in (select index_name 
                from user_indexes 
                where index_type not in ('IOT - TOP','LOB') 
                  and duration is NULL)
loop

 dbms_output.put_line('Index Name => '||l_index.index_name);
 
 execute immediate 'analyze index '||l_index.index_name||' validate structure' ;

 for l_data in ( select name, 
                        partition_name, 
                        lf_rows,  
                        del_lf_rows, 
                 (
                  case 
                   when (lf_rows=0) then 0
                   else round((del_lf_rows*100/lf_rows),3)
                  end
                 ) as pct_delete_rows,
                 (
                  case 
                   when (lf_rows=0) then 'VALID'
                   when round((del_lf_rows*100/lf_rows),3) <=  30 then 'VALID'
                   when round((del_lf_rows*100/lf_rows),3) >   30 then 'REBUILD'
                   else 'NO STATUS'
                 end
                ) as status
               from index_stats )
  loop
           if l_data.status='REBUILD' then
            dbms_output.put_line('.......... => PCT_DEL_ROWS = '||to_char(l_data.pct_delete_rows,'00D00')||'%');
            dbms_output.put_line('.......... => ALTER INDEX ' || l_data.name ||' REBUILD ONLINE;');
           else
            dbms_output.put_line('.......... => PCT_DEL_ROWS = '||to_char(l_data.pct_delete_rows,'00D00')||'%');
           end if;
           
  end loop;
end loop;
end;
/

