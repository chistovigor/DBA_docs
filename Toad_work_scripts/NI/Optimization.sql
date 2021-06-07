-- SQLT analysis run
--(role SQLT_USER_ROLE must be granted to the user who will run that, usually is it app user)

sqlplus igor_oem@way4db1
EXEC sqltxadmin.sqlt$a.set_sess_param('connect_identifier', '@way4db1'); --for remote execution
--xtract method
start W:\_Distrib\Oracle\sqlt\run\sqltxtract.sql 3xr4ktt8tpb3k sqlt2020#

--To monitor progress, login into another session and execute:
SELECT * FROM SQLTXADMIN.sqlt$_log_v;

-- ASH

SELECT * FROM V$SESSION WHERE USERNAME like '%_OEM'; --dba admins sessions
SELECT count(distinct SESSION_ID),trunc(sample_time),SESSION_ID FROM DBA_HIST_ACTIVE_SESS_HISTORY where USER_ID = (SELECT USER_ID FROM DBA_USERS WHERE USERNAME = 'MDATA_MDDEV_HADOOP') group by trunc(sample_time),SESSION_ID order by 1 desc;
SELECT * FROM SESSION_INFO; --when v$session select fails with partial multibyte character error
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SQL_ID = 'f381qj6qv32q6' order by 1;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SQL_ID = 'f381qj6qv32q6' order by 1;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE TOP_LEVEL_SQL_ID = 'f381qj6qv32q6' order by 1;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SQL_ID = 'ak6m7xt756bv5' and SESSION_ID = 5855 order by 1;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SQL_ID IN (SELECT SQL_ID FROM V$SQL WHERE upper(SQL_TEXT) LIKE 'SELECT TRADETIME, ORDERNO, SECURITYID, QUANTITY FROM CURR.V_TRADES_BASE%') order by 1;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SESSION_ID = 1311 and SESSION_SERIAL# = 55204 order by 1;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SESSION_ID = 2599 order by 1;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SESSION_ID in (3922,1216) order by SAMPLE_TIME;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE USER_ID  = 597 and SAMPLE_TIME between to_date('05122017 14:59:00','ddmmyyyy hh24:mi:ss') and to_date('05122017 15:00:00','ddmmyyyy hh24:mi:ss') order by SAMPLE_TIME;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE USER_ID  = 597 and SAMPLE_TIME >= sysdate- 1/24 order by SAMPLE_TIME;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SAMPLE_TIME between to_date('08012019 21:07:00','ddmmyyyy hh24:mi:ss') and to_date('08012019 21:07:10','ddmmyyyy hh24:mi:ss') order by SAMPLE_TIME;

--plan lines execution monitoring 

SELECT count(1),
       SQL_ID,
       SESSION_ID,
       SESSION_SERIAL#,
       SQL_CHILD_NUMBER,
       SQL_PLAN_HASH_VALUE,
       SQL_PLAN_LINE_ID,
       SQL_PLAN_OPERATION,
       SQL_PLAN_OPTIONS
  FROM V$ACTIVE_SESSION_HISTORY
 WHERE SQL_ID = 'g1d2u941gurtz' group by SQL_ID,
       SESSION_ID,
       SESSION_SERIAL#,
       SQL_CHILD_NUMBER,
       SQL_PLAN_HASH_VALUE,
       SQL_PLAN_LINE_ID,
       SQL_PLAN_OPERATION,
       SQL_PLAN_OPTIONS order by 1 desc;

-- SQL execution monitoring (for plan operations)

select * from V$SQL_PLAN_MONITOR where sql_id = '3xr4ktt8tpb3k' and SQL_EXEC_ID = 20437692 order by PLAN_LINE_ID;

-- if not enough info in ASH it seems ASH buffer size is too small

select min(SAMPLE_TIME) from V$ACTIVE_SESSION_HISTORY;
select * from v$ash_info;
select * from v$sgastat where name like 'ASH buffers';
--alter system set "_ash_size"=251658240 scope = memory sid = '*'; -- emergency flush will appear during resize (see alertlog) !

--maximum CPU usage metric history from DB (metric = Host CPU Utilization (%) )

  SELECT METRIC_NAME,
         SNAP_ID,
         BEGIN_TIME,
         END_TIME,
         ROUND (MAXVAL)                 MAXVAL,
         ROUND (AVERAGE)                AVERAGE,
         ROUND (STANDARD_DEVIATION)     STD_DEV
    FROM DBA_HIST_SYSMETRIC_SUMMARY
   WHERE     METRIC_ID = 2057
         AND INSTANCE_NUMBER = 1
         AND BEGIN_TIME >= ADD_MONTHS (SYSDATE, -2)
         AND                            /*to_number(to_char(begin_time,'hh24')) between 0 and 8
and*/
             MAXVAL > 30
         AND STANDARD_DEVIATION > 10
         AND AVERAGE > 10
       --AND MAXVAL > AVERAGE*2
ORDER BY SNAP_ID DESC;

-- find SQL by plan hash
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SQL_PLAN_HASH_VALUE = 3894657618 order by 1;
SELECT * FROM V$SQL WHERE SQL_ID = 'atj13qs9vgzvn';
SELECT * FROM V$SQL WHERE upper(SQL_TEXT) LIKE '%TRUNCATE%' order by FIRST_LOAD_TIME DESC;
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SESSION_ID = 1767 and SESSION_SERIAL# = 23143 and SAMPLE_TIME >= trunc(sysdate-1) order by SAMPLE_TIME;
--execution plans history with execution time
select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
nvl(executions_delta,0) execs,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where sql_id = 'fnx519kyqw9kn'
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
order by 1, 2, 3;
-- count wait events for query
  SELECT ASH.SQL_ID, ASH.SQL_PLAN_LINE_ID, COUNT (1)
    FROM DBA_HIST_ACTIVE_SESS_HISTORY ASH
   WHERE     ASH.SESSION_ID = 2318
         AND ASH.SAMPLE_TIME BETWEEN TO_DATE ('07.01.2019 17:00:00',
                                              'DD.MM.YYYY HH24:MI:SS')
                                 AND TO_DATE ('08.01.2019 23:59:00',
                                              'DD.MM.YYYY HH24:MI:SS')
GROUP BY ASH.SQL_ID, ASH.SQL_PLAN_HASH_VALUE,ASH.SQL_PLAN_LINE_ID
ORDER BY COUNT (1) DESC;
  SELECT ASH.SQL_ID, ASH.SQL_PLAN_LINE_ID, COUNT (1)
    FROM V$ACTIVE_SESSION_HISTORY ASH
   WHERE     ASH.SQL_ID = 'f381qj6qv32q6'
         AND ASH.SAMPLE_TIME BETWEEN TO_DATE ('16.01.2019 11:00:00',
                                              'DD.MM.YYYY HH24:MI:SS')
                                 AND TO_DATE ('16.01.2019 12:00:00',
                                              'DD.MM.YYYY HH24:MI:SS')
GROUP BY ASH.SQL_ID, ASH.SQL_PLAN_LINE_ID,ASH.SQL_PLAN_HASH_VALUE
ORDER BY COUNT (1) DESC;
  SELECT ASH.SQL_ID,
         ASH.SQL_PLAN_LINE_ID,
         ASH.SQL_CHILD_NUMBER,
         COUNT (1)
    FROM V$ACTIVE_SESSION_HISTORY ASH
   WHERE     ASH.SESSION_ID = 2318
         AND ASH.SAMPLE_TIME BETWEEN TO_DATE ('07.01.2019 17:00:00',
                                              'DD.MM.YYYY HH24:MI:SS')
                                 AND TO_DATE ('08.01.2019 23:59:00',
                                              'DD.MM.YYYY HH24:MI:SS')
GROUP BY ASH.SQL_ID, ASH.SQL_PLAN_LINE_ID, ASH.SQL_CHILD_NUMBER
ORDER BY COUNT (1) DESC;
select *
  from dba_hist_sqltext s
where s.SQL_ID = '7wyp2tu352jbv';

-- analyze execution time for query (min,max) with SQL_EXEC_ID

SELECT
    sql_id,
    sql_plan_hash_value,
    COUNT(*),
    round(AVG(EXTRACT(HOUR FROM run_time) * 3600 + EXTRACT(MINUTE FROM run_time) * 60 + EXTRACT(SECOND FROM run_time)), 2) avg_time_sec
    ,
    round(MIN(EXTRACT(HOUR FROM run_time) * 3600 + EXTRACT(MINUTE FROM run_time) * 60 + EXTRACT(SECOND FROM run_time)), 2) min_time_sec
    ,
    round(MAX(EXTRACT(HOUR FROM run_time) * 3600 + EXTRACT(MINUTE FROM run_time) * 60 + EXTRACT(SECOND FROM run_time)), 2) max_time_sec
FROM
    (
        SELECT
            sql_id,
            sql_exec_id,
            TO_CHAR(sql_exec_start, 'ddmmyyyy hh24:mi:ss') startted_at,
            sql_plan_hash_value,
            MAX(sample_time - sql_exec_start) run_time
        FROM
            dba_hist_active_sess_history --V$ACTIVE_SESSION_HISTORY 
        WHERE
            sql_exec_start IS NOT NULL
            AND sql_id = '6bwu1g1f9y0sw'--'3w8s06wss9vt4'
			AND DBID = (select DBID from v$database)
			AND sample_time >= sysdate-14
        GROUP BY
            sql_id,
            sql_exec_id,
            TO_CHAR(sql_exec_start, 'ddmmyyyy hh24:mi:ss'),
            sql_plan_hash_value
        --having MAX(sample_time - sql_exec_start) >=INTERVAL '01:00:00.0000000' HOUR TO SECOND
        ORDER BY
            sql_exec_id
    )
-- where rownum < 100
GROUP BY
    sql_id,
    sql_plan_hash_value
ORDER BY
    avg_time_sec DESC;
	
-- locking/locked ROWIDs

  SELECT ASH.SESSION_ID,
         ASH.SQL_ID,
         ASH.MODULE,
         ASH.MACHINE,
         ASH.ACTION,
         ASH.EVENT,
         ASH.BLOCKING_SESSION,
         ASH.CURRENT_OBJ#,
         ASH.CURRENT_FILE#,
         ASH.CURRENT_BLOCK#,
         ASH.CURRENT_ROW#,
         ASH.PLSQL_ENTRY_OBJECT_ID,
         ASH.PLSQL_ENTRY_SUBPROGRAM_ID,
         ASH.PLSQL_OBJECT_ID,
         ASH.PLSQL_SUBPROGRAM_ID,
         CASE
             WHEN EVENT = 'enq: TX - row lock contention'
             THEN
                 DBMS_ROWID.ROWID_CREATE (
                     1,
                     (SELECT DATA_OBJECT_ID
                        FROM DBA_OBJECTS
                       WHERE OBJECT_ID = ASH.CURRENT_OBJ#),
                     ASH.CURRENT_FILE#,
                     ASH.CURRENT_BLOCK#,
                     ASH.CURRENT_ROW#)
             ELSE
                 NULL
         END
             ROWID_TO_SEARCH,
         CASE
             WHEN EVENT = 'enq: TX - row lock contention'
             THEN
                 (SELECT OBJECT_NAME
                    FROM DBA_OBJECTS O
                   WHERE O.OBJECT_ID = ASH.CURRENT_OBJ#)
             ELSE
                 NULL
         END
             CURRENT_OBJECT_NAME,
         SUM (ASH.TIME_WAITED)
             TOTAL_TIME_WAITED,
         (SELECT MIN (SQL_TEXT)
            FROM V$SQL
           WHERE SQL_ID = ASH.SQL_ID)
             SQL_TEXT
    FROM v$active_session_history ASH     /*v$active_session_history DBA_HIST_ACTIVE_SESS_HISTORY ash*/
   WHERE     1 = 1 /*---------------------------------------------------------------*/
         /*--------------specify time interval here-----------------------*/
         AND SAMPLE_TIME >= TO_DATE ('2018-11-10 10:10', 'yyyy-mm-dd hh24:mi')
         AND SAMPLE_TIME <= TO_DATE ('2018-11-10 10:30', 'yyyy-mm-dd hh24:mi')
GROUP BY ASH.SESSION_ID,
         ASH.SQL_ID,
         ASH.MODULE,
         ASH.MACHINE,
         ASH.ACTION,
         ASH.EVENT,
         ASH.BLOCKING_SESSION,
         ASH.CURRENT_OBJ#,
         ASH.CURRENT_FILE#,
         ASH.CURRENT_BLOCK#,
         ASH.CURRENT_ROW#,
         ASH.PLSQL_ENTRY_OBJECT_ID,
         ASH.PLSQL_ENTRY_SUBPROGRAM_ID,
         ASH.PLSQL_OBJECT_ID,
         ASH.PLSQL_SUBPROGRAM_ID
ORDER BY TOTAL_TIME_WAITED DESC;
	
--analyze segments accessed for queries from particular user during particular time (warm up buffer cache)

select h.sql_id, min(sample_time), max (sample_time), 
case when sum(executions_delta) = 0 then 0   else round(sum(elapsed_time_delta)/sum(executions_delta)/1000000, 3)  end "ElapsedPerExec(s)",
    round(sum(elapsed_time_delta)/1000000) "ElapsedTime (s)",  sum(executions_delta) "Executions", object_type, object_name, operation, options,
    (select round(sum(bytes)/1025/1024) from dba_segments where segment_name = object_name) "Segment Size (Mb)"
from dba_hist_sql_plan p, dba_hist_active_sess_history h, dba_hist_sqltext s, dba_hist_sqlstat e
where p.object_owner = 'OWS' and p.sql_id =h.sql_id  and p.sql_id =s.sql_id and p.sql_id =e.sql_id 
and user_id=(select user_id from dba_users where username='DWH_CONNECTOR')
and sample_time between trunc(sysdate) and trunc(sysdate)+50/24
group by h.sql_id,  object_type, object_name, operation, options
order by 1, 2;

--	Top elapsed time queries (Egypt):

select st.*,sql_text  from
     (select * from
     (select * from
     (select    Parsing_schema_name schema, module, sql_id,plan_hash_value plan_HV, 
           min(t.snap_id) lo_snap, max(t.snap_id) hi_snap, count(t.snap_id) snap_cnt,
           min(to_number(to_char(end_interval_time,'hh24'))) min_hr, max(to_number(to_char(end_interval_time,'hh24'))) max_hr, 
           count(distinct to_number(to_char(end_interval_time,'hh24'))) hr_cnt, sum(executions_delta) exec#,
           trunc(sum(elapsed_time_delta)/1000000) elap, (sum(elapsed_time_delta)/1000000)/nullif(sum(executions_delta),0) elap_exec# , trunc(sum(cpu_time_delta)/1000000) cpu, trunc(sum(clwait_delta)/1000000) CLTIME,
           trunc(sum(ccwait_delta)/1000000) CCTIME, trunc(sum(apwait_delta)/1000000) APTIME, trunc(sum(iowait_delta)/1000000) IOTIME,
           sum(buffer_gets_delta) gets, sum(disk_reads_delta) reads,
           sum(physical_read_requests_delta) read_reqs,
           sum(rows_processed_delta) rowsss, sum(sorts_delta) sorts, sum(px_servers_execs_delta) PX
     from dba_hist_sqlstat t, dba_hist_snapshot n
     where t.snap_id=n.snap_id
     and   t.instance_number=n.instance_number
     and   t.dbid=n.dbid
     --and   to_number(to_char(end_interval_time,'hh24')) between 10 and 17
     and plan_hash_value>0
     and t.snap_id between 8192  and 8198
     --and end_interval_time>sysdate -(5/24)
     --and lower(module) like 'pth%' 
     --and sql_id='dsvnh50zv3g1z'
     group by Parsing_schema_name ,module, sql_id,plan_hash_value)) s ) st, dba_hist_sqltext sq
     where st.sql_id=sq.sql_id
     order by elap desc;

--	How to check if sql id has baseline created and which planhv (Egypt):

select s.*,
(select REGEXP_SUBSTR(plan_table_output,'[0-9]+') plan_hv
    from table(DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE(s.sql_handle, s.plan_name))
    where plan_table_output like 'Plan hash value:%'
    ) baseline_phv
      from dba_sql_plan_baselines s where SIGNATURE = (select DISTINCT EXACT_MATCHING_SIGNATURE from gv$sql  where sql_id = '48b7rapy18r91');

select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE UPPER(MODULE) LIKE '%INSERT_SE_ORD_TRD_ONLINE%' and SAMPLE_TIME >= trunc(sysdate-7) and MACHINE <> 'NT_D\CHISTOV15' order by SAMPLE_TIME;
SELECT COUNT(SQL_EXEC_ID),D_START FROM (SELECT DISTINCT SQL_EXEC_ID SQL_EXEC_ID,TRUNC(SQL_EXEC_START) D_START FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID = 'fu7p0q9y9wsgw') WHERE SQL_EXEC_ID IS NOT NULL GROUP BY D_START ORDER BY 1 DESC;
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SESSION_ID in (216,3884) and SAMPLE_TIME between to_date('19012018 03:40:00','ddmmyyyy hh24:mi:ss') and to_date('19012018 03:50:00','ddmmyyyy hh24:mi:ss') order by SAMPLE_TIME;
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SESSION_ID = 216 and SESSION_SERIAL# = 50507 and SAMPLE_TIME between to_date('19012018 00:00:00','ddmmyyyy hh24:mi:ss') and to_date('19012018 03:50:00','ddmmyyyy hh24:mi:ss') order by SAMPLE_TIME;	
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME between to_date('07012019 23:18:30','ddmmyyyy hh24:mi:ss') and to_date('07012019 23:18:45','ddmmyyyy hh24:mi:ss') order by sample_time;
--datalogia (insert into online tables)
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME between to_date('17052018 17:00:00','ddmmyyyy hh24:mi:ss') and to_date('17052018 18:00:00','ddmmyyyy hh24:mi:ss') and session_id = 1767  and MODULE = 'INSERT_SE_ORD_TRD_ONLINE' order by SAMPLE_TIME;
--
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID = '68nx6kzv9cx6j' and SAMPLE_TIME between to_date('05072018 09:00:00','ddmmyyyy hh24:mi:ss') and to_date('05072018 17:50:00','ddmmyyyy hh24:mi:ss') order by SAMPLE_TIME;
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME between to_date('24012018 23:49:00','ddmmyyyy hh24:mi:ss') and to_date('25012018 01:50:00','ddmmyyyy hh24:mi:ss') and USER_ID = 117 order by SAMPLE_TIME;
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SESSION_ID = 2594 AND SAMPLE_TIME between to_date('28042018 04:02:00','ddmmyyyy hh24:mi:ss') and to_date('28042018 06:10:00','ddmmyyyy hh24:mi:ss') and USER_ID = 117 order by SAMPLE_TIME;
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE USER_ID = 117 /*AND SESSION_ID = 1827*/ AND SAMPLE_TIME between to_date('19042018 4:08:20','ddmmyyyy hh24:mi:ss') and to_date('19042018 06:35:00','ddmmyyyy hh24:mi:ss') order by SAMPLE_TIME;
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_PLAN_HASH_VALUE = 1003673585 order by SAMPLE_TIME;
SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID = '2dyk32a8nvzft' and SAMPLE_TIME >= add_months(sysdate,-1) order by SAMPLE_TIME;
SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID = '1gp9f5gyaq3v7' and SAMPLE_TIME >= (sysdate-10/24) and session_id = 1054 order by SAMPLE_TIME;
SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID = 'g69svm2vvquky' and SAMPLE_TIME >= (sysdate-2) order by SAMPLE_TIME;
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID in ('28cqz096rgbya');
SELECT * FROM DBA_HIST_SQLTEXT WHERE upper(SQL_TEXT) like '%FORTS_AR.FUT_AR_DEAL_UPDBASE_3ST(119957)%';
SELECT * FROM DBA_USERS WHERE USERNAME in ('LOADER_FORTS_REPAAR','LOADER_COMPARE_ARDB6');
SELECT * FROM DBA_USERS WHERE USER_ID in (1547,1548);
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID IN
(select SQL_ID from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME between 
to_date('11072017 04:37:30','ddmmyyyy hh24:mi:ss') and to_date('11072017 04:39:00','ddmmyyyy hh24:mi:ss') and SQL_OPCODE = 189);
SELECT * FROM DBA_HIST_SQLTEXT WHERE lower(SQL_TEXT) LIKE '%v_lor%';
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID in ('904aa7z02tv6z','5q8j0zrqzsycm','0d5cwwc3wd65j');
SELECT * FROM DBA_HIST_SQLSTAT WHERE SQL_ID = 'bvkv5t8qmprd9' order by SNAP_ID;
SELECT * FROM DBA_HIST_SNAPSHOT where SNAP_ID = 26724;--order by 1;

-- deep AWR analysis

--execution time per SQL execution for particular SQL_ID

SELECT max(sample_time)-SQL_EXEC_START exec_time,sql_exec_id,sql_id,PROGRAM
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE SAMPLE_TIME BETWEEN TO_DATE ('24022021 20:31:10',
                                      'ddmmyyyy hh24:mi:ss')
                         AND TO_DATE ('24022021 20:39:50',
                                      'ddmmyyyy hh24:mi:ss') and SQL_ID = '3n4cu6chdnh6s'                                     
group by SQL_EXEC_START,sql_exec_id,sql_id,PROGRAM order by 1 desc;

--wait_time per event and amount of data being read for particular SQL_ID

select sum(READ_MB), sum(time_ms), event from (
  SELECT ROUND (SUM (DELTA_READ_IO_BYTES) / 1024 / 1024)     READ_MB,
         SUM (TIME_WAITED) time_ms,
         EVENT/*,
         SQL_EXEC_ID*/
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     DBID = 510869778
         AND SAMPLE_TIME BETWEEN TO_DATE ('24022021 20:31:10',
                                          'ddmmyyyy hh24:mi:ss')
                             AND TO_DATE ('24022021 20:40:10',
                                          'ddmmyyyy hh24:mi:ss')
         AND MACHINE = 'uniw4prfdb3p'
         --  AND SQL_EXEC_ID = 16777303
         AND SQL_ID = '86bwssryn55d0'
GROUP BY SQL_EXEC_ID,EVENT
ORDER BY 2 DESC)
group by event
order by 2 desc;

-- WAIT events histogram trend analysis for particular event

select trunc(snap_end),WAIT_TIME_MILLI,sum(WAIT_COUNT) from (
SELECT s.END_INTERVAL_TIME snap_end, h.*
  FROM DBA_HIST_EVENT_HISTOGRAM H, DBA_HIST_SNAPSHOT S
 WHERE     S.SNAP_ID = H.SNAP_ID
       AND S.INSTANCE_NUMBER = H.INSTANCE_NUMBER
       AND EVENT_NAME = 'log file sync'
       AND WAIT_TIME_MILLI = 4096
      -- AND WAIT_COUNT > 10
       AND H.INSTANCE_NUMBER = 1
       AND s.END_INTERVAL_TIME >= sysdate - 90
       order by WAIT_TIME_MILLI*WAIT_COUNT desc)
group by trunc(snap_end),WAIT_TIME_MILLI having trunc(snap_end) >= sysdate-90 order by 1,2 desc;

select trunc(snap_end),WAIT_TIME_MILLI,sum(WAIT_COUNT) from (
SELECT trunc(s.END_INTERVAL_TIME,'hh24') snap_end, h.WAIT_TIME_MILLI,sum(h.WAIT_COUNT) WAIT_COUNT
  FROM DBA_HIST_EVENT_HISTOGRAM H, DBA_HIST_SNAPSHOT S
 WHERE     S.SNAP_ID = H.SNAP_ID
       AND S.INSTANCE_NUMBER = H.INSTANCE_NUMBER
       AND EVENT_NAME = 'log file sync'
       AND WAIT_TIME_MILLI = 4096
    --   AND WAIT_COUNT > 10
       AND H.INSTANCE_NUMBER = 1
       AND s.END_INTERVAL_TIME >= sysdate - 3
       group by trunc(s.END_INTERVAL_TIME,'hh24'), h.WAIT_TIME_MILLI
       order by 1,sum(h.WAIT_COUNT) desc/*WAIT_TIME_MILLI*WAIT_COUNT desc*/)
group by trunc(snap_end),WAIT_TIME_MILLI having trunc(snap_end) >= sysdate-95 order by 1,3 desc;

-- histogram for i/o related wait events with the most difference:

  SELECT TRUNC (S.END_INTERVAL_TIME)     MON_DATE,
         EVENT_NAME,
         WAIT_CLASS,
         WAIT_TIME_MILLI,
         SUM (WAIT_COUNT) total_waits_for_day
    FROM DBA_HIST_EVENT_HISTOGRAM H, DBA_HIST_SNAPSHOT S
   WHERE     S.SNAP_ID = H.SNAP_ID
         AND S.INSTANCE_NUMBER = H.INSTANCE_NUMBER
         AND EVENT_NAME = 'log file sync'
         AND WAIT_TIME_MILLI = 4096
         -- AND WAIT_COUNT > 10
         AND H.INSTANCE_NUMBER = 1
         --AND WAIT_CLASS <> 'Idle'
         AND (WAIT_CLASS = 'Commit' OR WAIT_CLASS LIKE '% I/O')
         AND S.END_INTERVAL_TIME >= SYSDATE - 14
GROUP BY TRUNC (S.END_INTERVAL_TIME),
         EVENT_NAME,
         WAIT_CLASS,
         WAIT_TIME_MILLI
         HAVING SUM (WAIT_COUNT) > 5000
ORDER BY 1, 5 DESC;

-- wait events time for SQL_ID for particular action/module activity

  SELECT /*+ parallel*/
         TRUNC (SAMPLE_TIME)     REPORT_DATE,
         min(sample_time),
         max(sample_time)-min(sample_time) time_diff,
         SQL_ID,
         SQL_EXEC_ID,
         SQL_PLAN_HASH_VALUE,
         SQL_FULL_PLAN_HASH_VALUE,
         EVENT,
         WAIT_CLASS,
         SUM (TIME_WAITED)       WAITS,
         round(SUM (DELTA_READ_IO_BYTES)/1024/1024) READ_MB,
         round(SUM (DELTA_WRITE_IO_BYTES)/1024/1024) WRITE_MB
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE  dbid = 3829535888 and   ACTION LIKE '%opt_dunf_stmt_load%'
         AND TRUNC (SAMPLE_TIME) between
                TO_DATE ('10022021', 'ddmmyyyy') and
                  TO_DATE ('27022021', 'ddmmyyyy')
GROUP BY TRUNC (SAMPLE_TIME),
         SQL_ID,
         SQL_EXEC_ID,
         SQL_PLAN_HASH_VALUE,
         SQL_FULL_PLAN_HASH_VALUE,
         EVENT,
         WAIT_CLASS
ORDER BY 1, 4, 5, 2, 10 desc;

-- waits for particular SQL_ID with deviation groupped by event

  SELECT EVENT,
         ROUND (AVG (TIME_WAITED)) avg_wait,
         --COUNT (1),
         SUM (TIME_WAITED) total_waits,
         ROUND (STDDEV (TIME_WAITED)) deviation
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     DBID = 3829535888
         AND ACTION LIKE '%opt_dunf_stmt_load%'
         AND TRUNC (SAMPLE_TIME) BETWEEN TO_DATE ('10022021', 'ddmmyyyy')
                                     AND TO_DATE ('27022021', 'ddmmyyyy')
         AND SQL_ID = 'apqs43qp9j5bz'
         AND SQL_EXEC_ID = 16777216
GROUP BY TRUNC (SAMPLE_TIME),
         SQL_ID,
         SQL_EXEC_ID,
         EVENT
ORDER BY 3 DESC, 4 DESC;

-- temporary tablespace consumption over time (for SQL_ID, plan line)

  SELECT SQL_ID,
         EVENT,
         ROUND (TEMP_SPACE_ALLOCATED) / 1024 / 1024     TEMP_MB,
         SQL_PLAN_LINE_ID,
         DBA_HIST_ACTIVE_SESS_HISTORY.*
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE SAMPLE_TIME BETWEEN TO_DATE ('22022021 00:01:00',
                                      'ddmmyyyy hh24:mi:ss')
                         AND TO_DATE ('22022021 10:25:00',
                                      'ddmmyyyy hh24:mi:ss')
                                      and ROUND (TEMP_SPACE_ALLOCATED) / 1024 / 1024 > 1000
ORDER BY SAMPLE_TIME DESC;

-- find PL SQL procedures from AWR (PLSQL_ENTRY_OBJECT_ID)

select * from dba_procedures where object_name = 'SCDP' and procedure_name = 'POST_MTR1';

-- DISTINCT modules and action from last day

  SELECT DISTINCT MODULE, ACTION
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE SAMPLE_TIME >= TRUNC (SYSDATE) AND UPPER (MODULE) LIKE '%TALEND%'
ORDER BY 2,1;

--snap info
  SELECT A.DBID,
         MIN (A.SNAP_ID)                 MINSNAP,
         MAX (A.SNAP_ID)                 MAXSNAP,
         MIN (S.BEGIN_INTERVAL_TIME)     MINTIME,
         MAX (S.END_INTERVAL_TIME)       MAXTIME
    FROM DBA_HIST_ACTIVE_SESS_HISTORY A, DBA_HIST_SNAPSHOT S
   WHERE A.SNAP_ID = S.SNAP_ID AND A.DBID = S.DBID
GROUP BY A.DBID
ORDER BY A.DBID;
SELECT * FROM DBA_HIST_SQL_PLAN WHERE upper(OBJECT_NAME) like '%HP_FA_ACC_REST_OLT_BASE_1_UIDX%';
SELECT min(TIMESTAMP), max(TIMESTAMP) FROM DBA_HIST_SQL_PLAN;
-- find executions plans
SELECT * FROM DBA_HIST_SQL_PLAN WHERE SQL_ID = 'caa13zxgd05wp' order by TIMESTAMP,PLAN_HASH_VALUE,id;
SELECT * FROM DBA_HIST_SQL_PLAN WHERE PLAN_HASH_VALUE = 3310312296;
SELECT * FROM V$SQL_PLAN WHERE SQL_ID = 'caa13zxgd05wp' order by TIMESTAMP,PLAN_HASH_VALUE,id;
SELECT DISTINCT TRUNC(TIMESTAMP),PLAN_HASH_VALUE FROM DBA_HIST_SQL_PLAN WHERE SQL_ID = 'cd3qr7vu8arw4' order by TRUNC(TIMESTAMP),PLAN_HASH_VALUE;
-- find plans for the given SQL_ID over time from ASH
  SELECT SQL_EXEC_ID,
         SQL_PLAN_HASH_VALUE,
         MAX (SAMPLE_TIME) - MIN (SAMPLE_TIME)                     AS DURATION,
         COUNT (*)                                                 AS ASH_ROWS,
         COUNT (DISTINCT SESSION_ID || ' ' || SESSION_SERIAL#)     AS PX_COUN
    FROM V$ACTIVE_SESSION_HISTORY--DBA_HIST_ACTIVE_SESS_HISTORY--
   WHERE SQL_ID = '68nx6kzv9cx6j' AND SQL_EXEC_ID IS NOT NULL
GROUP BY SQL_EXEC_ID, SQL_PLAN_HASH_VALUE
ORDER BY MAX (SAMPLE_TIME) - MIN (SAMPLE_TIME) DESC;
--ORDER BY MIN (SAMPLE_TIME);
-- select plan from execution history
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'gr8m0ug8nbdn5',plan_hash_value=>4053659781,format=>'ALL'));
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'82ja5tjsrcz5y',plan_hash_value=>3052885806,format=>'+outline'));
--as in SQLT report (with bind variables)
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'3r93rsxgrsf49',plan_hash_value=>3803250840,format=>'ADVANCED ALLSTATS LAST REPORT ADAPTIVE +outline'));
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'7wyp2tu352jbv',format=>'ALL'));
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'gr8m0ug8nbdn5',format=>'+outline')); --after it select sql stmt with hint from Outline Data section from the output 
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'fxyh2jbc9wb5s',plan_hash_value=>2163610841,format=>'ALL'));
-- from sql plan baseline
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE(SQL_HANDLE => 'SQL_7ddbf799d693753b',PLAN_NAME=>'SQL_PLAN_7vqzrm7b96x9v4cb5a735',FORMAT => 'advanced'));
-- find plan with its bind variables
SELECT * FROM TABLE (DBMS_XPLAN.DISPLAY_CURSOR ('7wyp2tu352jbv',0, 'ADVANCED'));
SELECT * FROM TABLE (DBMS_XPLAN.DISPLAY_CURSOR ('f381qj6qv32q6',0, 'ADVANCED ALLSTATS LAST REPORT ADAPTIVE +PEEKED_BINDS'));
SELECT * FROM TABLE (DBMS_XPLAN.DISPLAY_CURSOR ('7wyp2tu352jbv',1, 'ADVANCED')); --child cursor 1
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(SQL_ID=>'68nx6kzv9cx6j',CURSOR_CHILD_NO=>0,format=>'ALLSTATS ALL'));
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('ak6m7xt756bv5', 1, format => '+note')); --for child cursor number 1, show note for plan
SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SESSION_ID = 2349;
SELECT * FROM DBA_HIST_SQLTEXT WHERE upper(SQL_TEXT) like '%select /*+ dynamic_sampling(0) */%';
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID = 'cv29ua5npgm14';
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SESSION_ID = 801 and SAMPLE_TIME BETWEEN to_date('25.01.2017 01:00:00','dd.mm.yyyy hh24:mi:ss') AND to_date('25.01.2017 02:01:00','dd.mm.yyyy hh24:mi:ss');
-- select (from SQLPLUS!) full information about the execution plan
spool c:\temp\sql_plan_full_bad.log
set timing on echo on linesize 250 pagesize 0
select  /*+ GATHER_PLAN_STATISTICS */ ...
SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR(FORMAT=>'ALLSTATS LAST ALL +OUTLINE'));
SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR(FORMAT=>'ALLSTATS LAST ALL +OUTLINE +PEEKED_BINDS'));
--another option (no change in query text is required):
alter session set statistics_level='ALL'; --same select, same DBMS_XPLAN select after that

--for more detailed plan:

alter session set statistics_level=all; 

-- ..sql query..

set trimspool on
set pagesize 130
set serveroutput off
SELECT * FROM TABLE(dbms_xplan.display_cursor(format=> 'ALL ADAPTIVE ALLSTATS ADVANCED LAST'));

spool off
exit

-- waits analyzing for dpump sessions

select * from v$session where sid in
(select vs.sid 
from   v$session vs, 
       v$process vp , 
       dba_datapump_sessions dp 
where  vp.addr = vs.paddr(+) and 
       vs.saddr = dp.saddr);
       
-- keep pool (keep_pool) usage size 

select segment_name, sum(bytes)
from dba_segments
where buffer_pool = 'KEEP'
group by segment_name
order by 2
;
	   
-- analyze wait_time by session/module/action for particular SQL_ID

  SELECT SUM (TIME_WAITED) / 1000000     SEC,
         SQL_ID,
         SQL_EXEC_ID,
         TRUNC (SAMPLE_TIME),
         min(SAMPLE_TIME),max(SAMPLE_TIME),
         MODULE,
         ACTION
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     SQL_ID IN ('6bwu1g1f9y0sw', '3w8s06wss9vt4')
         AND SAMPLE_TIME >= TRUNC (SYSDATE - 40)
GROUP BY SQL_ID,
         SQL_EXEC_ID,
         TRUNC (SAMPLE_TIME),
         MODULE,
         ACTION
         having sum(time_waited)/1000000>0
ORDER BY TRUNC (SAMPLE_TIME),min(SAMPLE_TIME);

-- waits for i/o IO from storage in the database:

  SELECT *
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     P3TEXT = 'block cnt'
         AND WAIT_CLASS = 'User I/O'
         AND SAMPLE_TIME BETWEEN TO_DATE ('11-03-2020 00:00:00',
                                          'dd-mm-yyyy hh24:mi:ss')
                             AND TO_DATE ('11-03-2020 06:00:00',
                                          'dd-mm-yyyy hh24:mi:ss')
ORDER BY TIME_WAITED DESC;

--grouping for trend analysis io i/o related issues slowness

  SELECT trunc(sample_time,'mi') hour,event,round(avg(time_waited/p3)) microsec_per_block,count(1)
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     P3TEXT = 'block cnt'
         AND WAIT_CLASS = 'User I/O'
         AND SAMPLE_TIME BETWEEN TO_DATE ('27-03-2020 04:00:00',
                                          'dd-mm-yyyy hh24:mi:ss')
                             AND TO_DATE ('27-03-2020 11:00:00',
                                          'dd-mm-yyyy hh24:mi:ss')
         --AND event not like '%write%'
         group by trunc(sample_time,'mi'),event
         having count(1) > 10
ORDER BY 3 desc;

     SELECT TRUNC (SAMPLE_TIME, 'mi')    MINUTE,
            EVENT,
            P3TEXT,
            P2TEXT,
            CASE
                WHEN P3TEXT IN ('blocks', 'block cnt')
                THEN
                    ROUND (AVG (TIME_WAITED / P3))
                ELSE
                    ROUND (AVG (TIME_WAITED / P2))
            END                          AVG_MICROSEC_PER_BLOCK,
            CASE
                WHEN P3TEXT IN ('blocks', 'block cnt')
                THEN
                    ROUND (MIN (TIME_WAITED / P3))
                ELSE
                    ROUND (AVG (TIME_WAITED / P2))
            END                          MIN_MICROSEC_PER_BLOCK,
            CASE
                WHEN P3TEXT IN ('blocks', 'block cnt')
                THEN
                    ROUND (MAX (TIME_WAITED / P3))
                ELSE
                    ROUND (AVG (TIME_WAITED / P2))
            END                          MAX_MICROSEC_PER_BLOCK,
            ROUND (
                  (CASE
                       WHEN P3TEXT IN ('blocks', 'block cnt')
                       THEN
                           ROUND (MAX (TIME_WAITED / P3))
                       ELSE
                           ROUND (AVG (TIME_WAITED / P2))
                   END)
                / (CASE
                       WHEN P3TEXT IN ('blocks', 'block cnt')
                       THEN
                           ROUND (MIN (TIME_WAITED / P3))
                       ELSE
                           ROUND (AVG (TIME_WAITED / P2))
                   END))                 TIMES_DIFF_MIN_MAX,
            COUNT (1)                    TOTAL_WAITS
       FROM DBA_HIST_ACTIVE_SESS_HISTORY
      WHERE     (P3TEXT IN ('block cnt', 'blocks') OR P2TEXT = 'blocks') --P3TEXT = 'block cnt'
            AND WAIT_CLASS = 'User I/O'
            AND SAMPLE_TIME BETWEEN TO_DATE ('27-03-2020 00:00:00',
                                             'dd-mm-yyyy hh24:mi:ss')
                                AND TO_DATE ('27-03-2020 11:00:00',
                                             'dd-mm-yyyy hh24:mi:ss')
   --AND EVENT NOT LIKE '%write%'
   GROUP BY TRUNC (SAMPLE_TIME, 'mi'),
            EVENT,
            P3TEXT,
            P2TEXT
     HAVING     COUNT (1) > 10
            AND CASE
                    WHEN P3TEXT IN ('blocks', 'block cnt')
                    THEN
                        ROUND (MIN (TIME_WAITED / P3))
                    ELSE
                        ROUND (AVG (TIME_WAITED / P2))
                END >
                0
   ORDER BY 8 DESC
FETCH FIRST 50 ROWS ONLY;

--check comparison results:

select sample_time,event,p2text,p2,p3text,p3,session_state,time_waited wait_microseconds FROM DBA_HIST_ACTIVE_SESS_HISTORY
      WHERE     WAIT_CLASS = 'User I/O' and (P3TEXT IN ('block cnt', 'blocks') OR P2TEXT = 'blocks')
            AND (SAMPLE_TIME BETWEEN TO_DATE ('10-04-2020 05:07:00',
                                          'dd-mm-yyyy hh24:mi:ss')
                             AND TO_DATE ('10-04-2020 05:08:00',
                                          'dd-mm-yyyy hh24:mi:ss') or SAMPLE_TIME BETWEEN TO_DATE ('11-04-2020 01:38:00',
                                          'dd-mm-yyyy hh24:mi:ss')
                             AND TO_DATE ('11-04-2020 01:39:00',
                                          'dd-mm-yyyy hh24:mi:ss')) order by SAMPLE_TIME;

--comparison analysis for particular SQLID:

SELECT event,count(1),sum(time_waited),max(time_waited/p2) max_mcs_per_block,min(time_waited/p2) min_mcs_per_block, min(sample_time),max(time_waited/p2)/min(time_waited/p2) times_diff_min_max,max(sample_time) from DBA_HIST_ACTIVE_SESS_HISTORY where sql_id = '3pk1t83zabb20' and 
sample_time BETWEEN TO_DATE('23032020 05:00:00',
                                          'ddmmyyyy hh24:mi:ss')
                             AND TO_DATE ('23032020 06:00:00',
                                          'ddmmyyyy hh24:mi:ss')
and (P3text in ('block cnt' ,'blocks') or P2text ='blocks') and time_waited > 0 group by event
union all
SELECT event,count(1),sum(time_waited),max(time_waited/p2) max_mcs_per_block,min(time_waited/p2) min_mcs_per_block, min(sample_time),max(time_waited/p2)/min(time_waited/p2) times_diff_min_max,max(sample_time) from DBA_HIST_ACTIVE_SESS_HISTORY where sql_id = '3pk1t83zabb20' and 
sample_time BETWEEN TO_DATE ('24032020 05:00:00',
                                          'ddmmyyyy hh24:mi:ss')
                             AND TO_DATE ('24032020 06:00:00',
                                          'ddmmyyyy hh24:mi:ss')
and (P3text in ('block cnt' ,'blocks') or P2text ='blocks') and time_waited > 0 group by event
 order by 6 ;
 
 --data amount read/write comparison
 
  SELECT SQL_ID,ROUND (SUM (DELTA_READ_IO_BYTES) / 1024 / 1024 / 1024)      READ_GB,
         ROUND (SUM (DELTA_WRITE_IO_BYTES) / 1024 / 1024 / 1024)     WRITE_GB,
         MIN (SAMPLE_TIME),
         MAX (SAMPLE_TIME),
         MAX (SAMPLE_TIME)-MIN (SAMPLE_TIME) EXEC_TIME,
         SQL_EXEC_ID
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     SQL_ID IN ('3pk1t83zabb20', '13z41gv6fkdw8')
         AND SAMPLE_TIME BETWEEN TO_DATE ('23032020 05:00:00',
                                          'ddmmyyyy hh24:mi:ss')
                             AND TO_DATE ('23032020 06:00:00',
                                          'ddmmyyyy hh24:mi:ss')
GROUP BY SQL_ID, SQL_EXEC_ID;

--by plan line comparison

  SELECT SQL_PLAN_LINE_ID,
         SQL_PLAN_LINE_ID,
         SQL_PLAN_OPTIONS,
         CURRENT_OBJ#,
         OWNER,
         OBJECT_NAME,
         SUBOBJECT_NAME,
         COUNT (1),
         ROUND (SUM (DELTA_READ_IO_BYTES) / 1024 / 1024)      READ_MB,
         ROUND (SUM (DELTA_WRITE_IO_BYTES) / 1024 / 1024)     WRITE_MB
    FROM DBA_HIST_ACTIVE_SESS_HISTORY, DBA_OBJECTS
   WHERE     DBA_HIST_ACTIVE_SESS_HISTORY.CURRENT_OBJ# = DBA_OBJECTS.OBJECT_ID
         AND SQL_ID = '3pk1t83zabb20'
         AND SAMPLE_TIME BETWEEN TO_DATE ('23032020 05:00:00',
                                          'ddmmyyyy hh24:mi:ss')
                             AND TO_DATE ('23032020 06:00:00',
                                          'ddmmyyyy hh24:mi:ss')
GROUP BY SQL_ID,
         SQL_PLAN_LINE_ID,
         SQL_PLAN_LINE_ID,
         SQL_PLAN_OPTIONS,
         CURRENT_OBJ#,
         OWNER,
         OBJECT_NAME,
         SUBOBJECT_NAME
ORDER BY COUNT (1) DESC;

-- get predicates with outline for query

--see plan with outline
select * from table(dbms_xplan.display_awr('2karxscbac5m7',format=>'+outline'));
--get outline from the below query, build its plan
select * from dba_hist_sqltext s where s.SQL_ID = '2karxscbac5m7';

-- objects in the buffer cache (Doc ID 180850.1)

select * from V$BH where OBJD in (select OBJECT_ID from dba_objects where object_name in ('OTC_INITIAL_MARGIN_BASE','VW_CONTRACT_OTC_BASE','SEL_LOG') and OWNER <> 'NAVIA');
select * from V$BH where OBJD in (select OBJECT_ID from dba_objects where object_name in ('V_$ENTERPRISE') and OWNER = 'MOSCOW_EXCHANGE');

-- all enabled traces in DB

SELECT * FROM DBA_ENABLED_TRACES;

-- SQL monitor report for SQL_ID in cursor cache

select DBMS_SQL_MONITOR.REPORT_SQL_MONITOR('3v33qj4rapzc0',type=>'HTML',sql_exec_start=>to_date('15.01.2018 12:00:07','dd.mm.yyyy hh24:mi:ss')) from dual;\
select DBMS_SQL_MONITOR.REPORT_SQL_MONITOR('2jykh7kw9c5tr',type=>'TEXT',sql_exec_id=>16777218) from dual; --from ASH
select DBMS_SQL_MONITOR.REPORT_SQL_MONITOR('1yv5b06tm696p',type=>'HTML',sql_exec_id=>16777216,report_level=>'all+plan_histogram+sql_fulltext',sql_plan_hash_value=>3539086373) from dual;
select DBMS_SQL_MONITOR.REPORT_SQL_MONITOR('4pcku9ns71v0n',type=>'HTML') from dual;
select DBMS_SQL_MONITOR.REPORT_SQL_MONITOR('gp5tuv2v1j9s4',type=>'TEXT',sql_exec_start=>to_date('13.04.2018 13:00:00','dd.mm.yyyy hh24:mi:ss')) from dual;
select DBMS_SQL_MONITOR.REPORT_SQL_MONITOR('f381qj6qv32q6',type=>'TEXT') from dual;

--active HTML report using the command line (same as in OEM)

select DBMS_SQL_MONITOR.REPORT_SQL_MONITOR('an05rsj1up1k5',report_level =>'all',type=>'ACTIVE') report from dual;
select DBMS_SQL_MONITOR.REPORT_SQL_MONITOR('0x6zwpwyr7nfx',sql_exec_id=>32156742,report_level =>'all',type=>'ACTIVE') report from dual; 
--if NOT avaialble we can force query monitoring
select /*+ MONITOR */ ... --monitor report will be avaialble post that

-- take monitor report with particular query

SHOW PARAMETER statistics_level

--have to be typical or all

--execute query like this

SELECT /*+ MONITOR */

--then generate the report (OEM style)

SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET LINESIZE 1000
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF

SPOOL /host/report_sql_monitor.htm
SELECT DBMS_SQLTUNE.report_sql_monitor(sql_id=> '526mvccm5nfy4',type=> 'HTML',report_level => 'ALL') AS report FROM dual;
SPOOL OFF
exit

SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET LINESIZE 1000
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF

SPOOL /host/report_sql_detail.htm
SELECT DBMS_SQLTUNE.report_sql_detail(sql_id=> '526mvccm5nfy4',-- type         => 'ACTIVE',
report_level => 'ALL') AS report FROM dual;
SPOOL OFF

-- active report for particular execution (OEM style)

SELECT DBMS_SQLTUNE.report_sql_monitor(
  sql_id       => '0x6zwpwyr7nfx',
  session_id   => 683,
  session_serial => 25218,
--  sql_exec_id  =>         ,
  type         => 'ACTIVE',
  report_level => 'ALL') AS report
FROM dual;

-- Creating AWR baselines

Select DBMS_WORKLOAD_REPOSITORY.create_baseline(start_snap_id=>123, end_snap_id=>124, baseline_name=>'name_for_baseline', expiration=>in number of days or NULL for non expired) as bline_id from dual;

--This function returns baseline_id for the baseline just created
--To check created baseline select:

SELECT baseline_id, baseline_name, START_SNAP_ID, 
       TO_CHAR(start_snap_time, 'DD-MON-YYYY HH24:MI') AS start_snap_time,       
       END_SNAP_ID,            
       TO_CHAR(end_snap_time, 'DD-MON-YYYY HH24:MI') AS end_snap_time
FROM   dba_hist_baseline
WHERE  baseline_type = 'STATIC'
ORDER BY baseline_id;

--To drop baseline along with its snapshots execute:

EXEC dbms_workload_repository.drop_baseline(baseline_name=>'name_for_baseline', cascade=>true);

--Only baseline, keep snapshots:

EXEC dbms_workload_repository.drop_baseline(baseline_name=>'name_for_baseline', cascade=>false);

-- change thresholds for AWR reports (add more SQL, files, etc in a report):
--Settings are effective only in the context of the session that executes the AWR_SET_REPORT_THRESHOLDS procedure

PROCEDURE awr_set_report_thresholds

exec dbms_workload_repository.awr_set_report_thresholds(top_n_sql=>100); --then run report in the same session

-- AWR snapshot capture parameters 

EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(INTERVAL=>10,TOPNSQL=>200); --TOPNSQL - Modify top SQL statements for AWR
SELECT * FROM V$PARAMETER WHERE NAME = 'statistics_level';
SELECT * FROM DBA_HIST_WR_CONTROL; --TOPNSQL = 30 for statistics_level = TYPICAL and 100 for ALL

-- ADD colored SQL (this will be gathered whether it is in TOP SQL or not) 

EXEC DBMS_WORKLOAD_REPOSITORY.ADD_COLORED_SQL(SQL_ID=>'9575wxsvqhzy4');
EXEC DBMS_WORKLOAD_REPOSITORY.REMOVE_COLORED_SQL(SQL_ID=>'9575wxsvqhzy4'); --for remove


-- AWR global report (RAC)

select output from table(DBMS_WORKLOAD_REPOSITORY.awr_global_report_html(
l_dbid=>(select dbid from v$database),
l_inst_num=>(select INSTANCE_NUMBER from v$instance), --NULL --if required ALL RAC instances
l_bid=>(select min(snap_id) from (
select snap_id,instance_number,begin_interval_time,end_interval_time from dba_hist_snapshot 
where INSTANCE_NUMBER = (select INSTANCE_NUMBER from v$instance)
and begin_interval_time between 
to_date('15/11/2018 00:50:00','dd/mm/yyyy hh24:mi:ss') and to_date('15/11/2018 01:30:00','dd/mm/yyyy hh24:mi:ss')
order by BEGIN_INTERVAL_TIME)),
l_eid=>(select max(snap_id) from (
select snap_id,instance_number,begin_interval_time,end_interval_time from dba_hist_snapshot 
where INSTANCE_NUMBER = (select INSTANCE_NUMBER from v$instance)
and begin_interval_time between 
to_date('15/11/2018 00:50:00','dd/mm/yyyy hh24:mi:ss') and to_date('15/11/2018 01:30:00','dd/mm/yyyy hh24:mi:ss')
order by BEGIN_INTERVAL_TIME))));

-- normal AWR report (from ONE instance) - substract 10 minutes from time borders

-- set 200 in TOP SQL

exec dbms_workload_repository.awr_set_report_thresholds(top_n_sql=>200);

SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET LINESIZE 1000
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF

SPOOL "W:\Dba_docs\DB Tasks\XLSDB\Issues\INFRA-1613\AWR\AWR Rpt xlsdb 02032021_10-30_15.html"

SELECT OUTPUT
  FROM TABLE (DBMS_WORKLOAD_REPOSITORY.AWR_REPORT_HTML (
                  L_DBID       => (SELECT DBID FROM V$DATABASE),
                  L_INST_NUM   => (SELECT INSTANCE_NUMBER FROM V$INSTANCE), --NULL --if required ALL RAC instances
                  L_BID        =>
                      (SELECT MIN (SNAP_ID)
                         FROM (  SELECT SNAP_ID,
                                        INSTANCE_NUMBER,
                                        BEGIN_INTERVAL_TIME,
                                        END_INTERVAL_TIME
                                   FROM DBA_HIST_SNAPSHOT
                                  WHERE     INSTANCE_NUMBER =
                                            (SELECT INSTANCE_NUMBER
                                               FROM V$INSTANCE)
                                        AND BEGIN_INTERVAL_TIME BETWEEN   TO_DATE (
                                                                              '19/10/2019 23:00:00',
                                                                              'dd/mm/yyyy hh24:mi:ss')
                                                                        - INTERVAL '15' MINUTE
                                                                    AND   TO_DATE (
                                                                              '19/10/2019 23:30:00',
                                                                              'dd/mm/yyyy hh24:mi:ss')
                                                                        - INTERVAL '10' MINUTE
                               ORDER BY BEGIN_INTERVAL_TIME)),
                  L_EID        =>
                      (SELECT MAX (SNAP_ID)
                         FROM (  SELECT SNAP_ID,
                                        INSTANCE_NUMBER,
                                        BEGIN_INTERVAL_TIME,
                                        END_INTERVAL_TIME
                                   FROM DBA_HIST_SNAPSHOT
                                  WHERE     INSTANCE_NUMBER =
                                            (SELECT INSTANCE_NUMBER
                                               FROM V$INSTANCE)
                                        AND BEGIN_INTERVAL_TIME BETWEEN   TO_DATE (
                                                                              '19/10/2019 23:00:00',
                                                                              'dd/mm/yyyy hh24:mi:ss')
                                                                        - INTERVAL '15' MINUTE
                                                                    AND   TO_DATE (
                                                                              '19/10/2019 23:30:00',
                                                                              'dd/mm/yyyy hh24:mi:ss')
                                                                        - INTERVAL '10' MINUTE
                               ORDER BY BEGIN_INTERVAL_TIME))));
							   
-- AWR SQL report (for particular SQL_ID)

select * from table
(dbms_workload_repository.awr_sql_report_text((select dbid from v$database), (select INSTANCE_NUMBER from v$instance), (select min(snap_id) from (
select snap_id,instance_number,begin_interval_time,end_interval_time from dba_hist_snapshot 
where INSTANCE_NUMBER = (select INSTANCE_NUMBER from v$instance)
and begin_interval_time between 
to_date('27/12/2018 08:30:00','dd/mm/yyyy hh24:mi:ss') and to_date('27/12/2018 08:50:00','dd/mm/yyyy hh24:mi:ss')
order by BEGIN_INTERVAL_TIME)), (select max(snap_id) from (
select snap_id,instance_number,begin_interval_time,end_interval_time from dba_hist_snapshot 
where INSTANCE_NUMBER = (select INSTANCE_NUMBER from v$instance)
and begin_interval_time between 
to_date('27/12/2018 08:30:00','dd/mm/yyyy hh24:mi:ss') and to_date('27/12/2018 08:50:00','dd/mm/yyyy hh24:mi:ss')
order by BEGIN_INTERVAL_TIME)), '&v_sql_id'));

-- ASH report from AWR for module (col MODULE in v$session) 

set linesize 8000 termout on feedback off heading off echo off veri off trimspool on trimout on  

SPOOL c:\temp\awr_GWDBUpdTradesOracledgw_18.12.html

/*
SELECT 
   output 
FROM TABLE( DBMS_WORKLOAD_REPOSITORY.ASH_GLOBAL_REPORT_HTML (
           496990843,
           1,
           TO_DATE ('06.12.2017 16:30:00', 'dd.mm.yyyy hh24:mi:ss'),
           TO_DATE ('06.12.2017 20:30:00', 'dd.mm.yyyy hh24:mi:ss'),
           L_MODULE   => 'GWDBUpdTradesOracle.spur_exadata%')
           );
  
SPOOL OFF
exit
*/

SELECT 
   output 
FROM TABLE( DBMS_WORKLOAD_REPOSITORY.ASH_REPORT_HTML (
           l_dbid=>496990843,
           l_inst_num=>1,
           l_sql_id => 'fu7p0q9y9wsgw',
           l_btime=>TO_DATE ('18.12.2017 00:00:00', 'dd.mm.yyyy hh24:mi:ss'),
           l_etime=>TO_DATE ('18.12.2017 17:00:00', 'dd.mm.yyyy hh24:mi:ss'))
           );
  
SPOOL OFF
exit



set linesize 8000 termout on feedback off heading off echo off veri off trimspool on trimout on  

SPOOL c:\temp\awr_trades_16082018_1230-1330.html

SELECT 
   output 
FROM TABLE( DBMS_WORKLOAD_REPOSITORY.ASH_GLOBAL_REPORT_HTML (
           (select dbid from v$database),
           (select instance_number from v$instance)
           ,TO_DATE ('11.04.2019 10:32:00', 'dd.mm.yyyy hh24:mi:ss')
           ,TO_DATE ('11.04.2019 12:13:00', 'dd.mm.yyyy hh24:mi:ss')
           --,L_MODULE   => 'GWDBUpdTradesOracle.spur_exadata%'
           ,L_SID => 505
           ));
  
SPOOL OFF
exit

SELECT 
   output 
FROM TABLE( DBMS_WORKLOAD_REPOSITORY.ASH_GLOBAL_REPORT_HTML (
           (select dbid from v$database),
           (select INSTANCE_NUMBER from v$instance)
           ,TO_DATE ('29.01.2019 22:00:00', 'dd.mm.yyyy hh24:mi:ss')
           ,TO_DATE ('30.01.2019 16:40:00', 'dd.mm.yyyy hh24:mi:ss')
           --,L_MODULE   => 'GWDBUpdTradesOracle.spur_exadata%'
           ,L_SID => 398,
		   l_slot_width=>300 -- period to break for in seconds
           ));
  
SPOOL OFF
exit

--GWDBUpdTradesOracle.spur_exadata% - EQ (SPUR_DAY)
--GWDBUpdTradesOracle@dgw1% - CU (SPUR_DAY_CU)

set linesize 8000 termout on feedback off heading off echo off veri off trimspool on trimout on  

--SPOOL c:\temp\awr_GWDBUpdTradesOracle.log
SPOOL c:\temp\awr_GWDBUpdTradesOracle.html

SELECT 
   output 
--FROM TABLE( DBMS_WORKLOAD_REPOSITORY.ASH_GLOBAL_REPORT_TEXT (
FROM TABLE( DBMS_WORKLOAD_REPOSITORY.ASH_GLOBAL_REPORT_HTML (
           496990843,
           1,
           TO_DATE ('27.07.2018 10:00:00', 'dd.mm.yyyy hh24:mi:ss'),--SYSDATE-1/24/2,
           TO_DATE ('27.07.2018 20:00:00', 'dd.mm.yyyy hh24:mi:ss'),--SYSDATE,
           L_MODULE   => 'GWDBUpdTradesOracle@dgw1%'));
  
  SPOOL OFF
exit

-- ASH report

select DBMS_WORKLOAD_REPOSITORY.ash_report_html(
l_dbid=>,
l_inst_num=>1,
l_btime=>TO_DATE ('17.10.2018 04:06:00', 'dd.mm.yyyy hh24:mi:ss'),
l_etime=>TO_DATE ('17.10.2018 05:25:00', 'dd.mm.yyyy hh24:mi:ss'),
l_slot_width=>60) as ash_rep from dual;

select output from table (DBMS_WORKLOAD_REPOSITORY.ash_report_html(
l_dbid=>(select dbid from v$database),
l_inst_num=>(select INSTANCE_NUMBER from v$instance),
l_btime=>TO_DATE ('19.11.2018 10:06:00', 'dd.mm.yyyy hh24:mi:ss'),
l_etime=>TO_DATE ('19.11.2018 10:12:00', 'dd.mm.yyyy hh24:mi:ss'),
l_slot_width=>10));

-- AWR report from sqlplus 

set linesize 8000 termout on feedback off heading off echo off veri off trimspool on trimout on  

SPOOL w:\trace\new4.html

SELECT OUTPUT
  FROM TABLE (DBMS_WORKLOAD_REPOSITORY.AWR_REPORT_HTML (
                  L_DBID       => (SELECT DBID FROM V$DATABASE),
                  L_INST_NUM   => (SELECT INSTANCE_NUMBER FROM V$INSTANCE), --NULL --if required ALL RAC instances
                  L_BID        =>373588,
                  L_EID        =>373589));
                  
spool off 
exit

--compare periods AWR report

select dbid from v$database;
select INSTANCE_NUMBER from v$instance;
select * from dba_hist_snapshot order by BEGIN_INTERVAL_TIME desc;

set linesize 8000 termout on feedback off heading off echo off veri off trimspool on trimout on  

SPOOL c:\temp\awr_periods_compare.html

SELECT OUTPUT
  FROM TABLE (DBMS_WORKLOAD_REPOSITORY.AWR_DIFF_REPORT_HTML (
                  DBID1       => 3923129717,
                  INST_NUM1   => 1,
                  BID1        => 4822,
                  EID1        => 4823,
                  DBID2       => 3923129717,
                  INST_NUM2   => 1,
                  BID2        => 4845,
                  EID2        => 4846));
				  
spool off
exit

SELECT OUTPUT
  FROM TABLE (DBMS_WORKLOAD_REPOSITORY.AWR_DIFF_REPORT_HTML (
                  DBID1       => (select dbid from v$database),
                  INST_NUM1   => (select INSTANCE_NUMBER from v$instance),
                  BID1        => (select min(snap_id)-1 from (
select snap_id,instance_number,begin_interval_time,end_interval_time from dba_hist_snapshot 
where INSTANCE_NUMBER = (select INSTANCE_NUMBER from v$instance)
and begin_interval_time between 
to_date('09/12/2018 01:00:00','dd/mm/yyyy hh24:mi:ss') and to_date('09/12/2018 01:50:00','dd/mm/yyyy hh24:mi:ss')
order by BEGIN_INTERVAL_TIME)),
                  EID1        => (select max(snap_id) from (
select snap_id,instance_number,begin_interval_time,end_interval_time from dba_hist_snapshot 
where INSTANCE_NUMBER = (select INSTANCE_NUMBER from v$instance)
and begin_interval_time between 
to_date('09/12/2018 01:00:00','dd/mm/yyyy hh24:mi:ss') and to_date('09/12/2018 01:50:00','dd/mm/yyyy hh24:mi:ss')
order by BEGIN_INTERVAL_TIME)),
                  DBID2       => (select dbid from v$database),
                  INST_NUM2   => (select INSTANCE_NUMBER from v$instance),
                  BID2        => (select min(snap_id)-1 from (
select snap_id,instance_number,begin_interval_time,end_interval_time from dba_hist_snapshot 
where INSTANCE_NUMBER = (select INSTANCE_NUMBER from v$instance)
and begin_interval_time between 
to_date('09/01/2019 01:00:00','dd/mm/yyyy hh24:mi:ss') and to_date('09/01/2019 01:40:00','dd/mm/yyyy hh24:mi:ss')
order by BEGIN_INTERVAL_TIME)),
                  EID2  =>  (select max(snap_id) from (
select snap_id,instance_number,begin_interval_time,end_interval_time from dba_hist_snapshot 
where INSTANCE_NUMBER = (select INSTANCE_NUMBER from v$instance)
and begin_interval_time between 
to_date('09/01/2019 01:00:00','dd/mm/yyyy hh24:mi:ss') and to_date('09/01/2019 01:40:00','dd/mm/yyyy hh24:mi:ss')
order by BEGIN_INTERVAL_TIME))));
                  

-- offloadable functions

select * from V$SQLFN_METADATA where OFFLOADABLE = 'YES';

-- CREATE/DROP EXTENDED STATS

select DBMS_STATS.CREATE_EXTENDED_STATS('PROT','BEE_STAT_TRANSFER','(TO_NUMBER (TO_CHAR (call_time, ''HH24'')))') from dual;
exec DBMS_STATS.drop_extended_stats('PROT','BEE_STAT_TRANSFER','(LOWER(CONNECTION_STATUS))');

SELECT * FROM dba_stat_extensions WHERE  table_name = 'BEE_STAT_TRANSFER';

-- GATHER HISTOGRAMS FOR PARTICULAR COLUMN

exec DBMS_STATS.GATHER_TABLE_STATS('OWS','UT_TEST_MSG',method_opt=>'FOR COLUMNS ID SIZE AUTO');
exec DBMS_STATS.GATHER_TABLE_STATS('OWS','DOC',method_opt=>'FOR COLUMNS AMND_STATE SIZE AUTO',degree=>8); -- in parallel

select * from dba_tab_col_statistics where TABLE_NAME = 'DOC' order by 1,2,3;
select * from dba_tab_histograms where TABLE_NAME = 'DOC' and column_name = 'AMND_STATE' order by 1,2,3;

BEGIN  DBMS_STATS.GATHER_TABLE_STATS ( 
    ownname          => 'OWS'
,   tabname          => 'DOC'
,   method_opt       => 'FOR COLUMNS TARGET_FEE_CODE TARGET_SERVICE SEC_TRANS_COND_ATT SIZE 1'
,   estimate_percent => 10 
);
END;

--gather Height Balanced histograms:

https://docs.oracle.com/database/121/TGSQL/tgsql_histo.htm#TGSQL383
https://docs.oracle.com/database/121/TGSQL/tgsql_histo.htm#TGSQL380

RECONS_AMOUNT
SOURCE_FEE_AMOUNT

BEGIN  DBMS_STATS.GATHER_TABLE_STATS ( 
    ownname          => 'OWS'
,   tabname          => 'DOC'
,   method_opt       => 'FOR COLUMNS RECONS_AMOUNT SOURCE_FEE_AMOUNT SIZE 254'
,   estimate_percent => 10 
);
END;

--gather frequency histogramm (default est %):

DBMS_STATS.GATHER_table_STATS ('OWS', 'DOC',METHOD_OPT => 'FOR COLUMNS OUTWARD_STATUS SIZE 14');

--check after/befor gathering

select distinct owner,table_name,column_name from dba_tab_histograms where TABLE_NAME = 'UT_TEST_MSG' order by 1,2,3; 
select * from dba_tab_histograms where TABLE_NAME = 'UT_TEST_MSG' and column_name = 'ID' order by 1,2,3;
select * from dba_tab_histograms where TABLE_NAME = 'UT_TEST_MSG' order by 1,2,3;

-- gather dictionary statistics (see Doc ID 2046826.1)

exec dbms_stats.gather_dictionary_stats;

--find the difference between statistics for the table over time (stats history must be enabled, default is 31 days)

SELECT dbms_stats.get_stats_history_availability FROM dual;
SELECT dbms_stats.get_stats_history_retention FROM dual;
--if available can be compared (clob output as report)
select  * from table(dbms_stats.diff_table_stats_in_history('OWS','DOC',systimestamp-2,systimestamp));

-- see column usage for the particular table:

select dbms_stats.report_col_usage('OWS', 'ACNT_CONTRACT') from dual; --or use SYS.COL_USAGE$ table
--(do before in order to flust all data into dictionary)
execute dbms_stats.flush_database_monitoring_info();

--change retention period for the stats

exec dbms_stats.alter_stats_history_retention(31); --The default is 31 days

-- bind variables for sql cursor cache

SELECT distinct SQL_TEXT,
       NAME,
       VALUE_STRING,
       DATATYPE_STRING
  FROM V$SQL_BIND_CAPTURE JOIN V$SQL USING (HASH_VALUE)
 WHERE V$SQL.SQL_ID = 'g69svm2vvquky' ORDER BY NAME,DATATYPE_STRING,VALUE_STRING;
 
-- bind variables for sql AWR
 
  SELECT B.*, T.SQL_TEXT
    FROM DBA_HIST_SQLBIND B, DBA_HIST_SQLTEXT T
   WHERE B.SQL_ID = 'g69svm2vvquky' AND B.SQL_ID = T.SQL_ID
   
-- convert BIND_DATA into string from V$SQL:

COL SQL_ID FOR A14;
COL SQL_TEXT FOR A32;
COL HASH_VALUE FOR 99999999999;
COL BIND_DATA FOR A32;
SELECT SQL_ID          
      ,SQL_TEXT
      ,LITERAL_HASH_VALUE
      ,HASH_VALUE
      ,DBMS_SQLTUNE.EXTRACT_BINDS(BIND_DATA) BIND_DATA
FROM V$SQL
WHERE SQL_ID = 'apk1h9qxx4zbr';
   
   
ORDER BY LAST_CAPTURED DESC;

-- RUN SQL tuning advisor for the given SQL_ID (cursor cache)

DECLARE
   L_SQL                VARCHAR2 (32000);
   L_SQL_TUNE_TASK_ID   VARCHAR2 (32000);
BEGIN
   L_SQL :='c489dgw4da8qq';

   L_SQL_TUNE_TASK_ID :=
      DBMS_SQLTUNE.CREATE_TUNING_TASK (
         SQL_ID      => L_SQL,
--		 plan_hash_value => 167909903,
         --SCOPE => 'LIMITED',--SCOPE_COMPREHENSIVE --default
         TIME_LIMIT    => 2400,
         TASK_NAME     => 'sqltune2_'||L_SQL);
   DBMS_OUTPUT.PUT_LINE ('l_sql_tune_task_id: ' || L_SQL_TUNE_TASK_ID);
   DBMS_SQLTUNE.execute_tuning_task(task_name => 'sqltune2_'||L_SQL);
END;
/
SELECT * FROM DBA_ADVISOR_LOG where EXECUTION_START > sysdate - 1/24 order by EXECUTION_START desc;
SELECT TASK_NAME FROM DBA_ADVISOR_LOG where EXECUTION_START > sysdate - 1/24 order by EXECUTION_START desc;
SELECT DBMS_SQLTUNE.report_tuning_task('sqltune2_c489dgw4da8qq') AS recommendations FROM dual;

-- RUN SQL tuning advisor for the given SQL_ID (AWR)

DECLARE
   L_SQL                VARCHAR2 (32000) DEFAULT 'gtfua5c96c307';
   L_SQL_TUNE_TASK_ID   VARCHAR2 (32000);
BEGIN
   L_SQL_TUNE_TASK_ID :=
      DBMS_SQLTUNE.CREATE_TUNING_TASK (
         SQL_ID      => L_SQL,
         begin_snap => 291609,
         end_snap => 291624,
         plan_hash_value => 2576595377,
         --SCOPE => 'LIMITED',--SCOPE_COMPREHENSIVE --default
         TIME_LIMIT    => 14400,
         TASK_NAME     => 'sqltune2_'||L_SQL);
   DBMS_OUTPUT.PUT_LINE ('l_sql_tune_task_id: ' || L_SQL_TUNE_TASK_ID);
   DBMS_SQLTUNE.execute_tuning_task(task_name => 'sqltune2_'||L_SQL);
END;
/

nohup echo '@sql_tuning_single_sqlid_AWR;' | sqlplus -S / as sysdba & 2>&1 &

SELECT DBMS_SQLTUNE.report_tuning_task(owner_name=>'SYS',task_name=>'sqltune2_gtfua5c96c307') AS recommendations FROM dual;


-- RUN SQL tuning advisor for the given SQL text with BIND variables

DECLARE
   L_SQL                VARCHAR2 (32000);
   L_SQL_TUNE_TASK_ID   VARCHAR2 (32000);
   V_SQLTEXT CLOB DEFAULT 'put text of SQL here';
   V_APP_SCHEMA VARCHAR2 (20) DEFAULT 'DWH';
BEGIN
   L_SQL_TUNE_TASK_ID :=
      DBMS_SQLTUNE.CREATE_TUNING_TASK (
         SQL_ID      => V_SQLTEXT,
         bind_list => sql_binds(anydata.ConvertNumber(91),anydata.ConvertVarchar2('Test')),
		 USER_NAME => V_APP_SCHEMA,
         --SCOPE => 'LIMITED',--SCOPE_COMPREHENSIVE --default
         TIME_LIMIT    => 7200,
         TASK_NAME     => 'sqltune2_'||L_SQL);
   DBMS_OUTPUT.PUT_LINE ('l_sql_tune_task_id: ' || L_SQL_TUNE_TASK_ID);
   DBMS_SQLTUNE.execute_tuning_task(task_name => 'sqltune2_'||L_SQL);
END;
/

--script for execute SQL with execution statistics

select /*+ gather_plan_statistics */ ... ;

REM Displays plan for most recently executed SQL. Just execute "@plan.sql" from sqlplus.
SET PAGES 2000 LIN 180;
SPO plan.txt;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL,TO_NUMBER(NULL),'ADVANCED RUNSTATS_LAST'));
SPO OFF;

-- SQL plan management and consistency (automatic capture/evolve of SQL plan baselines)
-- Master Note: Plan Stability Features (Including SQL Plan Management (SPM)) (Doc ID 1359841.1)
-- SQL Management Base will be in the SYSAUX tablespace (!), Managing the SQL Management Base

SELECT PARAMETER_NAME, PARAMETER_VALUE AS "%_LIMIT",
( SELECT sum(bytes/1024/1024) FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME = 'SYSAUX' ) AS SYSAUX_SIZE_IN_MB,
PARAMETER_VALUE/100 *
( SELECT sum(bytes/1024/1024) FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME = 'SYSAUX' ) AS "CURRENT_LIMIT_IN_MB"
FROM DBA_SQL_MANAGEMENT_CONFIG
WHERE PARAMETER_NAME = 'SPACE_BUDGET_PERCENT';

SELECT PARAMETER_NAME, PARAMETER_VALUE FROM DBA_SQL_MANAGEMENT_CONFIG WHERE PARAMETER_NAME = 'PLAN_RETENTION_WEEKS';

exec exec DBMS_SPM.CONFIGURE('PLAN_RETENTION_WEEKS',32); --configure plan retention weeks (default 53)
exec exec DBMS_SPM.CONFIGURE('SPACE_BUDGET_PERCENT',25); --configure space % inside SYSAUX TS (default 10)


-- init parameters related to that functionality
select NAME,VALUE,ISDEFAULT,ISSES_MODIFIABLE,ISSYS_MODIFIABLE,ISINSTANCE_MODIFIABLE,DESCRIPTION from v$parameter where NAME like '%sql_plan_baselines';

SPM is controlled by the use of the following parameters:

Document 567104.1 Init.ora Parameter "OPTIMIZER_CAPTURE_SQL_PLAN_BASELINES" Reference Note
Document 567107.1 Init.ora Parameter "OPTIMIZER_USE_SQL_PLAN_BASELINES" Reference Note

-- change parameter:
alter system set optimizer_capture_sql_plan_baselines = TRUE COMMENT='changed from FALSE 25.01.2019' scope = BOTH sid = '*';

select * from DBA_AUTOTASK_CLIENT; --statistical data for each automated maintenance task over 7-day and 30-day periods
select * from DBA_AUTOTASK_JOB_HISTORY; --list of those jobs run history
select * from DBA_AUTOTASK_CLIENT_HISTORY; --history of jobs runs for the windows
select * from DBA_AUTOTASK_CLIENT_JOB; --currently running Scheduler jobs created for automated maintenance tasks
select * from DBA_AUTOTASK_WINDOW_CLIENTS; --Lists the windows that belong to particular window

-- FOR DISABLE ALL auto task for all windows execute:

exec dbms_auto_task_admin.disable();

--disable all windows for MAINTENANCE

exec DBMS_SCHEDULER.DISABLE(name=>'"SYS"."MAINTENANCE_WINDOW_GROUP"',force=>TRUE);

-- enable Automatic SQL Tuning for all windows

BEGIN
dbms_auto_task_admin.enable(client_name => 'sql tuning advisor', operation => NULL, window_name => NULL);
dbms_auto_task_admin.enable(client_name => 'sql tuning advisor', operation => NULL, window_name => 'TUESDAY_WINDOW');
dbms_auto_task_admin.enable(client_name => 'sql tuning advisor', operation => NULL, window_name => 'WEDNESDAY_WINDOW');
dbms_auto_task_admin.enable(client_name => 'sql tuning advisor', operation => NULL, window_name => 'THURSDAY_WINDOW');
dbms_auto_task_admin.enable(client_name => 'sql tuning advisor', operation => NULL, window_name => 'FRIDAY_WINDOW');
dbms_auto_task_admin.enable(client_name => 'sql tuning advisor', operation => NULL, window_name => 'SATURDAY_WINDOW');
dbms_auto_task_admin.enable(client_name => 'sql tuning advisor', operation => NULL, window_name => 'SUNDAY_WINDOW');
dbms_auto_task_admin.enable(client_name => 'sql tuning advisor', operation => NULL, window_name => 'MONDAY_WINDOW');
END;
/
-- set parameters related to SPM for Automatic SQL Tuning task

BEGIN
dbms_sqltune.set_auto_tuning_task_parameter( 'LOCAL_TIME_LIMIT', 1200); --Maximum Time Spent Per SQL During Tuning (sec)
dbms_sqltune.set_auto_tuning_task_parameter( 'MAX_AUTO_SQL_PROFILES', 100); --Maximum SQL Profiles Implemented (Overall)	
END;
/
-- (!) for Automatic Implementation of SQL Profiles (NO is default) set the parameter:

exec dbms_sqltune.set_auto_tuning_task_parameter('ACCEPT_SQL_PROFILES', 'TRUE');

-- change windows MAINTENANCE parameters (defaults - start at 10pm, duration 240m, SUN, SAT - at 06am, duration 1200m)
-- set parameter for all windows - start at 10am, SUN - THU - duration 360m, FRI, SAT - duration 720m

BEGIN
DBMS_SCHEDULER.DISABLE(name=>'"SYS"."SUNDAY_WINDOW"',force=>TRUE);
DBMS_SCHEDULER.DISABLE(name=>'"SYS"."MONDAY_WINDOW"',force=>TRUE);
DBMS_SCHEDULER.DISABLE(name=>'"SYS"."TUESDAY_WINDOW"',force=>TRUE);
DBMS_SCHEDULER.DISABLE(name=>'"SYS"."WEDNESDAY_WINDOW"',force=>TRUE);
DBMS_SCHEDULER.DISABLE(name=>'"SYS"."THURSDAY_WINDOW"',force=>TRUE);
DBMS_SCHEDULER.DISABLE(name=>'"SYS"."FRIDAY_WINDOW"',force=>TRUE);
DBMS_SCHEDULER.DISABLE(name=>'"SYS"."SATURDAY_WINDOW"',force=>TRUE);

DBMS_SCHEDULER.SET_ATTRIBUTE(name=>'"SYS"."SUNDAY_WINDOW"',attribute=>'DURATION',value=>numtodsinterval(360, 'minute'));
DBMS_SCHEDULER.SET_ATTRIBUTE(name=>'"SYS"."MONDAY_WINDOW"',attribute=>'DURATION',value=>numtodsinterval(360, 'minute'));
DBMS_SCHEDULER.SET_ATTRIBUTE(name=>'"SYS"."TUESDAY_WINDOW"',attribute=>'DURATION',value=>numtodsinterval(360, 'minute'));
DBMS_SCHEDULER.SET_ATTRIBUTE(name=>'"SYS"."WEDNESDAY_WINDOW"',attribute=>'DURATION',value=>numtodsinterval(360, 'minute'));
DBMS_SCHEDULER.SET_ATTRIBUTE(name=>'"SYS"."THURSDAY_WINDOW"',attribute=>'DURATION',value=>numtodsinterval(360, 'minute'));
DBMS_SCHEDULER.SET_ATTRIBUTE(name=>'"SYS"."FRIDAY_WINDOW"',attribute=>'DURATION',value=>numtodsinterval(720, 'minute'));
DBMS_SCHEDULER.SET_ATTRIBUTE(name=>'"SYS"."SATURDAY_WINDOW"',attribute=>'DURATION',value=>numtodsinterval(720, 'minute'));

DBMS_SCHEDULER.SET_ATTRIBUTE(name=>'"SYS"."SUNDAY_WINDOW"',attribute=>'REPEAT_INTERVAL',value=>'FREQ=WEEKLY;BYDAY=TUE;BYHOUR=10;BYMINUTE=0;BYSECOND=0');
DBMS_SCHEDULER.SET_ATTRIBUTE(name=>'"SYS"."MONDAY_WINDOW"',attribute=>'REPEAT_INTERVAL',value=>'FREQ=WEEKLY;BYDAY=TUE;BYHOUR=10;BYMINUTE=0;BYSECOND=0');
DBMS_SCHEDULER.SET_ATTRIBUTE(name=>'"SYS"."TUESDAY_WINDOW"',attribute=>'REPEAT_INTERVAL',value=>'FREQ=WEEKLY;BYDAY=TUE;BYHOUR=10;BYMINUTE=0;BYSECOND=0');
DBMS_SCHEDULER.SET_ATTRIBUTE(name=>'"SYS"."WEDNESDAY_WINDOW"',attribute=>'REPEAT_INTERVAL',value=>'FREQ=WEEKLY;BYDAY=TUE;BYHOUR=10;BYMINUTE=0;BYSECOND=0');
DBMS_SCHEDULER.SET_ATTRIBUTE(name=>'"SYS"."THURSDAY_WINDOW"',attribute=>'REPEAT_INTERVAL',value=>'FREQ=WEEKLY;BYDAY=TUE;BYHOUR=10;BYMINUTE=0;BYSECOND=0');
DBMS_SCHEDULER.SET_ATTRIBUTE(name=>'"SYS"."FRIDAY_WINDOW"',attribute=>'REPEAT_INTERVAL',value=>'FREQ=WEEKLY;BYDAY=TUE;BYHOUR=10;BYMINUTE=0;BYSECOND=0');
DBMS_SCHEDULER.SET_ATTRIBUTE(name=>'"SYS"."SATURDAY_WINDOW"',attribute=>'REPEAT_INTERVAL',value=>'FREQ=WEEKLY;BYDAY=TUE;BYHOUR=10;BYMINUTE=0;BYSECOND=0');

DBMS_SCHEDULER.ENABLE(name=>'"SYS"."SUNDAY_WINDOW"');
DBMS_SCHEDULER.ENABLE(name=>'"SYS"."MONDAY_WINDOW"');
DBMS_SCHEDULER.ENABLE(name=>'"SYS"."TUESDAY_WINDOW"');
DBMS_SCHEDULER.ENABLE(name=>'"SYS"."WEDNESDAY_WINDOW"');
DBMS_SCHEDULER.ENABLE(name=>'"SYS"."THURSDAY_WINDOW"');
DBMS_SCHEDULER.ENABLE(name=>'"SYS"."FRIDAY_WINDOW"');
DBMS_SCHEDULER.ENABLE(name=>'"SYS"."SATURDAY_WINDOW"');
END;
/

-- evolve task for captured plans (SYS_AUTO_SPM_EVOLVE_TASK - executes daily in the scheduled maintenance window)

SELECT * FROM DBA_ADVISOR_TASKS WHERE task_name like '%SYS_AUTO_SPM_EVOLVE_TASK%';

SELECT parameter_name, parameter_value,IS_DEFAULT,IS_MODIFIABLE_ANYTIME,DESCRIPTION
FROM dba_advisor_parameters
WHERE task_name = 'SYS_AUTO_SPM_EVOLVE_TASK'
AND parameter_value != 'UNUSED'
ORDER BY parameter_name;

-- set evolve task parameters, only SYS (!) can set task parameters

exec DBMS_SPM.SET_EVOLVE_TASK_PARAMETER(task_name => 'SYS_AUTO_SPM_EVOLVE_TASK', parameter => 'ACCEPT_PLANS', value => 'true'); -- do not accept plans automaticaly (!)

-- display execution plans for the statement with the SQL ID 31d96zzzpcys9 with baseline:

SELECT PLAN_TABLE_OUTPUT
FROM V$SQL s, DBA_SQL_PLAN_BASELINES b,
TABLE(DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE(b.sql_handle,b.plan_name,'basic')) t WHERE s.EXACT_MATCHING_SIGNATURE=b.SIGNATURE;

-- Evolving SQL Plan Baselines Manually

--1) check info for the statement for evolve:

SELECT SQL_HANDLE, SQL_TEXT, PLAN_NAME, ORIGIN, ENABLED, ACCEPTED, FIXED, AUTOPURGE 
FROM DBA_SQL_PLAN_BASELINES WHERE SQL_TEXT LIKE '%q1_group%';

--2) Check the plan for this statement (after execution or from AWR)

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(null, null, 'basic +note'));

--3) Change plan for the statement and select DBA_SQL_PLAN_BASELINES again (there will be new PLAN_NAME for the same SQL_HANDLE)
--4) Create the manual evolve task

CONNECT / AS SYSDBA
VARIABLE cnt NUMBER
VARIABLE tk_name VARCHAR2(50)
VARIABLE exe_name VARCHAR2(50)
VARIABLE evol_out CLOB
EXEC :tk_name := DBMS_SPM.CREATE_EVOLVE_TASK(sql_handle => 'SQL_07f16c76ff893342',plan_name => 'SQL_PLAN_0gwbcfvzskcu20135fd6c');
SELECT :tk_name FROM DUAL;--TASK_11

--5) execute the manual evolve task

EXEC :exe_name :=DBMS_SPM.EXECUTE_EVOLVE_TASK(task_name=>:tk_name);
SELECT :exe_name FROM DUAL;--EXEC_2

--6) check the manual evolve task

EXEC :evol_out := DBMS_SPM.REPORT_EVOLVE_TASK( task_name=>:tk_name,execution_name=>:exe_name );
SELECT :evol_out FROM DUAL;--TASK report, see Findings/Recommendation (!) sections

--7) Implement the recommendations of the evolve task

EXEC :cnt := DBMS_SPM.IMPLEMENT_EVOLVE_TASK( task_name=>:tk_name,execution_name=>:exe_name );

--8) Query the data dictionary to ensure that the new plan is accepted

--9) DROP unnessessary baseline for sql_handle SQL_07f16c76ff893342

DECLARE
v_dropped_plans number;
BEGIN
v_dropped_plans := DBMS_SPM.DROP_SQL_PLAN_BASELINE (
sql_handle => 'SQL_b6b0d1c71cd1807b'
);
DBMS_OUTPUT.PUT_LINE('dropped ' || v_dropped_plans || ' plans');
END;
/

--or ONE(!) plan handle

select DBMS_SPM.DROP_SQL_PLAN_BASELINE(sql_handle => 'SQL_b6b0d1c71cd1807b',plan_name=>'some_name_111') from dual; --return 1 if plan dropped successfully

-- Attach certain execution plan for SQL (BASELINE creation)
--https://rnm1978.wordpress.com/2011/06/28/oracle-11g-how-to-force-a-sql_id-to-use-a-plan_hash_value-using-sql-baselines/

-- if it does not work (BASELINE were not created because of the bug 25026321), use recomendations from: Loading Hinted Execution Plans into SQL Plan Baseline. (Doc ID 787692.1)
-- script for load plan into baseline for SQL_ID 
-- script for that in @/home/oracle/scripts/sqlt/utl/coe_load_sql_baseline.sql or @/dba_docs/scripts/optimization/SQLT_utl/coe_load_sql_baseline.sql
--run from sqlplus (modified script in network folder - with OEM_USER privs, first - original sql_id, second - modified sql_id - with good plan)
@W:\Dba_docs\Scripts\Toad_work_scripts\NI\coe_load_sql_baseline.sql gr5kbhfs4k7my 5kfu5bxzhksrz

SELECT * FROM dba_sql_plan_baselines order by created desc;

-- Create SQL profile for particular SQL_ID using previous good plan from AWR:

-- script for that in @/home/oracle/scripts/sqlt/utl/coe_xfr_sql_profile.sql
--example (parameters sql_id plan_hash_value): @coe_xfr_sql_profile.sql 1hac18kfxwty1 622860035
--parameters - SQL_ID and/or plan_hash_value
-- this script may generate SQL profile with the given plan_hash_value - from MEMORY or AWR
--!!! need to check AWR for plan_hash_value if it does not appeared in the script output
--THEN execute generated file having name similar that: coe_xfr_sql_profile_08kgdgrf53jrg_1115852350.sql
-- can be also used to fix plans from UAT on PROD

-- plans in AWR - DBA_HIST_ACTIVE_SESS_HISTORY

  SELECT DISTINCT TRUNC (SAMPLE_TIME)     DAY,
                  SQL_ID,
                  SQL_PLAN_HASH_VALUE,
                  SNAP_ID
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     SQL_ID IN ('9575wxsvqhzy4', 'fnjzurfvss57v')
         AND SAMPLE_TIME >= TRUNC (SYSDATE - 6)
ORDER BY TRUNC (SAMPLE_TIME), SNAP_ID, SQL_ID;

-- plans history from AWR - DBA_HIST_SQL_PLAN (used for return plan with coe_xfr_sql_profile, if there is no plan here script will fail !)

  SELECT DISTINCT TRUNC (TIMESTAMP) DAY, SQL_ID, PLAN_HASH_VALUE
    FROM DBA_HIST_SQL_PLAN
   WHERE     TIMESTAMP >= TRUNC (SYSDATE - 6)
         AND SQL_ID IN ('9575wxsvqhzy4', 'fnjzurfvss57v')
ORDER BY 1, 2, 3;

-- plans statistics from AWR - DBA_HIST_SQLSTAT

  SELECT DISTINCT TRUNC (S.BEGIN_INTERVAL_TIME)     DAY,
                  H.SQL_ID,
                  H.PLAN_HASH_VALUE,
                  H.SNAP_ID
    FROM DBA_HIST_SQLSTAT H, DBA_HIST_SNAPSHOT S
   WHERE     H.SNAP_ID = S.SNAP_ID
         AND S.DBID = H.DBID
         AND S.INSTANCE_NUMBER = H.INSTANCE_NUMBER
         AND H.SQL_ID IN ('9575wxsvqhzy4', 'fnjzurfvss57v')
         AND H.SNAP_ID IN
                 (SELECT SNAP_ID
                    FROM DBA_HIST_SNAPSHOT
                   WHERE TRUNC (BEGIN_INTERVAL_TIME) >= TRUNC (SYSDATE - 6))
ORDER BY TRUNC (BEGIN_INTERVAL_TIME),
         H.SQL_ID,
         H.SNAP_ID,
         H.PLAN_HASH_VALUE;

--Flushing a Single SQL Statement from Library Cache (Only if required for checking SQL profile)

select ADDRESS, HASH_VALUE from V$SQLAREA where SQL_ID like '0sagz5rtm8jga';
exec DBMS_SHARED_POOL.PURGE ('0000000A2B3ECA20, 4080289258', 'C'); --ADDRESS HASH_VALUE as parameters (!!! AS SYS)
select ADDRESS, HASH_VALUE from V$SQLAREA where SQL_ID like '0sagz5rtm8jga'; --should be no rows!

--Fragmentation of the shared pool can be reduced by specifying that objects should be kept. 
--Kept objects are not subject to aging out of the shared pool
--reduce "library cache: mutex X" and "cursor: pin S" wait events

EXECUTE dbms_shared_pool.keep ('SYS.STANDARD','P'); --Package,Type,tRigger,FUNCTION
EXECUTE dbms_shared_pool.keep ('6B8551B8,593239587','C');
--first obtain the address of the parent cursor and the hash value V$SQL.ADDRESS (hexadecimal), V$SQL.HASH_VALUE (decimal)
--unkeep:
EXECUTE dbms_shared_pool.unkeep ('SYS.STANDARD','P');
EXECUTE dbms_shared_pool.unkeep ('6B8551B8,593239587','C');

--Reports the largest objects currently in the shared pool (specify min size in Kb)
SET SERVEROUTPUT ON
EXECUTE dbms_shared_pool.sizes (64);

-- MOVE SQL profiles between databases:

--destination db
--1) create staging table
EXEC DBMS_SQLTUNE.CREATE_STGTAB_SQLPROF('SQL_PROFILES_TAB','SYSTEM');

--2) move profiles in that table
EXEC DBMS_SQLTUNE.PACK_STGTAB_SQLPROF(PROFILE_NAME=>'%',STAGING_TABLE_NAME=>'SQL_PROFILES_TAB',STAGING_SCHEMA_OWNER=>'SYSTEM');

--3) export in the dump: expdp \"/ as sysdba\" schemas=SYSTEM include=TABLE:\"=\'SQL_PROFILES_TAB\'\" directory=STATS dumpfile=SQL_PROFILES_TAB logfile=SQL_PROFILES_TAB compression=all

--source db
--4) import dump file: impdp \"/ as sysdba\" schemas=SYSTEM dumpfile=SQL_PROFILES_TAB logfile=imp_SQL_PROFILES_TAB


--5) unpack profiles from it
EXEC DBMS_SQLTUNE.UNPACK_STGTAB_SQLPROF(PROFILE_NAME=>'%',PROFILE_CATEGORY=>'%',REPLACE=>TRUE,STAGING_TABLE_NAME=>'SQL_PROFILES_TAB',STAGING_SCHEMA_OWNER=>'SYSTEM');

--6) CHECK
SELECT * FROM DBA_SQL_PROFILES ORDER BY CREATED DESC;

-- MOVE SQL plan baselines between databases:

--destination db
--1) create staging table
 exec DBMS_SPM.CREATE_STGTAB_BASELINE('SQL_BASELINES_TAB','SYSTEM');

 --2) move baseline in that table
DECLARE
    L_PLANS_LOADED   PLS_INTEGER;
BEGIN
 DBMS_OUTPUT.ENABLE;
 L_PLANS_LOADED := DBMS_SPM.pack_stgtab_baseline(table_name=>'SQL_BASELINES_TAB',table_owner=>'SYSTEM',sql_handle=>'SQL_de6145e7e41cc1c1',plan_name=>'SQL_PLAN_dwsa5wzk1thf15424a30b');
 DBMS_OUTPUT.PUT_LINE ('PLANS altered: ' || L_PLANS_LOADED);
END;
/

--3) export in the dump: expdp \"/ as sysdba\" schemas=SYSTEM include=TABLE:\"=\'SQL_BASELINES_TAB\'\" directory=STATS dumpfile=SQL_BASELINES_TAB logfile=SQL_BASELINES_TAB compression=all

--source db
--4) import dump file: impdp \"/ as sysdba\" schemas=SYSTEM dumpfile=SQL_BASELINES_TAB logfile=imp_SQL_BASELINES_TAB

--5) unpack baselines from it

DECLARE
    L_BASELINES_UNPACKED   PLS_INTEGER;
BEGIN
 DBMS_OUTPUT.ENABLE;
 L_BASELINES_UNPACKED := DBMS_SPM.unpack_stgtab_baseline(table_name=>'SQL_BASELINES_TAB',table_owner=>'SYSTEM',sql_handle=>'SQL_de6145e7e41cc1c1',plan_name=>'SQL_PLAN_dwsa5wzk1thf15424a30b',enabled=>'YES',accepted=>'YES');
 DBMS_OUTPUT.PUT_LINE ('Baselines unpacked: ' || L_BASELINES_UNPACKED);
END;
/

--6) CHECK
SELECT * FROM DBA_SQL_PLAN_BASELINES ORDER BY CREATED DESC;


-- See: How to Load SQL Plans into SQL Plan Management (SPM) from the Automatic Workload Repository (AWR) (Doc ID 789888.1)
-- Create SQL Tuning Set (STS)

BEGIN
    DBMS_SQLTUNE.CREATE_SQLSET (
        SQLSET_NAME =>
            'STS_6qv1yffcdx0p7',
        DESCRIPTION =>
            'SQL Tuning Set for INSERT INTO MARKETDATA (OWNER DAKR_MSSQL)');
END;

-- Populate STS from AWR, using a time duration when the desired plan was used
--  List out snapshot times using :   SELECT SNAP_ID, BEGIN_INTERVAL_TIME, END_INTERVAL_TIME FROM dba_hist_snapshot ORDER BY END_INTERVAL_TIME DESC;
--  Specify the sql_id in the basic_filter (other predicates are available, see documentation)

DECLARE
    baseline_ref_cursor DBMS_SQLTUNE.SQLSET_CURSOR; --CUR   SYS_REFCURSOR;
BEGIN
    OPEN baseline_ref_cursor FOR SELECT VALUE (P)
                   FROM TABLE (DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY (
                                   BEGIN_SNAP =>
                                       42774,
                                   END_SNAP =>
                                       42777,
                                   BASIC_FILTER =>
                                       'sql_id = ''6qv1yffcdx0p7''',
                                       --'sql_id = ''6qv1yffcdx0p7'' and plan_hash_value=1615093783',
                                   ATTRIBUTE_LIST =>
                                       'ALL')) P;

    --DBMS_SQLTUNE.LOAD_SQLSET (SQLSET_NAME       => 'STS_6qv1yffcdx0p7',POPULATE_CURSOR   => CUR);
    
    DBMS_SQLTUNE.LOAD_SQLSET ('STS_6qv1yffcdx0p7',baseline_ref_cursor);
    
    --CLOSE CUR;
    
END;
/

-- List out SQL Tuning Set contents to check we got what we wanted

SELECT FIRST_LOAD_TIME,
       EXECUTIONS             AS EXECS,
       PARSING_SCHEMA_NAME,
       ELAPSED_TIME / 1000000 AS ELAPSED_TIME_SECS,
       CPU_TIME / 1000000     AS CPU_TIME_SECS,
       BUFFER_GETS,
       DISK_READS,
       DIRECT_WRITES,
       ROWS_PROCESSED,
       FETCHES,
       OPTIMIZER_COST,
       SQL_PLAN,
       PLAN_HASH_VALUE,
       SQL_ID,
       SQL_TEXT
  FROM TABLE (DBMS_SQLTUNE.SELECT_SQLSET (SQLSET_OWNER=>'SYS',SQLSET_NAME => 'STS_02_52-11_50')) where OPTIMIZER_COST>1 order by ELAPSED_TIME desc;
  
-- display plans and sql in sql tuning set

SELECT * FROM DBA_SQLSET ORDER BY CREATED DESC;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_SQLSET('STS_6qv1yffcdx0p7','6qv1yffcdx0p7'));

-- CREATE BASELINE FOR SQL_ID with CORRECT PLAN
-- Load desired plan from STS as SQL Plan Baseline
-- Filter explicitly for the plan_hash_value here if you want

DECLARE
    L_PLANS_LOADED   PLS_INTEGER;
BEGIN
    L_PLANS_LOADED :=
        DBMS_SPM.LOAD_PLANS_FROM_SQLSET (SQLSET_NAME=> 'STS_6qv1yffcdx0p7');
        --DBMS_SPM.LOAD_PLANS_FROM_SQLSET (SQLSET_NAME=> 'STS_6qv1yffcdx0p7',BASIC_FILTER =>'sql_id = ''6qv1yffcdx0p7'' and plan_hash_value=1615093783');
    DBMS_OUTPUT.PUT_LINE ('PLANS loaded'||L_PLANS_LOADED);
END;
/

-- List out the Baselines to see what's there (created baseline and plan, which will be user for SQL_ID)

SELECT * FROM DBA_SQL_PLAN_BASELINES order by CREATED desc; --see SQL_HANDLE
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE(SQL_HANDLE => 'SQL_7ddbf799d693753b',PLAN_NAME=>'SQL_PLAN_7vqzrm7b96x9v4cb5a735',FORMAT => 'advanced')); --see plan from BASELINE

DECLARE
    L_PLANS_LOADED   PLS_INTEGER;
BEGIN
    L_PLANS_LOADED :=
        DBMS_SPM.ALTER_SQL_PLAN_BASELINE (
            SQL_HANDLE        => 'SQL_7ddbf799d693753b',
            ATTRIBUTE_NAME    => 'AUTOPURGE',
            ATTRIBUTE_VALUE   => 'NO');
    DBMS_OUTPUT.PUT_LINE ('PLANS altered' || L_PLANS_LOADED);
/*        L_PLANS_LOADED :=
        DBMS_SPM.ALTER_SQL_PLAN_BASELINE (
            SQL_HANDLE        => 'SQL_0cdc728fc85a69d1',
            ATTRIBUTE_NAME    => 'DESCRIPTION',
            ATTRIBUTE_VALUE   => 'INSERT INTO MARKETDATA SELECT TRADEDATE DATE1%');
    DBMS_OUTPUT.PUT_LINE ('PLANS altered' || L_PLANS_LOADED);
*/    
END;
/

-- drop unused baselines (if any)

DECLARE
    L_PLANS_LOADED   PLS_INTEGER;
BEGIN
 L_PLANS_LOADED := DBMS_SPM.DROP_SQL_PLAN_BASELINE(SQL_HANDLE=> 'SQL_862e0a8804dd0f0e');
 DBMS_OUTPUT.PUT_LINE ('PLANS dropped' || L_PLANS_LOADED);
 COMMIT;   
END;
/  

-- extended trace for dbms_spm

exec dbms_spm.configure('spm_tracing',41); 
alter session set events '10046 trace name context forever, level 12'; 

-- PL/SQL run block for DBMS_SPM.LOAD_PLANS_FROM_SQLSET

alter session set events '10046 trace name context off'; 
exec dbms_spm.configure('spm_tracing',0); 

--list of tuning sets
SELECT * FROM DBA_SQLSET ORDER BY CREATED DESC;

DECLARE
    L_PLANS_LOADED   PLS_INTEGER;
BEGIN
    L_PLANS_LOADED :=
        DBMS_SPM.LOAD_PLANS_FROM_SQLSET (
            SQLSET_OWNER   => 'SQLTXADMIN',
            SQLSET_NAME    => 'STS_INT_TRADES_COMM');
    DBMS_OUTPUT.PUT_LINE (L_PLANS_LOADED);
END;
/

DECLARE
    L_PLANS_LOADED   PLS_INTEGER;
BEGIN
    L_PLANS_LOADED :=
        DBMS_SPM.LOAD_PLANS_FROM_SQLSET (
            SQLSET_NAME    => 'STS_INT_TRADES_COMM');
    DBMS_OUTPUT.PUT_LINE (L_PLANS_LOADED);
END;
/
-- List out the Baselines

SELECT * FROM DBA_SQL_PLAN_BASELINES order by CREATED desc;

SELECT * FROM DBA_SQL_PLAN_BASELINES WHERE CREATED >=sysdate-1/24 order by CREATED desc; --only new one

--Now when the query�s run, it will use the desired plan.

--LOAD plans from CURSOR CACHE (replace bad plan with good if it present in cursor cache)

SELECT DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(SQL_ID => '3zkmrvzst1ac1') FROM DUAL;

SELECT * FROM DBA_SQL_PLAN_BASELINES ORDER BY CREATED DESC;

SET SERVEROUTPUT ON
VAR RES NUMBER
--EXEC :RES := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(SQL_ID => '&hinted_SQL_ID', PLAN_HASH_VALUE => &HINTED_PLAN_HASH_VALUE, SQL_HANDLE => '&sql_handle_for_original');
EXEC :RES := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(SQL_ID => '9qyvcbc8tqgda', PLAN_HASH_VALUE => 2320859913, SQL_HANDLE => '3zkmrvzst1ac1');
EXEC DBMS_OUTPUT.PUT_LINE('Number of plans loaded: ' || :RES);
select DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(SQL_ID => '9qyvcbc8tqgda', PLAN_HASH_VALUE => 2320859913, SQL_HANDLE => 'SQL_bdc872a12dc08c92') from dual;

-- create baseline for the particular STMT with good plan in curor cache:

select count(*) from dba_sql_plan_baselines;

DECLARE
ret binary_integer;
BEGIN
RET:=DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(sql_id => '&sql_id',plan_hash_value =>&plan_hash_value,fixed=>'YES',enabled =>'YES');
END;
/

select count(*) from dba_sql_plan_baselines; --must be +1 in comparison with the above execution

-- FIX problems in SQL using SQL patch - wrong result of SQL statments

--1) execute select (exactly as it exists in application)

--2) find its sql_id

select * from v$sql where SQL_TEXT like '%g_analytic.ORDERS_MRKT%';

--3) rus sql diagnostic task in _SQLDIAG_FINDING_MODE

declare
l_sql_diag_task_id  varchar2(100);
begin
--
-- Create diagnostic task
--
    l_sql_diag_task_id :=  dbms_sqldiag.create_diagnosis_task (
      sql_id => '5zpcy29sgx73k',
      problem_type => dbms_sqldiag.PROBLEM_TYPE_WRONG_RESULTS,
      task_name => 'Test_WR_diagnostic_task4' );
 --
-- Setup parameters for the task to give verbose output
--
    dbms_sqltune.set_tuning_task_parameter(
      l_sql_diag_task_id,
      '_SQLDIAG_FINDING_MODE',
      DBMS_SQLDIAG.SQLDIAG_FINDINGS_FILTER_PLANS);
end;
/

--4) Execute the task

exec dbms_sqldiag.execute_diagnosis_task ( task_name  => 'Test_WR_diagnostic_task4' );

--5) Accept sql_patch if it exists

select dbms_sqldiag.report_diagnosis_task ('Test_WR_diagnostic_task4')   as recommendations  from dual;


-- AUTO SQL tuning advisor

SELECT STATUS FROM DBA_ADVISOR_TASKS WHERE TASK_NAME = 'SYS_AUTO_SQL_TUNING_TASK';
SELECT PARAMETER_NAME,PARAMETER_VALUE FROM DBA_ADVISOR_PARAMETERS WHERE TASK_NAME='SYS_AUTO_SQL_TUNING_TASK';

SELECT EXECUTION_NAME, COUNT(*) FROM DBA_ADVISOR_OBJECTS WHERE TASK_NAME ='SYS_AUTO_SQL_TUNING_TASK' AND TYPE = 'SQL' GROUP BY EXECUTION_NAME ORDER BY EXECUTION_NAME;
SELECT EXECUTION_NAME, EXECUTION_START, EXECUTION_END, STATUS FROM DBA_ADVISOR_EXECUTIONS WHERE TASK_NAME = 'SYS_AUTO_SQL_TUNING_TASK' ORDER BY EXECUTION_START;
SELECT * FROM DBA_ADVISOR_EXECUTIONS ORDER BY EXECUTION_START DESC;

-- run SQL tuning advisor for exact sql_id

DECLARE
    RET_VAL   VARCHAR2 (4000);
BEGIN
    RET_VAL :=
        DBMS_SQLTUNE.CREATE_TUNING_TASK (TASK_NAME    => 'tuning_&sql_id',
                                         SQL_ID       => '&&sql_id',
                                         TIME_LIMIT   => 600);
    DBMS_SQLTUNE.EXECUTE_TUNING_TASK ('tuning_&&sql_id');
END;
/

SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK ('tuning_&&sql_id') AS RECOMMENDATIONS FROM DUAL;


SET LONG 10000 PAGESIZE 50000 LINESIZE 300
column RECOMMENDATIONS format a300
-- optionally you can spool the output
spool SQL_tuning_task.log
SELECT DBMS_SQLTUNE.report_tuning_task('tune_STS_03_10-08_50_2') AS recommendations FROM dual;
SELECT DBMS_SQLTUNE.report_tuning_task(task_name=>'tune_STS_03_10-08_50_2',object_id=>2) AS recommendations FROM dual;
spool off


-- run SQL tuning advisor for SQL tuning set

DECLARE
    RET_VAL   VARCHAR2 (4000);
BEGIN
    RET_VAL :=
        DBMS_SQLTUNE.CREATE_TUNING_TASK (
            TASK_NAME     => 'tune_STS_03_10-08_50',
            SQLSET_NAME   => 'STS_03_10-08_50',
            BASIC_FILTER   =>
                'ELAPSED_TIME / 1000000 >=1 AND PARSING_SCHEMA_NAME = ''DWH_CONNECTOR'' AND EXECUTIONS > 1',
            TIME_LIMIT => 300,
			SQLSET_OWNER => 'IGOR_OEM');
    DBMS_SQLTUNE.EXECUTE_TUNING_TASK ('tune_STS_03_10-08_50');
END;
/

SELECT * FROM DBA_ADVISOR_EXECUTIONS WHERE TASK_NAME NOT LIKE 'ADDM:%' ORDER BY EXECUTION_START DESC;
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK ('tune_STS_02_55-09_40',owner_name=>'SYS') AS RECOMMENDATIONS FROM DUAL;

-- UNDO

-- autotuned tuned undo retention size and sql_id for it during the given period  

SELECT TO_CHAR (BEGIN_TIME, 'hh24:mi:ss'),
         MAXQUERYLEN,
         MAXQUERYSQLID,
         NOSPACEERRCNT,
         ACTIVEBLKS,
         UNEXPIREDBLKS,
         EXPIREDBLKS,
         TUNED_UNDORETENTION
    FROM DBA_HIST_UNDOSTAT
   WHERE     BEGIN_TIME > TO_DATE ('2017-05-16', 'yyyy-mm-dd')
         AND END_TIME < TO_DATE ('2017-05-19', 'yyyy-mm-dd')
ORDER BY BEGIN_TIME;

--autotuned tuned undo retention size in DB

SELECT BEGIN_TIME, END_TIME, UNDOBLKS,MAXQUERYLEN,ACTIVEBLKS,UNEXPIREDBLKS,EXPIREDBLKS,TUNED_UNDORETENTION FROM V$UNDOSTAT ORDER BY BEGIN_TIME;

SELECT FILE_NAME, BYTES FROM DBA_DATA_FILES WHERE TABLESPACE_NAME IN (SELECT TABLESPACE_NAME FROM DBA_TABLESPACES WHERE CONTENTS = 'UNDO');

--undo information on relevant database sessions

SELECT TO_CHAR(s.sid)||','||TO_CHAR(s.serial#) AS sid_serial,
       NVL(s.username, '(oracle)') AS username,
       s.program,
       r.name undoseg,
       t.used_ublk * TO_NUMBER(x.value)/1024||'K' AS undo
FROM   v$rollname    r,
       v$session     s,
       v$transaction t,
       v$parameter   x
WHERE  s.taddr = t.addr
AND    r.usn   = t.xidusn(+)
AND    x.name  = 'db_block_size';

-- used extents in rollback segments of UNDO (in order to remove UNDO TS there must not be ACTIVE segments in it)

set linesize 250 pagesize 10000
col sum_bytes for 999,999,999,999,999
select to_char(sysdate,'dd-mm-yyyy hh24:mi:ss') from dual;
SELECT DISTINCT STATUS, SUM(BYTES) sum_bytes, COUNT(*),TABLESPACE_NAME FROM DBA_UNDO_EXTENTS GROUP BY TABLESPACE_NAME,STATUS;
select tablespace_name , status , count(*) from dba_rollback_segs group by tablespace_name , status;

-- transactions using undo TS 

select v.sid, v.username, t.xidusn, t.ses_addr, r.segment_id, r.segment_name, r.status
from v$session v, v$transaction t, dba_rollback_segs r
where v.saddr = t.ses_addr
and t.xidusn = r.segment_id
and r.tablespace_name= 'UNDOTBS2';

select * from dba_rollback_segs;
select tablespace_name , sum(blocks)*8/(1024)  space_in_use from dba_undo_extents where status IN ('ACTIVE','UNEXPIRED') group by  tablespace_name;
--select tablespace_name , sum(blocks)*8/(1024)  reusable_space from dba_undo_extents where status='EXPIRED'  group by  tablespace_name;

-- INDEXES INFO

-- usage of monitored indexes
SELECT * FROM DBA_OBJECT_USAGE ORDER BY OWNER,INDEX_NAME, USED DESC;
SELECT * FROM DBA_OBJECT_USAGE WHERE USED = 'NO' ORDER BY OWNER,INDEX_NAME;
SELECT * FROM DBA_OBJECT_USAGE WHERE USED = 'YES' ORDER BY OWNER,INDEX_NAME;  

  SELECT *
    FROM DBA_IND_COLUMNS
   WHERE (INDEX_OWNER,
          INDEX_NAME,
          TABLE_OWNER,
          TABLE_NAME) IN
             (SELECT I.INDEX_OWNER,
                     I.INDEX_NAME,
                     I.TABLE_OWNER,
                     I.TABLE_NAME
                FROM INDEX_DDL_BACKUP_DWH122 I, DBA_OBJECT_USAGE D
               WHERE     I.INDEX_OWNER = D.OWNER
                     AND I.INDEX_NAME = D.INDEX_NAME
                     AND D.USED = 'YES')
ORDER BY INDEX_OWNER, INDEX_NAME;

select count(1) from CFTUSER.HP_FA_ACCOUNTS where ACCOUNT_NO = '60307810100000000008';
select * from CFTUSER.HP_FA_ACCOUNTS;
select /*+ FULL(a) */ count(1) from CFTUSER.HP_FA_ACCOUNTS a where a.ACCOUNT_NO = '60307810100000000079';

select * from CURR.ORDERS_BASE where ORDERNO  = 6735625;--4sec--unique index 4sec
select /*+ FULL(a) */ * from CURR.ORDERS_BASE a where a.ORDERNO  = 6735623;--530sec
select /*+ INDEX(a ORDER_CURR_ORDNO_IDX) */ * from CURR.ORDERS_BASE a where a.ORDERNO  = 6735621;--21 sec

select * from DBA_IND_STATISTICS;

--table with indexes for delete DDL backup
SELECT * FROM INDEX_DDL_BACKUP_DWH122 ORDER BY 1,2;
SELECT * FROM INDEX_DDL_BACKUP_DWH122 WHERE STATE_CHANGE IS NULL AND COMMENTS IS NULL AND DELETED IS NULL AND INDEX_OWNER NOT LIKE 'G_%' ORDER BY 1,2;
SELECT * FROM INDEX_DDL_BACKUP_DWH122 WHERE INDEX_OWNER = 'FORTS_CLEARING' ORDER BY TABLE_NAME,INDEX_NAME;
EDIT INDEX_DDL_BACKUP_DWH122 ORDER BY 1,2;
EDIT INDEX_DDL_BACKUP_DWH122 WHERE INDEX_NAME = 'HP_FA_ACC_REST_OLTP_DY_C1';
EDIT INDEX_DDL_BACKUP_DWH122 WHERE TABLE_NAME = 'ST_NSDACCBAL';
EDIT INDEX_DDL_BACKUP_DWH122 WHERE INDEX_OWNER LIKE 'EQ%' ORDER BY INDEX_OWNER,TABLE_NAME,INDEX_NAME;
SELECT 'alter index '||INDEX_OWNER||'.'||INDEX_NAME||' monitoring usage;' FROM INDEX_DDL_BACKUP_DWH122;
SELECT DBMS_METADATA.GET_DDL (OBJECT_TYPE=>'INDEX',NAME=>'ORDERS_CURR_UIDX',SCHEMA=>'CURR') FROM DUAL;

  SELECT OWNER,
         INDEX_NAME,
         TABLE_OWNER,
         TABLE_NAME,
         UNIQUENESS,
         COMPRESSION,
         VISIBILITY,
         DBMS_METADATA.GET_DDL (OBJECT_TYPE   => 'INDEX',
                                NAME          => INDEX_NAME,
                                SCHEMA        => OWNER)
    FROM (SELECT *
            FROM DBA_INDEXES
           WHERE     UNIQUENESS <> 'UNIQUE'
                 AND OWNER NOT IN ('BI_METADATA',
                                   'SPUR_DAY_CU_TEST',
                                   'SPUR_DAY_TEST',
                                   'SPUR_DAY_CU',
                                   'SPUR_DAY',
                                   'SQLTXPLAIN',
                                   'SYSTEM',
                                   'SYS',
                                   'AUDSYS',
                                   'MOSCOW_EXCHANGE',
                                   'MDMWORK_TST',
                                   'MOSCOW_EXCHANGE_TST',
                                   'MOSCOW_EXCHANGE_PMI')
                 AND NUM_ROWS > 10000
                 AND (TABLE_OWNER, TABLE_NAME) IN (SELECT OWNER, TABLE_NAME
                                                     FROM DBA_TABLES
                                                    WHERE PARTITIONED = 'YES')
          UNION
          SELECT *
            FROM DBA_INDEXES
           WHERE     UNIQUENESS <> 'UNIQUE'
                 AND OWNER NOT IN ('BI_METADATA',
                                   'SPUR_DAY_CU_TEST',
                                   'SPUR_DAY_TEST',
                                   'SPUR_DAY_CU',
                                   'SPUR_DAY',
                                   'SQLTXPLAIN',
                                   'SYSTEM',
                                   'SYS',
                                   'AUDSYS',
                                   'MOSCOW_EXCHANGE',
                                   'MDMWORK_TST',
                                   'MOSCOW_EXCHANGE_TST',
                                   'MOSCOW_EXCHANGE_PMI')
                 AND (TABLE_OWNER, TABLE_NAME) IN
                         (SELECT T.OWNER, T.TABLE_NAME
                            FROM DBA_TABLES T, DBA_SEGMENTS S
                           WHERE     T.OWNER = S.OWNER
                                 AND T.TABLE_NAME = S.SEGMENT_NAME
                                 AND T.PARTITIONED = 'NO'
                                 AND S.SEGMENT_TYPE = 'TABLE'
                                 AND S.BYTES >= 1024 * 1024 * 512 ))
WHERE (OWNER,INDEX_NAME) NOT IN (SELECT INDEX_OWNER,INDEX_NAME FROM INDEX_DDL_BACKUP_DWH122) 
ORDER BY OWNER, INDEX_NAME;

-- insert information about redundant indexes

INSERT INTO INDEX_DDL_BACKUP_DWH122 (INDEX_OWNER,
                                     INDEX_NAME,
                                     TABLE_OWNER,
                                     TABLE_NAME,
                                     UNIQUNESS,
                                     COMPRESSION,
                                     INDEX_VISIBLE,
                                     INDEX_DDL)
    SELECT OWNER,
           INDEX_NAME,
           TABLE_OWNER,
           TABLE_NAME,
           UNIQUENESS,
           COMPRESSION,
           VISIBILITY,
           DBMS_METADATA.GET_DDL (OBJECT_TYPE   => 'INDEX',
                                  NAME          => INDEX_NAME,
                                  SCHEMA        => OWNER)
      FROM (SELECT *
              FROM DBA_INDEXES
             WHERE     NUM_ROWS > 10000
                   AND INDEX_NAME IN ('FUT_SESS_CONTENTS_BASE_UIDX','OPT_SESS_CONTENTS2_BASE_1_UIDX'));
                   
select * from INDEX_DDL_BACKUP_DWH122 where INDEX_NAME in ('FUT_SESS_CONTENTS_BASE_UIDX','OPT_SESS_CONTENTS2_BASE_1_UIDX');

INSERT INTO INDEX_DDL_BACKUP_DWH122 (INDEX_OWNER,
                                     INDEX_NAME,
                                     TABLE_OWNER,
                                     TABLE_NAME,
                                     UNIQUNESS,
                                     COMPRESSION,
                                     INDEX_VISIBLE,
                                     INDEX_DDL)
    SELECT OWNER,
           INDEX_NAME,
           TABLE_OWNER,
           TABLE_NAME,
           UNIQUENESS,
           COMPRESSION,
           VISIBILITY,
           DBMS_METADATA.GET_DDL (OBJECT_TYPE   => 'INDEX',
                                  NAME          => INDEX_NAME,
                                  SCHEMA        => OWNER)
      FROM (SELECT *
              FROM DBA_INDEXES
             WHERE     UNIQUENESS <> 'UNIQUE'
                   AND OWNER NOT IN ('BI_METADATA',
                                     'SPUR_DAY_CU_TEST',
                                     'SPUR_DAY_TEST',
                                     'SPUR_DAY_CU',
                                     'SPUR_DAY',
                                     'SQLTXPLAIN',
                                     'SYSTEM',
                                     'SYS',
                                     'AUDSYS',
                                     'MOSCOW_EXCHANGE',
                                     'MDMWORK_TST',
                                     'MOSCOW_EXCHANGE_TST',
                                     'MOSCOW_EXCHANGE_PMI')
                   AND NUM_ROWS > 10000
                   AND (TABLE_OWNER, TABLE_NAME) IN
                           (SELECT OWNER, TABLE_NAME
                              FROM DBA_TABLES
                             WHERE PARTITIONED = 'YES')
            UNION
            SELECT *
              FROM DBA_INDEXES
             WHERE     UNIQUENESS <> 'UNIQUE'
                   AND OWNER NOT IN ('BI_METADATA',
                                     'SPUR_DAY_CU_TEST',
                                     'SPUR_DAY_TEST',
                                     'SPUR_DAY_CU',
                                     'SPUR_DAY',
                                     'SQLTXPLAIN',
                                     'SYSTEM',
                                     'SYS',
                                     'AUDSYS',
                                     'MOSCOW_EXCHANGE',
                                     'MDMWORK_TST',
                                     'MOSCOW_EXCHANGE_TST',
                                     'MOSCOW_EXCHANGE_PMI')
                   AND (TABLE_OWNER, TABLE_NAME) IN
                           (SELECT T.OWNER, T.TABLE_NAME
                              FROM DBA_TABLES T, DBA_SEGMENTS S
                             WHERE     T.OWNER = S.OWNER
                                   AND T.TABLE_NAME = S.SEGMENT_NAME
                                   AND T.PARTITIONED = 'NO'
                                   AND S.SEGMENT_TYPE = 'TABLE'
                                   AND S.BYTES >= 1024 * 1024 * 512))
     WHERE (OWNER, INDEX_NAME) NOT IN (SELECT INDEX_OWNER, INDEX_NAME
                                         FROM INDEX_DDL_BACKUP_DWH122);

-- partitioned *BASE tables with indexes

  SELECT DISTINCT OWNER, TABLE_NAME
    FROM DBA_TABLES
   WHERE     PARTITIONED <> 'NO'
         AND OWNER NOT LIKE 'SYS%'
         AND TABLE_NAME LIKE '%BASE%'
         AND TABLE_NAME IN (SELECT TABLE_NAME
                              FROM DBA_INDEXES)
ORDER BY 1, 2;

-- RESULT CACHE

--Primary DB must be resterted after switchover to enable RC because of bug 16264207 (see http://jira.moex.com/browse/DKSMON-301)
 
sho parameter result_cache
EXECUTE DBMS_RESULT_CACHE.MEMORY_REPORT;
select SYS.DBMS_RESULT_CACHE.STATUS from dual;
select * from V$RESULT_CACHE_MEMORY;
select * from V$RESULT_CACHE_DEPENDENCY;
select * from V$RESULT_CACHE_OBJECTS;
select * from V$RESULT_CACHE_STATISTICS;

-- list tables with no statistics during last 2 days

  SELECT OWNER, TABLE_NAME
    FROM DBA_TABLES
   WHERE     PARTITIONED = 'YES'
         AND LAST_ANALYZED < TRUNC (SYSDATE - 1)
         AND OWNER NOT IN ('SYS', 'SYSTEM')
         AND TABLE_NAME NOT LIKE 'SYS_FBA_HIST%'
ORDER BY 1, 2;

-- list stale statistics for schemas in MANUAL_STATISTICS table

DECLARE
    OBJLIST                DBMS_STATS.OBJECTTAB;
    V_OBJECT_SIZE_GB       NUMBER;
    V_MAX_OBJECT_SIZE_GB   NUMBER DEFAULT 25;
    SQL_TXT                VARCHAR2 (3000);
    V_PL_SQLINIT           VARCHAR2 (3000) DEFAULT 'testing';
BEGIN
    FOR REC IN (  SELECT DISTINCT OBJECT_OWNER
                    FROM MANUAL_STATISTICS
                  -- WHERE OBJECT_OWNER IN ('EQ', 'CURR')
                ORDER BY 1)
    LOOP
        DBMS_STATS.GATHER_SCHEMA_STATS (REC.OBJECT_OWNER,
                                        OBJLIST   => OBJLIST,
                                        OPTIONS   => 'LIST STALE');

        IF OBJLIST IS NOT EMPTY
        THEN
            FOR I IN OBJLIST.FIRST .. OBJLIST.LAST
            LOOP
                IF OBJLIST (I).PARTNAME IS NULL
                THEN
                    SELECT ROUND (SUM (BYTES) / 1024 / 1024 / 1024)
                      INTO V_OBJECT_SIZE_GB
                      FROM DBA_SEGMENTS
                     WHERE     OWNER = OBJLIST (I).OWNNAME
                           AND SEGMENT_NAME = OBJLIST (I).OBJNAME;

                    IF V_OBJECT_SIZE_GB >= V_MAX_OBJECT_SIZE_GB
                    THEN
                  --      WORK_WITH_PARTITIONED_TABLES.LOG_WORK (
                    --        V_PL_SQLINIT,
                      --         'TABLE '
                        --    || OBJLIST (I).OWNNAME
                          --  || '.'
--                            || OBJLIST (I).OBJNAME
  --                          || ' SIZE IS '
    --                        || V_OBJECT_SIZE_GB
      --                      || ' GB, GATHER ITS STATISTICS MANUALLY',
        --                    3);
                       -- COMMIT;
                       
                       dbms_output.put_line('TABLE '
                            || OBJLIST (I).OWNNAME
                            || '.'
                            || OBJLIST (I).OBJNAME
                            || ' SIZE IS '
                            || V_OBJECT_SIZE_GB
                            || ' GB, GATHER ITS STATISTICS MANUALLY');
                    ELSE
                        SQL_TXT :=
                               'BEGIN'
                            || CHR (10)
                            || ' SYS.DBMS_STATS.GATHER_TABLE_STATS('''
                            || OBJLIST (I).OWNNAME
                            || ''','''
                            || OBJLIST (I).OBJNAME
                            || ''');'
                            || CHR (10)
                            || 'END;';

                      --  SYS.DBMS_STATS.GATHER_TABLE_STATS (
                        --    OBJLIST (I).OWNNAME,
                          --  OBJLIST (I).OBJNAME);
                          
                         dbms_output.put_line(SQL_TXT);

                        --EXECUTE IMMEDIATE SQL_TXT;

--                        WORK_WITH_PARTITIONED_TABLES.LOG_WORK (
  --                          V_PL_SQLINIT,
    --                        REPLACE (SQL_TXT, CHR (10), ' '),
      --                      3);
                        --COMMIT;
                    END IF;
                ELSE
                    SQL_TXT :=
                           'BEGIN'
                        || CHR (10)
                        || ' SYS.DBMS_STATS.GATHER_TABLE_STATS('''
                        || OBJLIST (I).OWNNAME
                        || ''','''
                        || OBJLIST (I).OBJNAME
                        || ''','''
                        || OBJLIST (I).PARTNAME
                        || ''',GRANULARITY => ''PARTITION'');'
                        || CHR (10)
                        || 'END;';
                        
                    dbms_output.put_line(SQL_TXT);

     --               SYS.DBMS_STATS.GATHER_TABLE_STATS (
       --                 OBJLIST (I).OWNNAME,
         --               OBJLIST (I).OBJNAME,
           --             OBJLIST (I).PARTNAME,
             --           GRANULARITY   => 'PARTITION');

                    --EXECUTE IMMEDIATE SQL_TXT;

       --             WORK_WITH_PARTITIONED_TABLES.LOG_WORK (
         --               V_PL_SQLINIT,
           --             REPLACE (SQL_TXT, CHR (10), ' '),
             --           3);
                    --COMMIT;
                END IF;
            END LOOP;
        ELSE
  --          WORK_WITH_PARTITIONED_TABLES.LOG_WORK (V_PL_SQLINIT,
    --                  'NO STALE STATS FOR SCHEMA ' || REC.OBJECT_OWNER,
      --                3);
      dbms_output.put_line('NO STALE STATS FOR SCHEMA ' || REC.OBJECT_OWNER);
            --COMMIT;
        END IF;
    END LOOP;
END;

--SQL Plan Directives (https://oracle-base.com/articles/12c/sql-plan-directives-12cr1)
--https://yasu-khan.github.io/SQL-Plan-Directives-(Part-2)

The optimizer use of SQL plan directives is controlled by the database initialization parameter
optimizer_adaptive_statistics, which has the default value of FALSE. This setting is recommended for most systems.

  SELECT TO_CHAR (D.DIRECTIVE_ID) DIR_ID,
         O.OWNER,
         O.OBJECT_NAME,
         O.SUBOBJECT_NAME       COL_NAME,
         O.OBJECT_TYPE,
         D.TYPE,
         D.STATE,
         D.REASON
    FROM DBA_SQL_PLAN_DIRECTIVES D, DBA_SQL_PLAN_DIR_OBJECTS O
   WHERE     D.DIRECTIVE_ID = O.DIRECTIVE_ID
         AND O.OWNER = 'CURR'
         AND O.OBJECT_NAME = 'TRADES_BASE'
ORDER BY 1,
         2,
         3,
         4,
         5;
         
select * from DBA_SQL_PLAN_DIRECTIVES order by created desc;
         
-- find WHICH directives as used by particular SQL:

explain plan for --below the SQL statement for which you need to find an information
select /*NORULE */'DATAPOINT@ ' bpb,                 
df.TABLESPACE_NAME,         sum(fs.PHYRDS),         sum(fs.PHYWRTS),    
     sum(fs.PHYBLKRD),         sum(fs.PHYBLKWRT)    from            
V$FILESTAT fs, DBA_DATA_FILES df,                 (SELECT DISTINCT 
(P.TABLESPACE_NAME) TABLESPACE_NAME                  FROM 
P$ETSM_CNTNREF P                  WHERE p.container_id = 2 ) K where    
       df.FILE_ID = fs.FILE# and   DF.TABLESPACE_NAME=K.TABLESPACE_NAME 
group by   df.TABLESPACE_NAME;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(null, null,'+metrics'));

--directives will be in the "Sql Plan Directive information" section

EXEC DBMS_SPD.DROP_SQL_PLAN_DIRECTIVE(10091005918999074784);

--lock SQL plan directive usage

exec DBMS_SPD.ALTER_SQL_PLAN_DIRECTIVE (11378594116199125643, 'ENABLED','NO');

--disable all (directive_id issue)

SET SERVEROUTPUT ON TERMOUT ON FEEDBACK ON TIMING ON

DECLARE
    V_DIR_ID   NUMBER;
BEGIN
    DBMS_OUTPUT.ENABLE;

    FOR REC IN (SELECT DIRECTIVE_ID FROM DBA_SQL_PLAN_DIRECTIVES)
    LOOP
        V_DIR_ID := REC.DIRECTIVE_ID;
        DBMS_SPD.ALTER_SQL_PLAN_DIRECTIVE (V_DIR_ID, 'ENABLED', 'NO');
        DBMS_OUTPUT.PUT_LINE ('directive ' || V_DIR_ID || ' disabled');
    END LOOP;
END;
/

--Repairing SQL Performance Regression with SQL Plan Management (rdbms version >=18c)
--https://blogs.oracle.com/optimizer/repairing-sql-performance-regression-with-sql-plan-management
-- ?? Exadata only
--Database 12c Release 2 includes the parameter settings used above but the task will sometimes fail with ORA-01422 due to bug number 29539794

BEGIN 
   --
   -- Create a SQL plan baseline for the problem query plan
   -- (in this case assuming that it is in the cursor cache)
   -- 
   n := dbms_spm.load_plans_from_cursor_cache(
                  sql_id => '<problem_SQL_ID>', 
                  plan_hash_value=> <problem_plan_hash_value>, 
                  enabled => 'no');
   --
   -- Set up evolve
   --
   tname := DBMS_SPM.CREATE_EVOLVE_TASK(sql_handle=>handle); 

   DBMS_SPM.SET_EVOLVE_TASK_PARAMETER( 
      task_name => tname,
      parameter => 'ALTERNATE_PLAN_BASELINE', 
      value     => 'EXISTING');

   DBMS_SPM.SET_EVOLVE_TASK_PARAMETER( 
      task_name => tname,
      parameter => 'ALTERNATE_PLAN_SOURCE', 
      value     => 'CURSOR_CACHE+AUTOMATIC_WORKLOAD_REPOSITORY+SQL_TUNING_SET');

   DBMS_SPM.SET_EVOLVE_TASK_PARAMETER( 
      task_name => tname,
      parameter => 'ALTERNATE_PLAN_LIMIT', 
      value     => 'UNLIMITED');
   --
   -- Evolve
   --
   ename := DBMS_SPM.EXECUTE_EVOLVE_TASK(tname);
   --
   -- Optionally, choose to implement immediately
   --
   n := DBMS_SPM.IMPLEMENT_EVOLVE_TASK(tname);
END; 
/

--19c approach: https://blogs.oracle.com/optimizer/what-is-automatic-sql-plan-management-and-why-should-you-care
