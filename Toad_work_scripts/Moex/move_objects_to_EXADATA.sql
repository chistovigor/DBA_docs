-- рассчет прироста БД за 2017 год

SELECT *
  FROM DBA_TABLESPACE_USAGE_METRICS
 WHERE TABLESPACE_NAME IN ('FORTS_AR_DATA',
                           'FORTS_CLEARING_DATA',
                           'FORTS_CLEARING_INDX',
                           'FORTS_JAVA_DATA',
                           'FORTS_JAVA_LM_DATA',
                           'FORTS_REPAAR_DATA');
                           
-- размер объектов с учетом текущего свободного места в табличных пространствах 

SELECT OWNER,TABLE_NAME,SUM(GB_RAW) GB_RAW FROM (
    SELECT S.OWNER,
         S.SEGMENT_NAME,
         NVL(i.TABLE_NAME,S.SEGMENT_NAME) TABLE_NAME,
         ROUND (
               (SUM (S.BYTES) + SUM (S.BYTES) * (1 - M.USED_PERCENT / 100))
             / 1024
             / 1024
             / 1024)
             GB_USED,
         ROUND (SUM (S.BYTES) / 1024 / 1024 / 1024)
             GB_RAW
    FROM DBA_SEGMENTS S, DBA_TABLESPACE_USAGE_METRICS M,dba_indexes i
   WHERE     S.TABLESPACE_NAME = M.TABLESPACE_NAME
         AND S.SEGMENT_NAME = i.INDEX_NAME(+)
         AND S.TABLESPACE_NAME IN ('FORTS_AR_DATA',
                                   'FORTS_CLEARING_DATA',
                                   'FORTS_CLEARING_INDX',
                                   'FORTS_JAVA_DATA',
                                   'FORTS_JAVA_LM_DATA',
                                   'FORTS_REPAAR_DATA')
GROUP BY S.OWNER, S.SEGMENT_NAME, M.USED_PERCENT,NVL(i.TABLE_NAME,S.SEGMENT_NAME)
  HAVING ROUND (
               (SUM (S.BYTES) + SUM (S.BYTES) * (1 - M.USED_PERCENT / 100))
             / 1024
             / 1024
             / 1024) >
         1
--ORDER BY S.OWNER,
  --       ROUND (
    --           (SUM (S.BYTES) + SUM (S.BYTES) * (1 - M.USED_PERCENT / 100))
      --       / 1024
        --     / 1024
          --   / 1024) DESC,
         --S.SEGMENT_NAME;
) GROUP BY OWNER,TABLE_NAME HAVING SUM(GB_RAW) > 1 ORDER BY 1,3 DESC,2
         
         
select * from dba_indexes where ; 
select * from dba_data_files;

SELECT SUM (BYTES) / 1024 / 1024 / 1024 / 1024
  FROM DBA_DATA_FILES;

  SELECT ROUND (SUM (BYTES) / 1024 / 1024 / 1024)*2 GB, TABLESPACE_NAME
    FROM DBA_DATA_FILES
GROUP BY TABLESPACE_NAME
  HAVING ROUND (SUM (BYTES) / 1024 / 1024 / 1024)*2 > 0
  UNION ALL
    SELECT ROUND (SUM (BYTES) / 1024 / 1024 / 1024)*2 GB, TABLESPACE_NAME
    FROM DBA_TEMP_FILES
GROUP BY TABLESPACE_NAME
  HAVING ROUND (SUM (BYTES) / 1024 / 1024 / 1024)*2 > 1;

select * from dba_temp_files;


-- зазмеры объектов БД (LDWH,LM-BASE,VDRF)

select sum(bytes)/1024/1024/1024 GB from dba_segments; --10486.5837402344
select sum(bytes)/1024/1024/1024 GB from dba_temp_files; --826.735328674316
select sum(bytes)/1024/1024/1024 from dba_data_files where TABLESPACE_NAME = 'UNDOTBS2'  --314.86328125
--13ТБ

select sum(bytes)/1024/1024/1024 GB from dba_data_files; --13126.0117034912
select sum(bytes)/1024/1024/1024 GB from dba_temp_files; --826.735328674316
--14ТБ

-- Физич хранение LDWH 0.3

-- data size at DWH and spur for TLDWH objects

-- base

  SELECT SUM (MB) BASE_SIZE, TLDWH_NAME, DB
    FROM (  SELECT L.NAME                          TLDWH_NAME,
                   D.OWNER,
                   D.SEGMENT_NAME,
                   ROUND (SUM (D.BYTES) / 1024 / 1024) MB,
                   'DWH'                           DB
              FROM DBA_SEGMENTS D, LDWH_BASE_TABLES L
             WHERE     D.SEGMENT_NAME = L.REFERENCED_NAME
                   AND D.OWNER = L.REFERENCED_OWNER
                   AND L.NAME IN ('PAYMENTS',
                                  'ORDER',
                                  'REPO_ORDER',
                                  'ANON_ORDER_LOG',
                                  'ORDER_LOG',
                                  'EXP_ORDER',
                                  'TRADE')
          GROUP BY L.NAME, D.OWNER, D.SEGMENT_NAME
          UNION ALL
            SELECT L.NAME,
                   D.OWNER,
                   D.SEGMENT_NAME,
                   ROUND (SUM (D.BYTES) / 1024 / 1024) MB,
                   'DWH'                           DB
              FROM DBA_SEGMENTS@SPUR30 D, LDWH_BASE_TABLES L
             WHERE     D.SEGMENT_NAME = L.REFERENCED_NAME
                   AND D.OWNER = L.REFERENCED_OWNER
                   AND L.NAME IN ('PAYMENTS',
                                  'ORDER',
                                  'REPO_ORDER',
                                  'ANON_ORDER_LOG',
                                  'ORDER_LOG',
                                  'EXP_ORDER',
                                  'TRADE')
          GROUP BY L.NAME, D.OWNER, D.SEGMENT_NAME
          ORDER BY 4,
                   1,
                   2,
                   3)
GROUP BY TLDWH_NAME, DB
ORDER BY 2, 1;

-- LM

  SELECT SUM (MB) LM_SIZE, TLDWH_NAME, DB
    FROM (  SELECT L.NAME                          TLDWH_NAME,
                   D.OWNER,
                   D.SEGMENT_NAME,
                   ROUND (SUM (D.BYTES) / 1024 / 1024) MB,
                   'DWH'                           DB
              FROM DBA_SEGMENTS D, LDWH_BASE_TABLES L
             WHERE     D.SEGMENT_NAME =
                           REPLACE (L.REFERENCED_NAME, '_BASE', '_LM')
                   AND D.OWNER = L.REFERENCED_OWNER || '_LM'
                   AND L.NAME IN ('POS_FIRM_ASSET')
          GROUP BY L.NAME, D.OWNER, D.SEGMENT_NAME
          UNION ALL
            SELECT L.NAME,
                   D.OWNER,
                   D.SEGMENT_NAME,
                   ROUND (SUM (D.BYTES) / 1024 / 1024) MB,
                   'DWH'                           DB
              FROM DBA_SEGMENTS@SPUR30 D, LDWH_BASE_TABLES L
             WHERE     D.SEGMENT_NAME =
                           REPLACE (L.REFERENCED_NAME, '_BASE', '_LM')
                   AND D.OWNER = L.REFERENCED_OWNER
                   AND L.NAME IN ('PAYMENTS',
                                  'ORDER',
                                  'REPO_ORDER',
                                  'ANON_ORDER_LOG',
                                  'ORDER_LOG',
                                  'EXP_ORDER',
                                  'TRADE')
          GROUP BY L.NAME, D.OWNER, D.SEGMENT_NAME
          ORDER BY 4,
                   1,
                   2,
                   3)
GROUP BY TLDWH_NAME, DB
ORDER BY 2, 1;

-- index_size at DWH for TLDWH objects

SELECT SUM(MB),TLDWH_NAME,DB FROM 
  (SELECT L.NAME                            TLDWH_NAME,
         D.OWNER,
         D.SEGMENT_NAME,
         ROUND (SUM (D.BYTES) / 1024 / 1024) MB,
         'DWH'                             DB
    FROM DBA_SEGMENTS D, LDWH_BASE_TABLES L, DBA_TABLES DD
   WHERE     D.SEGMENT_NAME || L.REFERENCED_OWNER || L.REFERENCED_NAME IN
                 (SELECT INDEX_NAME || TABLE_OWNER || TABLE_NAME
                    FROM DBA_INDEXES
                   WHERE TABLE_OWNER || TABLE_NAME IN
                             (SELECT REFERENCED_OWNER || REFERENCED_NAME
                                FROM LDWH_BASE_TABLES
                               WHERE NAME IN ('PAYMENTS',
                                              'ORDER',
                                              'REPO_ORDER',
                                              'ANON_ORDER_LOG',
                                              'ORDER_LOG',
                                              'EXP_ORDER',
                                              'TRADE')))
         AND DD.OWNER = L.REFERENCED_OWNER
         AND DD.TABLE_NAME = L.REFERENCED_NAME
         AND L.NAME IN ('PAYMENTS',
                        'ORDER',
                        'REPO_ORDER',
                        'ANON_ORDER_LOG',
                        'ORDER_LOG',
                        'EXP_ORDER',
                        'TRADE')
         AND D.OWNER NOT IN ('SPUR_DAY_CU_TEST','SPUR_DAY_TEST')
GROUP BY L.NAME, D.OWNER, D.SEGMENT_NAME
ORDER BY 1,5,2)
GROUP BY TLDWH_NAME,DB ORDER BY 3,1 DESC,2;

-- year growth

select * from LDWH_BASE_TABLES L where L.NAME IN ('POS_RK_SETTLE_ASSET') order by 3,NUM_ROWS desc;


select max(SESS_ID) from FORTS_JAVA.FUT_POS_BASE;
SELECT COUNT(1) FROM EQ.RPT99HOLD_BASE;
select count(1) from forts_clearing.CLIENT_MONEY_BASE;
select * from ASTS.SE_ACCOUNT_BALANCE_BASE;
select * from ASTS.SE_RM_HOLD_BASE;
select max(REPDATE) from ASTS.SE_RM_HOLD_DETL_BASE;
select min(REPDATE) from ASTS.SE_RM_HOLD_BASE;
select count(1) from ASTS.SE_RM_HOLD_BASE;
select * from EQ.HOLD_BASE;
select max(TRADEDATE) from EQ.MMSTATS_BASE;
select * from EQ.RPT99HOLD_BASE;
select min(TODAYDATE) from EQ.HOLD_BASE;
select min(TODAYDATE) from EQ.RPT99HOLD_BASE;
select min(UPDATEDT) from FORTS_CLEARING.SYS_MONEY_REPORT_BASE;
select min(REPDATE) from SPUR.ASTS_SE_POSITIONS;
select min(SYST_ID) from forts_clearing.SYS_MONEY_REPORT_BASE;
select max(SYST_ID) from forts_clearing.SYS_MONEY_REPORT_BASE;
select min(REPDATE) from ASTS.SE_10_POSITIONS_BASE;
select min(REPDATE) from ASTS.SE_ACCOUNT_BALANCE_BASE;


select min("date"),max("date") from forts_java.OPT_EXP_ORDERS_BASE;
select count(1) from forts_java.OPT_EXP_ORDERS_BASE;

select max(UPDATEDT),min(UPDATEDT) from FORTS_JAVA.BROKER_REALACCOUNT_BASE;
select min(TODAYDATE),max(TODAYDATE) from EQ.RPT99CASH_BASE;


select * from forts_java.FUT_POS_BASE;
select max(SESS_ID) from forts_java.PART_BASE;
select min(SYST_ID) from FORTS_CLEARING.SYS_MONEY_REPORT_BASE;

select min(MSF_OUT),max(MSF_OUT) from MSFOUSER.MSFO_OBOROTLS_OUT_BASE;
select * from MSFOUSER.MSFO_OBOROTLS_OUT_BASE;
select count(1)/3 from MSFOUSER.MSFO_OBOROTLS_OUT_BASE;

-- index size (for count year's growth)

select OWNER,REFERENCED_NAME,sum(MB) from 
(SELECT   L.REFERENCED_NAME,
         D.OWNER,
         D.SEGMENT_NAME,
         ROUND (SUM (D.BYTES) / 1024 / 1024) MB,
         'DWH'                             DB
    FROM DBA_SEGMENTS D, LDWH_BASE_TABLES L, DBA_TABLES DD
   WHERE     (D.SEGMENT_NAME,L.REFERENCED_OWNER,L.REFERENCED_NAME) IN
                 (SELECT INDEX_NAME,TABLE_OWNER,TABLE_NAME
                    FROM DBA_INDEXES
                   WHERE (TABLE_OWNER,TABLE_NAME) IN
                             (SELECT REFERENCED_OWNER,REFERENCED_NAME
                                FROM LDWH_BASE_TABLES
                               WHERE NAME IN ('POS_FIRM_SEC')))
         AND DD.OWNER = L.REFERENCED_OWNER
         AND DD.TABLE_NAME = L.REFERENCED_NAME
         AND L.NAME IN ('POS_FIRM_SEC')
         AND D.OWNER NOT IN ('SPUR_DAY_CU_TEST','SPUR_DAY_TEST')
         AND L.NUM_ROWS > 1000000
GROUP BY L.REFERENCED_NAME, D.OWNER, D.SEGMENT_NAME)
GROUP BY OWNER,REFERENCED_NAME
ORDER BY 1,2;

select OWNER,REFERENCED_NAME,sum(MB) from 
(SELECT   L.REFERENCED_NAME,
         D.OWNER,
         D.SEGMENT_NAME,
         ROUND (SUM (D.BYTES) / 1024 / 1024) MB,
         'DWH'                             DB
    FROM DBA_SEGMENTS@spur30 D, LDWH_BASE_TABLES L, DBA_TABLES@spur30 DD
   WHERE     (D.SEGMENT_NAME,L.REFERENCED_OWNER,L.REFERENCED_NAME) IN
                 (SELECT INDEX_NAME,TABLE_OWNER,TABLE_NAME
                    FROM DBA_INDEXES@spur30
                   WHERE (TABLE_OWNER,TABLE_NAME) IN
                             (SELECT REFERENCED_OWNER,REFERENCED_NAME
                                FROM LDWH_BASE_TABLES
                               WHERE NAME IN ('REPO_ORDER')))
         AND DD.OWNER = L.REFERENCED_OWNER
         AND DD.TABLE_NAME = L.REFERENCED_NAME
         AND L.NAME IN ('REPO_ORDER')
         AND D.OWNER NOT IN ('SPUR_DAY_CU_TEST','SPUR_DAY_TEST')
         AND L.NUM_ROWS > 1000000
GROUP BY L.REFERENCED_NAME, D.OWNER, D.SEGMENT_NAME)
GROUP BY OWNER,REFERENCED_NAME
ORDER BY 1,2;
2373976064
             
-- size comparison in DWH and spur

select sum(MB) FROM
  (SELECT OWNER, SEGMENT_NAME, ROUND(SUM (BYTES)/1024/1024) MB
    FROM DBA_SEGMENTS@SPUR30
   WHERE (OWNER,SEGMENT_NAME) IN (SELECT REFERENCED_OWNER,REFERENCED_NAME
                                     FROM LDWH_BASE_TABLES L
                                    WHERE L.NAME IN ('REPO_ORDER'))
GROUP BY OWNER, SEGMENT_NAME);

--2232418304

select sum(MB) FROM
  (SELECT OWNER, SEGMENT_NAME, ROUND(SUM (BYTES)/1024/1024) MB
    FROM DBA_SEGMENTS
   WHERE (OWNER,SEGMENT_NAME) IN (SELECT REFERENCED_OWNER,REFERENCED_NAME
                                     FROM LDWH_BASE_TABLES L
                                    WHERE L.NAME IN ('REPO_ORDER'))
GROUP BY OWNER, SEGMENT_NAME);

--1534066688

-- growth per year (data and index)

SELECT MIN (DATETIME), MAX (DATETIME) FROM FORTS_CLEARING.PAYMENT_BASE;
select round(count(1)/3) from EQ.HOLD_BASE where TODAYDATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*3)) and TRUNC(SYSDATE);
select round(count(1)/3) from EQ.MMSTATS_BASE where TRADEDATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*3)) and TRUNC(SYSDATE);
select round(count(1)/3) from curr.MMSTATS_BASE where TRADEDATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*3)) and TRUNC(SYSDATE);
select round(count(1)/3) from FORTS_ARC.POSITIONS where DAT_OPEN_DAY BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*3)) and TRUNC(SYSDATE);
select round(count(1)/1) from FORTS_CLEARING.SYS_MONEY_REPORT_BASE where updatedt BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*1)) and TRUNC(SYSDATE);
select round(count(1)/2) from ASTS.SE_10_POSITIONS_BASE where REPDATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*2)) and TRUNC(SYSDATE);
select round(count(1)/2) from ASTS.SE_RM_HOLD_BASE where REPDATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*2)) and TRUNC(SYSDATE);
select round(count(1)/2) from ASTS.SE_RM_HOLD_DETL_BASE where REPDATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*2)) and TRUNC(SYSDATE);
select round(count(1)/3) from ASTS.SE_ACCOUNT_BALANCE_BASE where REPDATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*3)) and TRUNC(SYSDATE);
select round(count(1)/3) from EQ.RPT99CASH_BASE where TODAYDATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*3)) and TRUNC(SYSDATE);
select round(count(1)/3) from EQ.RPT99HOLD_BASE where TODAYDATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*3)) and TRUNC(SYSDATE);
select round(count(1)/3) from EQ.RPT99CASH_DETL_BASE where TODAYDATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*3)) and TRUNC(SYSDATE);

select MIN (TODAYDATE), MAX (TODAYDATE) FROM EQ.RPT99CASH_DETL_BASE;
SELECT MIN (SYST_ID), MAX (SYST_ID) FROM FORTS_CLEARING.DILER_MARK_BASE;

select * from FORTS_JAVA.FUT_ORDERS_BASE;

-- rows growth per year

select min(SYST_ID),max(SYST_ID) from FORTS_CLEARING.PAYMENT_BASE;
select min(SESS_ID),max(SESS_ID) from FORTS_JAVA.FUT_ORDERS_BASE;
select min(ENTRYDATE),max(ENTRYDATE) from SPUR_DAY.REPOORDERS;
select min(MOMENT),max(MOMENT) from FORTS_JAVA.ADJUSTED_FEE_BASE;
select min(TRADEDATE),max(TRADEDATE) from BL.TRADES_BASE;
select min(TRADE_DATE),max(TRADE_DATE) from FORTS_JAVA.OTC_DEALS_REPL_LOG_BASE;
select min(DAT_TIME),max(DAT_TIME) from FORTS_AR.FUT_AR_REPOTRADE_BASE;

select min(TODAYDATE),max(TODAYDATE) from EQ.RPT99HOLD_DETL_BASE@spur30;
select min(TODAYDATE),max(TODAYDATE) from EQ.RPT99CASH_DETL_BASE;


select FORTS_JAVA.GET_SESS_ID(ADD_MONTHS(SYSDATE,-12*3)),FORTS_JAVA.GET_SESS_ID(SYSDATE) from dual;
select /*+ PARALLEL(8) FULL(A) */ round(count(1)/3) from BL.TRADES_BASE A where A.TRADEDATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*3)) and TRUNC(SYSDATE);
select /*+ PARALLEL(8) FULL(A) */ round(count(1)/3) from SPUR.ASTS_POSITIONS A where A.REPDATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*3)) and TRUNC(SYSDATE);
select /*+ PARALLEL(8) FULL(A) */ round(count(1)/2) from SPUR.ASTS_SE_POSITIONS A where A.REPDATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*2)) and TRUNC(SYSDATE);
select /*+ PARALLEL(8) FULL(A) */ round(count(1)/2) from BL.REPOORDERS_BASE A where A.UPDATEDT BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*2)) and TRUNC(SYSDATE);
select /*+ PARALLEL(8) FULL(A) */ round(count(1)/1) from FORTS_CLEARING.SYS_MONEY_REPORT_BASE A where A.UPDATEDT BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*2)) and TRUNC(SYSDATE);
select /*+ PARALLEL(8) FULL(A) */ round(count(1)/3) from FORTS_AR.FUT_AR_REPOTRADE_BASE A where A.DAT_TIME BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*2)) and TRUNC(SYSDATE);
select min(SESS_ID),max(SESS_ID) from FORTS_JAVA.FUT_ORDERS_BASE;
select /*+ PARALLEL(8) FULL(A) */ round(count(1)/2) from FORTS_CLEARING.DEAL_BASE A where A.SYST_ID BETWEEN 4449 and 5206;
select /*+ PARALLEL(8) FULL(A) */ round(count(1)/2) from FORTS_JAVA.ADJUSTED_FEE_BASE A where A.MOMENT BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*3)) and TRUNC(SYSDATE);
select /*+ PARALLEL(8) FULL(A) */ round(count(1)/3) from FORTS_CLEARING.SYS_MONEY_REPORT_BASE A where A.SYST_ID BETWEEN --4449
4595-255*3 and 4595;
select /*+ PARALLEL(8) FULL(A) */ round(count(1)/3) from forts_java.PART_BASE A where A.SESS_ID BETWEEN --4449
5208-255*3 and 5208;
select /*+ PARALLEL(8) FULL(A) */ round(count(1)/3) from FORTS_JAVA.FUT_POS_BASE A where A.SESS_ID BETWEEN --4449
5216-255*3 and 5216;
select /*+ PARALLEL(8) FULL(A) */ round(count(1)/3) from CFTUSER.HP_FA_ACC_REST_OLTP_DY A where A.REAL_DATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-12*3)) and TRUNC(SYSDATE);

select 52250964/3 from dual;
select count(1) from forts_java.FUT_VM_BASE;

select * from EQ.RPT99HOLD_DETL_BASE;
select * from FORTS_JAVA.ADJUSTED_FEE_BASE where SESS_ID = 4916;

-- big objects NOT included in LDWH TABLES

  SELECT *
    FROM LDWH_BASE_TABLES L
   WHERE L.NAME IN ('PAYMENTS',
                    'ORDER',
                    'REPO_ORDER',
                    'ANON_ORDER_LOG',
                    'ORDER_LOG',
                    'EXP_ORDER',
                    'TRADE')
ORDER BY NUM_ROWS DESC;

  SELECT OWNER,
         SEGMENT_NAME,
         SEG,
         ROUND (SUM (BYTES) / 1024 / 1024 / 1024, 1) GB
    FROM (SELECT OWNER,
                 SEGMENT_NAME,
                 SUBSTR (SEGMENT_TYPE, 0, 5) SEG,
                 BYTES
            FROM DBA_SEGMENTS SEGMENT_TYPE
           WHERE SEGMENT_TYPE LIKE 'TABLE%' OR SEGMENT_TYPE LIKE 'INDEX%')
  HAVING ROUND (SUM (BYTES) / 1024 / 1024 / 1024, 1) >= 10 AND OWNER <> 'SYS'
GROUP BY OWNER, SEGMENT_NAME, SEG
ORDER BY OWNER, ROUND (SUM (BYTES) / 1024 / 1024 / 1024, 1) DESC;

-- tables by DB,schema,ILM tables separate (tables like *_LM_JET* were excluded )

  SELECT OWNER, COUNT (TABLE_NAME)
    FROM DBA_TABLES
   WHERE     OWNER NOT LIKE '%SYS%'
         AND OWNER NOT LIKE '%TEST'
         AND OWNER NOT IN ('PUBLIC',
                           'ORACLE_OCM',
                           'GSMADMIN_INTERNAL',
                           'APEX_050000',
                           'OUTLN',
                           'APEX_LISTENER',
                           'TOAD',
                           'DBSNMP',
                           'XDB')
         AND TABLE_NAME NOT LIKE '%/_LM/_JET' ESCAPE '/'
GROUP BY OWNER
ORDER BY 1, 2;

-- LM tables

  SELECT OWNER, COUNT (TABLE_NAME)
    FROM DBA_TABLES
   WHERE     OWNER NOT LIKE '%SYS%'
         AND OWNER NOT LIKE '%TEST'
         AND OWNER NOT IN ('PUBLIC',
                           'ORACLE_OCM',
                           'GSMADMIN_INTERNAL',
                           'APEX_050000',
                           'OUTLN',
                           'APEX_LISTENER',
                           'TOAD',
                           'DBSNMP',
                           'XDB')
         AND TABLE_NAME LIKE '%/_LM' ESCAPE '/'
GROUP BY OWNER
ORDER BY 1, 2;

select * from DBA_TABLES WHERE OWNER = 'CURR' AND TABLE_NAME NOT LIKE '%/_LM/_JET' ESCAPE '/' order by TABLE_NAME;

-- not loaded object to Exadata from other our db (xls file)

SELECT DISTINCT OWNER, OBJECT_NAME
  FROM ALL_OBJECTS
 WHERE     OWNER || '.' || OBJECT_NAME IN
              (  SELECT OWNER || '.' || SEGMENT_NAME
                   FROM DBA_SEGMENTS@SPURTAB
                  WHERE SEGMENT_TYPE NOT LIKE 'INDEX%'
               GROUP BY OWNER, SEGMENT_NAME
                 HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) >= 1)
       AND OWNER <> 'SYS';

  SELECT OWNER, SEGMENT_NAME, ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) GB
    FROM DBA_SEGMENTS@SPURTAB
   WHERE     SEGMENT_TYPE NOT LIKE 'INDEX%'
         AND OWNER || '.' || SEGMENT_NAME NOT IN
                (SELECT DISTINCT OWNER || '.' || OBJECT_NAME
                   FROM ALL_OBJECTS
                  WHERE OWNER || '.' || OBJECT_NAME IN
                           (  SELECT OWNER || '.' || SEGMENT_NAME
                                FROM DBA_SEGMENTS@SPURTAB
                               WHERE SEGMENT_TYPE NOT LIKE 'INDEX%'
                            GROUP BY OWNER, SEGMENT_NAME
                              HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024),
                                            1) >= 1))
GROUP BY OWNER, SEGMENT_NAME
  HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) >= 1
ORDER BY OWNER, 3 DESC;

  SELECT OWNER, SEGMENT_NAME, ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) GB
    FROM DBA_SEGMENTS@SPURTAB
   WHERE     SEGMENT_TYPE NOT LIKE 'INDEX%'
         AND OWNER || '.' || SEGMENT_NAME NOT IN
                (SELECT DISTINCT OWNER || '.' || OBJECT_NAME
                   FROM ALL_OBJECTS
                  WHERE OWNER || '.' || OBJECT_NAME IN
                           (  SELECT OWNER || '.' || SEGMENT_NAME
                                FROM DBA_SEGMENTS@SPURTAB
                               WHERE SEGMENT_TYPE NOT LIKE 'INDEX%'
                            GROUP BY OWNER, SEGMENT_NAME
                              HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024),
                                            1) <= 1))
         AND OWNER NOT IN ('APEX_050000',
                           'APEX_SPUR_DEV',
                           'ARDB_USER',
                           'CTXSYS',
                           'CU_ARC',
                           'DBSNMP',
                           'EXFSYS',
                           'FLOWS_FILES',
                           'MDSYS',
                           'OLAPSYS',
                           'ORDDATA',
                           'OUTLN',
                           'SCOTT',
                           'SYS',
                           'SYSMAN',
                           'SYSTEM',
                           'WMSYS',
                           'XDB')
GROUP BY OWNER, SEGMENT_NAME
  HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) < 1
ORDER BY OWNER, 3 DESC;

  SELECT OWNER, SEGMENT_NAME, ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) GB
    FROM DBA_SEGMENTS@SPUR30
   WHERE     SEGMENT_TYPE NOT LIKE 'INDEX%'
         AND OWNER NOT IN ('SYS',
                           'TEST_LOADRP31',
                           'POLYANTSEVNA',
                           'MOSCOW_EXCHANGE_TST',
                           'MOSCOW_EXCHANGE',
                           'KUNETSAS',
                           'LOAD_ALAMEDA',
                           'MDMWORK_TST')
         AND OWNER || '.' || SEGMENT_NAME NOT IN
                (SELECT DISTINCT OWNER || '.' || OBJECT_NAME
                   FROM ALL_OBJECTS
                  WHERE OWNER || '.' || OBJECT_NAME IN
                           (  SELECT OWNER || '.' || SEGMENT_NAME
                                FROM DBA_SEGMENTS@SPUR30
                               WHERE SEGMENT_TYPE NOT LIKE 'INDEX%'
                            GROUP BY OWNER, SEGMENT_NAME
                              HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024),
                                            1) >= 1))
GROUP BY OWNER, SEGMENT_NAME
  HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) >= 1
ORDER BY OWNER, 3 DESC;

  SELECT OWNER, SEGMENT_NAME, ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) GB
    FROM DBA_SEGMENTS@SPUR30
   WHERE     SEGMENT_TYPE NOT LIKE 'INDEX%'
         AND OWNER NOT IN ('EXPIMP',
                           'ORDSYS',
                           'VVM',
                           'APEX_050000',
                           'APEX_SPUR_DEV',
                           'ARDB_USER',
                           'CTXSYS',
                           'CU_ARC',
                           'DBSNMP',
                           'EXFSYS',
                           'FLOWS_FILES',
                           'MDSYS',
                           'OLAPSYS',
                           'ORDDATA',
                           'OUTLN',
                           'SCOTT',
                           'SYS',
                           'SYSMAN',
                           'SYSTEM',
                           'WMSYS',
                           'XDB')
         AND OWNER || '.' || SEGMENT_NAME NOT IN
                (SELECT DISTINCT OWNER || '.' || OBJECT_NAME
                   FROM ALL_OBJECTS
                  WHERE OWNER || '.' || OBJECT_NAME IN
                           (  SELECT OWNER || '.' || SEGMENT_NAME
                                FROM DBA_SEGMENTS@SPUR30
                               WHERE SEGMENT_TYPE NOT LIKE 'INDEX%'
                            GROUP BY OWNER, SEGMENT_NAME
                              HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024),
                                            1) <= 1))
GROUP BY OWNER, SEGMENT_NAME
  HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) < 1
ORDER BY OWNER, 3 DESC;

-- logical objects in DWH

  SELECT OWNER,
         OBJECT_NAME,
         OBJECT_TYPE,
         STATUS
    FROM ALL_OBJECTS
   WHERE     OBJECT_TYPE IN ('SEQUENCE',
                             'PROCEDURE',
                             'PACKAGE',
                             'PACKAGE BODY',
                             'TRIGGER',
                             'MATERIALIZED VIEW',
                             'VIEW',
                             'SYNONYM',
                             'FUNCTION',
                             'TYPE')
         AND OWNER NOT LIKE '%SYS%'
         AND OWNER NOT IN ('PUBLIC',
                           'ORACLE_OCM',
                           'GSMADMIN_INTERNAL',
                           'APEX_050000',
                           'OUTLN',
                           'APEX_LISTENER',
                           'TOAD',
                           'DBSNMP',
                           'XDB')
ORDER BY OWNER, STATUS, OBJECT_NAME;

-- logical objects in SPUR

  SELECT OWNER,
         OBJECT_NAME,
         OBJECT_TYPE,
         STATUS
    FROM ALL_OBJECTS@SPUR30
   WHERE     OBJECT_TYPE IN ('SEQUENCE',
                             'PROCEDURE',
                             'PACKAGE',
                             'PACKAGE BODY',
                             'TRIGGER',
                             'MATERIALIZED VIEW',
                             'VIEW',
                             'SYNONYM',
                             'FUNCTION',
                             'TYPE')
         AND OWNER NOT IN ('CBPROXYUSER',
                           'APPQOSSYS',
                           'TOAD',
                           'ORDPLUGINS',
                           'ORDSYS',
                           'PUBLIC',
                           'OWBSYS',
                           'EXPIMP',
                           'CBSYSUSER',
                           'OWBSYS_AUDIT',
                           'APEX_050000',
                           'APEX_SPUR_DEV',
                           'ARDB_USER',
                           'CTXSYS',
                           'CU_ARC',
                           'DBSNMP',
                           'EXFSYS',
                           'FLOWS_FILES',
                           'MDSYS',
                           'OLAPSYS',
                           'ORDDATA',
                           'OUTLN',
                           'SCOTT',
                           'SYS',
                           'SYSMAN',
                           'SYSTEM',
                           'WMSYS',
                           'XDB')
ORDER BY OWNER, STATUS, OBJECT_NAME;

-- logical objects in SPURTAB

  SELECT OWNER,
         OBJECT_NAME,
         OBJECT_TYPE,
         STATUS
    FROM ALL_OBJECTS@SPURTAB
   WHERE     OBJECT_TYPE IN ('SEQUENCE',
                             'PROCEDURE',
                             'PACKAGE',
                             'PACKAGE BODY',
                             'TRIGGER',
                             'MATERIALIZED VIEW',
                             'VIEW',
                             'SYNONYM',
                             'FUNCTION',
                             'TYPE')
         AND OWNER NOT IN ('ORACLE_OCM',
                     'CBMVUSER',
                     'JET',
                     'CBMIRROR',
                     'CBPROXYUSER',
                     'APPQOSSYS',
                     'TOAD',
                     'ORDPLUGINS',
                     'ORDSYS',
                     'PUBLIC',
                     'OWBSYS',
                     'EXPIMP',
                     'CBSYSUSER',
                     'OWBSYS_AUDIT',
                     'APEX_050000',
                     'APEX_SPUR_DEV',
                     'ARDB_USER',
                     'CTXSYS',
                     'CU_ARC',
                     'DBSNMP',
                     'EXFSYS',
                     'FLOWS_FILES',
                     'MDSYS',
                     'OLAPSYS',
                     'ORDDATA',
                     'OUTLN',
                     'SCOTT',
                     'SYS',
                     'SYSMAN',
                     'SYSTEM',
                     'WMSYS',
                     'XDB')
ORDER BY OWNER, STATUS, OBJECT_NAME;

-- difference

  SELECT OWNER,
         OBJECT_NAME,
         OBJECT_TYPE,
         STATUS
    FROM ALL_OBJECTS@SPUR30
   WHERE     OBJECT_TYPE IN ('SEQUENCE',
                             'PROCEDURE',
                             'PACKAGE',
                             'PACKAGE BODY',
                             'TRIGGER',
                             'MATERIALIZED VIEW',
                             'VIEW',
                             'SYNONYM',
                             'FUNCTION',
                             'TYPE')
         AND OWNER NOT IN ('CBPROXYUSER',
                           'APPQOSSYS',
                           'TOAD',
                           'ORDPLUGINS',
                           'ORDSYS',
                           'PUBLIC',
                           'OWBSYS',
                           'EXPIMP',
                           'CBSYSUSER',
                           'OWBSYS_AUDIT',
                           'APEX_050000',
                           'APEX_SPUR_DEV',
                           'ARDB_USER',
                           'CTXSYS',
                           'CU_ARC',
                           'DBSNMP',
                           'EXFSYS',
                           'FLOWS_FILES',
                           'MDSYS',
                           'OLAPSYS',
                           'ORDDATA',
                           'OUTLN',
                           'SCOTT',
                           'SYS',
                           'SYSMAN',
                           'SYSTEM',
                           'WMSYS',
                           'XDB')
MINUS
   SELECT OWNER,
         OBJECT_NAME,
         OBJECT_TYPE,
         STATUS
    FROM ALL_OBJECTS
   WHERE     OBJECT_TYPE IN ('SEQUENCE',
                             'PROCEDURE',
                             'PACKAGE',
                             'PACKAGE BODY',
                             'TRIGGER',
                             'MATERIALIZED VIEW',
                             'VIEW',
                             'SYNONYM',
                             'FUNCTION',
                             'TYPE')
         AND OWNER NOT LIKE '%SYS%'
         AND OWNER NOT IN ('PUBLIC',
                           'ORACLE_OCM',
                           'GSMADMIN_INTERNAL',
                           'APEX_050000',
                           'OUTLN',
                           'APEX_LISTENER',
                           'TOAD',
                           'DBSNMP',
                           'XDB')
ORDER BY OWNER, STATUS, OBJECT_NAME;

SELECT OWNER,
         OBJECT_NAME,
         OBJECT_TYPE,
         STATUS
    FROM ALL_OBJECTS@SPURTAB
   WHERE     OBJECT_TYPE IN ('SEQUENCE',
                             'PROCEDURE',
                             'PACKAGE',
                             'PACKAGE BODY',
                             'TRIGGER',
                             'MATERIALIZED VIEW',
                             'VIEW',
                             'SYNONYM',
                             'FUNCTION',
                             'TYPE')
         AND OWNER NOT IN ('ORACLE_OCM',
                     'CBMVUSER',
                     'JET',
                     'CBMIRROR',
                     'CBPROXYUSER',
                     'APPQOSSYS',
                     'TOAD',
                     'ORDPLUGINS',
                     'ORDSYS',
                     'PUBLIC',
                     'OWBSYS',
                     'EXPIMP',
                     'CBSYSUSER',
                     'OWBSYS_AUDIT',
                     'APEX_050000',
                     'APEX_SPUR_DEV',
                     'ARDB_USER',
                     'CTXSYS',
                     'CU_ARC',
                     'DBSNMP',
                     'EXFSYS',
                     'FLOWS_FILES',
                     'MDSYS',
                     'OLAPSYS',
                     'ORDDATA',
                     'OUTLN',
                     'SCOTT',
                     'SYS',
                     'SYSMAN',
                     'SYSTEM',
                     'WMSYS',
                     'XDB')
MINUS
   SELECT OWNER,
         OBJECT_NAME,
         OBJECT_TYPE,
         STATUS
    FROM ALL_OBJECTS
   WHERE     OBJECT_TYPE IN ('SEQUENCE',
                             'PROCEDURE',
                             'PACKAGE',
                             'PACKAGE BODY',
                             'TRIGGER',
                             'MATERIALIZED VIEW',
                             'VIEW',
                             'SYNONYM',
                             'FUNCTION',
                             'TYPE')
         AND OWNER NOT LIKE '%SYS%'
         AND OWNER NOT IN ('PUBLIC',
                           'ORACLE_OCM',
                           'GSMADMIN_INTERNAL',
                           'APEX_050000',
                           'OUTLN',
                           'APEX_LISTENER',
                           'TOAD',
                           'DBSNMP',
                           'XDB')
ORDER BY OWNER, STATUS, OBJECT_NAME;
