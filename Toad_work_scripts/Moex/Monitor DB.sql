-- ONLINE temp usage monitoring (view on V$SESSION A, V$SORT_USAGE B, V$SQLAREA C)

SELECT * FROM MONITOR_TEMP                         -- WHERE STATUS = 'ACTIVE';
;

-- promlems with TEMP usage by app

  SELECT *
    FROM TEMP_SEG_USAGE
   WHERE     DATE_TIME > SYSDATE - 7
         AND MB_USED > 5000
         AND USERNAME NOT LIKE 'G_%'
ORDER BY DATE_TIME DESC, MB_USED DESC;

-- problems with TEMP usage by DOMAIN USERS

  SELECT *
    FROM TEMP_SEG_USAGE
   WHERE DATE_TIME > SYSDATE - 14 AND MB_USED > 10000 AND USERNAME LIKE 'G_%'
ORDER BY DATE_TIME DESC, MB_USED DESC;

  SELECT count(distinct program)
    FROM TEMP_SEG_USAGE
   WHERE  UPPER(SQL_TEXT) LIKE '%MV_POS_TKS_ASSET%' AND DATE_TIME > sysdate - 2/24
ORDER BY DATE_TIME DESC, MB_USED DESC;

  SELECT *
    FROM TEMP_SEG_USAGE
   WHERE  UPPER(SQL_TEXT) LIKE '%MV_POS_TKS_ASSET%'
ORDER BY DATE_TIME DESC, MB_USED DESC;

-- ONLINE import into our DBs monitoring

SELECT * FROM MONITOR_ONLINE;
SELECT * FROM MONITOR_ONLINE where TRADEDATE = 'TODAY';

-- MDP materialized view and procedures monitoring

select * from TRADES_ORDERS_MDP_MONITORING where SYST_TIME >= to_date('13.04.2018 11:03:00','dd.mm.yyyy hh24:mi:ss') order by SYST_TIME desc;
select * from TRADES_ORDERS_MDP_MONITORING where MARKET = 'EQ_MVLOG' order by SYST_TIME desc;
SELECT MAX(SECONDS_DIFF) MAX_DIFF,ROUND(AVG(SECONDS_DIFF)) AVERAGE,MARKET FROM TRADES_ORDERS_MDP_MONITORING where SYST_TIME >= to_date('13.04.2018 11:03:00','dd.mm.yyyy hh24:mi:ss') GROUP BY MARKET;
select * from MDP.V_LOR where day=trunc(sysdate-7) and PROC='SE';
select * from MDP.V_LOR where day=trunc(sysdate) and PROC='CU';
select * from CURR.TRADES_ORDERS;
select * from EQ.TRADES_ORDERS;
select * from DBA_MVIEWS where MVIEW_NAME in ('TRADES_ORDERS','MV_EQ_TRADES_ORDERS');
select OWNER,MVIEW_NAME,QUERY_LEN,LAST_REFRESH_DATE,LAST_REFRESH_END_TIME,LAST_REFRESH_TYPE from DBA_MVIEWS where MVIEW_NAME = 'MV_EQ_TRADES_ORDERS';
SELECT * FROM MVIEW_MONITORING ORDER BY MONITOR_TIME DESC; --SCHEDULED JOB MONITOR_EQ_MDP
select max(SECONDS_FOR_COUNT),min(SECONDS_FOR_COUNT),avg(SECONDS_FOR_COUNT),VIEW_NAME from SE_MV_ORDLOG_TOD_TEST group by VIEW_NAME; --SCHEDULED JOBS MONITOR_MV_SEL_%
select * from DBA_MVIEWS where MVIEW_NAME = 'TRADES_ORDERS_TEST';
select * from DBA_REFRESH where RNAME = 'MV_EQ_TRADES_ORDERS';

SELECT MAX(TRADETIME) FROM SPUR_DAY_CU.TRADES WHERE TRADEDATE = TRUNC(SYSDATE); --finished at 23-51-59
SELECT MAX(ENTRYTIME) FROM SPUR_DAY_CU.ORDERS WHERE ENTRYDATE = TRUNC(SYSDATE);
SELECT MAX(TRADETIME) FROM SPUR_DAY.TRADES WHERE TRADEDATE = TRUNC(SYSDATE); --finished at ~ 20-30
SELECT MAX(ENTRYTIME) FROM SPUR_DAY.ORDERS WHERE ENTRYDATE = TRUNC(SYSDATE);
SELECT MAX(TRADETIME) FROM EQ.TRADES_BASE WHERE TRADEDATE = TRUNC(SYSDATE);

SELECT MIN(TRADETIME) FROM SPUR_DAY.TRADES WHERE TRADEDATE = TRUNC(SYSDATE-1) and TRADETIME > 0;

-- manual stat gather history

  SELECT *
    FROM ARDB_USER.MANUAL_STATISTICS
--ORDER BY LAST_COLLECTION_TIME DESC;
ORDER BY LAST_COLLECTED DESC;


-- admin procedures logs

select * from errlog where proc like '%WEEKLY%' order by 1 desc;
select * from errlog where proc like '%ONLINE%' order by 1 desc;
select * from errlog where proc like '%COPY_STATISTICS' order by 1 desc;
select * from errlog where proc like '%ILM_MANUAL%' order by 1 desc;
select * from errlog where proc like '%MOVE_DATA_FROM_ARCH_TS%'  order by  UPDATEDT desc;
select * from errlog where proc like '%DEFRAGMENT_TABLESPACE%' order by 1 desc;
select * from errlog where proc like '%testing%' and MSG LIKE '%GRANULARITY%' order by 1 desc;
select * from errlog where proc like '%MANUAL_STATISTICS_GATHER%' and ERRSTATUS <> 3 order by 1 desc;
select * from errlog where proc like '%MANUAL_STATISTICS_GATHER%' order by 1 desc;
select * from errlog where proc like '%MANUAL_STATISTICS_GATHER%' and MSG LIKE '%START COLLECTING STATISTICS FOR %' order by 1 desc;
select * from errlog where proc like '%MANUAL_STATISTICS_GATHER%' and MSG LIKE 'BEGIN  SYS.DBMS_STATS%' order by 1 desc;
select * from errlog where proc like '%MANUAL_STATISTICS_GATHER%' and (MSG LIKE '%TRADES%GRANULARITY%' or MSG LIKE '%ORDERS%GRANULARITY%') order by 1 desc;
select * from errlog where proc like '%AUDIT%' order by 1 desc;
-- results of copy_statistics in MANUAL_STATISTICS_GATHER procedure
select * from dba_tab_statistics where table_name = 'ORDERS' and OWNER in ('SPUR_DAY_CU','SPUR_DAY');
select * from dba_tab_statistics where table_name = 'TRADES_BASE' and OWNER in ('EQ','CURR') and PARTITION_NAME like '%_TRADES_BASE_P_'||substr(to_char(sysdate,'yyyymmdd'),1,6)||'%' order by OWNER,PARTITION_POSITION;
select * from dba_tab_statistics where table_name = 'ORDERS_BASE' and OWNER in ('EQ','CURR') and PARTITION_NAME like '%_ORDERS_BASE_P_'||substr(to_char(sysdate,'yyyymmdd'),1,6)||'%' order by OWNER,PARTITION_POSITION;
exec DBMS_STATS.COPY_TABLE_STATS('EQ','ORDERS_BASE',SRCPARTNAME => 'EQ_ORDERS_BASE_P_20180803',DSTPARTNAME => 'EQ_ORDERS_BASE_P_20180806',SCALE_FACTOR => 0.5);
exec DBMS_STATS.GATHER_TABLE_STATS('EQ','TRADES_BASE','EQ_TRADES_BASE_P_20180622',granularity=>'PARTITION');
exec DBMS_STATS.GATHER_TABLE_STATS('CURR','TRADES_BASE','CURR_TRADES_BASE_P_20180625',granularity=>'PARTITION');


-- monitoring Standby for SPUR and CBVIEWP

SELECT STANDBY_LOG_MONITOR ('spur') "SPUR'S STANDBY GAP",
       STANDBY_LOG_MONITOR ('cb')   "CBVIEWP'S STANDBY GAP",
       STANDBY_LOG_MONITOR          "DWH'S STANDBY GAP"
  FROM DUAL;

-- standby gap in time
  
select scn_to_timestamp(current_scn) from v$database;
  
-- database links

select * from dba_db_links order by 1,2;
select * from dba_db_links@cbviewp order by 1,2; 
select distinct owner,name,text from all_source@cbviewp where upper(text) like '%DATA_FROM_CFT2MMVB%'; 

-- close db_link connection by name

EXEC DBMS_SESSION.CLOSE_DATABASE_LINK ('DB LINK NAME');

-- check if patch is turned on by bug number

select DBMS_SQLDIAG.GET_FIX_CONTROL(16726844) from dual;

-- physical backup

SELECT COPY#,ROUND(SUM(BYTES)/1024/1024/1024/1024,2) TB FROM V$BACKUP_PIECE_DETAILS WHERE DEVICE_TYPE = 'SBT_TAPE' GROUP BY COPY#;

SELECT COPY#,
         ROUND (SUM (BYTES) / 1024 / 1024 / 1024 / 1024, 2) TB,
         SUBSTR (TAG, 1, 2) BACKUP_TYPE
    FROM V$BACKUP_PIECE_DETAILS
GROUP BY COPY#, SUBSTR (TAG, 1, 2)
  HAVING ROUND (SUM (BYTES) / 1024 / 1024 / 1024 / 1024, 2) > 0
ORDER BY 3, 1, 2;

-- size of backups (for ONE site) by file backup types (datafile,archivelog, etc)

  SELECT SUM (GB),
         SUBSTR (TAG,
                 1,
                   INSTR (TAG,
                          '_',
                          1,
                          2)
                 - 1)
             BACKUP_TYPE,
         BACKUP_DAY
    FROM (  SELECT ROUND (SUM (BYTES) / 1024 / 1024 / 1024 / 2) GB,
                   TAG,
                   TRUNC (START_TIME)                       BACKUP_DAY
              FROM V$BACKUP_PIECE_DETAILS
          GROUP BY TAG, TRUNC (START_TIME)
            HAVING SUM (BYTES) > 9 * 10E9)
GROUP BY SUBSTR (TAG,
                 1,
                   INSTR (TAG,
                          '_',
                          1,
                          2)
                 - 1),
         BACKUP_DAY
ORDER BY BACKUP_DAY DESC, BACKUP_TYPE;

SELECT * FROM V$BACKUP_PIECE_DETAILS ORDER BY START_TIME; 

SELECT * FROM V$BACKUP_DATAFILE_DETAILS WHERE FILE# = 1;

SELECT * FROM V$DATABASE;

-- Analyze the growth of archivelogs in DB (DOC id 2265722.1) 

-- redo logs in DB

  SELECT LG.GROUP#,
         LG.BYTES / 1024 / 1024 MB,
         LG.STATUS,
         LG.ARCHIVED,
         LF.MEMBER
    FROM V$LOGFILE LF, V$LOG LG
   WHERE LG.GROUP# = LF.GROUP#
ORDER BY 1, 2;

-- archivelogs switches time map

  SELECT TO_CHAR (FIRST_TIME, 'YYYY-MON-DD')
             "Date",
         TO_CHAR (FIRST_TIME, 'DY')
             DAY,
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '00', 1, 0)),
                  '999')
             "00",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '01', 1, 0)),
                  '999')
             "01",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '02', 1, 0)),
                  '999')
             "02",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '03', 1, 0)),
                  '999')
             "03",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '04', 1, 0)),
                  '999')
             "04",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '05', 1, 0)),
                  '999')
             "05",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '06', 1, 0)),
                  '999')
             "06",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '07', 1, 0)),
                  '999')
             "07",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '08', 1, 0)),
                  '999')
             "08",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '09', 1, 0)),
                  '999')
             "09",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '10', 1, 0)),
                  '999')
             "10",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '11', 1, 0)),
                  '999')
             "11",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '12', 1, 0)),
                  '999')
             "12",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '13', 1, 0)),
                  '999')
             "13",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '14', 1, 0)),
                  '999')
             "14",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '15', 1, 0)),
                  '999')
             "15",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '16', 1, 0)),
                  '999')
             "16",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '17', 1, 0)),
                  '999')
             "17",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '18', 1, 0)),
                  '999')
             "18",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '19', 1, 0)),
                  '999')
             "19",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '20', 1, 0)),
                  '999')
             "20",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '21', 1, 0)),
                  '999')
             "21",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '22', 1, 0)),
                  '999')
             "22",
         TO_CHAR (SUM (DECODE (TO_CHAR (FIRST_TIME, 'HH24'), '23', 1, 0)),
                  '999')
             "23",
         COUNT (*)
             TOTAL
    FROM V$LOG_HISTORY
GROUP BY TO_CHAR (FIRST_TIME, 'YYYY-MON-DD'), TO_CHAR (FIRST_TIME, 'DY')
ORDER BY TO_DATE (TO_CHAR (FIRST_TIME, 'YYYY-MON-DD'), 'YYYY-MON-DD');

-- segments growth over period

  SELECT TO_CHAR (BEGIN_INTERVAL_TIME, 'YY-MM-DD HH24')
             SNAP_TIME,
         DHSO.OWNER,
         DHSO.OBJECT_NAME,
         DHSO.SUBOBJECT_NAME,
         ROUND (SUM (DB_BLOCK_CHANGES_DELTA) * 8192 / 1024 / 1024 / 1024)
             GB_CHANGED
    FROM DBA_HIST_SEG_STAT    DHSS,
         DBA_HIST_SEG_STAT_OBJ DHSO,
         DBA_HIST_SNAPSHOT    DHS
   WHERE     DHS.SNAP_ID = DHSS.SNAP_ID
         AND DHS.INSTANCE_NUMBER = DHSS.INSTANCE_NUMBER
         AND DHSS.OBJ# = DHSO.OBJ#
         AND DHSS.DATAOBJ# = DHSO.DATAOBJ#
         AND BEGIN_INTERVAL_TIME BETWEEN TO_DATE ('17-12-05 00:00',
                                                  'YY-MM-DD HH24:MI') -- <<<<<<<<<<<< Need to modify the time as per the above query where more redo log switch happened (keep it for 1 hour)
                                     AND TO_DATE ('17-12-06 00:00',
                                                  'YY-MM-DD HH24:MI') --<<<<<<<<<<<< Need to modify the time as per the above query where more redo log switch happened (interval shld be only 1 hour)
GROUP BY TO_CHAR (BEGIN_INTERVAL_TIME, 'YY-MM-DD HH24'),
         DHSO.OBJECT_NAME,
         DHSO.OWNER,
         DHSO.SUBOBJECT_NAME
  HAVING ROUND (SUM (DB_BLOCK_CHANGES_DELTA) * 8192 / 1024 / 1024 / 1024) > 0
ORDER BY SUM (DB_BLOCK_CHANGES_DELTA) DESC;

-- find SQL causing huge redo generation

  SELECT TO_CHAR (BEGIN_INTERVAL_TIME, 'YYYY_MM_DD HH24') WHEN,
         DBMS_LOB.SUBSTR (SQL_TEXT, 4000, 1)            SQL,
         DHSS.INSTANCE_NUMBER                           INST_ID,
         DHSS.SQL_ID,
         EXECUTIONS_DELTA                               EXEC_DELTA,
         ROWS_PROCESSED_DELTA                           ROWS_PROC_DELTA
    FROM DBA_HIST_SQLSTAT DHSS, DBA_HIST_SNAPSHOT DHS, DBA_HIST_SQLTEXT DHST
   WHERE     UPPER (DHST.SQL_TEXT) LIKE '%IN_REQUEST%' -- >>>>>>>>>>>>>>>>>> Update the segment name as per the result of previous query result
         AND LTRIM (UPPER (DHST.SQL_TEXT)) NOT LIKE 'SELECT%'
         AND DHSS.SNAP_ID = DHS.SNAP_ID
         AND DHSS.INSTANCE_NUMBER = DHS.INSTANCE_NUMBER
         AND DHSS.SQL_ID = DHST.SQL_ID
         AND BEGIN_INTERVAL_TIME BETWEEN TO_DATE ('17-12-05 00:00',
                                                  'YY-MM-DD HH24:MI') -->>>>>>>>>>>> Update time frame as required
                                     AND TO_DATE ('17-12-06 00:00',
                                                  'YY-MM-DD HH24:MI')
ORDER BY EXECUTIONS_DELTA DESC, ROWS_PROCESSED_DELTA DESC;                                                 -->>>>>>>>>>>> Update time frame as required

-- monitor physical backup wait EVENTS FROM ASH

set timing on ECHO ON
spool C:\temp\rman_ash_1.log


  SELECT SESSION_STATE, COUNT (*)
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE (SESSION_ID, SESSION_SERIAL#) IN
             (SELECT DISTINCT SID, SERIAL
                FROM V$BACKUP_ASYNC_IO
               WHERE   TYPE = 'OUTPUT'
                     AND FILENAME NOT LIKE '%ARCHIVELOG%'
                     AND OPEN_TIME BETWEEN TO_DATE ('27-09-2017 10:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss')
                                       AND TO_DATE ('27-09-2017 15:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss'))
AND SAMPLE_TIME BETWEEN TO_DATE ('27-09-2017 10:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss')
                                       AND TO_DATE ('27-09-2017 15:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss')
GROUP BY SESSION_STATE;

  SELECT EVENT, COUNT (*)
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE (SESSION_ID, SESSION_SERIAL#) IN
             (SELECT DISTINCT SID, SERIAL
                FROM V$BACKUP_ASYNC_IO
               WHERE     TYPE = 'OUTPUT'
                     AND FILENAME NOT LIKE '%ARCHIVELOG%'
                     AND OPEN_TIME BETWEEN TO_DATE ('27-09-2017 10:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss')
                                       AND TO_DATE ('27-09-2017 15:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss'))
AND SAMPLE_TIME BETWEEN TO_DATE ('27-09-2017 10:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss')
                                       AND TO_DATE ('27-09-2017 15:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss')
GROUP BY EVENT
ORDER BY 2 DESC;

  SELECT TOP_LEVEL_CALL#, TOP_LEVEL_CALL_NAME, COUNT (*)
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE (SESSION_ID, SESSION_SERIAL#) IN
             (SELECT DISTINCT SID, SERIAL
                FROM V$BACKUP_ASYNC_IO
               WHERE     TYPE = 'OUTPUT'
                     AND FILENAME NOT LIKE '%ARCHIVELOG%'
                     AND OPEN_TIME BETWEEN TO_DATE ('27-09-2017 10:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss')
                                       AND TO_DATE ('27-09-2017 15:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss'))
AND SAMPLE_TIME BETWEEN TO_DATE ('27-09-2017 10:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss')
                                       AND TO_DATE ('27-09-2017 15:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss')
GROUP BY TOP_LEVEL_CALL#, TOP_LEVEL_CALL_NAME
ORDER BY 2 DESC;

  SELECT MODULE, ACTION, COUNT (*)
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE (SESSION_ID, SESSION_SERIAL#) IN
             (SELECT DISTINCT SID, SERIAL
                FROM V$BACKUP_ASYNC_IO
               WHERE     TYPE = 'OUTPUT'
                     AND FILENAME NOT LIKE '%ARCHIVELOG%'
                     AND OPEN_TIME BETWEEN TO_DATE ('27-09-2017 10:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss')
                                       AND TO_DATE ('27-09-2017 15:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss'))
AND SAMPLE_TIME BETWEEN TO_DATE ('27-09-2017 10:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss')
                                       AND TO_DATE ('27-09-2017 15:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss')
GROUP BY MODULE, ACTION
ORDER BY 1, 3 DESC, 2;

  SELECT EVENT, SUM (TIME_WAITED_MICRO) / 1E6 SECONDS
    FROM V$SESSION_EVENT
   WHERE SID IN
             (SELECT DISTINCT SID
                FROM V$BACKUP_ASYNC_IO
               WHERE /*    TYPE = 'OUTPUT'
                     AND FILENAME LIKE '%ARCHIVELOG%'
                      AND */ OPEN_TIME BETWEEN TO_DATE ('28-09-2017 10:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss')
                                       AND TO_DATE ('28-09-2017 15:00:00',
                                                    'dd-mm-yyyy hh24:mi:ss'))
GROUP BY EVENT
ORDER BY 2 DESC;

spool off
exit

-- monitor data transferred via db link 

SELECT * FROM v$mystat WHERE rownum = 1;

SELECT s.statistic#, sn.name, s.value
FROM v$sesstat s, v$statname sn
WHERE s.statistic# = sn.statistic#
AND sn.name LIKE '%link%'
AND s.value > 0
AND s.sid = 1262
ORDER BY 1;

-- MAX PGA MEMORY usage by processes

  SELECT PM.PID,
         S.PROGRAM,
         S.SID,
         S.SCHEMANAME,
         S.STATUS,
         S.EVENT,
         round(MAX (PM.ALLOCATED)/1024/1024/1024,2) GB
    FROM V$PROCESS_MEMORY PM, V$PROCESS P, V$SESSION S
   WHERE PM.PID = P.PID AND P.ADDR = S.PADDR
GROUP BY PM.PID,
         S.PROGRAM,
         S.SID,
         S.SCHEMANAME,
         S.STATUS,
         S.EVENT
ORDER BY MAX(PM.ALLOCATED) DESC;

-- InMemory segments

SELECT * FROM V$IM_SEGMENTS ORDER BY 1,2,3;
  SELECT OWNER,
         SEGMENT_NAME,
         PARTITION_NAME,
         SEGMENT_TYPE,
         TABLESPACE_NAME,
         ROUND (INMEMORY_SIZE / 1024 / 1024) MB_IN_MEMORY,
         ROUND (BYTES / 1024 / 1024)       MB,
         INMEMORY_COMPRESSION
    FROM V$IM_SEGMENTS
ORDER BY INMEMORY_SIZE DESC,OWNER;

SELECT ROUND (SUM (INMEMORY_SIZE) / 1024 / 1024 / 1024, 1) GB_IN_MEMORY FROM V$IM_SEGMENTS;

  SELECT OWNER,
         SEGMENT_NAME,
         ROUND (SUM (INMEMORY_SIZE) / 1024 / 1024) MB_IN_MEMORY
    FROM V$IM_SEGMENTS
GROUP BY OWNER, SEGMENT_NAME
ORDER BY ROUND (SUM (INMEMORY_SIZE) / 1024 / 1024) DESC;

-- database options and parameters

SELECT * FROM V$OPTION ORDER BY VALUE DESC,PARAMETER; --WHERE PARAMETER = 'Unified Auditing';

-- ONLINE LOGFILES, STANDBY LOGFILES, ADD logfiles

select * from v$logfile;
select * from v$log;
select * from v$STANDBY_LOG;

--alter database add logfile group 10 '+DATAC1/SPURSTB/ONLINELOG/group_10.redo','+RECOC1/SPURSTB/ONLINELOG/group_10.redo' size 4G;
--alter database add logfile group 11 '+DATAC1/SPURSTB/ONLINELOG/group_11.redo','+RECOC1/SPURSTB/ONLINELOG/group_11.redo' size 4G;
--alter database add standby logfile thread 1 group 12 '+RECOC1/SPURSTB/STANDBYLOG/log_stb12.dbf' size 4G reuse;
--alter database add standby logfile thread 1 group 13 '+RECOC1/SPURSTB/STANDBYLOG/log_stb13.dbf' size 4G reuse;
--alter database drop standby logfile group 12;
--alter database drop standby logfile group 13;

--alter database add logfile group 10 '+DATAC1/SPUR/ONLINELOG/group_10.redo','+RECOC1/SPUR/ONLINELOG/group_10.redo' size 4G;
--alter database add logfile group 11 '+DATAC1/SPUR/ONLINELOG/group_11.redo','+RECOC1/SPUR/ONLINELOG/group_11.redo' size 4G;
--alter database add standby logfile thread 1 group 12 '+RECOC1/SPUR/STANDBYLOG/log_stb12.dbf' size 4G reuse;
--alter database add standby logfile thread 1 group 13 '+RECOC1/SPUR/STANDBYLOG/log_stb13.dbf' size 4G reuse;

-- DB audit

select * from DBA_AUDIT_TRAIL;

-- disable FGA policy

exec DBMS_FGA.DISABLE_POLICY('CURR','SWAP_REP','SWAP_REP_UD');

select count(1) from SYS.FGA_LOG$;

select count(1),POLICYNAME from SYS.FGA_LOG$ where NTIMESTAMP# > sysdate-1 group by POLICYNAME order by 1 desc;

select count(1),POLICYNAME,trunc(NTIMESTAMP#) from SYS.FGA_LOG$ where NTIMESTAMP# > sysdate-1 group by POLICYNAME,trunc(NTIMESTAMP#) order by 1 desc;

-- Statistics monitoring

SELECT * FROM DBA_TAB_STATISTICS WHERE TABLE_NAME = 'ORDERS_BASE' AND STATTYPE_LOCKED IS NOT NULL /*and NUM_ROWS = 0 and AVG_ROW_LEN = 0 */ORDER BY 1,2,3 ;
SELECT * FROM DBA_TAB_STATISTICS WHERE STATTYPE_LOCKED IS NOT NULL /*and NUM_ROWS = 0 and AVG_ROW_LEN = 0 */ORDER BY 1,2,3 ;
-- stale statistics
SELECT * FROM DBA_TAB_STATISTICS WHERE (STALE_STATS IS NULL OR STALE_STATS <> 'NO') AND OWNER NOT IN ('SYS','APEX_050000') AND OWNER NOT LIKE '%/_LM' ESCAPE '/' ORDER BY OWNER,TABLE_NAME,PARTITION_NAME;
SELECT * FROM DBA_TAB_STATISTICS WHERE PARTITION_NAME = 'EQ_ORDERS_BASE_P_20161212';

-- modifications of table data and statistics for its partitions

SELECT *
  FROM DBA_TAB_MODIFICATIONS M, DBA_TAB_STATISTICS S
 WHERE     M.TABLE_OWNER = 'FORTS_AR'-- 'EQ'
       AND M.TABLE_NAME = 'FUT_ORDLOG'--'ORDERS_BASE'
       AND M.TABLE_OWNER = S.OWNER
       AND M.TABLE_NAME = S.TABLE_NAME
       AND M.PARTITION_NAME = S.PARTITION_NAME
     --  AND S.STATTYPE_LOCKED = 'ALL'
     --  AND S.STALE_STATS <> 'NO'
       AND M.TIMESTAMP >= S.LAST_ANALYZED
 ORDER BY TO_NUMBER(REGEXP_REPLACE(M.PARTITION_NAME,'[A-Z,_]',''));--M.PARTITION_NAME-- M.TIMESTAMP;

SELECT * FROM DBA_TAB_MODIFICATIONS where TABLE_NAME = 'CUBE_ABC3_REPORT'; 
SELECT * FROM DBA_TAB_MODIFICATIONS where TABLE_OWNER = 'CURR' and TABLE_NAME = 'ORDERS_BASE';
SELECT * FROM DBA_TAB_MODIFICATIONS where TABLE_OWNER = 'EQ' and TABLE_NAME = 'ORDERS_BASE';

-- Automatic partitioning (automatic creation of range partitions in a table)

-- if table uses flashback archive
exec DBMS_FLASHBACK_ARCHIVE.disassociate_fba(owner_name=>'FORTS_CLEARING',table_name=>'SYS_MONEY_REPORT_BASE');
alter table FORTS_JAVA.PART_BASE SET INTERVAL(1);
exec DBMS_FLASHBACK_ARCHIVE.reassociate_fba(owner_name=>'FORTS_CLEARING',table_name=>'FORTS_STAT_BASE');
-- if table not uses flashback archive
alter table FORTS_REPAAR.P2_PROXY_LOG_BASE SET INTERVAL( NUMTODSINTERVAL(1,'DAY'));

-- lock partition statistics
SELECT 'EXEC DBMS_STATS.LOCK_PARTITION_STATS(ownname=>'''||OWNER||''',tabname=>'''||TABLE_NAME||''',partname=>'''||PARTITION_NAME||''');' FROM DBA_TAB_STATISTICS WHERE TABLE_NAME = 'FUTDEAL_BASE' ORDER BY PARTITION_NAME;
SELECT 'EXEC DBMS_STATS.LOCK_PARTITION_STATS(ownname=>'''||OWNER||''',tabname=>'''||TABLE_NAME||''',partname=>'''||PARTITION_NAME||''');' FROM DBA_TAB_STATISTICS WHERE TABLE_NAME = 'ORDERS_BASE' and OWNER = 'CURR' ORDER BY PARTITION_NAME;
EXEC DBMS_STATS.LOCK_PARTITION_STATS(ownname=>'CBMIRROR',tabname=>'TRADES_BASE',partname=>'EQ_TRADES_BASE_P_20051107');
-- unlock locked statistics on partitions
SELECT 'EXEC DBMS_STATS.UNLOCK_PARTITION_STATS(ownname=>'''||OWNER||''',tabname=>'''||TABLE_NAME||''',partname=>'''||PARTITION_NAME||''');' FROM DBA_TAB_STATISTICS WHERE STATTYPE_LOCKED = 'ALL' and PARTITION_NAME is not null ORDER BY OWNER,TABLE_NAME,PARTITION_NAME;
--EXEC DBMS_STATS.UNLOCK_PARTITION_STATS(ownname=>'EQ',tabname=>'ORDERS_BASE',partname=>'

-- setup GRANULARITY parameter for a table with incremental statistics

exec DBMS_STATS.SET_TABLE_PREFS('CURR','ORDERS_BASE','GRANULARITY','GLOBAL AND PARTITION');
exec DBMS_STATS.SET_TABLE_PREFS('EQ','ORDERS_BASE','GRANULARITY','GLOBAL AND PARTITION');
--exec DBMS_STATS.SET_TABLE_PREFS('FORTS_AR','FUT_ORDLOG','GRANULARITY','APPROX_GLOBAL AND PARTITION');
exec DBMS_STATS.SET_TABLE_PREFS('EQ','ORDLOG_BASE','ESTIMATE_PERCENT',5);
exec DBMS_STATS.SET_TABLE_PREFS('FORTS_AR','FUT_ORDLOG','ESTIMATE_PERCENT',5);
exec DBMS_STATS.SET_TABLE_PREFS('FORTS_AR','FUT_ORDLOG','METHOD_OPT','FOR ALL COLUMNS SIZE 254');
exec DBMS_STATS.SET_TABLE_PREFS('FORTS_AR','OPT_ORDLOG','GRANULARITY','PARTITION');
exec DBMS_STATS.SET_TABLE_PREFS('FORTS_AR','FUT_ORDLOG','METHOD_OPT','FOR ALL COLUMNS SIZE AUTO FOR COLUMNS SIZE 1 COMMENT_1 FOR COLUMNS SIZE 1 KOL FOR COLUMNS SIZE 1 REST_COL FOR COLUMNS SIZE 1 NUMB_ORDER');

-- DBMS_STATS trace

-- tracefile for the current session
SELECT VALUE FROM V$DIAG_INFO WHERE NAME = 'Default Trace File';
-- turn ON tracing (!!! all call within instance in all sessions will be traced after that)
EXEC DBMS_STATS.SET_PARAM('trace', 4+8+16+64+128+1024+2048+32768); -- when this level of trace is used DBMS_STATS.get_param('trace') = 36060
-- turn OFF tracing
EXEC DBMS_STATS.SET_PARAM('trace', NULL);
-- check the fact of turning OFF
SELECT DBMS_STATS.GET_PARAM('trace') FROM DUAL;

-- Prepare traces for oracle support (225598.1)
-- For analyzing optimizer (when executing the same SQL their text should be changed in 1 character in order to parce appeared again)

alter session set max_dump_file_size = unlimited;
ALTER SESSION SET TRACEFILE_IDENTIFIER = "SESSION_666";

ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';
alter system set events '10053 trace name context off';

-- trace execution for tkprof
ALTER SESSION SET EVENTS '10046 trace name context forever, level 1';
alter SESSION set events '10046 trace name context off';

-- tracing certain error (in the example below ora-08103)
alter session set events '8103 trace name errorstack level 5';
alter session set events '8103 trace name context off';

-- trace optimizer for the certain SQL_ID

select child_number, plan_hash_value from v$sql where sql_id='9nq2ru1t84dsg'; -- find child number
exec DBMS_SQLDIAG.DUMP_TRACE(p_sql_id=>'9nq2ru1t84dsg', p_child_number=>1, p_component=>'Optimizer', p_file_id=>'trace9nq2ru1t84dsg');

-- Collect Incremental Statistics For a Large Partitioned Table in 10g and in 11g (Doc ID 1319225.1)

-- show current parameters for table
select DBMS_STATS.GET_PREFS('INCREMENTAL','CURR','ORDERS_BASE') from dual;
select DBMS_STATS.GET_PREFS('DEGREE','CURR','ORDERS_BASE') from dual;
select DBMS_STATS.GET_PREFS('PUBLISH','CURR','ORDERS_BASE') from dual;
select DBMS_STATS.GET_PREFS('INCREMENTAL') from dual;
select DBMS_STATS.GET_PREFS('INCREMENTAL_STALENESS') from dual;
select DBMS_STATS.GET_PREFS('ESTIMATE_PERCENT') from dual;
select DBMS_STATS.GET_PREFS('GRANULARITY') from dual;
select DBMS_STATS.GET_PREFS('GRANULARITY','FORTS_AR','FUT_ORDLOG') from dual;
select DBMS_STATS.GET_PREFS('ESTIMATE_PERCENT','FORTS_AR','FUT_ORDLOG') from dual;
select DBMS_STATS.GET_PREFS('STALE_PERCENT','EQ','ORDERS_BASE') from dual;
select DBMS_STATS.GET_PREFS('GRANULARITY','MSTR_BI_DATA','TMP_F_GL_BUDGET_AS5_TM') from dual;
select DBMS_STATS.GET_PREFS('ESTIMATE_PERCENT','FORTS_AR','OPT_ORDLOG') from dual;
select DBMS_STATS.GET_PREFS('METHOD_OPT','FORTS_AR','OPT_ORDLOG') from dual;
-- collect incremental stats
SET TIMING ON
EXEC DBMS_STATS.GATHER_TABLE_STATS('FORTS_AR','FUT_ORDLOG');
EXEC DBMS_STATS.GATHER_TABLE_STATS('FORTS_AR','ARPART_LOG_BASE');
EXEC DBMS_STATS.GATHER_TABLE_STATS('MARKET_JOIN','LKC_TRADE');
EXEC DBMS_STATS.GATHER_TABLE_STATS('CURR','ORDERS_BASE');
EXEC DBMS_STATS.GATHER_TABLE_STATS('EQ','TRADES_BASE',DEGREE=>4,GRANULARITY=>'GLOBAL AND PARTITION');
EXEC DBMS_STATS.GATHER_TABLE_STATS('MSTR_BI_DATA','TMP_F_GL_BUDGET_AS5_TM',GRANULARITY=>'GLOBAL AND PARTITION');
-- restore statistics of table
EXEC DBMS_STATS.RESTORE_TABLE_STATS('FORTS_AR','FUT_ORDLOG',SYSDATE-1);

-- collect statistics on partition
EXEC DBMS_STATS.GATHER_TABLE_STATS ('CURR','ORDERS_BASE', 'CURR_ORDERS_BASE_P_20171001', GRANULARITY => 'PARTITION');
EXEC DBMS_STATS.GATHER_TABLE_STATS ('CURR','TRADES_BASE', 'CURR_TRADES_BASE_P_20171001', GRANULARITY => 'PARTITION'); 

SELECT COUNT(1) FROM EQ.ORDERS_BASE PARTITION(EQ_ORDERS_BASE_P_20161212);
SELECT * FROM FORTS_AR.FUT_ORDLOG PARTITION(FUT_ORDLOG_5101);
SELECT MAX(SESS_ID) FROM FORTS_AR.FUT_ORDLOG;

-- maintance tasks in DB

-- change maintance scheduler windows

BEGIN
DBMS_SCHEDULER.DISABLE(
name=>'"SYS"."WEDNESDAY_WINDOW"',
force=>TRUE);
END;

-- duration 10 hours

BEGIN
DBMS_SCHEDULER.SET_ATTRIBUTE(
name=>'"SYS"."WEDNESDAY_WINDOW"',
attribute=>'DURATION',
value=>numtodsinterval(600, 'minute'));
END;

-- start each wednesday at 13-00

BEGIN
DBMS_SCHEDULER.SET_ATTRIBUTE(
name=>'"SYS"."WEDNESDAY_WINDOW"',
attribute=>'REPEAT_INTERVAL',
value=>'FREQ=WEEKLY;BYDAY=WED;BYHOUR=13;BYMINUTE=0;BYSECOND=0');
END;

BEGIN
DBMS_SCHEDULER.ENABLE(
name=>'"SYS"."WEDNESDAY_WINDOW"');
END;

--ALTER TABLESPACE TEMP SHRINK SPACE;
ALTER TABLESPACE G_TEMP SHRINK SPACE;

-- ASM info

SELECT * FROM V$ASM_DISKGROUP;
SELECT GROUP_NUMBER,NAME,TOTAL_MB,FREE_MB FROM V$ASM_DISKGROUP;
SELECT * FROM V$ASM_DISK ORDER BY FAILGROUP,MODE_STATUS,DISK_NUMBER; 
SELECT * FROM V$ASM_OPERATION;
SELECT * FROM V$ASM_ATTRIBUTE;
SELECT DG.NAME,A.VALUE FROM V$ASM_DISKGROUP DG, V$ASM_ATTRIBUTE A WHERE DG.GROUP_NUMBER=A.GROUP_NUMBER AND A.NAME='disk_repair_time';

-- space usage in ASM (for details see query inside FROM block)

  SELECT SUBSTR (alias_path,
                 2,
                   INSTR (alias_path,
                          '/',
                          1,
                          2)
                 - 2)
            Database,
         ROUND (SUM (alloc_bytes) / 1024 / 1024 / 1024, 1) "GB"
    FROM (    SELECT SYS_CONNECT_BY_PATH (alias_name, '/') alias_path, alloc_bytes
                FROM (SELECT g.name disk_group_name,
                             a.parent_index pindex,
                             a.name alias_name,
                             a.reference_index rindex,
                             f.space alloc_bytes,
                             f.TYPE TYPE
                        FROM v$asm_file f
                             RIGHT OUTER JOIN v$asm_alias a
                                USING (group_number, file_number)
                             JOIN v$asm_diskgroup g USING (group_number))
               WHERE TYPE IS NOT NULL
          START WITH (MOD (pindex, POWER (2, 24))) = 0
          CONNECT BY PRIOR rindex = pindex)
GROUP BY SUBSTR (alias_path,
                 2,
                   INSTR (alias_path,
                          '/',
                          1,
                          2)
                 - 2)
ORDER BY 2 DESC;

-- scheduler jobs

select * from USER_SCHEDULER_JOB_RUN_DETAILS where JOB_NAME <> 'TEMP_SEG_USAGE_INSERT_JOB' order by 1 desc;
select count(*),STATUS,JOB_NAME from USER_SCHEDULER_JOB_RUN_DETAILS group by STATUS,JOB_NAME order by 1 desc;
select * from USER_SCHEDULER_JOB_RUN_DETAILS where log_date in (select max(log_date) from USER_SCHEDULER_JOB_RUN_DETAILS group by JOB_NAME) and log_date > add_months(sysdate,-1) order by 1 desc;
select * from ALL_SCHEDULER_JOB_RUN_DETAILS where log_date in (select max(log_date) from USER_SCHEDULER_JOB_RUN_DETAILS group by JOB_NAME) and log_date > sysdate-7 order by 1 desc;
select count(*) from USER_SCHEDULER_JOB_RUN_DETAILS where log_date in (select max(log_date) from USER_SCHEDULER_JOB_RUN_DETAILS group by JOB_NAME) and log_date > add_months(sysdate,-1) and STATUS <> 'SUCCEEDED';

-- failed admin jobs in OMS

select count(*) as FAILED_ADMIN_JOBS from USER_SCHEDULER_JOB_RUN_DETAILS where job_name not like 'KARPOV_%' and log_date in (select max(log_date) from USER_SCHEDULER_JOB_RUN_DETAILS group by JOB_NAME) and log_date > sysdate-7 and STATUS <> 'SUCCEEDED';
select * from USER_SCHEDULER_JOB_RUN_DETAILS where log_date > sysdate-7 order by log_date desc;
select * from USER_SCHEDULER_JOB_RUN_DETAILS where log_date > sysdate-7 and JOB_NAME <> 'TEMP_SEG_USAGE_INSERT_JOB' order by log_date desc;

-- SIZE and partitions

  SELECT OWNER, SEGMENT_TYPE, ROUND (SUM (BYTES) / 1024 / 1024 / 1024, 0) GB
    FROM DBA_SEGMENTS
   WHERE OWNER NOT LIKE 'SYS%'
GROUP BY OWNER, SEGMENT_TYPE
  HAVING ROUND (SUM (BYTES) / 1024 / 1024 / 1024, 2) > 5
ORDER BY 1,2,3 DESC;

-- Objects growth in the given tablespace during the time period kept in the AWR data

  SELECT O.OWNER,
         O.OBJECT_NAME,
         O.SUBOBJECT_NAME,
         O.OBJECT_TYPE,
         T.NAME
             "Tablespace Name",
         ROUND (S.GROWTH / (1024 * 1024))
             "Growth in MB",
         (SELECT ROUND(SUM (BYTES) / (1024 * 1024))
            FROM DBA_SEGMENTS
           WHERE SEGMENT_NAME = O.OBJECT_NAME)
             "Current Size in MB"
    FROM DBA_OBJECTS O,
         (  SELECT TS#, OBJ#, SUM (SPACE_USED_DELTA) GROWTH
              FROM DBA_HIST_SEG_STAT
             WHERE SNAP_ID IN
                       (SELECT SNAP_ID
                          FROM DBA_HIST_SNAPSHOT
                         WHERE BEGIN_INTERVAL_TIME BETWEEN to_date('07082018 04:00:00','ddmmyyyy hh24:mi:ss') and to_date('07082018 06:00:00','ddmmyyyy hh24:mi:ss'))--TRUNC (SYSDATE - 2) AND   SYSDATE)
          GROUP BY TS#, OBJ#
            HAVING SUM (SPACE_USED_DELTA) > 0
          ORDER BY 2 DESC) S,
         V$TABLESPACE T
   WHERE     S.OBJ# = O.OBJECT_ID
         --AND T.NAME = 'LDWH_DATA'
         --AND T.NAME = 'SMALL_TABLES_DATA'
         --AND T.NAME = 'HCNG_DATA'
         --AND T.NAME = 'DWHLOAD_DATA'
         --AND T.NAME = 'FINMODEL_DATA'
         --AND T.NAME = 'FORTS_AR_DATA'
         AND S.TS# = T.TS#
ORDER BY 6 DESC;

-- monitor objects' in a tablespace growtn during the given time period (in minutes)

--- Header: $Id: segs2.sql 33 2015-12-17 01:22:24Z mve $
--- Copyright 2015 HASHJOIN (http://www.hashjoin.com/). All Rights Reserved.

ttit "Fast Extending Segments in the last &&1 minutes"
set lines 159
set trims on

col end_interval_time   format a26
col owner               format a20
col object_name		format a20
col subobject_name	format a20
col instance_number     format 999 heading "I#"
col mbytes              format 999999999999

break on report
compute sum of mbytes on report

select
   s.end_interval_time
,  h.INSTANCE_NUMBER
,  n.tablespace_name
,  n.owner
,  n.object_name
,  n.subobject_name
,  n.object_type
,  h.space_allocated_delta/1024/1024 mbytes
from dba_hist_seg_stat h,
     dba_hist_snapshot s,
     dba_hist_seg_stat_obj n
where h.snap_id = s.snap_id
  and h.INSTANCE_NUMBER = s.INSTANCE_NUMBER
  and h.dbid = s.dbid
  and h.ts# = n.ts#
  and h.dbid = n.dbid
  and h.dataobj# = n.dataobj#
  and h.obj# = n.obj#
  and n.tablespace_name = '&&2'
  and h.space_allocated_delta > 0
  and s.end_interval_time >= sysdate-&&1/24/60
order by s.end_interval_time;

--- Header: $Id: segs3.sql 33 2015-12-17 01:22:24Z mve $
--- Copyright 2015 HASHJOIN (http://www.hashjoin.com/). All Rights Reserved.

ttit "Fast Extending Segments Since Last Datafile Creation"
set lines 159
set trims on

col end_interval_time   format a26
col owner               format a20
col object_name		format a20
col subobject_name	format a20
col instance_number     format 999 heading "I#"
col mbytes              format 999999999999

break on report
compute sum of mbytes on report

select
   s.end_interval_time
,  h.INSTANCE_NUMBER
,  n.tablespace_name
,  n.owner
,  n.object_name
,  n.subobject_name
,  n.object_type
,  h.space_allocated_delta/1024/1024 mbytes
from dba_hist_seg_stat h,
     dba_hist_snapshot s,
     dba_hist_seg_stat_obj n
where h.snap_id = s.snap_id
  and h.INSTANCE_NUMBER = s.INSTANCE_NUMBER
  and h.dbid = s.dbid
  and h.ts# = n.ts#
  and h.dbid = n.dbid
  and h.dataobj# = n.dataobj#
  and h.obj# = n.obj#
  and n.tablespace_name = '&&1'
  and h.space_allocated_delta > 0
  and s.end_interval_time >= (select max(creation_time) from v$datafile where ts# = n.ts#)
order by s.end_interval_time;


-- Objects' dependencies

SELECT *
  FROM DBA_DEPENDENCIES
 WHERE     REFERENCED_OWNER = 'ANALYTIC_DATA'
       AND REFERENCED_NAME IN
               (SELECT OBJECT_NAME
                  FROM DBA_OBJECTS
                 WHERE     OWNER LIKE '%ANALYTIC%'
                       AND (   OBJECT_NAME LIKE '%_BASE'
                            OR OBJECT_NAME LIKE '%_LM'
                            OR OBJECT_NAME LIKE '%_HCNG')
                       AND OBJECT_TYPE = 'TABLE');

-- INDEXES (check indexed columns inside db)

select * from dba_ind_columns where column_name IN ('AMND_DATE','TRANS_DATE') and TABLE_NAME = 'DOC' order by 2,5;
select * from dba_indexes where index_name in (select index_name from dba_ind_columns where column_name IN ('AMND_DATE','TRANS_DATE') and TABLE_NAME = 'DOC');
					   
-- MATERIALIZED VIEWS

--refresh matview (? - force - fast, if impossible - complete) 

set timing on echo on
exec DBMS_SNAPSHOT.REFRESH(LIST=>'EQ.MV_TRADES_ORDERS',METHOD=>'C');
set timing on echo on
exec DBMS_SNAPSHOT.REFRESH(LIST=>'EQ.MV_TRADES_ORDERS',METHOD=> '?');
exec DBMS_SNAPSHOT.REFRESH(LIST=>'EQ.MV_TRADES_ORDERS',METHOD=> '?',parallelism=>2);

set timing on
BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'DM.MV_TRADE_ORDER'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE
   ,NESTED               => FALSE);
END;
/

--complete refresh, if previous did not add data in MVIEW table
BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'FINMODEL.MV_FMD_TRADES_CURR'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE
   ,NESTED               => FALSE);
END;
/

-- procedure explains the various capabilities of a potential materialized view or an existing materialized view

EXEC DBMS_MVIEW.EXPLAIN_MVIEW(MV=>'MDP.MV_EQ_TRADES_ORDERS');
SELECT * FROM MV_CAPABILITIES_TABLE;
delete from MV_CAPABILITIES_TABLE;

--Materialized View Refresh: Log Population and Purge (Doc ID 236233.1), NOT simply truncate MV logs, snapshot info for that log must be cleared first

select * from sys.slog$ where master='F_ATOM_ITEMS_FO_ORD'; --SNAPID

BEGIN
DBMS_SNAPSHOT.PURGE_MVIEW_FROM_LOG (mview_id => 6138); 
END;

-- grants for create matview for tables in another user schema

grant CREATE ANY TABLE to MDP_TEST;
grant COMMENT ANY TABLE to MDP_TEST;
grant SELECT ANY TABLE to MDP_TEST;

-- *LM more than 500MB size

  SELECT *
    FROM DBA_SEGMENTS S, DBA_TABLES T
   WHERE     S.OWNER = T.OWNER
         AND S.SEGMENT_NAME = T.TABLE_NAME
         AND S.SEGMENT_TYPE = 'TABLE'
         AND S.SEGMENT_NAME LIKE '%\_LM' ESCAPE '\'
         AND S.BYTES > 500*1024*1024
ORDER BY S.BYTES DESC;

select max(DAT_TIME) from FORTS_AR_LM.OPT_AR_ORDLOG2016_LM;

SELECT OWNER,PARTITION_NAME,ROUND(BYTES/1024/1024) MB FROM DBA_SEGMENTS WHERE SEGMENT_NAME = 'ORDLOG_BASE' ORDER BY OWNER,PARTITION_NAME;
SELECT OWNER,PARTITION_NAME,SEGMENT_NAME,SEGMENT_TYPE,ROUND(BYTES/1024/1024) MB FROM DBA_SEGMENTS WHERE PARTITION_NAME = 'EQ_ORDERS_BASE_P_20160628';
SELECT * FROM DBA_TAB_PARTITIONS WHERE TABLE_NAME = 'OL_CUWABASPD' AND SEGMENT_CREATED = 'YES' ORDER BY TABLE_OWNER,PARTITION_NAME;
SELECT * FROM DBA_IND_PARTITIONS WHERE INDEX_NAME IN (SELECT INDEX_NAME FROM DBA_INDEXES WHERE TABLE_NAME = 'ORDLOG_BASE') AND SEGMENT_CREATED = 'YES' ORDER BY INDEX_OWNER,PARTITION_NAME;
SELECT 'alter index '||INDEX_OWNER||'.'||INDEX_NAME||' rebuild partition '||PARTITION_NAME||' compress advanced low;' FROM DBA_IND_PARTITIONS WHERE INDEX_NAME LIKE 'ORDLOG_%_UIDX' AND SEGMENT_CREATED = 'NO' ORDER BY INDEX_OWNER,PARTITION_NAME;

-- ILM

--objects
SELECT *
  FROM DBA_ILMDATAMOVEMENTPOLICIES MP, DBA_ILMOBJECTS IO
 WHERE     IO.POLICY_NAME = MP.POLICY_NAME
       --AND SUBOBJECT_NAME NOT LIKE 'SYS_%'
--       AND CONDITION_TYPE = 'CREATION TIME';
       --AND CONDITION_TYPE = 'LAST MODIFICATION TIME'
       AND OBJECT_NAME = 'ORDLOG_BASE'
       AND OBJECT_OWNER = 'EQ';

-- executions
SELECT * FROM SYS.ILM_RESULTS$ WHERE SPARE4 LIKE '%OPT_ORDLOG_5403%';
SELECT * FROM DBA_ILMOBJECTS WHERE OBJECT_NAME='ERRLOG'; --POLICY_NAME
SELECT * FROM DBA_ILMOBJECTS WHERE SUBOBJECT_NAME='OPT_ORDLOG_5403';
SELECT * FROM DBA_ILMDATAMOVEMENTPOLICIES WHERE POLICY_NAME = 'P48605';
SELECT * FROM DBA_ILMPOLICIES WHERE POLICY_NAME='P48605';
SELECT * FROM DBA_ILMEVALUATIONDETAILS WHERE POLICY_NAME='P48605'; --TASK_ID
SELECT * FROM DBA_ILMEVALUATIONDETAILS WHERE POLICY_NAME='P48605' AND JOB_NAME IS NOT NULL; --TASK_ID
SELECT * FROM DBA_ILMEVALUATIONDETAILS WHERE SELECTED_FOR_EXECUTION not in ('TARGET COMPRESSION NOT HIGHER THAN CURRENT','PRECONDITION NOT SATISFIED','POLICY DISABLED')
ORDER BY OBJECT_OWNER,OBJECT_NAME,SUBOBJECT_NAME;
--evaluation deteils for table
SELECT * FROM DBA_ILMEVALUATIONDETAILS WHERE OBJECT_OWNER = 'FORTS_AR' AND OBJECT_NAME = 'FUT_ORDLOG' ORDER BY TO_NUMBER(REGEXP_REPLACE(SUBOBJECT_NAME,'[A-Z,_]',''));
SELECT * FROM DBA_ILMEVALUATIONDETAILS WHERE POLICY_NAME = 'P31245';
SELECT * FROM DBA_ILMEVALUATIONDETAILS WHERE JOB_NAME = 'ILMJOB8609766';
SELECT * FROM DBA_ILMEVALUATIONDETAILS WHERE SUBOBJECT_NAME = 'OPT_ORDLOG_5403';
SELECT * FROM DBA_ILMRESULTS WHERE JOB_NAME='ILMJOB8609766';  --JOB_NAME
-- executed ILM jobs for table
SELECT * FROM DBA_ILMTASKS WHERE TASK_ID IN (SELECT TASK_ID FROM DBA_ILMEVALUATIONDETAILS WHERE POLICY_NAME = 'P31245');
SELECT * FROM SYS.ILM_RESULTS$ WHERE EXECUTION_ID IN (SELECT TASK_ID FROM DBA_ILMEVALUATIONDETAILS WHERE POLICY_NAME = 'P31245');
SELECT * FROM DBA_ILMRESULTS WHERE JOB_NAME IN (SELECT JOB_NAME FROM DBA_ILMEVALUATIONDETAILS WHERE OBJECT_OWNER = 'FORTS_AR' AND OBJECT_NAME = 'FUT_ORDLOG') ORDER BY START_TIME DESC;
SELECT * FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE JOB_NAME='ILMJOB98372';

-- partitions with 2 policies (one from table, one at partition level) SR 3-12940642121 : IMDP message 'Table exists, all dependent metadata will be skipped' on tables with ILM

select distinct OBJECT_OWNER,OBJECT_NAME from 
(SELECT OBJECT_OWNER,OBJECT_NAME,SUBOBJECT_NAME,count(1) FROM DBA_ILMOBJECTS WHERE OBJECT_TYPE = 'TABLE PARTITION' group by OBJECT_OWNER,OBJECT_NAME,SUBOBJECT_NAME having count(1) > 1) order by 1,2;
SELECT 'ALTER TABLE '||OBJECT_OWNER||'.'||OBJECT_NAME||' MODIFY PARTITION '||SUBOBJECT_NAME||' ILM DELETE POLICY '||POLICY_NAME||';' FROM DBA_ILMOBJECTS
WHERE OBJECT_NAME in ('DEAL_BASE') order by OBJECT_OWNER,OBJECT_NAME,SUBOBJECT_NAME;
ALTER TABLE COGNOS_DATA.ACTI_CUBE_ABC3_REPORT_BASE ILM DELETE_ALL;
select 'ALTER TABLE '||OBJECT_OWNER||'.'||OBJECT_NAME||' MODIFY PARTITION '||subobject_name||' ILM DELETE_ALL;' from dba_ilmobjects where object_NAME='ACTI_CUBE_ABC3_REPORT_BASE';
SELECT * FROM DBA_ILMOBJECTS WHERE POLICY_NAME = 'P45965';
SELECT * FROM DBA_ILMOBJECTS WHERE OBJECT_NAME = 'P2_PROXY_LOG_BASE2016';
SELECT * FROM DBA_ILMOBJECTS WHERE OBJECT_TYPE = 'TABLE PARTITION' AND OBJECT_NAME = 'P2_PROXY_LOG_BASE2016' and INHERITED_FROM = 'POLICY NOT INHERITED';
SELECT * FROM DBA_ILMOBJECTS WHERE OBJECT_TYPE = 'TABLE SUBPARTITION' AND OBJECT_NAME = 'P2_PROXY_LOG_BASE2016' and INHERITED_FROM = 'POLICY NOT INHERITED';
SELECT p.TABLE_NAME,p.PARTITION_NAME,p.COMPRESS_FOR,i.POLICY_NAME,i.SUBOBJECT_NAME FROM DBA_ILMOBJECTS i,DBA_TAB_SUBPARTITIONS p WHERE i.OBJECT_NAME = p.TABLE_NAME and i.SUBOBJECT_NAME = p.SUBPARTITION_NAME and i.OBJECT_TYPE = 'TABLE SUBPARTITION' AND i.OBJECT_NAME = 'P2_PROXY_LOG_BASE2016'
order by TO_DATE(REPLACE(p.PARTITION_NAME,'P2_PROXY_LOG_BASE_',''),'yyyymmdd'),i.SUBOBJECT_NAME;
-- delete not INHERITED POILITICIES FROM TABLE PARTITIONS
SELECT 'ALTER TABLE '||OBJECT_OWNER||'.'||OBJECT_NAME||' MODIFY PARTITION '||SUBOBJECT_NAME||' ILM DELETE POLICY '||POLICY_NAME||';'
FROM DBA_ILMOBJECTS WHERE OBJECT_TYPE = 'TABLE PARTITION' AND OBJECT_NAME = 'P2_PROXY_LOG_BASE2016' and INHERITED_FROM = 'POLICY NOT INHERITED';
-- disable and delete all policies from table
alter table FORTS_REPAAR.P2_PROXY_LOG_BASE2016 ILM DELETE POLICY P42123;
alter table FORTS_REPAAR.P2_PROXY_LOG_BASE2016 ILM DISABLE_ALL;
alter table FORTS_REPAAR.P2_PROXY_LOG_BASE2016 ILM DELETE_ALL;

-- init parameters

select * from v$spparameter where ISSPECIFIED = 'TRUE' order by NAME;

-- FLASHBACK

SELECT DISTINCT F.OWNER_NAME||'.'||F.TABLE_NAME FROM DBA_FLASHBACK_ARCHIVE_TABLES F,DBA_ILMOBJECTS I WHERE F.OWNER_NAME = I.OBJECT_OWNER AND F.TABLE_NAME = I.OBJECT_NAME ORDER BY 1;
SELECT * FROM DBA_FLASHBACK_ARCHIVE_TABLES ORDER BY 2,1; --ARCHIVE_TABLE_NAME
SELECT * FROM DBA_FLASHBACK_ARCHIVE_TABLES WHERE ARCHIVE_TABLE_NAME LIKE '%7044725%';
SELECT * FROM DBA_FLASHBACK_ARCHIVE_TABLES WHERE OWNER_NAME = 'COGNOS_DATA' ORDER BY 2,1; --ARCHIVE_TABLE_NAME
SELECT * FROM DBA_FLASHBACK_ARCHIVE_TABLES WHERE TABLE_NAME = 'HP_FA_ACCOUNTS_BASE' ORDER BY 2,1; --ARCHIVE_TABLE_NAME
exec DBMS_FLASHBACK_ARCHIVE.disassociate_fba(owner_name=>'FORTS_CLEARING',table_name=>'DEAL_BASE');
exec DBMS_FLASHBACK_ARCHIVE.reassociate_fba(owner_name=>'FORTS_CLEARING',table_name=>'DEAL_BASE');
exec DBMS_FLASHBACK_ARCHIVE.disassociate_fba(owner_name=>'MOSCOW_EXCHANGE',table_name=>'VALUE_MASTER_DATA');
Alter table FORTS_CLEARING.DEAL_BASE move partition DEAL_BASE_1 row store compress basic update indexes online ;
exec DBMS_FLASHBACK_ARCHIVE.reassociate_fba(owner_name=>'MOSCOW_EXCHANGE',table_name=>'INPUT_MODIFY');

-- query from flashback archive for the given table
select 'B',b.*  from FORTS_CLEARING.SYS_MONEY_REPORT_BASE as of timestamp(to_timestamp(to_date('29.07.2017 14:00:00','dd.mm.yyyy hh24:mi:ss'))) b  where trunc(b.UPDATEDT) = to_date('28.07.2017','dd.mm.yyyy') and b.L_ID = 25625265;

-- oldest change in flashback archive table

select min(ENDSCN),max(STARTSCN) from FORTS_CLEARING.SYS_FBA_HIST_188363;
select scn_to_timestamp(10165568098824),scn_to_timestamp(10175229131114) from dual;
select min(ENDSCN),min(STARTSCN) from EQ.SYS_FBA_HIST_424490;
select scn_to_timestamp(10160335182653),scn_to_timestamp(10160335164563) from dual;

-- FLASHBACK DATABASE

SELECT OLDEST_FLASHBACK_TIME,
       ROUND (FLASHBACK_SIZE / 1024 / 1024 / 1024, 1) FLASHBACK_SIZE_GB,
       ROUND (ESTIMATED_FLASHBACK_SIZE / 1024 / 1024 / 1024, 1)
           ESTIMATED_FLASHBACK_SIZE_GB,
       RETENTION_TARGET
  FROM V$FLASHBACK_DATABASE_LOG;
SELECT * FROM V$FLASHBACK_DATABASE_LOGFILE ORDER BY FIRST_TIME;
SELECT * FROM V$FLASHBACK_DATABASE_STAT ORDER BY 1;
SELECT * FROM V$FLASH_RECOVERY_AREA_USAGE;

-- sql to objects of INTERNAL% schemas in history, exclude app server
select distinct SQL_ID from DBA_HIST_ACTIVE_SESS_HISTORY where SQL_ID in
(SELECT distinct SQL_ID FROM DBA_HIST_SQLTEXT where upper(SQL_TEXT) like '%INTERNAL%'
UNION
SELECT distinct SQL_ID FROM V$SQLTEXT where upper(SQL_TEXT) like '%INTERNAL%') and MACHINE <> 'asbpel';

SELECT * FROM V$SESSION WHERE SERIAL# = 825;
SELECT COUNT(1),USERNAME,SERVICE_NAME,MACHINE FROM V$SESSION GROUP BY USERNAME,SERVICE_NAME,MACHINE ORDER BY 1 DESC;
SELECT * FROM V$SESSION WHERE SID in (2736);
SELECT * FROM V$SESSION WHERE BLOCKING_SESSION in (1561,1285);
SELECT * FROM V$SESSION WHERE USERNAME = 'MDP';
select * from v$process where addr = (SELECT PADDR FROM V$SESSION WHERE SID in (825));
select count(1),MACHINE from v$session group by MACHINE order by 1 desc;
select count(1),'sessions' from v$session
union all
select count(1),'processes' from v$process;
select * from v$session;
select * from v$process order by PNAME;
select count(1),MACHINE,SCHEMANAME from v$session group by  MACHINE,SCHEMANAME order by 1 desc;

-- users locked a object (table for change)

SELECT    'USER: '
       || S.USERNAME
       || ' SID: '
       || S.SID
       || ' SERIAL #: '
       || S.SERIAL#
           "USER HOLDING LOCK",
       O.OBJECT_NAME,
       O.OBJECT_TYPE
  FROM GV$LOCK L, DBA_OBJECTS O, GV$SESSION S
 WHERE     L.ID1 = O.OBJECT_ID
       AND S.SID = L.SID
       --AND O.OWNER = 'SPUR_DAY'
       AND O.OBJECT_NAME = 'F_ATOM_ITEMS_RP_ORD_LM';
;

--Displays undo information on relevant database sessions

SELECT s.username,
       s.sid,
       s.serial#,
       t.used_ublk,
       t.used_urec,
       rs.segment_name,
       round(r.rssize/1024/1024/1024,1) GB,
       r.status
FROM   v$transaction t,
       v$session s,
       v$rollstat r,
       dba_rollback_segs rs
WHERE  s.saddr = t.ses_addr
AND    t.xidusn = r.usn
AND    rs.segment_id = t.xidusn
--ORDER BY t.used_ublk DESC;
ORDER BY r.rssize DESC;

set linesize 250 pagesize 10000
col sum_bytes for 999,999,999,999,999
select to_char(sysdate,'dd-mm-yyyy hh24:mi:ss') from dual;
SELECT DISTINCT STATUS, SUM(BYTES) sum_bytes, COUNT(*),TABLESPACE_NAME FROM DBA_UNDO_EXTENTS GROUP BY TABLESPACE_NAME,STATUS;
select tablespace_name , status , count(*) from dba_rollback_segs group by tablespace_name , status;

select file_id from dba_data_files where tablespace_name='UNDOTBS2';
select begin_time, end_time, UNDOBLKS,MAXQUERYLEN,ACTIVEBLKS,UNEXPIREDBLKS,EXPIREDBLKS,TUNED_UNDORETENTION from v$undostat order by begin_time;
select SNAP_ID,BEGIN_TIME,END_TIME,UNDOBLKS,MAXQUERYLEN,ACTIVEBLKS,UNEXPIREDBLKS,EXPIREDBLKS,TUNED_UNDORETENTION from sys.WRH$_UNDOSTAT order by snap_id,begin_time;
  SELECT BEGIN_TIME,
         UNXPSTEALCNT "#UnexpiredBlksTaken",
         EXPSTEALCNT "#ExpiredBlksTaken",
         NOSPACEERRCNT "SpaceRequests"
    FROM V$UNDOSTAT
ORDER BY BEGIN_TIME;
SELECT regid, table_name FROM DBA_CHANGE_NOTIFICATION_REGS;
select * from USER_CHANGE_NOTIFICATION_REGS;
select * from DBA_CQ_NOTIFICATION_QUERIES;

--recreate undo TS

--create undo tablespace UNDOTBS1;
alter system set undo_retention = 0 scope = memory sid = '*';
alter system set undo_tablespace = UNDOTBS1 scope = both sid = '*';
alter system set undo_retention = 3600 scope = memory sid = '*';
-- drop old undo TS

--Drop tablespace UNDOTBS1 including contents and datafiles;
