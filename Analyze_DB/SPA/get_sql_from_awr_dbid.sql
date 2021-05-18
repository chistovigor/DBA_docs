--Функция получения запросов с учетом dbid в аттаче, часть полей устанавливаем в null, т.к. в оригинальной процедуре от Oracle они тоже пустые.
--Пример запуска:
--select * from table(MY_SELECT_CURSOR_AWR(3728474010,46495,46496,'Z#MAIN_DOCUM,Z#RECORDS,Z#DOCUMENT,Z#FIN_ORDER','IBSO')) ;
--
--Фильтр для простоты встроен в процедуру. 
--

create or replace function MY_SELECT_CURSOR_AWR( p_dbid        in number
                                               , p_snap_id_beg in number
                                               , p_snap_id_end in number 
                                               , p_table_list  in varchar2
                                               , p_owner       in varchar2
                                               )
RETURN sys.sqlset PIPELINED IS
   my_rec sqlset_row;
begin
  my_rec:=sqlset_row();

  for my_cur IN
  (
         SELECT st.sql_id, st.force_matching_signature, t.sql_text 
              , null as object_list        --??
              , st.bind_data
              , st.parsing_schema_name
              , module
              , action   
              , elapsed_time
              , cpu_time
              , buffer_gets
              , disk_reads
              , direct_writes
              , rows_processed
              , fetches
              , executions
              , end_of_fetch_count as end_of_fetch_count
              , st.optimizer_cost
              , optimizer_env      
              , 0 as priority              --??
              , t.command_type as command_type 
              , '' as first_load_time      --??    -- VARCHAR2(19),        /* load time of parent cursor */
              , 0 as stat_period           --??    -- NUMBER,       /* period of time (seconds) when the */
              , 0 as active_stat_period    --??    -- NUMBER,    /* effecive period of time (in seconds) */
              , null as other              --??    -- CLOB,  /* other column for user defined attributes */
              , plan_hash_value               
              , null as sql_plan      
              , null as bind_list           --??   -- sql_binds, /* list of user specified binds for Sql */
        FROM (select st.dbid
                  , st.sql_id, st.optimizer_env_hash_value, st.force_matching_signature
                  , st.bind_data
                  , st.parsing_schema_name
                  , st.module
                  , st.action   
                  , sum(elapsed_time_delta) as elapsed_time
                  , sum(cpu_time_delta) as cpu_time
                  , sum(buffer_gets_delta) as buffer_gets
                  , sum(disk_reads_delta) as disk_reads
                  , sum(direct_writes_delta) as direct_writes
                  , sum(rows_processed_delta) as rows_processed
                  , sum(fetches_delta) as fetches
                  , sum(executions_delta) as executions
                  , sum(end_of_fetch_count_delta) as end_of_fetch_count
                  , st.optimizer_cost
                  , st.plan_hash_value                          
                from dba_hist_sqlstat st
                where dbid=p_dbid
                  AND st.snap_id BETWEEN p_snap_id_beg AND p_snap_id_end
                group by st.dbid, st.snap_id, st.instance_number
                  , st.sql_id, st.optimizer_env_hash_value, st.force_matching_signature
                  , st.bind_data
                  , st.parsing_schema_name
                  , st.module
                  , st.action   
                  , st.optimizer_cost 
                  , st.plan_hash_value
              ) st
             , dba_hist_sqltext t
             , DBA_HIST_OPTIMIZER_ENV e
        WHERE st.dbid=p_dbid
          AND st.dbid=t.dbid AND st.sql_id=t.sql_id 
          and st.dbid=e.dbid
          and st.optimizer_env_hash_value=e.optimizer_env_hash_value
          and st.sql_id in (    
                          select unique sql_id from
                            ( select sql_id from dba_hist_sql_plan where (object_owner, object_name) in 
                              ( -- only tables that we need
                                 select owner, table_name 
                                   from dba_tables 
                                  where owner =p_owner
                                   and table_name in 
                                     ( --convert list of table to rows
                                      select tname 
                                        from (
                                              select substr (txt,
                                                              instr (txt, ',', 1, level  ) + 1,
                                                              instr (txt, ',', 1, level+1) - instr (txt, ',', 1, level) -1 
                                                            )  as tname
                                                from (select ','||p_table_list||',' txt from dual)
                                             connect by level <= length(txt)
                                                                -length(replace(txt,',',null))+1
                                             ) 
                                          where tname is not null
                                     ) 
                                union -- and indexes on these tables
                                 select owner, index_name from dba_indexes 
                                  where table_owner = p_owner
                                    and table_name in 
                                      (
                                          select tname 
                                            from (
                                                  select substr (txt,
                                                                  instr (txt, ',', 1, level  ) + 1,
                                                                  instr (txt, ',', 1, level+1) - instr (txt, ',', 1, level) -1 
                                                                )  as tname
                                                    from (select ','||p_table_list||',' txt from dual)
                                                 connect by level <= length(txt)
                                                                    -length(replace(txt,',',null))+1
                                                 ) 
                                              where tname is not null
                                      )
                              )
                            )
                         )
   ) loop            
      my_rec.sql_id                   := my_cur.sql_id                  ;
      my_rec.force_matching_signature := my_cur.force_matching_signature;
      my_rec.sql_text                 := my_cur.sql_text                ;
      my_rec.object_list              := null;--my_cur.object_list        ;
      my_rec.bind_data                := my_cur.bind_data               ;
      my_rec.parsing_schema_name      := my_cur.parsing_schema_name  ;
      my_rec.module                   := my_cur.module               ;
      my_rec.action                   := my_cur.action               ;
      my_rec.elapsed_time             := my_cur.elapsed_time         ;
      my_rec.cpu_time                 := my_cur.cpu_time             ;
      my_rec.buffer_gets              := my_cur.buffer_gets          ;
      my_rec.disk_reads               := my_cur.disk_reads           ;
      my_rec.direct_writes            := my_cur.direct_writes        ;
      my_rec.rows_processed           := my_cur.rows_processed       ;
      my_rec.fetches                  := my_cur.fetches              ;
      my_rec.executions               := my_cur.executions           ;
      my_rec.end_of_fetch_count       := my_cur.end_of_fetch_count   ;
      my_rec.optimizer_cost           := my_cur.optimizer_cost       ;
      my_rec.optimizer_env            := my_cur.optimizer_env        ;
      my_rec.priority                 := my_cur.priority             ;
      my_rec.command_type             := my_cur.command_type         ;
      my_rec.first_load_time          := my_cur.first_load_time      ;
      my_rec.stat_period              := my_cur.stat_period          ;
      my_rec.active_stat_period       := my_cur.active_stat_period   ;
      my_rec.other                    := my_cur.other                ;
      my_rec.plan_hash_value          := my_cur.plan_hash_value      ;
      my_rec.sql_plan                 := null;--my_cur.sql_plan             ;
      my_rec.bind_list                := null;--;my_cur.bind_list            ;

      select CAST(COLLECT
                    (sql_plan_row_type(
                         statement_id,plan_id,timestamp,remarks,
                         operation,options,object_node,object_owner,object_name,
                         object_alias,object_instance,object_type,optimizer,
                         search_columns,id,parent_id,depth,position,cost,
                         cardinality,bytes,other_tag,partition_start,
                         partition_stop,partition_id,distribution,cpu_cost,
                         io_cost,temp_space,access_predicates,filter_predicates,
                         projection,time,qblock_name,other_xml)
                    ) AS SQL_PLAN_TABLE_TYPE) 
        into my_rec.sql_plan
        from (
                select sql_id as statement_id, plan_hash_value as plan_id, timestamp, remarks,
                       operation, options, object_node, object_owner, object_name,
                       object_alias, OBJECT# as object_instance, object_type, optimizer,
                       search_columns, id, parent_id, depth, position,cost,
                       cardinality, bytes, other_tag, partition_start,
                       partition_stop, partition_id, distribution, cpu_cost,
                       io_cost, temp_space, access_predicates, filter_predicates,
                       projection, time, qblock_name, other_xml                                                            
                  from dba_hist_sql_plan 
                 where dbid = p_dbid 
                   and sql_id = my_cur.sql_id 
                   and plan_hash_value = my_cur.plan_hash_value
             );               

      pipe row (my_rec);         
  end loop;

  return ;
end;
/

