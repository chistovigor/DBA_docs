-- blocking sessions

  SELECT blocking_session,
         sid,
         serial#,
         wait_class,
         seconds_in_wait
    FROM v$session
   WHERE blocking_session IS NOT NULL
ORDER BY blocking_session;


select * from DBA_AUDIT_SESSION where ACTION_NAME <> 'LOGOFF' order by 6,3; 

select count(1) from v$session;

SELECT
  'Currently, ' 
  || (SELECT COUNT(*) FROM V$SESSION)
  || ' out of ' 
  || VP.VALUE 
  || ' connections are used.' AS USAGE_MESSAGE
FROM 
  V$PARAMETER VP
WHERE VP.NAME = 'sessions';

-- открытые сессиями курсоры

SELECT a.VALUE,
       s.username,
       s.sid,
       s.serial#
  FROM v$sesstat a, v$statname b, v$session s
 WHERE     a.statistic# = b.statistic#
       AND s.sid = a.sid
       AND b.name = 'opened cursors current'
       AND s.username IS NOT NULL order by 1 desc;

-- wait events count by category

  SELECT a.top_level_call#,
         a.top_level_call_name,
         a.top_level_sql_opcode,
         s.command_name,
         COUNT (*)
    FROM v$active_session_history a, v$sqlcommand s
   WHERE a.top_level_sql_opcode = s.command_type
GROUP BY a.top_level_call#,
         a.top_level_call_name,
         a.top_level_sql_opcode,
         s.command_name
ORDER BY COUNT (*) DESC;

-- анализ сессий и планов выполнения sql в них по ID процесса

SELECT *
  FROM v$process
 WHERE spid = &spid;

SELECT *
  FROM v$session s
 WHERE S.PADDR IN (SELECT addr
                     FROM v$process
                    WHERE spid = &spid);
                    
select sql_id,snap_id, instance_number ,dbid from dba_hist_sqlstat where sql_id in ('&sql_id');

SELECT *
  FROM v$sql s
 WHERE S.SQL_ID = '&sql_id';

SELECT * FROM v$instance;

  SELECT DISTINCT SNAP_ID,
                  SESSION_ID,
                  SESSION_SERIAL#,
                  USER_ID,
                  SQL_EXEC_START
    FROM dba_hist_active_sess_history
   WHERE sql_id = '&sql_id'
ORDER BY SQL_EXEC_START;

select  * from DBA_HIST_SQL_PLAN d where D.SQL_ID = '&sql_id';

select * from sys.V_$SQL_PLAN d where D.PLAN_HASH_VALUE in (&plan_HASH_VALUE);

select * from v$sql_plan s where S.HASH_VALUE = &plan_HASH_VALUE; 

EXEC dbms_workload_repository.create_snapshot;