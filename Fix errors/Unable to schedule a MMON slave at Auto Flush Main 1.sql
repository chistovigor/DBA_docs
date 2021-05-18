В БД блокировки с ожиданием library cache: mutex X

1) Остановить процессы mmon,mmnl,m000
2) Остановить EMCA
3) Убить сессии EMCA (DBSNMP) с указанными блокировками

Если не помогает:

  SELECT blocking_session,
         sid,
         serial#,
         wait_class,
         seconds_in_wait
    FROM v$session
   WHERE blocking_session IS NOT NULL
ORDER BY blocking_session;

1) https://iusoltsev.wordpress.com/2012/02/12/awr-snapshot-suspend-oracle-11g/

alter system set "_awr_disabled_flush_tables"='WRH$_TEMPSTATXS,WRH$_IOSTAT_FILETYPE';

-- может выполняться ДОЛГО:

select * from v$sql where sql_text like 'insert into wrh$_tempstatxs%';

2) --alter system set "_awr_disabled_flush_tables" = 'wrh$_tempstatxs';

3) Oracle support Doc ID 1392603.1, Bug 13372759, 2043531.1

select table_name_kewrtb name, end_time-begin_time time 
 from wrm$_snapshot_details, x$kewrtb 
 where snap_id = :snap_id 
 and dbid = :dbid 
 and table_id = table_id_kewrtb 
 order by time desc; 
 
 4)
 
 To gather the dictionary stats:-
 
EXEC DBMS_STATS.GATHER_SCHEMA_STATS ('SYS');
exec DBMS_STATS.GATHER_DATABASE_STATS (gather_sys=>TRUE);
EXEC DBMS_STATS.GATHER_DICTIONARY_STATS;
exec DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;


