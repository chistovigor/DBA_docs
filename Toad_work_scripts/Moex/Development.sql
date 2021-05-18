-- objects size in the schema

SELECT * FROM TABLE(OUTST_POLKOVNIKOVMO.UTIL_DBA_INFO.GET_TABLES_SIZE('LDWH',OUTST_POLKOVNIKOVMO.UTIL_DBA_INFO.C_GB_SIZE));

-- compression used for variuos rows in a table

SELECT rowid,
       CASE DBMS_COMPRESSION.get_compression_type ('FORTS_JAVA', 'FUT_USER_DEAL_BASE', rowid)
         WHEN 1     THEN 'COMP_NOCOMPRESS'
         WHEN 2     THEN 'COMP_ADVANCED'
         WHEN 4     THEN 'COMP_QUERY_HIGH'
         WHEN 8     THEN 'COMP_QUERY_LOW'
         WHEN 16    THEN 'COMP_ARCHIVE_HIGH'
         WHEN 32    THEN 'COMP_ARCHIVE_LOW'
         WHEN 64    THEN 'COMP_BLOCK'
         WHEN 128   THEN 'COMP_LOB_HIGH'
         WHEN 256   THEN 'COMP_LOB_MEDIUM'
         WHEN 512   THEN 'COMP_LOB_LOW'
         WHEN 1024  THEN 'COMP_INDEX_ADVANCED_HIGH'
         WHEN 2048  THEN 'COMP_INDEX_ADVANCED_LOW'
         WHEN 1000  THEN 'COMP_RATIO_LOB_MINROWS'
         WHEN 4096  THEN 'COMP_BASIC'
         WHEN 5000  THEN 'COMP_RATIO_LOB_MAXROWS'
         WHEN 8192  THEN 'COMP_INMEMORY_NOCOMPRESS'
         WHEN 16384 THEN 'COMP_INMEMORY_DML'
         WHEN 32768 THEN 'COMP_INMEMORY_QUERY_LOW'
         WHEN 65536 THEN 'COMP_INMEMORY_QUERY_HIGH'
         WHEN 32768 THEN 'COMP_INMEMORY_CAPACITY_LOW'
         WHEN 65536 THEN 'COMP_INMEMORY_CAPACITY_HIGH'
       END AS compression_type
FROM   FORTS_JAVA.FUT_USER_DEAL_BASE
WHERE SESS_ID = 5500 and  rownum <= 15;

-- find out the space gain when using compression

SET SERVEROUTPUT ON
DECLARE
  l_blkcnt_cmp    PLS_INTEGER;
  l_blkcnt_uncmp  PLS_INTEGER;
  l_row_cmp       PLS_INTEGER;
  l_row_uncmp     PLS_INTEGER;
  l_cmp_ratio     NUMBER;
  l_comptype_str  VARCHAR2(32767);
BEGIN
  DBMS_COMPRESSION.get_compression_ratio (
    scratchtbsname  => 'OPT_VM_BASE_TST',
    ownname         => 'FORTS_JAVA',
    tabname         => 'OPT_VM_BASE',
    partname        => NULL,
    --comptype        => DBMS_COMPRESSION.comp_for_oltp,
    comptype        => DBMS_COMPRESSION.COMP_ARCHIVE_LOW,
    blkcnt_cmp      => l_blkcnt_cmp,
    blkcnt_uncmp    => l_blkcnt_uncmp,
    row_cmp         => l_row_cmp,
    row_uncmp       => l_row_uncmp,
    cmp_ratio       => l_cmp_ratio,
    comptype_str    => l_comptype_str,
    subset_numrows  => DBMS_COMPRESSION.comp_ratio_allrows
  );

  DBMS_OUTPUT.put_line('Number of blocks used (compressed)       : ' ||  l_blkcnt_cmp);
  DBMS_OUTPUT.put_line('Number of blocks used (uncompressed)     : ' ||  l_blkcnt_uncmp);
  DBMS_OUTPUT.put_line('Number of rows in a block (compressed)   : ' ||  l_row_cmp);
  DBMS_OUTPUT.put_line('Number of rows in a block (uncompressed) : ' ||  l_row_uncmp);
  DBMS_OUTPUT.put_line('Compression ratio                        : ' ||  l_cmp_ratio);
  DBMS_OUTPUT.put_line('Compression type                         : ' ||  l_comptype_str);
END;
/

-- template for partitioned table

--INTERVAL( NUMTODSINTERVAL(1,'DAY'))

/*
ROW STORE COMPRESS ADVANCED
TABLESPACE EQ_DATA
PCTUSED    0
PCTFREE    3
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING
ILM ADD POLICY COMPRESS FOR ARCHIVE LOW SEGMENT AFTER 1 MONTH OF CREATION
PARTITION BY RANGE (TRADEDATE)
INTERVAL( NUMTODSINTERVAL(1,'DAY'))
(  
  PARTITION START_PART_TABLE VALUES LESS THAN (TO_DATE(' 2005-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
);
*/

/*

LOGGING 
ILM ADD POLICY COMPRESS FOR ARCHIVE HIGH SEGMENT AFTER 13 MONTH OF CREATION
PARTITION BY RANGE (GL_DATE)
INTERVAL( NUMTOYMINTERVAL(1,'MONTH'))
(  
  PARTITION ST_XXGL050_NFO_BALANCE_BASE VALUES LESS THAN (TO_DATE(' 2000-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
);


*/


-- ONLINE speed increasing

--1) interval table tradeno by tradedate

DROP TABLE EQ.TRADEDATE_TRADENO_INTERVAL;

set timing on echo on
CREATE TABLE EQ.TRADEDATE_TRADENO_INTERVAL
AS
      SELECT TB.TRADEDATE   T_TRADEDATE,
             MIN (TB.TRADENO) MIN_TRADENO,
             MAX (TB.TRADENO) MAX_TRADENO
        FROM EQ.TRADES_BASE TB
       WHERE TB.TRADEDATE < (SELECT MAX (TRADEDATE) FROM EQ.TRADES_BASE)
    GROUP BY TB.TRADEDATE;
    
--2) view for ONLINE using this table (ONLY rows from TRADES table)

DROP VIEW EQ.V_TRADES_ONLINE_TEST;
--DROP VIEW EQ.V_TRADES_ONLINE_TEST1; --plan with table partition full scan worse than with INDEX partition range scan

CREATE OR REPLACE VIEW EQ.V_TRADES_ONLINE_TEST
AS
    SELECT TB.*
      FROM TRADES_BASE TB
     WHERE EXISTS
               (SELECT *
                  FROM TRADEDATE_TRADENO_INTERVAL TS
                 WHERE     TS.T_TRADEDATE = TB.TRADEDATE
                       AND TB.TRADENO BETWEEN TS.MIN_TRADENO
                                          AND TS.MAX_TRADENO);
                                          
-- daily update table with new tradeno for the current tradedate (!!! ONLY in business days)

--current tradedate

--check the update
SELECT COUNT(1) FROM EQ.TRADEDATE_TRADENO_INTERVAL GROUP BY T_TRADEDATE HAVING COUNT(1) > 1;
SELECT * FROM EQ.TRADEDATE_TRADENO_INTERVAL WHERE T_TRADEDATE >= (SELECT MAX(T_TRADEDATE)-1 FROM EQ.TRADEDATE_TRADENO_INTERVAL); --23.05.2018	2836616176	999999999999999 --����� ���������� 2836616176	2837066650

UPDATE EQ.TRADEDATE_TRADENO_INTERVAL
   SET MIN_TRADENO =
           (  SELECT MIN (TB.TRADENO)
                FROM EQ.TRADES_BASE TB
               WHERE TB.TRADEDATE =
                     (SELECT MAX(T_TRADEDATE) FROM EQ.TRADEDATE_TRADENO_INTERVAL)
            GROUP BY TB.TRADEDATE),
       MAX_TRADENO =
           (  SELECT MAX (TB.TRADENO)
                FROM EQ.TRADES_BASE TB
               WHERE TB.TRADEDATE =
                     (SELECT MAX(T_TRADEDATE) FROM EQ.TRADEDATE_TRADENO_INTERVAL)
            GROUP BY TB.TRADEDATE)
 WHERE T_TRADEDATE = (SELECT MAX(T_TRADEDATE) FROM EQ.TRADEDATE_TRADENO_INTERVAL);

--next tradedate

--new row insert
INSERT INTO EQ.TRADEDATE_TRADENO_INTERVAL (T_TRADEDATE,
                                           MIN_TRADENO,
                                           MAX_TRADENO)
      SELECT MAX (T_TRADEDATE) + 1, MAX_TRADENO + 1, 999999999999
        FROM EQ.TRADEDATE_TRADENO_INTERVAL
       WHERE T_TRADEDATE =
             (SELECT MAX (T_TRADEDATE) FROM EQ.TRADEDATE_TRADENO_INTERVAL)
    GROUP BY T_TRADEDATE, MAX_TRADENO;


DECLARE
V_MAX_TRADEDATE DATE;
V_MAX_DATE_IN_INT_TABLE DATE;
V_MAX_TRADENO_PREV NUMBER;
V_MIN_TRADENO_CURRENT NUMBER;
BEGIN

-- find current values for border variables

SELECT MAX(TRADENO) INTO V_MAX_TRADENO_PREV FROM EQ.TRADES_BASE WHERE TRADEDATE = TRUNC(SYSDATE-1);
SELECT MAX(TRADENO) + 1 INTO V_MIN_TRADENO_CURRENT FROM EQ.TRADES_BASE WHERE TRADEDATE = (SELECT MAX(TRADEDATE) FROM EQ.TRADES_BASE WHERE TRADEDATE >= SYSDATE-15);
SELECT MAX(T_TRADEDATE) INTO V_MAX_DATE_IN_INT_TABLE FROM EQ.TRADEDATE_TRADENO_INTERVAL;
SELECT MAX(TRADEDATE) INTO V_MAX_TRADEDATE FROM EQ.TRADES_BASE WHERE TRADEDATE >= SYSDATE-15;

-- daily update the last row of the service table with actual for previuos tradedate data (if previuos sysdate was tradedate)

IF V_MAX_DATE_IN_INT_TABLE = V_MAX_TRADEDATE THEN

UPDATE EQ.TRADEDATE_TRADENO_INTERVAL
   SET MIN_TRADENO =
           (  SELECT MIN (TB.TRADENO)
                FROM EQ.TRADES_BASE TB
               WHERE TB.TRADEDATE = V_MAX_DATE_IN_INT_TABLE
            GROUP BY TB.TRADEDATE),
       MAX_TRADENO =
           (  SELECT MAX (TB.TRADENO)
                FROM EQ.TRADES_BASE TB
               WHERE TB.TRADEDATE = V_MAX_DATE_IN_INT_TABLE
            GROUP BY TB.TRADEDATE)
 WHERE T_TRADEDATE = V_MAX_DATE_IN_INT_TABLE;
 
 END IF;
 
-- if previuos sysdate was not tradedate then update newest row in the service table with potential data for the next tradedate

IF V_MAX_TRADENO_PREV IS NULL THEN
UPDATE EQ.TRADEDATE_TRADENO_INTERVAL
   SET T_TRADEDATE = V_MAX_DATE_IN_INT_TABLE + 1,
       MIN_TRADENO = V_MIN_TRADENO_CURRENT,
       MAX_TRADENO = 999999999999
 WHERE T_TRADEDATE = V_MAX_DATE_IN_INT_TABLE;
ELSE
-- if sysdate was tradedate - insert new for for the next potential tradedate
 INSERT INTO EQ.TRADEDATE_TRADENO_INTERVAL (T_TRADEDATE,
                                           MIN_TRADENO,
                                           MAX_TRADENO)
      VALUES (V_MAX_DATE_IN_INT_TABLE + 1, V_MIN_TRADENO_CURRENT, 999999999999);
END IF;

COMMIT;

--EXCEPTION BLOCK !

END;

--check the insert
SELECT 'EQ_TRADES' AS "TABLE",TRADEDATE,MIN(TRADENO),MAX(TRADENO) FROM EQ.TRADES_BASE WHERE TRADEDATE >= TRUNC(ADD_MONTHS(SYSDATE,-1)) GROUP BY TRADEDATE
UNION ALL                    
SELECT 'NEW_TABLE',T_TRADEDATE,MIN_TRADENO,MAX_TRADENO FROM EQ.TRADEDATE_TRADENO_INTERVAL WHERE T_TRADEDATE >= (SELECT MAX(TRUNC(ADD_MONTHS(SYSDATE,-1))) FROM EQ.TRADEDATE_TRADENO_INTERVAL) order by 2;

SELECT * FROM EQ.TRADEDATE_TRADENO_INTERVAL order by 1;
                    
select nvl(trunc(sysdate-1),trunc(sysdate)) from dual;
select nvl(null,trunc(sysdate)) from dual;
SELECT NVL(MAX (TRADEDATE),TRUNC(SYSDATE+1)) FROM EQ.TRADES_BASE WHERE TRADEDATE > (SELECT MAX(T_TRADEDATE) FROM EQ.TRADEDATE_TRADENO_INTERVAL);
SELECT NVL(MAX (TRADEDATE),TRUNC(SYSDATE+1)) FROM EQ.TRADES_BASE WHERE TRADEDATE = (trunc(sysdate-2));

-- check ONLINE operations using new table

select * from EQ.TRADEDATE_TRADENO_INTERVAL order by T_TRADEDATE desc;
select * from EQ.V_TRADES_ONLINE_TEST where TRADENO = 2836202808 + 100 and BUYSELL = 'B';
select * from SPUR_DAY.TRADES where TRADENO = 2836202808 + 100 and BUYSELL = 'B';
select * from EQ.V_TRADES_ONLINE_TEST where TRADENO = 2836202808 + 100 and BUYSELL = 'S';
select /*+ gather_plan_statistics */ * from EQ.V_TRADES_ONLINE_TEST where TRADENO = 2836202808 + 100 and BUYSELL = 'S';
--update SPUR_DAY.TRADES set CONFIRMED = 'C' where TRADENO = 2836202808 + 100 and BUYSELL = 'B';
--update EQ.V_TRADES_ONLINE_TEST set CONFIRMED = 'C' where TRADENO = 2836202808 + 100 and BUYSELL = 'B';
select * from DBA_UPDATABLE_COLUMNS where TABLE_NAME = 'V_TRADES_ONLINE_TEST' and OWNER = 'EQ';

--compare old and new trade objects
SELECT *
  FROM (SELECT *
          FROM EQ.V_TRADES_ONLINE_TEST
         WHERE TRADEDATE = TRUNC (SYSDATE - 1)
        MINUS
        SELECT *
          FROM SPUR_DAY.TRADES
         WHERE TRADEDATE = TRUNC (SYSDATE - 1))
UNION ALL
(SELECT *
   FROM SPUR_DAY.TRADES
  WHERE TRADEDATE = TRUNC (SYSDATE - 1)
 MINUS
 SELECT *
   FROM EQ.V_TRADES_ONLINE_TEST
  WHERE TRADEDATE = TRUNC (SYSDATE - 1));

-- �������� ��������� ������� ��� ���� (http://jira.moex.com/browse/SPUR-152) ! ������ �� CCP_NORM, ST_DATA_SET �� �������� ����� var-scan5.moex.com - http://jira.moex.com/browse/SPUR-154
--(�������, ������, ������� ����������, ������������)
--!!! �������������� ������� ����� CCP_NORM_TEST,ST_DATA_SET_TEST,NCC_NORM_UI_TEST,LOADER_CCP_NORM_TEST

set timing on echo on termout on serveroutput on
begin
CREATE_CCP_NORM_TEST.EXP_CCP_NORM_TEST;
CREATE_CCP_NORM_TEST.IMP_CCP_NORM_TEST;
CREATE_CCP_NORM_TEST.GRANTS_TO_CCP_NORM_TEST;
end;
/
select sysdate from dual;

-- �������� ����� �������� �����������

select * from v$session where upper(action) like '%PROCEDURE WORKING%';
select CREATE_CCP_NORM_TEST.CHECK_CURRENT_JOB('EXP_CCP_NORM_TEST') from dual;
select CREATE_CCP_NORM_TEST.CHECK_CURRENT_JOB('IMP_CCP_NORM_TEST') from dual;

select CREATE_CCP_NORM_TEST.CHECK_ACTIVE_SESSIONS('a') from dual;
select CREATE_CCP_NORM_TEST.CHECK_ACTIVE_SESSIONS from dual;

-- data pump

-- EXLUDE SCHEMAS DDL DURING EXPORT

        DBMS_DATAPUMP.SET_PARAMETER (HANDLE   => V_JOB_HANDLE,
                                     NAME     => 'USER_METADATA',
                                     VALUE    => 0);

-- http://jira.moex.com/browse/ORACLE-44 ( archivelog )
--���������������� ���������� ����� ���������� ���������� (�������� �� 2, ����� ������������ � ��������� ������� �����)

--folder Huge_REDO_generation
-- file for tracing ONLINE SE ORDERS: ll -th spur1_ora_81709.trc, file for FORTS_JAVA_LM: spur1_ora_156447_FORTS_JAVA_LM.tkp 

  SELECT USERNAME,
         MACHINE,
         TRUNC (SNAP_DATE)                               DAY,
         EXTRACT (HOUR FROM CAST (SNAP_DATE AS TIMESTAMP)) HOUR,
         TRUNC (SUM (DELTA_REDO_SIZE) / 1000000000*2)    REDO_GB
    FROM DB_AFONINSS.REDO_SESSION_HISTORY
   WHERE USERNAME <> 'SYS'
GROUP BY USERNAME,
         MACHINE,
         TRUNC (SNAP_DATE),
         EXTRACT (HOUR FROM CAST (SNAP_DATE AS TIMESTAMP))
  HAVING TRUNC (SUM (DELTA_REDO_SIZE) / 1000000000*2) > 1
ORDER BY TRUNC (SNAP_DATE) DESC,
         EXTRACT (HOUR FROM CAST (SNAP_DATE AS TIMESTAMP)),
         TRUNC (SUM (DELTA_REDO_SIZE) / 1000000000*2) DESC;
         
select min(SNAP_DATE),max(SNAP_DATE) from DB_AFONINSS.REDO_SESSION_HISTORY;
select * from DB_AFONINSS.REDO_SESSION_HISTORY;

-- schemas generated maximum REDO

  SELECT USERNAME, MACHINE, TRUNC (SUM (DELTA_REDO_SIZE) / 1000000000*2) REDO_GB
    FROM DB_AFONINSS.REDO_SESSION_HISTORY
     WHERE USERNAME <> 'SYS'
  HAVING TRUNC (SUM (DELTA_REDO_SIZE) / 1000000000*2) > 2
GROUP BY USERNAME, MACHINE
ORDER BY TRUNC (SUM (DELTA_REDO_SIZE) / 1000000000*2) DESC;

-- during last month

  SELECT USERNAME, MACHINE, TRUNC (SUM (DELTA_REDO_SIZE) / 1000000000*2) REDO_GB
    FROM DB_AFONINSS.REDO_SESSION_HISTORY
     WHERE USERNAME <> 'SYS' AND SNAP_DATE >= TRUNC(ADD_MONTHS(SYSDATE,-1))
  HAVING TRUNC (SUM (DELTA_REDO_SIZE) / 1000000000*2) > 2
GROUP BY USERNAME, MACHINE
ORDER BY TRUNC (SUM (DELTA_REDO_SIZE) / 1000000000*2) DESC;

  SELECT USERNAME, MACHINE, TRUNC (SUM (DELTA_REDO_SIZE) / 1000000000*2) REDO_GB, TRUNC(SNAP_DATE) DAY
    FROM DB_AFONINSS.REDO_SESSION_HISTORY
     WHERE USERNAME <> 'SYS'
     AND TRUNC(SNAP_DATE) < TRUNC(SYSDATE)
  HAVING TRUNC (SUM (DELTA_REDO_SIZE) / 1000000000*2) > 2
GROUP BY USERNAME, MACHINE, TRUNC(SNAP_DATE)
ORDER BY TRUNC(SNAP_DATE) DESC,TRUNC (SUM (DELTA_REDO_SIZE) / 1000000000*2) DESC;

-- statements generated maximum REDO

  SELECT R.USERNAME,
         R.MACHINE,
         R.SQL_ID,
         CAST (H.SQL_TEXT AS VARCHAR2 (4000)),
         TRUNC (SUM (R.DELTA_REDO_SIZE) / 1000000000 * 2) REDO_GB
    FROM DB_AFONINSS.REDO_SESSION_HISTORY R, DBA_HIST_SQLTEXT H
   WHERE R.USERNAME IN ('LOADER_MDM') AND R.SQL_ID = H.SQL_ID
  HAVING TRUNC (SUM (R.DELTA_REDO_SIZE) / 1000000000 * 2) > 2
GROUP BY R.USERNAME,
         R.MACHINE,
         R.SQL_ID,
         CAST (H.SQL_TEXT AS VARCHAR2 (4000))
ORDER BY TRUNC (SUM (DELTA_REDO_SIZE) / 1000000000 * 2) DESC;

select * from DBA_HIST_SQLTEXT where SQL_ID = 'dkcf9jhaus87s';

-- statements generated maximum REDO for the table and for the period

  SELECT R.USERNAME,
         R.MACHINE,
         R.SQL_ID,
         CAST (H.SQL_TEXT AS VARCHAR2 (4000)),
         TRUNC (SUM (R.DELTA_REDO_SIZE) / 1000000000 * 2) REDO_GB,
         TRUNC (SNAP_DATE)                              DATA
    FROM DB_AFONINSS.REDO_SESSION_HISTORY R, DBA_HIST_SQLTEXT H
   WHERE     R.USERNAME IN ('FORTS_JAVA_LM')
         AND R.SQL_ID = H.SQL_ID
         --AND CAST (H.SQL_TEXT AS VARCHAR2 (4000)) LIKE '%POSITION%'
         AND TRUNC (SNAP_DATE) BETWEEN TRUNC (SYSDATE - 10) AND TRUNC (SYSDATE - 1)
       --  AND EXTRACT (HOUR FROM CAST (SNAP_DATE AS TIMESTAMP)) > 12
GROUP BY R.USERNAME,
         R.MACHINE,
         R.SQL_ID,
         CAST (H.SQL_TEXT AS VARCHAR2 (4000)),
         TRUNC (SNAP_DATE)
ORDER BY TRUNC (SNAP_DATE) DESC, TRUNC (SUM (DELTA_REDO_SIZE) / 1000000000 * 2) DESC; 

-- REDO generated by session for SQL_ID from previous statement

  SELECT S.SID,
         S.LOGON_TIME,
         SYSDATE,
         S.USERNAME,
         S.MACHINE,
         S.PROGRAM,
         SN.NAME,
         ROUND (SS.VALUE / 1024 / 1024) MB
    FROM V$SESSTAT SS, V$STATNAME SN, V$SESSION S
   WHERE     SS.STATISTIC# = SN.STATISTIC#
         AND S.SID = SS.SID
         AND S.SID IN
                 (SELECT SID
                    FROM V$SESSION
                   WHERE     SID IN
                                 (SELECT DISTINCT SESSION_ID
                                    FROM V$ACTIVE_SESSION_HISTORY
                                   WHERE     SQL_ID = 'c5awhz5h0ufra'
                                         AND SAMPLE_TIME >= SYSDATE - 1 / 24)
                         AND SCHEMANAME = 'FORTS_JAVA_LM'
                  UNION ALL
                  SELECT SID
                    FROM V$SESSION
                   WHERE     PROGRAM =
                             'GWDBUpdTradesOracle.spur_exadata.orders@dgw1 (TN'
                         AND SCHEMANAME = 'SPUR_DAY')
         AND SN.NAME IN ('redo size', 'undo change vector size')
ORDER BY S.USERNAME, SS.VALUE DESC;

-- size of all objects in the schema (check RW TS ONLY !!!)

  SELECT ROUND(SUM (BYTES)/1024/1024/1024) GB, TABLESPACE_NAME, OWNER
    FROM DBA_SEGMENTS
   WHERE OWNER = 'FORTS_JAVA_LM'
GROUP BY TABLESPACE_NAME, OWNER;

-- �������������� �������������� ������� � ������� ����� ��� ��������

CREATE OR REPLACE TRIGGER create_view_trigger
  AFTER CREATE ON ST_DATA_SET.SCHEMA
BEGIN
  IF SYS.DICTIONARY_OBJ_TYPE in ('TABLE', 'VIEW') THEN
-- ����� �� ������� �������� ��� ������ ������� � ����������� ������:
         execute immediate 'GRANT SELECT ON '||SYS.DICTIONARY_OBJ_NAME||' TO R_ALDONINAVV';
      END IF;
END;
--������/����������� MDP.insert_SE_ord_trd_online ��. http://jira.moex.com/browse/MDP-34

--https://mauro-pagano.com/2016/05/05/how-to-find-file-and-block-to-dump-in-exadata/
������ �������� � UNDO (obj#=0) ��� ������� ������ ����
WAIT #139814194230344: nam='cell single block physical read' ela= 175 cellhash#=1796605293 diskhash#=791468035 bytes=8192 obj#=0 tim=5253059754126
alter session set events '10200 trace name context forever, level 1';
alter session set events '10201 trace name context forever';
alter session set events '10203 trace name context forever';
--��������� �����������
alter session set events 'immediate trace name trace_buffer_off';

begin
MDP_TEST.insert_SE_ord_trd_online;
end;

begin
MDP_TEST.INSERT_SE_ORD_TR_DAY_V(trunc(sysdate-1));
end;

begin
MDP_TEST.insert_CU_ord_trd_online;
end;
begin
MDP_TEST.INSERT_CU_ORD_TR_DAY_V(trunc(sysdate-1));
end;

select * from MDP_TEST.v_lor where PROC = 'CU';
select * from MDP.v_lor where PROC = 'CU';

SELECT 'TST', T.*
  FROM MDP_TEST.V_LOR T
 WHERE T.PROC = 'SE' AND T.DAY = TO_DATE ('17.01.2018', 'dd.mm.yyyy')
UNION ALL
SELECT 'PROD', P.*
  FROM MDP.V_LOR P
 WHERE P.PROC = 'SE' AND P.DAY = TO_DATE ('17.01.2018', 'dd.mm.yyyy')
ORDER BY 2, 6 DESC, 1;

select * from MDP_TEST.v_lor where PROC = 'SE';
select * from MDP.v_lor where PROC = 'SE';
select * from MDP.SE_ORD_TRD_LOG_ONLINE;
select * from MDP_TEST.SE_ORD_TRD_LOG_ONLINE;
select count(*) from MDP_TEST.SE_ORD_TRD_LOG_ONLINE;
select count(*) from MDP.SE_ORD_TRD_LOG_ONLINE; --10610 (� 11-54)
truncate table MDP_TEST.SE_ORD_TRD_LOG_ONLINE;

select * from MDP.errlog where proc = 'insert_se_ord_trd_online' order by UPDATEDT desc;

-- move archive data for partitions without indexes

set timing on echo on feedback on
ALTER TABLESPACE CURR_ORD_2014 READ WRITE;
ALTER TABLESPACE CURR_ORD_2014 RENAME TO CURR_ORD_2014_OLD;
CREATE BIGFILE TABLESPACE CURR_ORD_2014 DATAFILE '+DATAC1' SIZE 10M AUTOEXTEND ON NEXT 10M LOGGING DEFAULT NO INMEMORY COLUMN STORE COMPRESS FOR ARCHIVE HIGH EXTENT MANAGEMENT LOCAL AUTOALLOCATE BLOCKSIZE 8K SEGMENT SPACE MANAGEMENT AUTO FLASHBACK ON;

-- create NONpartitioned table with the same structure for exchanging partitions

CREATE TABLE CURR_ORDERS_TEMP
COLUMN STORE COMPRESS FOR ARCHIVE HIGH
TABLESPACE CURR_ORD_2014
AS
    SELECT *
      FROM CURR.ORDERS_BASE
     WHERE 1 = 0;
     
CREATE TABLE CURR_ORDLOG_TEMP
COLUMN STORE COMPRESS FOR ARCHIVE HIGH
TABLESPACE CURR_ORD_2014
AS
    SELECT *
      FROM CURR.ORDLOG_BASE
     WHERE 1 = 0;
     
--create indexes with the same structure on NONpartitioned table for exchanging partitions (indexes become unusable after each exchange)
     
CREATE UNIQUE INDEX ORDERS_CURR_UIDX_TEMP ON CURR_ORDERS_TEMP (ENTRYDATE, ORDERNO) COMPRESS 1  TABLESPACE CURR_ORD_2014;
CREATE INDEX ORDER_CURR_ORDNO_IDX_TEMP ON CURR_ORDERS_TEMP (ORDERNO) TABLESPACE CURR_ORD_2014; 
ALTER INDEX ORDERS_CURR_UIDX_TEMP REBUILD COMPRESS 1 TABLESPACE CURR_ORD_2014; 
ALTER INDEX ORDER_CURR_ORDNO_IDX_TEMP REBUILD  TABLESPACE CURR_ORD_2014; 
CREATE UNIQUE INDEX ORDLOG_CURR_UIDX_TEMP ON CURR_ORDLOG_TEMP (TRADEDATE, NO) TABLESPACE CURR_ORD_2014;

-- exchange partition code example for ONE partition (indexes will be unusable but in another (!!!) TS)

set timing on echo on pagesize 0 linesize 200
alter index ORDERS_CURR_UIDX_TEMP rebuild compress 1 tablespace CURR_ORD_2014;
alter index ORDER_CURR_ORDNO_IDX_TEMP rebuild tablespace CURR_ORD_2014;
alter index ORDERS_CURR_UIDX_TEMP unusable;
alter index ORDER_CURR_ORDNO_IDX_TEMP unusable;
alter table curr.orders_base exchange partition CURR_ORDERS_BASE_P_20140101 with TABLE curr_orders_temp including indexes;
alter table curr.orders_base exchange partition CURR_ORDERS_BASE_P_20140101 with TABLE curr_orders_temp excluding indexes;
select count(1) from curr.orders_base partition(CURR_ORDERS_BASE_P_20140102);
select count(1) from curr_orders_temp;
select INDEX_NAME,PARTITION_NAME,STATUS,TABLESPACE_NAME from dba_ind_partitions where PARTITION_NAME = 'CURR_ORDERS_BASE_P_20140102';
select PARTITION_NAME,BYTES from dba_segments where PARTITION_NAME = 'CURR_ORDERS_BASE_P_20140102';

-- the same example for ORDLOG_BASE (check (!!!) CTAS table for ALL structure - not nulls, constraints, etc)

alter index ORDLOG_CURR_UIDX_TEMP rebuild  tablespace CURR_ORD_2014;
alter index ORDLOG_CURR_UIDX_TEMP unusable;
alter table curr.ORDLOG_BASE exchange partition CURR_ORDLOG_P_201403 with TABLE CURR_ORDLOG_TEMP including indexes;
alter table curr.ORDLOG_BASE exchange partition CURR_ORDLOG_P_201403 with TABLE CURR_ORDLOG_TEMP excluding indexes;

--select all index partitions for move into another TS

  SELECT DISTINCT INDEX_OWNER, PARTITION_NAME
    FROM (SELECT INDEX_OWNER,
                 INDEX_NAME,
                 PARTITION_NAME,
                 PARTITION_POSITION,
                 STATUS,
                 TABLESPACE_NAME
            FROM DBA_IND_PARTITIONS
           WHERE TABLESPACE_NAME = 'CURR_ORD_2014_OLD')
ORDER BY INDEX_OWNER, PARTITION_NAME;

select * from dba_indexes where table_name = 'ORDERS_BASE' and TABLE_OWNER = 'CURR';

BEGIN
    FOR REC
        IN (  SELECT DISTINCT INDEX_OWNER, PARTITION_NAME
                FROM (SELECT INDEX_OWNER,
                             INDEX_NAME,
                             PARTITION_NAME,
                             PARTITION_POSITION,
                             STATUS,
                             TABLESPACE_NAME
                        FROM DBA_IND_PARTITIONS
                       WHERE     TABLESPACE_NAME = 'CURR_ORD_2014_OLD')
            ORDER BY INDEX_OWNER, PARTITION_NAME)
    LOOP
     DBMS_OUTPUT.PUT_LINE ('alter index ORDERS_CURR_UIDX_TEMP rebuild compress 1 tablespace CURR_ORD_2014;');
     DBMS_OUTPUT.PUT_LINE ('alter index ORDER_CURR_ORDNO_IDX_TEMP rebuild tablespace CURR_ORD_2014;');
     DBMS_OUTPUT.PUT_LINE ('alter index ORDERS_CURR_UIDX_TEMP unusable;');
     DBMS_OUTPUT.PUT_LINE ('alter index ORDER_CURR_ORDNO_IDX_TEMP unusable;');
     DBMS_OUTPUT.PUT_LINE ('alter table curr.orders_base exchange partition '||REC.PARTITION_NAME||' with TABLE curr_orders_temp including indexes;');
     DBMS_OUTPUT.PUT_LINE ('alter table curr.orders_base exchange partition '||REC.PARTITION_NAME||' with TABLE curr_orders_temp excluding indexes;');
    END LOOP;
END;

BEGIN
    FOR REC
        IN (  SELECT DISTINCT INDEX_OWNER, PARTITION_NAME
                FROM (SELECT INDEX_OWNER,
                             INDEX_NAME,
                             PARTITION_NAME,
                             PARTITION_POSITION,
                             STATUS,
                             TABLESPACE_NAME
                        FROM DBA_IND_PARTITIONS
                       WHERE     STATUS <> 'USABLE'
                             AND TABLESPACE_NAME = 'CURR_ORD_2014_OLD')
            ORDER BY INDEX_OWNER, PARTITION_NAME)
    LOOP
     DBMS_OUTPUT.PUT_LINE ('alter index ORDERS_CURR_UIDX_TEMP rebuild compress 1 tablespace CURR_ORD_2014;');
     DBMS_OUTPUT.PUT_LINE ('alter index ORDER_CURR_ORDNO_IDX_TEMP rebuild tablespace CURR_ORD_2014;');
     DBMS_OUTPUT.PUT_LINE ('alter table curr.ORDLOG_BASE exchange partition '||REC.PARTITION_NAME||' with TABLE CURR_ORDLOG_TEMP including indexes;');
     DBMS_OUTPUT.PUT_LINE ('alter table curr.ORDLOG_BASE exchange partition '||REC.PARTITION_NAME||' with TABLE CURR_ORDLOG_TEMP excluding indexes;');
    END LOOP;
END;

select count(1) from curr.ORDLOG_BASE partition(CURR_ORDLOG_P_201407);
select count(1) from CURR_ORDLOG_TEMP;
select INDEX_NAME,PARTITION_NAME,STATUS,TABLESPACE_NAME from dba_ind_partitions where PARTITION_NAME = 'CURR_ORDLOG_P_201407';
select PARTITION_NAME,BYTES from dba_segments where PARTITION_NAME = 'CURR_ORDLOG_P_201407';

-- check data on OLD TS

select * from dba_ind_partitions where TABLESPACE_NAME = 'CURR_ORD_2014_OLD';
select * from dba_tab_partitions where TABLESPACE_NAME = 'CURR_ORD_2014_OLD';
select * from dba_indexes where TABLESPACE_NAME = 'CURR_ORD_2014_OLD';
select * from dba_tables where TABLESPACE_NAME = 'CURR_ORD_2014_OLD';

-- actions for FORTS_AR.FUT_ORDLOG partitions

-- find how to place partitions in %_YYYY tablespaces

select forts_java.GET_SESS_ID(sysdate) from dual;
select forts_java.GET_SESS_ID(to_date('01.01.2015','dd.mm.yyyy'))+1 from dual; --4688
select forts_java.GET_SESS_ID(to_date('31.12.2015','dd.mm.yyyy')) from dual; --4939
select forts_java.GET_SESS_ID(to_date('01.01.2016','dd.mm.yyyy'))+1 from dual; --4940
select forts_java.GET_SESS_ID(to_date('31.12.2016','dd.mm.yyyy')) from dual; --5191
select forts_java.GET_SESS_ID(to_date('01.01.2017','dd.mm.yyyy'))+1 from dual; --5192
select forts_java.GET_SESS_ID(to_date('31.12.2017','dd.mm.yyyy')) from dual; --5443
select forts_java.GET_SESS_ID(to_date('01.01.2018','dd.mm.yyyy'))+1 from dual; --5444
select forts_java.GET_SESS_ID(to_date('31.12.2018','dd.mm.yyyy')) from dual;  

-- exchange partitions with FUT_ORDLOG_TEMP table in ARDB_USER schema

alter index UIDX_FUT_ORDLOG rebuild  tablespace FUT_ORDLOG_2016;
alter table FUT_ORDLOG_TEMP move tablespace FUT_ORDLOG_2016;
ALTER INDEX FORTS_AR.UIDX_FUT_ORDLOG MODIFY PARTITION FUT_ORDLOG_5173 UNUSABLE;
alter table FORTS_AR.FUT_ORDLOG exchange partition FUT_ORDLOG_5173 with TABLE FUT_ORDLOG_TEMP including indexes;
alter table FORTS_AR.FUT_ORDLOG exchange partition FUT_ORDLOG_5173 with TABLE FUT_ORDLOG_TEMP excluding indexes;
select count(1) from FORTS_AR.FUT_ORDLOG partition(FUT_ORDLOG_5173);
select count(1) from FUT_ORDLOG_TEMP;
select INDEX_NAME,PARTITION_NAME,STATUS,TABLESPACE_NAME from dba_ind_partitions where PARTITION_NAME = 'FUT_ORDLOG_5173';
select PARTITION_NAME,SEGMENT_TYPE,BYTES from dba_segments where PARTITION_NAME = 'FUT_ORDLOG_5173';
select PARTITION_NAME,SEGMENT_TYPE,BYTES,OWNER from dba_segments where (SEGMENT_NAME in ('FUT_ORDLOG_TEMP','UIDX_FUT_ORDLOG') AND OWNER = 'ARDB_USER');

begin
 for i in 5171..5191
  loop
  dbms_output.put_line('alter index UIDX_FUT_ORDLOG rebuild  tablespace FUT_ORDLOG_2016;');
  dbms_output.put_line('alter table FUT_ORDLOG_TEMP move tablespace FUT_ORDLOG_2016;');
  dbms_output.put_line('ALTER INDEX FORTS_AR.UIDX_FUT_ORDLOG MODIFY PARTITION FUT_ORDLOG_'||to_char(i)||' UNUSABLE;');
  dbms_output.put_line('alter table FORTS_AR.FUT_ORDLOG exchange partition FUT_ORDLOG_'||to_char(i)||' with TABLE FUT_ORDLOG_TEMP including indexes;');
  dbms_output.put_line('alter table FORTS_AR.FUT_ORDLOG exchange partition FUT_ORDLOG_'||to_char(i)||' with TABLE FUT_ORDLOG_TEMP excluding indexes;');
  end loop;
end;

-- SUM BYTES from DBA_SEGMENTS

  SELECT OWNER,
         SEGMENT_NAME,
         SEGMENT_TYPE,
         ROUND (SUM (BYTES) / 1024 / 1024 / 1024) GB
    FROM DBA_SEGMENTS
GROUP BY OWNER, SEGMENT_NAME, SEGMENT_TYPE
  HAVING ROUND (SUM (BYTES) / 1024 / 1024 / 1024) > 1
ORDER BY ROUND (SUM (BYTES) / 1024 / 1024 / 1024) DESC;

  SELECT OWNER,
         ROUND (SUM (BYTES) / 1024 / 1024 / 1024) GB
    FROM DBA_SEGMENTS
GROUP BY OWNER
  HAVING ROUND (SUM (BYTES) / 1024 / 1024 / 1024) > 1
ORDER BY ROUND (SUM (BYTES) / 1024 / 1024 / 1024) DESC;

-- SET AUTOMATIC INTERVAL PARTITIONING FOR TABLES

ALTER TABLE FINANCE_SRC.F_ATOM_ITEMS_BILL_ACT_BASE SET INTERVAL(NUMTOYMINTERVAL(1, 'MONTH'));
ALTER TABLE FINANCE_SRC.F_ATOM_ITEMS_BILL_ACT_BASE SET INTERVAL(NUMTODSINTERVAL(1, 'DAY'));

-- set NLS session parameters (delimeter)

exec dbms_session.set_nls('NLS_NUMERIC_CHARACTERS', '''.,''');
exec dbms_session.set_nls('NLS_NUMERIC_CHARACTERS', ''',.''');

--�������� ����������
select to_char(22/10) from dual;


-- MOVE all schema tables and indexes in another tablespace
  SELECT    'ALTER '
         || OBJECT_TYPE
         || ' '
         || OWNER
         || '.'
         || OBJECT_NAME
         || CASE WHEN OBJECT_TYPE = 'TABLE' THEN ' MOVE ' ELSE ' REBUILD ' END
         || 'TABLESPACE SMALL_TABLES_DATA;'
    FROM DBA_OBJECTS
   WHERE OWNER = 'ERK' AND OBJECT_TYPE IN ('TABLE', 'INDEX')
ORDER BY OBJECT_TYPE DESC;

-- Procedure for shrink tablespace with archived partitioned data

select * from DBA_TABLESPACE_USAGE_METRICS where TABLESPACE_NAME = 'CURR_ORD_2016';
select * from dba_data_files where TABLESPACE_NAME = 'CURR_ORD_2016';

CREATE BIGFILE TABLESPACE CURR_ORD_2016_DEFRAG LOGGING DEFAULT COLUMN STORE COMPRESS FOR ARCHIVE HIGH;

-- free size in files of tablespace

SELECT SUM (FREE_MB)
  FROM (SELECT A.FILE_NAME,
               ROUND (A.BYTES / 1024 / 1024)                 AS SIZE_MB,
               ROUND (A.MAXBYTES / 1024 / 1024)              AS MAXSIZE_MB,
               ROUND (B.FREE_BYTES / 1024 / 1024)            AS FREE_MB,
               ROUND ( (A.MAXBYTES - A.BYTES) / 1024 / 1024) AS GROWTH_MB,
               100 - ROUND ( ( (B.FREE_BYTES + A.GROWTH) / A.MAXBYTES) * 100)
                   AS PCT_USED
          FROM (SELECT FILE_NAME,
                       FILE_ID,
                       BYTES,
                       GREATEST (BYTES, MAXBYTES)         AS MAXBYTES,
                       GREATEST (BYTES, MAXBYTES) - BYTES AS GROWTH
                  FROM DBA_DATA_FILES) A,
               (  SELECT FILE_ID, SUM (BYTES) AS FREE_BYTES
                    FROM DBA_FREE_SPACE
                GROUP BY FILE_ID) B
         WHERE     A.FILE_ID = B.FILE_ID
               AND A.FILE_NAME IN (SELECT FILE_NAME
                                     FROM DBA_DATA_FILES
                                    WHERE TABLESPACE_NAME = 'EQ_ORD_2016'));
                                    
select COUNT(1) from dba_tables where TABLESPACE_NAME = 'EQ_ORD_2016';
select * from dba_indexes where TABLESPACE_NAME = 'EQ_ORD_2016';
select distinct SEGMENT_TYPE from dba_segments where TABLESPACE_NAME = 'EQ_ORD_2016';
select sum(bytes)/1024/1024/1024 from dba_segments where TABLESPACE_NAME = 'EQ_ORD_2016';

select * from dba_tab_partitions where TABLESPACE_NAME = 'EQ_ORD_2016';
select * from dba_ind_partitions where TABLESPACE_NAME = 'EQ_ORD_2016';

--exec DEFRAGMENT_TABLESPACE('OPT_ORDLOG_2016',false);

select * from errlog order by id desc;


  