-- ASH

SELECT count(distinct SESSION_ID),trunc(sample_time),SESSION_ID FROM DBA_HIST_ACTIVE_SESS_HISTORY where USER_ID = (SELECT USER_ID FROM DBA_USERS WHERE USERNAME = 'MDATA_MDDEV_HADOOP') group by trunc(sample_time),SESSION_ID order by 1 desc;
SELECT * FROM SESSION_INFO; --when v$session select fails with partial multibyte character error
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SQL_ID = 'aur2r27g3xt07' order by 1 desc;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SESSION_ID = 1200 and SESSION_SERIAL# = 7318 order by 1 desc;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SESSION_ID in (509,4082) order by SAMPLE_TIME;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE USER_ID  = 88 and SAMPLE_TIME between to_date('05122017 14:59:00','ddmmyyyy hh24:mi:ss') and to_date('05122017 15:00:00','ddmmyyyy hh24:mi:ss') order by SAMPLE_TIME;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SAMPLE_TIME between to_date('29122017 12:00:00','ddmmyyyy hh24:mi:ss') and to_date('29122017 12:01:00','ddmmyyyy hh24:mi:ss') and MODULE = 'INSERT_SE_ORD_TRD_ONLINE' order by SAMPLE_TIME;
-- поиск выполняемого запроса по плану выполнения
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SQL_PLAN_HASH_VALUE = 3894657618 order by 1;
SELECT * FROM V$SQL WHERE SQL_ID = '3cvmfuv9tn9vd';
SELECT * FROM V$SQL WHERE upper(SQL_TEXT) LIKE '%OPTCOMMON_BASE%';
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SESSION_ID = 4732 and SESSION_SERIAL# = 23143 and SAMPLE_TIME >= trunc(sysdate-1) order by SAMPLE_TIME;
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE UPPER(MODULE) LIKE '%INSERT_SE_ORD_TRD_ONLINE%' and SAMPLE_TIME >= trunc(sysdate-7) and MACHINE <> 'NT_D\CHISTOV15' order by SAMPLE_TIME;
SELECT COUNT(SQL_EXEC_ID),D_START FROM (SELECT DISTINCT SQL_EXEC_ID SQL_EXEC_ID,TRUNC(SQL_EXEC_START) D_START FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID = 'fu7p0q9y9wsgw') WHERE SQL_EXEC_ID IS NOT NULL GROUP BY D_START ORDER BY 1 DESC;
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SESSION_ID in (509,4082) and SAMPLE_TIME between to_date('26122017 04:00:00','ddmmyyyy hh24:mi:ss') and to_date('26122017 10:00:00','ddmmyyyy hh24:mi:ss') order by SAMPLE_TIME;
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME between to_date('28122017 11:17:25','ddmmyyyy hh24:mi:ss') and to_date('28122017 11:18:05','ddmmyyyy hh24:mi:ss') order by SAMPLE_TIME;
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME between to_date('29122017 12:00:00','ddmmyyyy hh24:mi:ss') and to_date('29122017 12:01:00','ddmmyyyy hh24:mi:ss') and MODULE = 'INSERT_SE_ORD_TRD_ONLINE' order by SAMPLE_TIME;
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID = 'fa31wtss9ag2g' and SAMPLE_TIME between to_date('28122017 00:00:00','ddmmyyyy hh24:mi:ss') and to_date('28122017 10:00:00','ddmmyyyy hh24:mi:ss') order by SAMPLE_TIME;
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID = 'fa31wtss9ag2g' and SAMPLE_TIME between to_date('22122017 04:00:00','ddmmyyyy hh24:mi:ss') and to_date('22122017 04:30:00','ddmmyyyy hh24:mi:ss') and USER_ID = 117 order by SAMPLE_TIME;
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME between 
to_date('06092017 06:00:00','ddmmyyyy hh24:mi:ss') and to_date('06092017 06:41:00','ddmmyyyy hh24:mi:ss') AND SQL_ID = 'd97qngc79shw7' order by SAMPLE_TIME;
SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID = '3avzr1bvh928v' and SAMPLE_TIME >= add_months(sysdate,-1) order by SAMPLE_TIME;
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID in ('4vys7bg8t0hdm');
SELECT * FROM DBA_HIST_SQLTEXT WHERE upper(SQL_TEXT) like '%/*+ APPEND */%TMP_CONTRAGENT%';
SELECT * FROM DBA_USERS WHERE USER_ID = 117;
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID IN
(select SQL_ID from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME between 
to_date('11072017 04:37:30','ddmmyyyy hh24:mi:ss') and to_date('11072017 04:39:00','ddmmyyyy hh24:mi:ss') and SQL_OPCODE = 189);
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_TEXT LIKE '%%';
SELECT * FROM DBA_HIST_SQLSTAT WHERE SQL_ID = '5zpcy29sgx73k' order by SNAP_ID;
SELECT * FROM DBA_HIST_SNAPSHOT where SNAP_ID = 26724;--order by 1;
SELECT * FROM DBA_HIST_SQL_PLAN WHERE upper(OBJECT_NAME) like '%F_ATOM_ITEMS_RP_TRD_PK%';
SELECT min(TIMESTAMP), max(TIMESTAMP) FROM DBA_HIST_SQL_PLAN;
-- поиск планов выполнения запроса
SELECT * FROM DBA_HIST_SQL_PLAN WHERE SQL_ID = 'caa13zxgd05wp' order by TIMESTAMP,PLAN_HASH_VALUE,id;
SELECT * FROM DBA_HIST_SQL_PLAN WHERE PLAN_HASH_VALUE = 3310312296;
SELECT * FROM V$SQL_PLAN WHERE SQL_ID = 'caa13zxgd05wp' order by TIMESTAMP,PLAN_HASH_VALUE,id;
SELECT DISTINCT TRUNC(TIMESTAMP),PLAN_HASH_VALUE FROM DBA_HIST_SQL_PLAN WHERE SQL_ID = 'cd3qr7vu8arw4' order by TRUNC(TIMESTAMP),PLAN_HASH_VALUE;
-- выбор плана из истории выполнения
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'aur2r27g3xt07',plan_hash_value=>3661611610,format=>'ALL'));
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'3cvmfuv9tn9vd',plan_hash_value=>3661611610,format=>'ALL'));
-- выбор текущего плана выполнения с переменными привязки
SELECT * FROM TABLE (DBMS_XPLAN.DISPLAY_CURSOR ('fxyh2jbc9wb5s',0, 'ADVANCED'));
SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SESSION_ID = 2349;
SELECT * FROM DBA_HIST_SQLTEXT WHERE upper(SQL_TEXT) like '%select /*+ dynamic_sampling(0) */%';
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SESSION_ID = 801 and SAMPLE_TIME BETWEEN to_date('25.01.2017 01:00:00','dd.mm.yyyy hh24:mi:ss') AND to_date('25.01.2017 02:01:00','dd.mm.yyyy hh24:mi:ss');

-- объекты в буферном кеше (buffer cache) (Doc ID 180850.1)

select * from V$BH where OBJD in (select OBJECT_ID from dba_objects where object_name in ('OTC_INITIAL_MARGIN_BASE','VW_CONTRACT_OTC_BASE','SEL_LOG') and OWNER <> 'NAVIA');
select * from V$BH where OBJD in (select OBJECT_ID from dba_objects where object_name in ('V_$ENTERPRISE') and OWNER = 'MOSCOW_EXCHANGE');

-- все включенные трассировки в БД

SELECT * FROM DBA_ENABLED_TRACES;

-- SQL monitor report for SQL_ID in cursor cache

select DBMS_SQL_MONITOR.REPORT_SQL_MONITOR('6y2k6huhm121v',type=>'HTML',sql_exec_start=>to_date('04.01.2018 15:00:12','dd.mm.yyyy hh24:mi:ss')) from dual;
select DBMS_SQL_MONITOR.REPORT_SQL_MONITOR('6y2k6huhm121v',type=>'HTML') from dual;

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

SPOOL c:\temp\awr_full.html

SELECT 
   output 
FROM TABLE( DBMS_WORKLOAD_REPOSITORY.ASH_GLOBAL_REPORT_HTML (
           496990843,
           1,
           TO_DATE ('10.11.2017 08:30:00', 'dd.mm.yyyy hh24:mi:ss'),
           TO_DATE ('10.11.2017 10:30:00', 'dd.mm.yyyy hh24:mi:ss')));
  
SPOOL OFF
exit

--GWDBUpdTradesOracle.spur_exadata% - EQ (SPUR_DAY)
--GWDBUpdTradesOracle@dgw1% - CU (SPUR_DAY_CU)

set linesize 8000 termout on feedback off heading off echo off veri off trimspool on trimout on  

SPOOL c:\temp\awr_GWDBUpdTradesOracle.log

SELECT 
   output 
FROM TABLE( DBMS_WORKLOAD_REPOSITORY.ASH_GLOBAL_REPORT_TEXT (
           496990843,
           1,
           TO_DATE ('04.12.2017 17:59:00', 'dd.mm.yyyy hh24:mi:ss'),--SYSDATE-1/24/2,
           TO_DATE ('04.12.2017 18:59:00', 'dd.mm.yyyy hh24:mi:ss'),--SYSDATE,
           L_MODULE   => 'GWDBUpdTradesOracle.spur_exadata%'));
  
  SPOOL OFF
exit

-- offloadable functions

select * from V$SQLFN_METADATA where OFFLOADABLE = 'YES';

-- CREATE/DROP EXTENDED STATS

select DBMS_STATS.CREATE_EXTENDED_STATS('PROT','BEE_STAT_TRANSFER','(TO_NUMBER (TO_CHAR (call_time, ''HH24'')))') from dual;
exec DBMS_STATS.drop_extended_stats('PROT','BEE_STAT_TRANSFER','(LOWER(CONNECTION_STATUS))');

SELECT * FROM dba_stat_extensions WHERE  table_name = 'BEE_STAT_TRANSFER';

-- переменные привязки (binds) в sql в курсорном кеше

SELECT distinct SQL_TEXT,
       NAME,
       VALUE_STRING,
       DATATYPE_STRING
  FROM V$SQL_BIND_CAPTURE JOIN V$SQL USING (HASH_VALUE)
 WHERE V$SQL.SQL_ID = 'a6qg6km8ab5ny' ORDER BY NAME,DATATYPE_STRING,VALUE_STRING;

-- RUN SQL tuning advisor for the given SQL_ID

DECLARE
   L_SQL                VARCHAR2 (32000);
   L_SQL_TUNE_TASK_ID   VARCHAR2 (32000);
BEGIN
   L_SQL :='9pwa2179vxcqd';

   L_SQL_TUNE_TASK_ID :=
      DBMS_SQLTUNE.CREATE_TUNING_TASK (
         SQL_ID      => L_SQL,
         TIME_LIMIT    => 600,
         TASK_NAME     => 'sqltune_'||L_SQL);
   DBMS_OUTPUT.PUT_LINE ('l_sql_tune_task_id: ' || L_SQL_TUNE_TASK_ID);
   DBMS_SQLTUNE.execute_tuning_task(task_name => 'sqltune_'||L_SQL);
END;
/
SELECT * FROM DBA_ADVISOR_LOG where EXECUTION_START > sysdate - 1/24 order by EXECUTION_START desc;
SELECT DBMS_SQLTUNE.report_tuning_task('sqltune_9pwa2179vxcqd') AS recommendations FROM dual;

--скрипт для вывода плана выполнения SQL со статистикой выполнения

select /*+ gather_plan_statistics */ ... ;

REM Displays plan for most recently executed SQL. Just execute "@plan.sql" from sqlplus.
SET PAGES 2000 LIN 180;
SPO plan.txt;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL,TO_NUMBER(NULL),'ADVANCED RUNSTATS_LAST'));
SPO OFF;

-- Закрепление определенного плана выполнения для SQL (создание BASELINE)
--https://rnm1978.wordpress.com/2011/06/28/oracle-11g-how-to-force-a-sql_id-to-use-a-plan_hash_value-using-sql-baselines/

-- если не работает (BASELINE не создается - из-за bug 25026321), используем рекомендации из: Loading Hinted Execution Plans into SQL Plan Baseline. (Doc ID 787692.1) 
-- скрипт для этого /home/oracle/scripts/sqlt/utl/coe_load_sql_baseline.sql

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
    CUR   SYS_REFCURSOR;
BEGIN
    OPEN CUR FOR SELECT VALUE (P)
                   FROM TABLE (DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY (
                                   BEGIN_SNAP =>
                                       42774,
                                   END_SNAP =>
                                       42777,
                                   BASIC_FILTER =>
                                       'sql_id = ''6qv1yffcdx0p7''',
                                   ATTRIBUTE_LIST =>
                                       'ALL')) P;

    DBMS_SQLTUNE.LOAD_SQLSET (SQLSET_NAME       => 'STS_6qv1yffcdx0p7',
                              POPULATE_CURSOR   => CUR);

    CLOSE CUR;
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
  FROM TABLE (DBMS_SQLTUNE.SELECT_SQLSET (SQLSET_OWNER=>'ARDB_USER',SQLSET_NAME => 'STS_6qv1yffcdx0p7'));
  
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
        DBMS_SPM.LOAD_PLANS_FROM_SQLSET (
            SQLSET_NAME    => 'STS_6qv1yffcdx0p7');
    DBMS_OUTPUT.PUT_LINE ('PLANS loaded'||L_PLANS_LOADED);
END;
/

-- List out the Baselines to see what's there

SELECT * FROM DBA_SQL_PLAN_BASELINES order by CREATED desc; --see SQL_HANDLE

DECLARE
    L_PLANS_LOADED   PLS_INTEGER;
BEGIN
    L_PLANS_LOADED :=
        DBMS_SPM.ALTER_SQL_PLAN_BASELINE (
            SQL_HANDLE        => 'SQL_0cdc728fc85a69d1',
            ATTRIBUTE_NAME    => 'AUTOPURGE',
            ATTRIBUTE_VALUE   => 'NO');
    DBMS_OUTPUT.PUT_LINE ('PLANS altered' || L_PLANS_LOADED);
        L_PLANS_LOADED :=
        DBMS_SPM.ALTER_SQL_PLAN_BASELINE (
            SQL_HANDLE        => 'SQL_0cdc728fc85a69d1',
            ATTRIBUTE_NAME    => 'DESCRIPTION',
            ATTRIBUTE_VALUE   => 'INSERT INTO MARKETDATA SELECT TRADEDATE DATE1%');
    DBMS_OUTPUT.PUT_LINE ('PLANS altered' || L_PLANS_LOADED);
END;
/

-- расширенная трассировка dbms_spm

exec dbms_spm.configure('spm_tracing',41); 
alter session set events '10046 trace name context forever, level 12'; 

-- PL/SQL блок вызова DBMS_SPM.LOAD_PLANS_FROM_SQLSET

alter session set events '10046 trace name context off'; 
exec dbms_spm.configure('spm_tracing',0); 

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

--Now when the query’s run, it will use the desired plan.

--LOAD plans from CURSOR CACHE (replace bad plan with good if it present in cursor cache)

SELECT DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(SQL_ID => '3zkmrvzst1ac1') FROM DUAL;

SELECT * FROM DBA_SQL_PLAN_BASELINES ORDER BY CREATED DESC;

SET SERVEROUTPUT ON
VAR RES NUMBER
--EXEC :RES := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(SQL_ID => '&hinted_SQL_ID', PLAN_HASH_VALUE => &HINTED_PLAN_HASH_VALUE, SQL_HANDLE => '&sql_handle_for_original');
EXEC :RES := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(SQL_ID => '9qyvcbc8tqgda', PLAN_HASH_VALUE => 2320859913, SQL_HANDLE => '3zkmrvzst1ac1');
EXEC DBMS_OUTPUT.PUT_LINE('Number of plans loaded: ' || :RES);
select DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(SQL_ID => '9qyvcbc8tqgda', PLAN_HASH_VALUE => 2320859913, SQL_HANDLE => 'SQL_bdc872a12dc08c92') from dual;

-- FIX problems in SQL using SQL patch - wrong result of SQL statemеnts

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

-- вставка в таблицу информации о новых ненужных индексах

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

-- партиционированные *BASE таблицы с индексами на них

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
    V_MAX_OBJECT_SIZE_GB   NUMBER DEFAULT 50;
    SQL_TXT                VARCHAR2 (3000);
    V_PL_SQLINIT           VARCHAR2 (3000) DEFAULT 'testing';
BEGIN
    FOR REC IN (  SELECT DISTINCT OBJECT_OWNER
                    FROM MANUAL_STATISTICS
                   WHERE OBJECT_OWNER IN ('EQ', 'CURR')
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
                        WORK_WITH_PARTITIONED_TABLES.LOG_WORK (
                            V_PL_SQLINIT,
                               'TABLE '
                            || OBJLIST (I).OWNNAME
                            || '.'
                            || OBJLIST (I).OBJNAME
                            || ' SIZE IS '
                            || V_OBJECT_SIZE_GB
                            || ' GB, GATHER ITS STATISTICS MANUALLY',
                            3);
                        COMMIT;
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

                        SYS.DBMS_STATS.GATHER_TABLE_STATS (
                            OBJLIST (I).OWNNAME,
                            OBJLIST (I).OBJNAME);

                        --EXECUTE IMMEDIATE SQL_TXT;

                        WORK_WITH_PARTITIONED_TABLES.LOG_WORK (
                            V_PL_SQLINIT,
                            REPLACE (SQL_TXT, CHR (10), ' '),
                            3);
                        COMMIT;
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

                    SYS.DBMS_STATS.GATHER_TABLE_STATS (
                        OBJLIST (I).OWNNAME,
                        OBJLIST (I).OBJNAME,
                        OBJLIST (I).PARTNAME,
                        GRANULARITY   => 'PARTITION');

                    --EXECUTE IMMEDIATE SQL_TXT;

                    WORK_WITH_PARTITIONED_TABLES.LOG_WORK (
                        V_PL_SQLINIT,
                        REPLACE (SQL_TXT, CHR (10), ' '),
                        3);
                    COMMIT;
                END IF;
            END LOOP;
        ELSE
            WORK_WITH_PARTITIONED_TABLES.LOG_WORK (V_PL_SQLINIT,
                      'NO STALE STATS FOR SCHEMA ' || REC.OBJECT_OWNER,
                      3);
            COMMIT;
        END IF;
    END LOOP;
END;

--SQL Plan Directives (https://oracle-base.com/articles/12c/sql-plan-directives-12cr1)

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

EXEC DBMS_SPD.DROP_SQL_PLAN_DIRECTIVE(10091005918999074784);

--блокирование использования директивы:

exec DBMS_SPD.ALTER_SQL_PLAN_DIRECTIVE (11378594116199125643, 'ENABLED','NO');