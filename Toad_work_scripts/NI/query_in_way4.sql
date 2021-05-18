--Handle long running queries from way4manager in way4 prod DB (https://jira.network.ae/jira/browse/PRD-10098)

SELECT
    substr(message_name,instr(message_name,'=',1,1)+1,instr(message_name,';',1,2)-instr(message_name,'=',1,1)-1) sid,
    substr(message_name,instr(message_name,'=',1,4)+1,instr(message_name,';',1,5)-instr(message_name,'=',1,4)-1) sql_id,
    TO_CHAR(message_date, 'dd/mm/yyyy hh24:mi:ss') time
FROM
    process_log JOIN process_mess
    ON process_mess.process_log__oid = process_log.id
WHERE
    process_log.process_name = 'OPT_SESSION_MONITOR'
    AND process_mess.message_date > SYSDATE - 30 -- can be changed as per required
    AND process_mess.object_type = 'KILL_SESSION';

-- ControlM clone JOB duration analysis

select * from (
  SELECT JOB_MEM_NAME,
         case when ENDED_STATUS = '16' then 'SUCCESS' ELSE 'FAILURE' END JOB_STATUS,
         (END_TIME - START_TIME)*24*60*60 DURATION_SECONDS,
         START_TIME,
         END_TIME,
         APPLICATION,
         GROUP_NAME,
         ORDER_DATE
    FROM EMUSER.RUNINFO_HISTORY
   WHERE     SCHED_TABLE IN
                 ('NETWORK1_TZ2_W4_DAILY',
                  'PRD_WAY4ETL_DAILY',
                  'NETWORK1_TZ11_W4_DAILY')
                  AND START_TIME > ADD_MONTHS(sysdate,-1)
         AND JOB_MEM_NAME IN (SELECT JOB_NAME
                                FROM EMUSER.DEF_JOB
                               WHERE CYCLIC = '0')
                               and END_TIME > START_TIME
                               AND JOB_MEM_NAME not like '%_ETL%'
                               AND JOB_MEM_NAME not like 'EMSP_TZ11_CLN_START_SLEEP'
ORDER BY (END_TIME - START_TIME) desc)
 where JOB_MEM_NAME = ''
 ;
 
 EMSY_N1_DM_W4_SLEEP - ?


-- TALEND related sessions AWR info:

  SELECT count(1),MACHINE,PROGRAM,MODULE,ACTION
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     SAMPLE_TIME BETWEEN sysdate-2 and sysdate and MACHINE in ('TALNDFSB','WHOTALNDAPB01')
   group by MACHINE,PROGRAM,MODULE,ACTION 
ORDER BY 1 desc;

  SELECT count(1),MACHINE,PROGRAM,MODULE,ACTION
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     SAMPLE_TIME BETWEEN sysdate-2 and sysdate and MACHINE <> 'TALNDFSB' and upper(module) like 'TALEND%'
   group by MACHINE,PROGRAM,MODULE,ACTION 
ORDER BY 1 desc;

  SELECT MACHINE,ACTION,MODULE,substr(module,1,12) mod1
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     SAMPLE_TIME BETWEEN sysdate-2 and sysdate and MACHINE in ('TALNDFSB','WHOTALNDAPB01')
   group by MACHINE,MODULE,ACTION,substr(module,1,12)
 --  having module not like '%:%'
ORDER BY 1,2;

select distinct mod1 from (
  SELECT MACHINE,ACTION,MODULE,substr(module,1,12) mod1
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     SAMPLE_TIME BETWEEN sysdate-1 and sysdate and MACHINE in ('TALNDFSB','WHOTALNDAPB01')
   group by MACHINE,MODULE,ACTION,substr(module,1,12)
 --  having module not like '%:%'
ORDER BY 1,2);

-- Kill long running sessions from w4 manager users query (https://jira.network.ae/jira/browse/PRD-10098):

SELECT
    substr(message_name,instr(message_name,'=',1,1)+1,instr(message_name,';',1,2)-instr(message_name,'=',1,1)-1) sid,
    substr(message_name,instr(message_name,'=',1,4)+1,instr(message_name,';',1,5)-instr(message_name,'=',1,4)-1) sql_id,
    TO_CHAR(message_date, 'dd/mm/yyyy hh24:mi:ss') time
FROM
    process_log JOIN process_mess
    ON process_mess.process_log__oid = process_log.id
WHERE
    process_log.process_name = 'OPT_SESSION_MONITOR'
    AND process_mess.message_date > SYSDATE - 1 -- can be changed as per required
    AND process_mess.object_type = 'KILL_SESSION';

-- OSwatcher historical logs / traces analysis

--way4db PROD servers:

--run in bg:
cd /grid/OSwatcher/oswbb
nohup java -jar oswbba.jar -i /grid/OSwatcher/oswbb/output -b Feb 28 00:00:00 2021 -e Mar 02 11:30:00 2021 -s >> analysis_`date +%Y%m%d_%H%M%S`.log 2>&1 &
java -jar oswbba.jar -i /grid/OSwatcher/oswbb/output -b Feb 09 00:00:00 2021 -e Feb 16 10:00:00 2021 -s

-- dependencies for OWS objects (for patching, datapatch phase)

with o as
 (select /*+materialize*/
 distinct o.referenced_owner, o.referenced_name, o.referenced_type
 from dba_dependencies o
 where o.owner = 'OWS'
 and (o.referenced_owner = 'SYS' or o.referenced_owner = 'PUBLIC')
 and o.referenced_type <> 'JAVA CLASS')
select o.referenced_owner, o.referenced_name, o.referenced_type
 from o
union
select distinct d.referenced_owner, d.referenced_name, d.referenced_type
 from dba_dependencies d, o
 start with d.owner = o.referenced_owner and d.name = o.referenced_name and
 d.type = o.referenced_type
connect by prior d.referenced_owner = d.owner AND
 PRIOR d.referenced_name = d.name AND
 PRIOR d.referenced_type = d.type
 order by referenced_type, referenced_name;
 
--recompiled sys objects while doing patching (see LAST_DDL_TIME value during datapatch execution)
 
   SELECT *
    FROM DBA_OBJECTS
   WHERE     OWNER = 'SYS'
         AND OBJECT_TYPE NOT IN ('JOB',
                                 'INDEX PARTITION',
                                 'TABLE PARTITION',
                                 'TABLE SUBPARTITION',
                                 'TABLE',
                                 'JAVA CLASS',
                                 'INDEX',
                                 'CLUSTER','LOB','SEQUENCE')and LAST_DDL_TIME >= add_months(sysdate,-9)
ORDER BY LAST_DDL_TIME DESC;

--ETL timings for each day from datamart. Everyday there will be 5 processes (on release days there could be one more).

select  round((finished-started)*24*60,2) as duration,to_char(started,'dd-mon-yyyy hh24:mi:ss'),to_char(finished,'dd-mon-yyyy hh24:mi:ss'),l.* 
from process_log l where process_name like '%Lock%' order by id desc;

-- datamart process log

select * from dwh.process_log where last_updated >= trunc(sysdate) and error_level is not null order by last_updated;

-- LONG running sessions monitoring:

  SELECT DISTINCT SQL_ID, MAX (EXEC_TIME)
    FROM DB_ADM_MON.WAY4MAN_LONG_RUNNING_MONITOR
GROUP BY SQL_ID
  HAVING MAX (EXEC_TIME) > INTERVAL '15' MINUTE
ORDER BY 2 DESC;

CREATE OR REPLACE FORCE VIEW DB_ADM_MON.V_WAY4MAN_LONG_RUNNING_KILL
(
    KILLPHRASE,
    SID,
    SERIAL#,
    MODULE,
    COST,
    SQL_ID,
    SQL_TEXT,
    TIME_REMAINING,
    MESSAGE
)
BEQUEATH DEFINER
AS
    SELECT    'alter system kill session '''
           || S.SID
           || ','
           || S.SERIAL#
           || ''' immediate'
               KILLPHRASE,
           S.SID,
           S.SERIAL#,
           S.MODULE,
           P.COST,
           Q.SQL_ID,
           Q.SQL_TEXT,
           L.TIME_REMAINING,
           L.MESSAGE
      FROM V$SESSION          S,
           V$SQL              Q,
           V$SQL_PLAN         P,
           V$SESSION_LONGOPS  L
     WHERE     S.STATUS = 'ACTIVE'
           AND S.TYPE = 'USER'
           AND S.SQL_ID = P.SQL_ID
           AND S.SQL_ID = Q.SQL_ID
           AND S.SQL_CHILD_NUMBER = P.CHILD_NUMBER
           AND S.SQL_CHILD_NUMBER = Q.CHILD_NUMBER
           AND S.SID = L.SID(+)
           AND S.SERIAL# = L.SERIAL#(+)
           AND (   (    (   L.TARGET IN ('ACNT_CONTRACT', 'CLIENT', 'DOC')
                         OR L.OPNAME = 'Hash Join')
                    AND P.ID = 0
                    AND L.TIME_REMAINING > 600
                    AND S.MODULE IN ('WAY4 Manager'))
                OR (    P.OPERATION = 'TABLE ACCESS'
                    AND P.OPTIONS = 'FULL'
                    AND P.OBJECT_OWNER = 'OWS'
                    AND P.OBJECT_NAME IN ('DOC', 'CREDIT_HISTORY')
                    AND S.MODULE IN ('WAY4 Manager')
                    AND NVL (S.ACTION, 'dummy') NOT LIKE 'HSK%')
                OR S.SQL_ID IN (SELECT DISTINCT SQL_ID
                                  FROM WAY4MAN_LONG_RUNNING_MONITOR
                                 WHERE SQL_ID IN ('9yz2hj3wgugvb') AND 1 = 0));

-- TALEND jobs with profiling:

select distinct module,action from V$ACTIVE_SESSION_HISTORY WHERE upper(module) like '%TALEND%' order by 1; 

--Monitoring Process Log of Scheduler Sub-Jobs compared to previous execution
--Example: 1month data, comparison of last 3 log

--For once a day job, this will give you last 3 days of log vs last 1 month of log (excluding the first 3 days). 
--For jobs executed multiple times a day, this will be the number of execution of that job and not the number of days! 

WITH
    MONTH_LOGS
    AS
        (SELECT J.CODE,
                J.NAME,
                C.STARTED,
                C.CLOSED,
                (C.CLOSED - C.STARTED) * (60 * 60 * 24)
                    SECONDS,
                TRUNC (STARTED)
                    START_DATE,
                DENSE_RANK ()
                    OVER (PARTITION BY J.CODE ORDER BY C.STARTED DESC)
                    RANK
           FROM OWS.SCH_JOB_CALL C, OWS.SCH_JOB M, OWS.SCH_JOB J
          WHERE     C.SCH_JOB__OID = J.ID
                AND J.MASTER_JOB = M.ID
                AND M.NAME = 'SEMF(Scoring engine master file) Export' -- <Name of Master Job>
                AND M.AMND_STATE = 'A'
                AND J.AMND_STATE = 'A'
                AND C.HAS_CLOSED = 'C'
                AND J.STATUS <> 'N'
                AND STARTED > SYSDATE - 31) -- <Number of days for collecting the data for comparison>
  SELECT LAST_LOG.CODE,
         LAST_LOG.NAME,
         ROUND (AVG (LAST_LOG.SECONDS))
             LAST_DURATION,
         ROUND (AVG (OTHER_LOG.SECONDS))
             AVERAGE_DURATION,
         ROUND (
               (AVG (LAST_LOG.SECONDS) / GREATEST (AVG (OTHER_LOG.SECONDS), 1))
             * 100)
             DIFF_DURATION_PCNT
    FROM MONTH_LOGS LAST_LOG, MONTH_LOGS OTHER_LOG
   WHERE     LAST_LOG.RANK <= 3 -- <Number of execution starting from which we want to compare. e.g. 3 means we will compare the last 3 execution of logs with all the logs older than those 3 execution>
         AND OTHER_LOG.RANK > 3 -- <Number of execution after which we will start to use for baseline (average)>
         AND LAST_LOG.CODE = OTHER_LOG.CODE
GROUP BY LAST_LOG.CODE, LAST_LOG.NAME;

-- datamart issues

TALEND (sqlid different)

SELECT INS.CODE AS ORG, INS.NAME AS ORG_NAME, substr(PRD.CODE,1,3) AS PRD, PRD.NAME AS PRD_NAME, CON.PERSONAL_ACCOUNT AS ACCT, CL.FIRST_NAME AS SHORT_NAME, NVL(CNL.AMOUNT,0) AS CR_LIM, CON.DATE_OPEN



-- Script to generate SOD statistics

  SELECT REPLACE (
             REPLACE (
                 CASE PROCESS_NAME
                     WHEN 'Contr Daily Update2 for Time Zone 0'
                     THEN
                         'Contr Daily Update Evening for Time Zone 0'
                     WHEN 'Contr Daily Update2 for Time Zone 2'
                     THEN
                         'Contr Daily Update Evening for Time Zone 2'
                     ELSE
                         PROCESS_NAME
                 END,
                 'Contr Daily Update',
                 'CDU'),
             'Time Zone ',
             'TZ')
             "PROCESS_NAME",
         STARTED
             "DATE_STARTED_FULL",
         FINISHED
             "DATE_FINISHED_FULL",
         TO_CHAR (STARTED, 'yyyy-mm')
             "DATE_STARTED",
         TO_CHAR (STARTED, 'dd')
             "DAY",
         (FINISHED - STARTED)
             "TOTAL_ELAPSED",
         (FINISHED - STARTED) * 24 * 60 * 60
             "TOTAL_ELAPSED_SEC",
         (FINISHED - STARTED) * 24 * 60
             "TOTAL_ELAPSED_MIN",
         (NUMBER_OF)
             "TOTAL_REC",
         ROUND (NUMBER_OF / ((FINISHED - STARTED) * 24 * 60 * 60), 2)
             "RPS"
    FROM OWS.PROCESS_LOG
   WHERE     PROCESS_NAME IN ('Contr Daily Update2 for Time Zone 0',
                              '---Contr Daily Update2 for Time Zone 2',
                              'Contr Daily Update Evening for Time Zone 0',
                              '---Contr Daily Update Evening for Time Zone 2',
                              'Contr Daily Update for Time Zone 0',
                              '---Contr Daily Update for Time Zone 2')
         AND STARTED > CURRENT_DATE - 200
         AND NUMBER_OF > 10
         AND (   PROCESS_NAME <> 'Contr Daily Update for Time Zone 0'
              OR (    PROCESS_NAME = 'Contr Daily Update for Time Zone 0'
                  AND NUMBER_OF > 941127))
         AND (   PROCESS_NAME <> 'Contr Daily Update2 for Time Zone 0'
              OR (    PROCESS_NAME = 'Contr Daily Update2 for Time Zone 0'
                  AND NUMBER_OF > 941127))
         AND (   PROCESS_NAME <> 'Contr Daily Update Evening for Time Zone 0'
              OR (    PROCESS_NAME =
                      'Contr Daily Update Evening for Time Zone 0'
                  AND NUMBER_OF > 941127))
         AND (   PROCESS_NAME <> 'Contr Daily Update for Time Zone 2'
              OR (    PROCESS_NAME = 'Contr Daily Update for Time Zone 2'
                  AND NUMBER_OF > 13000
                  AND NUMBER_OF < 29000))
         AND (   PROCESS_NAME <> 'Contr Daily Update2 for Time Zone 2'
              OR (    PROCESS_NAME = 'Contr Daily Update2 for Time Zone 2'
                  AND PARAMETERS LIKE '%ocd.acnt_contract__id%'))
         AND (   PROCESS_NAME <> 'Contr Daily Update Evening for Time Zone 2'
              OR (    PROCESS_NAME =
                      'Contr Daily Update Evening for Time Zone 2'
                  AND PARAMETERS LIKE '%ocd.acnt_contract__id%'))
ORDER BY 2 DESC, 1;

-- INDEXES

select * from dba_ind_columns where column_name IN ('AMND_DATE','TRANS_DATE') and TABLE_NAME = 'DOC' order by 2,5;
select * from dba_indexes where index_name in (select index_name from dba_ind_columns where column_name IN ('AMND_DATE','TRANS_DATE') and TABLE_NAME = 'DOC');

select * from ows.doc where AMND_DATE between sysdate -60 and sysdate;

-- COMPARE periods for CDU

SELECT OUTPUT
  FROM TABLE (DBMS_WORKLOAD_REPOSITORY.AWR_DIFF_REPORT_HTML (
                  DBID1       => (select dbid from v$database),
                  INST_NUM1   => (select INSTANCE_NUMBER from v$instance),
                  BID1        => (select min(snap_id) from (
select snap_id,instance_number,begin_interval_time,end_interval_time from dba_hist_snapshot 
where INSTANCE_NUMBER = (select INSTANCE_NUMBER from v$instance)
and begin_interval_time between 
to_date('15/10/2018 00:30:00','dd/mm/yyyy hh24:mi:ss') and to_date('15/10/2018 00:50:00','dd/mm/yyyy hh24:mi:ss')
order by BEGIN_INTERVAL_TIME)),
                  EID1        => (select max(snap_id) from (
select snap_id,instance_number,begin_interval_time,end_interval_time from dba_hist_snapshot 
where INSTANCE_NUMBER = (select INSTANCE_NUMBER from v$instance)
and begin_interval_time between 
to_date('15/10/2018 00:30:00','dd/mm/yyyy hh24:mi:ss') and to_date('15/10/2018 00:50:00','dd/mm/yyyy hh24:mi:ss')
order by BEGIN_INTERVAL_TIME)),
                  DBID2       => (select dbid from v$database),
                  INST_NUM2   => (select INSTANCE_NUMBER from v$instance),
                  BID2        => (select min(snap_id) from (
select snap_id,instance_number,begin_interval_time,end_interval_time from dba_hist_snapshot 
where INSTANCE_NUMBER = (select INSTANCE_NUMBER from v$instance)
and begin_interval_time between 
to_date('15/11/2018 00:30:00','dd/mm/yyyy hh24:mi:ss') and to_date('15/11/2018 00:50:00','dd/mm/yyyy hh24:mi:ss')
order by BEGIN_INTERVAL_TIME)),
                  EID2  =>  (select max(snap_id) from (
select snap_id,instance_number,begin_interval_time,end_interval_time from dba_hist_snapshot 
where INSTANCE_NUMBER = (select INSTANCE_NUMBER from v$instance)
and begin_interval_time between 
to_date('15/11/2018 00:30:00','dd/mm/yyyy hh24:mi:ss') and to_date('15/11/2018 00:50:00','dd/mm/yyyy hh24:mi:ss')
order by BEGIN_INTERVAL_TIME))));

-- ASH report for problem period

select output from table (DBMS_WORKLOAD_REPOSITORY.ash_report_html(
l_dbid=>(select dbid from v$database),
l_inst_num=>(select INSTANCE_NUMBER from v$instance),
l_btime=>TO_DATE ('19.11.2018 10:06:00', 'dd.mm.yyyy hh24:mi:ss'),
l_etime=>TO_DATE ('19.11.2018 10:12:00', 'dd.mm.yyyy hh24:mi:ss'),
l_slot_width=>10));

-- locking ROWIDs

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


-- privileges in DB


SELECT
    DISTINCT GRANTEE AS GRANTED_ON, OWNER, TABLE_NAME, PRIVILEGE
FROM
    dba_tab_privs
WHERE
    owner = 'OWS'
    AND upper(table_name) IN (
        'CONTR_STATUS',
        'F_I',
        'CLIENT_ADDRESS',
        'ADDRESS_TYPE',
        'LANG'
    )
    AND ( grantee = ( 'OWS_READ' )
          OR grantee IN (
        SELECT
            granted_role
        FROM
            dba_role_privs
        WHERE
            grantee = 'OWS_READ'
    ) );
    
SELECT *
  FROM V$ACTIVE_SESSION_HISTORY
 WHERE     --SAMPLE_TIME >= TRUNC (SYSDATE - 30 / 24 / 60)
       --AND 
       EVENT LIKE '%lock contention%'
       AND BLOCKING_SESSION IS NOT NULL;
       
select * from V$SESSION_EVENT;
select * from V$EVENT_NAME where WAIT_CLASS in ('A');
select distinct WAIT_CLASS,DISPLAY_NAME from V$EVENT_NAME order by 1,2;

-- queries for select in the process log of way4

select main_process_id,
       main_process_date,
       p.process_name,
       p.fullname,
       TO_CHAR(p.started, 'dd.mm.yyyy HH24:MI:SS') started,
       TO_CHAR(p.finished, 'dd.mm.yyyy HH24:MI:SS') finished,
       p.status,
       p.id,
       p.number_of,
       p.current_number,
       TO_CHAR(p.last_updated, 'dd.mm.yyyy HH24:MI:SS') last_updated,
       TO_CHAR(sysdate, 'dd.mm.yyyy HH24:MI:SS') sys_date,
       round(duration,2) duration,
       round(avg(duration) over (partition by p.process_name),2) avg_duration,
       round(min(duration) over (partition by p.process_name),2) min_duration,
       round(max(duration) over (partition by p.process_name),2) max_duration,
       round(duration - avg(duration) over (partition by p.process_name),2) dev_duration,
       round(avg(number_of) over (partition by p.process_name),2) avg_number_of,
       round(min(number_of) over (partition by p.process_name),2) min_number_of,
       round(max(number_of) over (partition by p.process_name),2) max_number_of,
       round(number_of - avg(number_of) over (partition by p.process_name),2) dev_number_of,
       min(started) over (partition by p.process_name) first_started
  from (select level l,
               CONNECT_BY_ROOT pl.id main_process_id,
               CONNECT_BY_ROOT trunc(pl.started) main_process_date,
               SYS_CONNECT_BY_PATH(pl.process_name, '/') fullname,
               (nvl(pl.finished, sysdate) - pl.started) * 24 * 60 duration,
               pl.*
          from (Select * from process_log where last_updated > sysdate - 1) pl
          start with process_name in ('Lock Loading DWH','Incremental Load: Bank (local) date closing',' Incremental Load All Financial Institute Auth')
        connect by prior id = process_log__oid) p
 order by p.id;

select p.process_name,p.fullname,p.status,p.id PL_ID,
       TO_CHAR(p.started, 'dd.mm.yyyy HH24:MI:SS') started, TO_CHAR(p.finished, 'dd.mm.yyyy HH24:MI:SS') finished, p.number_of,p.current_number, 
       TO_CHAR(p.last_updated, 'dd.mm.yyyy HH24:MI:SS') last_updated,
       TO_CHAR(sysdate, 'dd.mm.yyyy HH24:MI:SS') sys_date,(nvl(p.finished,sysdate) - p.started)*24*60 running_min,pm.message_type,
       TO_CHAR(pm.message_date, 'dd.mm.yyyy HH24:MI:SS') message_date,pm.message_name, pm.id pm_id,
       (pm.message_date - LAG(pm.message_date) OVER (ORDER BY pm.id))*24*60 message_minutes
  from (select level l,SYS_CONNECT_BY_PATH(pl.process_name,'/') fullname, pl.*
          from (Select * from process_log where last_updated > sysdate - 1) pl /*put problematic date here*/
          start with process_name in ('Lock Loading DWH','Incremental Load: Bank (local) date closing',' Incremental Load All Financial Institute Auth')
        connect by prior id = process_log__oid) p,
        process_mess pm
  where pm.process_log__oid = p.id
  order by p.id,pm.id;
  
-- see particular process

select * from process_log where process_name = 'Incremental Load: Bank (local) date closing' and started >= sysdate - 5;

-- find SID,serial for way4 processes (way4db, datamart - !!!)

select * from ows.process_log where process_name like '%Manager%' 
and last_updated >= trunc(sysdate-1) and started_by is not null order by id; --STARTED_BY = officer

select * from officer where id = 15129; --USER_ID = login_schema

select * from ows.process_log where id = 602816;
select * from ows.process_log where id = 602534;     
select * from ows.process_log where id = 602531; --no PROCESS_LOG__OID for main parent process (if PROCESS_LOG__OID is not null, check parent process)

select * from ows.sy_proc_aux where PROCESS_LOG__OID = 89987840; --SID,serial ID from process_log, total time MIN(ATTACHED) - MAX(DETACHED) for all jobs

select * from login_history where ID = 212879200; --SID,serial for DB manager/Way4manager process, use LOGIN_HISTORY__ID from process_log

--more detailed view

select * from process_log where process_log__oid = 565056;

-- SCH_ADMIN job document posting
-- Service: way4_back  >   Module: Parallel Running  >   Action: Accept Documents.thread 9/41[FIL

DECLARE job BINARY_INTEGER := :job; next_date TIMESTAMP WITH TIME ZONE := :mydate; broken BOOLEAN := FALSE; job_name VARCHAR2(30) := :job_name; job_subname VARCHAR2(30) := :job_subname; job_owner VARCHAR2(30) := :job_owner; job_start TIMESTAMP WITH TIME ZONE := :job_start; job_scheduled_start TIMESTAMP WITH TIME ZONE := :job_scheduled_start; window_start TIMESTAMP WITH TIME ZONE := :window_start; window_end TIMESTAMP WITH TIME ZONE := :window_end; chain_id VARCHAR2(14) := :chainid; credential_owner varchar2(30) := :credown; credential_name varchar2(30) := :crednam; destination_owner varchar2(30) := :destown; destination_name varchar2(30) := :destnam; job_dest_id varchar2(14) := :jdestid; log_id number := :log_id; BEGIN declare ProcessId constant dtype. RecordId%type := 73114140; SessionId constant dtype. RecordId%type := 193576010; SessionRole constant dtype. Name%type := 'thread 9/41'; begin begin 
if 
sy_cycle.START_LOOP1 (73114140, 193576010, 'thread 9/41', 9, 0 ) = stnd.Yes 
then 
loop sy_cycle.START_LOOP2; 
begin 
declare 
lcr local_constants %rowtype; 
RecId dtype. RecordId %type; 
begin 
YGLOCAL_CONSTANTS (stnd.ConnectionId, lcr); 
for r in ( 
select doc.id + 0 id /*HASH_VALUE*/ 
from doc 
where (posting_status = 'W' and amnd_state = 'A' and ( doc.amnd_date <= to_date('2019-01-15 17:42:45', 'yyyy-mm-dd hh24:mi:ss') )) 
and mod (coalesce(/*PRD-1563*/case when trim(doc.source_code) in ('124020000R', '124020001R', '124020012R', '2515', '2717', '2719') then 0 else null end, ora_hash(doc.target_number, 65535), dbms_rowid.ROWID_BLOCK_NUMBER(doc.rowid)), sy_cycle.CycleNJobs) = sy_cycle.CycleJobN 
and doc.id-1 >= sy_cycle.CycleLastID 
/*MAXNUMBER*/ 

order by 1 
) loop 
RecId := r.id; 
loop 
sy_cycle.BEFORE_PROCESS_ID (RecId); 
begin scdp.ACCEPT_DOC1 (RecId); 
sy_cycle.MARK_ID_PROCESSED (RecID); 
exception 
when others then 
sy_cycle.PROCESS_EXC2 (RecId, sqlcode, sqlerrm); 
end; 
exit when sy_cycle.CycleExcLevel > sy_cycle.ExcLevelSkipThisId; 
sy_cycle.RETRIEVE_BUFFERED_ID (RecId); 
exit when RecId is null; 
end loop; 
exit when sy_cycle.CycleExcLevel >= sy_cycle.ExcLevelReopenSel; 
end loop; 
sy_cycle.MARK_ID_PROCESSED (null); 
end; 
exception 
when others then 
sy_cycle.PROCESS_EXC1 (sqlcode, sqlerrm, null); 
end; 
exit when sy_cycle.IS_TO_EXIT1 = stnd.Yes; 
end loop; 
sy_cycle.FINISH_LOOP2; 
sy_cycle.FINISH_LOOP1; 
end if; 
exception 
when others then 
sy_dbscd.PROCESS_THREAD_EXCEPTION (stnd.No); 
end; end; :mydate := next_date; IF broken THEN :b := 1; ELSE :b := 0; END IF; END; 

-- MONITORING MASKING status inside database

  SELECT PROCESS_NAME,
         STARTED,
         FINISHED,
         ROUND (
               (  CURRENT_NUMBER
                / CASE
                      WHEN NUMBER_OF = 0
                      THEN
                          CASE
                              WHEN CURRENT_NUMBER = 0 THEN 1
                              ELSE CURRENT_NUMBER * 100
                          END
                      ELSE
                          NUMBER_OF
                  END)
             * 100)    AS PERCENT_COMPLETED,
         NUMBER_OF,
         CURRENT_NUMBER,
         LAST_UPDATED
    FROM OWS.PROCESS_LOG
   WHERE STARTED >= TRUNC (SYSDATE)
ORDER BY STARTED DESC;

-- standart checksum problem select 1

WITH
    PART1
    AS
        (SELECT /*+ MATERIALIZE */
                'objGrantee'     LNAME,
                GRANTEE,
                TABLE_NAME,
                GRANTABLE,
                PRIVILEGE,
                OWNER,
                USER
           FROM DBA_TAB_PRIVS
          WHERE    GRANTEE IN ('OWSRADM',
                               'OWSRADMS',
                               'OWSRCLES',
                               'OWSROWN',
                               'OWSRSADM',
                               'OWSRSEL',
                               'OWSRVIEW',
                               'OWSRCOMS',
                               'OWSRNETS',
                               'OWSRSSADM',
                               'OWSRCNT',
                               'OWSRRES',
                               'OWSRW4RA',
                               'OWSRAPP',
                               'OWSRW4R')
                OR GRANTEE = USER),
    PART2
    AS
        (SELECT 'ROLEGRANTEE'
                    LNAME,
                GRANTEE,
                   'ROLE='
                || DECODE (
                       INSTR (GRANTED_ROLE, UPPER ('OWS')),
                       1,    '{OWS_OWNER}'
                          || SUBSTR (GRANTED_ROLE,
                                     LENGTH (UPPER ('OWS')) + 1),
                       GRANTED_ROLE)
                || DECODE (ADMIN_OPTION, 'YES', '; ADMIN=Y', NULL)
                || CASE
                       WHEN GRANTEE = USER AND DEFAULT_ROLE = 'YES'
                       THEN
                           '; DEFAULT=Y'
                   END
                    PRIVILEGE
           FROM DBA_ROLE_PRIVS
          WHERE     GRANTED_ROLE IN ('OWSRADM',
                                     'OWSRADMS',
                                     'OWSRCLES',
                                     'OWSROWN',
                                     'OWSRSADM',
                                     'OWSRSEL',
                                     'OWSRVIEW',
                                     'OWSRCOMS',
                                     'OWSRNETS',
                                     'OWSRSSADM',
                                     'OWSRCNT',
                                     'OWSRRES',
                                     'OWSRW4RA',
                                     'OWSRAPP',
                                     'OWSRW4R')
                AND (   GRANTEE IN ('OWSRADM',
                                    'OWSRADMS',
                                    'OWSRCLES',
                                    'OWSROWN',
                                    'OWSRSADM',
                                    'OWSRSEL',
                                    'OWSRVIEW',
                                    'OWSRCOMS',
                                    'OWSRNETS',
                                    'OWSRSSADM',
                                    'OWSRCNT',
                                    'OWSRRES',
                                    'OWSRW4RA',
                                    'OWSRAPP',
                                    'OWSRW4R')
                     OR GRANTEE IN ('SYS', USER))
         UNION ALL
         SELECT 'SYSGRANTEE',
                GRANTEE,
                   'SYSPRIV='
                || PRIVILEGE
                || DECODE (ADMIN_OPTION, 'YES', '; ADMIN=Y', NULL)
           FROM DBA_SYS_PRIVS
          WHERE     (   GRANTEE IN ('OWSRADM',
                                    'OWSRADMS',
                                    'OWSRCLES',
                                    'OWSROWN',
                                    'OWSRSADM',
                                    'OWSRSEL',
                                    'OWSRVIEW',
                                    'OWSRCOMS',
                                    'OWSRNETS',
                                    'OWSRSSADM',
                                    'OWSRCNT',
                                    'OWSRRES',
                                    'OWSRW4RA',
                                    'OWSRAPP',
                                    'OWSRW4R')
                     OR GRANTEE IN (USER))
                AND PRIVILEGE NOT IN
                        ('SELECT ANY DICTIONARY',
                         'ADMINISTER RESOURCE MANAGER',
                         'CREATE USER')
         UNION ALL
         SELECT 'JAVAGRANTEE',
                P.GRANTEE,
                   DECODE (P.KIND, 'GRANT', 'JPRIV=', 'JREST=')
                || '('
                || P.TYPE_SCHEMA
                || ':'
                || P.TYPE_NAME
                || ')'
                || P.NAME
                || '; '
                || P.ACTION
                || DECODE (P.ENABLED,
                           'ENABLED', NULL,
                           '; ENBL=' || LOWER (P.ENABLED))
           FROM DBA_JAVA_POLICY P
          WHERE P.GRANTEE = USER)
  SELECT    LNAME
         || '='
         || DECODE (GRANTEE,
                    'SYS', 'SYS',
                    USER, 'MAIN_USER',
                    SUBSTR (GRANTEE, LENGTH (UPPER ('OWS')) + 1))
             GRANTEE,
         PRIVILEGE
    FROM (SELECT DISTINCT
                 LNAME,
                 GRANTEE,
                    'priv='
                 || PRIVILEGE
                 || ' '
                 || DECODE (
                        OWNER,
                        'SYS',    'SYS.'
                               || DECODE (
                                      INSTR (TABLE_NAME, USER),
                                      1,    '{OWS_OWNER}'
                                         || SUBSTR (TABLE_NAME,
                                                    LENGTH (USER) + 1),
                                      TABLE_NAME),
                        DECODE (OWNER, USER, '', OWNER || '.') || TABLE_NAME)
                 || DECODE (GRANTABLE, 'YES', '; GRANT=Y', NULL)
                     PRIVILEGE
            FROM PART1
           WHERE     PART1.TABLE_NAME NOT LIKE 'AUX#_%' ESCAPE '#'
                 AND NOT REGEXP_LIKE (PART1.TABLE_NAME, '^\w{2,3}__')
                 AND PART1.OWNER IN (USER, 'SYS')
                 AND SUBSTR (PART1.TABLE_NAME, 1, 4) NOT IN ('OLD_',
                                                             'TMP_',
                                                             'OPT_',
                                                             'BIN$',
                                                             'INT_')
                 AND PART1.TABLE_NAME NOT LIKE '%$OPT#_%' ESCAPE '#'
                 AND PART1.TABLE_NAME NOT LIKE 'V#_C$%' ESCAPE '#'
                 AND PART1.TABLE_NAME NOT LIKE '__#_#_%' ESCAPE '#'
                 AND PART1.TABLE_NAME NOT LIKE '___#_#_%' ESCAPE '#'
                 AND PART1.TABLE_NAME NOT IN ('DBMS_RESOURCE_MANAGER',
                                              'DBMS_RESOURCE_MANAGER_PRIVS',
                                              'DBMS_REPCAT_INTERNAL_PACKAGE',
                                              'OWS_ADMINISTER_USER')
                 AND PART1.TABLE_NAME NOT LIKE 'QT%BUFFER'
          UNION ALL
          SELECT * FROM PART2)
ORDER BY 1, 2;
