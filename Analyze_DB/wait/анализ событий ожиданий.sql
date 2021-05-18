Метрика загрузки БД (высокая нагрузка, если > 95%)

select  METRIC_NAME,
        VALUE
from    SYS.V_$SYSMETRIC
where   METRIC_NAME IN ('Database CPU Time Ratio',
                        'Database Wait Time Ratio') AND
        INTSIZE_CSEC = 
        (select max(INTSIZE_CSEC) from SYS.V_$SYSMETRIC);

История % загрузки процессора за последний час
		
		
select  end_time,
        value
from    sys.v_$sysmetric_history
where   metric_name = 'Database CPU Time Ratio'
order by 1;

Общие метрики загрузки

  SELECT CASE METRIC_NAME
            WHEN 'SQL Service Response Time'
            THEN
               'SQL Service Response Time (secs)'
            WHEN 'Response Time Per Txn'
            THEN
               'Response Time Per Txn (secs)'
            ELSE
               METRIC_NAME
         END
            METRIC_NAME,
         CASE METRIC_NAME
            WHEN 'SQL Service Response Time' THEN ROUND ( (MINVAL / 100), 2)
            WHEN 'Response Time Per Txn' THEN ROUND ( (MINVAL / 100), 2)
            ELSE MINVAL
         END
            MININUM,
         CASE METRIC_NAME
            WHEN 'SQL Service Response Time' THEN ROUND ( (MAXVAL / 100), 2)
            WHEN 'Response Time Per Txn' THEN ROUND ( (MAXVAL / 100), 2)
            ELSE MAXVAL
         END
            MAXIMUM,
         CASE METRIC_NAME
            WHEN 'SQL Service Response Time' THEN ROUND ( (AVERAGE / 100), 2)
            WHEN 'Response Time Per Txn' THEN ROUND ( (AVERAGE / 100), 2)
            ELSE AVERAGE
         END
            AVERAGE
    FROM SYS.V_$SYSMETRIC_SUMMARY
   WHERE METRIC_NAME IN
            ('CPU Usage Per Sec',
             'CPU Usage Per Txn',
             'Database CPU Time Ratio',
             'Database Wait Time Ratio',
             'Executions Per Sec',
             'Executions Per Txn',
             'Response Time Per Txn',
             'SQL Service Response Time',
             'User Transaction Per Sec')
ORDER BY 1;

Анализ активности БД

select  case db_stat_name
            when 'parse time elapsed' then 
                'soft parse time'
            else db_stat_name
            end db_stat_name,
        case db_stat_name
            when 'sql execute elapsed time' then 
                time_secs - plsql_time 
            when 'parse time elapsed' then 
                time_secs - hard_parse_time
            else time_secs
            end time_secs,
        case db_stat_name
            when 'sql execute elapsed time' then 
                round(100 * (time_secs - plsql_time) / db_time,2)
            when 'parse time elapsed' then 
                round(100 * (time_secs - hard_parse_time) / db_time,2)  
            else round(100 * time_secs / db_time,2)  
            end pct_time
from
(select stat_name db_stat_name,
        round((value / 1000000),3) time_secs
    from sys.v_$sys_time_model
    where stat_name not in('DB time','background elapsed time',
                            'background cpu time','DB CPU')),
(select round((value / 1000000),3) db_time 
    from sys.v_$sys_time_model 
    where stat_name = 'DB time'),
(select round((value / 1000000),3) plsql_time 
    from sys.v_$sys_time_model 
    where stat_name = 'PL/SQL execution elapsed time'),
(select round((value / 1000000),3) hard_parse_time 
    from sys.v_$sys_time_model 
    where stat_name = 'hard parse elapsed time')
order by 2 desc;

Анализ классов ожиданий

select  WAIT_CLASS,
        TOTAL_WAITS,
        round(100 * (TOTAL_WAITS / SUM_WAITS),2) PCT_WAITS,
        ROUND((TIME_WAITED / 100),2) TIME_WAITED_SECS,
        round(100 * (TIME_WAITED / SUM_TIME),2) PCT_TIME
from
(select WAIT_CLASS,
        TOTAL_WAITS,
        TIME_WAITED
from    V$SYSTEM_WAIT_CLASS
where   WAIT_CLASS != 'Idle'),
(select  sum(TOTAL_WAITS) SUM_WAITS,
        sum(TIME_WAITED) SUM_TIME
from    V$SYSTEM_WAIT_CLASS
where   WAIT_CLASS != 'Idle')
order by 5 desc;

Анализ событий ожиданий за последний час

  SELECT TO_CHAR (a.end_time, 'DD-MON-YYYY HH:MI:SS') end_time,
         b.wait_class,
         ROUND ( (a.time_waited / 100), 2) time_waited
    FROM sys.v_$waitclassmetric_history a, sys.v_$system_wait_class b
   WHERE a.wait_class# = b.wait_class# AND b.wait_class != 'Idle'
ORDER BY 1, 2;

Анализ событий ожиданий с группировкой по пользователям

  SELECT a.sid,
         b.username,
         a.wait_class,
         a.total_waits,
         ROUND ( (a.time_waited / 100), 2) time_waited_secs
    FROM sys.v_$session_wait_class a, sys.v_$session b
   WHERE b.sid = a.sid AND b.username IS NOT NULL AND a.wait_class != 'Idle'
ORDER BY 5 desc;

Анализ активности сессий за период времени (последние 2 часа)

column WAIT_EVENT format a30
column program format a30
column pct_time_waited format 999,999,999

  SELECT sess_id,
         username,
         program,
         wait_event,
         sess_time,
         ROUND (100 * (sess_time / total_time), 2) pct_time_waited
    FROM (  SELECT a.session_id sess_id,
                   DECODE (session_type, 'background', session_type, c.username)
                      username,
                   a.program program,
                   b.name wait_event,
                   SUM (a.time_waited) sess_time
              FROM sys.v_$active_session_history a,
                   sys.v_$event_name b,
                   sys.dba_users c
             WHERE     a.event# = b.event#
                   AND a.user_id = c.user_id
                 AND sample_time > sysdate-2/24
                 AND sample_time < sysdate
                   AND b.wait_class = 'User I/O'
          GROUP BY a.session_id,
                   DECODE (session_type,
                           'background', session_type,
                           c.username),
                   a.program,
                   b.name),
         (SELECT SUM (a.time_waited) total_time
            FROM sys.v_$active_session_history a, sys.v_$event_name b
           WHERE     a.event# = b.event#
                 AND sample_time > sysdate-2/24
                 AND sample_time < sysdate
                 AND b.wait_class = 'User I/O')
ORDER BY 6 DESC;

--Топ 5 SQL запросов с самым высоким временем ожидания

select *
from
(select sql_text,
        sql_id,
        elapsed_time,
        cpu_time,
        user_io_wait_time
from    sys.v_$sqlarea
order by 5 desc)
where rownum < 6;

--Топ 5 SQL по DB_TIME

SELECT *
  FROM (  SELECT NVL (sql_id, 'NULL') AS sql_id, SUM (1) AS DBtime_secs
            FROM v$active_session_history
           WHERE sample_time > SYSDATE - 5 / 1440
        GROUP BY sql_id
        ORDER BY 2 DESC)
 WHERE rownum < 6
 
--ASH_WAIT_TREE.SQL Очередь ожиданий из истории активных сессий по произвольному условию

--
-- ASH wait tree for Waits Event or SQL_ID
-- Usage: SQL> @ash_wait_tree.sql "event = 'log file sync'"
-- Igor Usoltsev
--
 
set echo off feedback off heading on timi off pages 1000 lines 500 VERIFY OFF
 
col WAIT_LEVEL for 999
col BLOCKING_TREE for a30
col EVENT for a64
col WAITS for 999999
col AVG_TIME_WAITED_MS for 999999
 
select LEVEL as WAIT_LEVEL,
       LPAD(' ', (LEVEL - 1) * 2) || decode(ash.session_type, 'BACKGROUND', REGEXP_SUBSTR(program, '\([^\)]+\)'), 'FOREGROUND') as BLOCKING_TREE,
       ash.EVENT,
       count(*) as WAITS_COUNT,
       round(avg(time_waited) / 1000) as AVG_TIME_WAITED_MS,
       round(sum(case when time_waited > 0 then greatest(1, (1000000 / time_waited)) else 0 end)) as est_waits, -- http://www.nocoug.org/download/2013-08/NOCOUG_201308_ASH_Architecture_and_Advanced%20Usage.pdf
       round(sum(1000) / round(sum(case when time_waited > 0 then greatest(1, (1000000 / time_waited)) else 1 end))) as est_avg_latency_ms
  from gv$active_session_history ash
 where session_state = 'WAITING'
 start with &&1 --event = nvl('&&1',event) and sql_id = nvl('&&2',sql_id)
connect by nocycle prior ash.SAMPLE_ID = ash.SAMPLE_ID
       and ash.SESSION_ID = prior ash.BLOCKING_SESSION
 group by LEVEL,
          LPAD(' ', (LEVEL - 1) * 2) || decode(ash.session_type, 'BACKGROUND', REGEXP_SUBSTR(program, '\([^\)]+\)'), 'FOREGROUND'),
          ash.EVENT
 order by LEVEL, count(*) desc
/
set feedback on echo off VERIFY ON
 
-- ASW.SQL Суммарные ожидания активных сессий

select RANK,
       WAIT_EVENT,
       lpad(TO_CHAR(PCTTOT, '990D99'), 6) || '% waits with avg.du =' ||
       TO_CHAR(AVERAGE_WAIT_MS, '9999990D99') || ' ms' as EVENT_VALUES
  from (select RANK() OVER(order by sum(time_waited) desc) as RANK,
               event as WAIT_EVENT,
               round(RATIO_TO_REPORT(sum(time_waited)) OVER() * 100, 2) AS PCTTOT,
               round(avg(average_wait) * 10, 2) as AVERAGE_WAIT_MS
          from (select se.SID,
                       se.INST_ID,
                       se.EVENT,
                       se.TIME_WAITED,
                       se.AVERAGE_WAIT
                  from gv$session_event se
                 where se.WAIT_CLASS not in ('Idle')
                union
                select ss.SID,
                       ss.INST_ID,
                       sn.NAME    as EVENT,
                       ss.VALUE   as TIME_WAITED,
                       0          as AVERAGE_WAIT
                  from gv$sesstat ss, v$statname sn
                 where ss."STATISTIC#" = sn."STATISTIC#"
                   and sn.NAME in ('CPU used when call started'))
         where (sid, inst_id) in
               (select sid, inst_id
                  from gv$session
                 where gv$session.SERVICE_NAME not in ('SYS$BACKGROUND'))
         group by event
         order by PCTTOT desc) we
 where RANK <= 10
/ 
 

--Анализ деталей (файл, объект, пользователь) конкретного запроса по SQL_ID

column event format a30
column OBJECT_NAME format a20
column owner format a15

select event,
        time_waited,
        owner,
        object_name,
        current_file#,
        current_block# 
from    sys.v_$active_session_history a,
        sys.dba_objects b 
where   sql_id = '5hdq8grgc9c9f' and
        a.current_obj# = b.object_id and
        time_waited <> 0 order by time_waited;
