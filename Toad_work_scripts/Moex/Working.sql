--INSERT INTO F_ATOM_ITEMS_RP_ORD_LM from V_INS_RP_ATOM_ITEMS_ORD  slow 04.06.2018

--296         11643    7aqu7m864dz27              LOADER_CASH 23374

select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID = '7aqu7m864dz27' and SAMPLE_TIME between to_date('04072018 02:00:00','ddmmyyyy hh24:mi:ss') and to_date('04072018 10:00:00','ddmmyyyy hh24:mi:ss') order by SAMPLE_TIME;

  SELECT ASH.SQL_ID, ASH.SQL_PLAN_LINE_ID, COUNT (1)
    FROM DBA_HIST_ACTIVE_SESS_HISTORY ASH
   WHERE     ASH.SESSION_ID = 296
         AND ASH.SAMPLE_TIME BETWEEN TO_DATE ('04072018 02:00:00',
                                              'DDMMYYYY HH24:MI:SS')
                                 AND TO_DATE ('04072018 10:00:00',
                                              'DDMMYYYY HH24:MI:SS')
GROUP BY ASH.SQL_ID, ASH.SQL_PLAN_LINE_ID
ORDER BY COUNT (1) DESC;
--plan_line_id count  
--7aqu7m864dz27	128	2632
--7aqu7m864dz27	125	19

/*predicate for this plan line
 124 - inmemory("SYSTEMREF" IS NOT NULL AND ("BOARDID"='NDEP' OR "BOARDID"='TDEP') AND "TRADEDATE">='01.07.2017' AND 
              "BOARDID"<>'RPMM' AND "TRADEDATE"<TRUNC(SYSDATE@!))
*/

/*
это отсюда
FROM v_rp_orders
часть
(  SELECT e.SYSTEMREF
                        FROM internaldm.v_eq_trades e
                       WHERE     (e.SYSTEMREF IS NOT NULL)
                             AND e.TRADEDATE >= '01.07.2017'
                             AND e.BOARDID IN ('TDEP', 'NDEP')
                    GROUP BY e.SYSTEMREF);
*/



SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'7aqu7m864dz27',format=>'+outline'));
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'7aqu7m864dz27',plan_hash_value=>3755205244,format=>'ALL'));

--

select * from spur_day.trades where TradeNo = :TradeNo and BuySell = :BuySell and TradeDate = :TradeDate;
select /*+ INDEX (TRADES_EQ_UIDX)*/ * from spur_day.trades where TradeNo = :TradeNo and BuySell = :BuySell and TradeDate = :TradeDate;
select /*+ INDEX (EQ.TRADES_BASE EQ_TRADES_BASE_TRNO_BS_IDX) */ * from spur_day.trades where TradeNo = :TradeNo and BuySell = :BuySell and TradeDate = :TradeDate;

-- запрос Кулешова от 26.06.2018

select * from finance_src.v_dp_trades t where  t.tradedate=to_date('25.06.2018','dd.mm.rrrr');
--не помогло
select  /*+ OPT_PARAM('_bloom_filter_enabled' 'FALSE') */ * from finance_src.v_dp_trades t where  t.tradedate=to_date('25.06.2018','dd.mm.rrrr');

-- Ошибка выполнения реквеста Разовое исправление TRADES|ORDERS (http://jira.moex.com/browse/VTD-556)
-- workaround со стороны сверок: http://jira.moex.com/browse/DWH-392

select * from compare_ardb.check_this_table_log order by updatedt;

--analyze 23.05.2018
select * from DBA_HIST_SQLTEXT WHERE lower(SQL_TEXT) like '%post_load_correct_ardb5(68532)%';
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID = '4ps4scf00av6y' order by SAMPLE_TIME;
select * from dba_users where USER_ID = 117;
--end  23.05.2018

  SELECT COMMENTS,
         TO_DATE (SUBSTR (COMMENTS, -10), 'dd.mm.yyyy') DATE_CORRECT,
         REQ_EXECUTE_DATE,
           TO_NUMBER(REQ_EXECUTE_DATE
         - TO_DATE (SUBSTR (COMMENTS, -10), 'dd.mm.yyyy')) DATE_DIFF,
         REQ_BEGIN_DATE,
         REQ_END_DATE,
         ROUND((REQ_END_DATE - REQ_BEGIN_DATE)*24*60,1) WORK_MINUTES, 
         REQ_STATUS,
         UPDATEDT
    FROM LOADER_COMPARE_ARDB6.IN_REQUEST
   WHERE     COMMENTS LIKE 'Запуск исправления%'
         AND UPDATEDT >= TRUNC (SYSDATE - 90)
         AND COMMENTS NOT LIKE '%CBMIRROR%'
         AND REQ_BEGIN_DATE IS NOT NULL
         --AND REQ_STATUS < 0
ORDER BY TO_NUMBER(REQ_EXECUTE_DATE
         - TO_DATE (SUBSTR (COMMENTS, -10), 'dd.mm.yyyy')),UPDATEDT;
         
select * from LOADER_COMPARE_ARDB6.REQ_LOG where UPDATEDT >= sysdate -20 order by UPDATEDT;--see 67653,67652;

SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE USER_ID = 117 /*AND SESSION_ID = 1827*/ AND SAMPLE_TIME BETWEEN TO_DATE('19042018 4:08:20','ddmmyyyy hh24:mi:ss') AND TO_DATE('19042018 06:35:00','ddmmyyyy hh24:mi:ss') ORDER BY SAMPLE_TIME;
--sids 3553,3038,1827
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID in ('75dzbrpys9yfz');

--анализ за 28.04.2018

SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID in (  SELECT TOP_LEVEL_SQL_ID
    FROM DBA_HIST_ACTIVE_SESS_HISTORY ASH
   WHERE    ASH.SAMPLE_TIME BETWEEN TO_DATE ('28042018 04:02:00',
                                              'DDMMYYYY HH24:MI:SS')
                                 AND TO_DATE ('28042018 06:10:00',
                                              'DDMMYYYY HH24:MI:SS')
GROUP BY ASH.SESSION_ID,TOP_LEVEL_SQL_ID having COUNT (1) > 100);


select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SESSION_ID = 2594 AND SAMPLE_TIME between to_date('28042018 04:02:00','ddmmyyyy hh24:mi:ss') and to_date('28042018 06:10:00','ddmmyyyy hh24:mi:ss') and USER_ID = 117 order by SAMPLE_TIME;
--502jpt86f0m54	BEGIN in_req_after_execute(31598, 0); END;
SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME between to_date('28042018 04:02:00','ddmmyyyy hh24:mi:ss') and to_date('28042018 06:10:00','ddmmyyyy hh24:mi:ss') and top_level_sql_id = '502jpt86f0m54' ORDER BY SAMPLE_TIME;
SELECT * FROM DBA_OBJECTS WHERE OBJECT_ID = 7954141;

-- !!! correct SID = 1314
  SELECT ASH.SQL_ID, ASH.SQL_PLAN_LINE_ID, COUNT (1)
    FROM DBA_HIST_ACTIVE_SESS_HISTORY ASH
   WHERE     ASH.SESSION_ID = 1314
         AND ASH.SAMPLE_TIME BETWEEN TO_DATE ('28042018 04:02:00',
                                              'DDMMYYYY HH24:MI:SS')
                                 AND TO_DATE ('28042018 06:10:00',
                                              'DDMMYYYY HH24:MI:SS')
GROUP BY ASH.SQL_ID, ASH.SQL_PLAN_LINE_ID
ORDER BY COUNT (1) DESC;

  SELECT ASH.SQL_ID, ASH.SQL_PLAN_LINE_ID, COUNT (1)
    FROM DBA_HIST_ACTIVE_SESS_HISTORY ASH
   WHERE     ASH.SESSION_ID = 2594
         AND ASH.SAMPLE_TIME BETWEEN TO_DATE ('28042018 04:02:00',
                                              'DDMMYYYY HH24:MI:SS')
                                 AND TO_DATE ('28042018 06:10:00',
                                              'DDMMYYYY HH24:MI:SS')
GROUP BY ASH.SQL_ID, ASH.SQL_PLAN_LINE_ID
ORDER BY COUNT (1) DESC;

--sql_id = 4u8p2rmhwhybm plan lines 2 (282 sample) and 1 (111 sample)

SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'4u8p2rmhwhybm',plan_hash_value=>445624621,format=>'ALL'));

-- анализ за 31.03.2018 

select * from compare_ardb.v__ardblink3 where run_id = 605482 and order_num = 3;
select * from compare_ardb.v__ardblink3 where TABLE_NAME = 'EQ.TRADES_BASE' and UPDATEDT between to_date('28042018 04:00:00','ddmmyyyy hh24:mi:ss') and to_date('28042018 07:00:00','ddmmyyyy hh24:mi:ss') order by UPDATEDT;

select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME between to_date('31032018 04:05:00','ddmmyyyy hh24:mi:ss') and to_date('31032018 04:30:00','ddmmyyyy hh24:mi:ss') and USER_ID = 117 order by SAMPLE_TIME;
--BEGIN in_req_after_execute(31443, 0); END; -реквест 31.03 --g5366kdm9hyz9
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME between to_date('31032018 04:05:00','ddmmyyyy hh24:mi:ss') and to_date('31032018 04:30:00','ddmmyyyy hh24:mi:ss') and TOP_LEVEL_SQL_ID = 'g5366kdm9hyz9' order by SAMPLE_TIME;
--BEGIN in_req_after_execute(31448, 0); END; -реквест 01.04 --84usxycguwc8k
select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME between to_date('01042018 04:05:00','ddmmyyyy hh24:mi:ss') and to_date('01042018 04:30:00','ddmmyyyy hh24:mi:ss') and TOP_LEVEL_SQL_ID = '84usxycguwc8k' order by SAMPLE_TIME;


SELECT * FROM DBA_HIST_SQLTEXT where sql_id = 'c0wafmwnt1w6a';

--'COMPARE_ARDB.CORRECT_IN_BLOCK(605482,3,28.03.2018%';
--CORRECT_TRADES_THIS_DAY(605482

select run_id, order_num, table_name
              from COMPARE_ARDB.CHECK_TABLES_LOG 
             where run_id = to_number(605482)
               and order_num = to_number(3);

SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID in (  SELECT TOP_LEVEL_SQL_ID
    FROM DBA_HIST_ACTIVE_SESS_HISTORY ASH
   WHERE   ASH.SAMPLE_TIME BETWEEN TO_DATE ('31032018 04:02:00',--'31032018 04:02:00',
                                              'DDMMYYYY HH24:MI:SS')
                                 AND TO_DATE ('01042018 04:30:00',
                                              'DDMMYYYY HH24:MI:SS')
                                 --AND USER_ID = 117
GROUP BY ASH.SESSION_ID,TOP_LEVEL_SQL_ID having COUNT (1) > 100
);

SELECT ASH.SQL_ID, ASH.SQL_PLAN_LINE_ID, COUNT (1)
    FROM DBA_HIST_ACTIVE_SESS_HISTORY ASH
   WHERE   ASH.SAMPLE_TIME BETWEEN TO_DATE ('31032018 04:02:00',
                                              'DDMMYYYY HH24:MI:SS')
                                 AND TO_DATE ('31032018 04:30:00',
                                              'DDMMYYYY HH24:MI:SS')
                                 AND SESSION_ID = 5290
GROUP BY ASH.SQL_ID, ASH.SQL_PLAN_LINE_ID
ORDER BY COUNT (1) DESC;

-- Оптимизация Даталогия (http://jira.moex.com/browse/MDP-44)

-- сравнение работы процедур с новым и старым объектами
--Боевой объект, с которым работают процедуры, указанные ниже – это один объект с физической точки зрения. Тестовый объект – это 2 физических объекта: новое мат представление + данные из старого объекта за вчерашний день.
--Кроме того, в новом объекте используется преобразование ORA_ROWSCN вместо UPDATEDT в старом. Отсюда и разница в скорости.


-- BAD (test, 14-24 секунд)
SELECT TRUNC (SYSDATE)
           SESSIONID,
       CLIENTID,
       TICKER,
       TOTAL_TRADES_VOLUME,
       NETFLOW,
       TO_TIMESTAMP (TO_CHAR (MAX (CL_LAST_DT) OVER (PARTITION BY TICKER)),
                     'YYYYMMDDHH24MISS.FF')
           LAST_DT
  FROM (  SELECT CLIENTID,
                 SECURITYID
                     TICKER,
                 SUM (TRADE_QUANTITY * TRADE_PRICE)
                     TOTAL_TRADES_VOLUME,
                 SUM (
                     CASE
                         WHEN BUYSELL = 'B' THEN TRADE_QUANTITY * TRADE_PRICE
                         ELSE (-1) * TRADE_QUANTITY * TRADE_PRICE
                     END)
                     NETFLOW,
                 MAX (
                       TO_CHAR (TRADEDATE, 'YYYYMMDD') * 1000000
                     + TRADETIME
                     + TRADEMICROSECONDS / 1000000)
                     CL_LAST_DT
            FROM MDP_TEST.V_SE_MV_ORDLOG_TOD OL
           WHERE     TRUNC (SESSIONID) = TRUNC (SYSDATE)
                 AND BOARDID = 'TQBR'
                 AND SECURITYID IN ('SBER', 'GAZP')
                 AND TRADENO IS NOT NULL
        GROUP BY CLIENTID, SECURITYID) LTS;

-- GOOD (prod, 6-9 секунд)
SELECT TRUNC (SYSDATE)
           SESSIONID,
       CLIENTID,
       TICKER,
       TOTAL_TRADES_VOLUME,
       NETFLOW,
       TO_TIMESTAMP (TO_CHAR (MAX (CL_LAST_DT) OVER (PARTITION BY TICKER)),
                     'YYYYMMDDHH24MISS.FF')
           LAST_DT
  FROM (  SELECT CLIENTID,
                 SECURITYID
                     TICKER,
                 SUM (TRADE_QUANTITY * TRADE_PRICE)
                     TOTAL_TRADES_VOLUME,
                 SUM (
                     CASE
                         WHEN BUYSELL = 'B' THEN TRADE_QUANTITY * TRADE_PRICE
                         ELSE (-1) * TRADE_QUANTITY * TRADE_PRICE
                     END)
                     NETFLOW,
                 MAX (
                       TO_CHAR (TRADEDATE, 'YYYYMMDD') * 1000000
                     + TRADETIME
                     + TRADEMICROSECONDS / 1000000)
                     CL_LAST_DT
            FROM INTERNALMDP.V_SE_ORDLOG_TOD OL
           WHERE     TRUNC (SESSIONID) = TRUNC (SYSDATE)
                 AND BOARDID = 'TQBR'
                 --            and status in ('M', 'W', 'C', 'D')
                 AND SECURITYID IN ('SBER', 'GAZP')
                 AND TRADENO IS NOT NULL
        GROUP BY CLIENTID, SECURITYID) LTS;
        
-- new (testing with new object with the same structure as matview) sql_id 3hbp6hba1hy1u

SELECT TRUNC (SYSDATE)
           SESSIONID,
       CLIENTID,
       TICKER,
       TOTAL_TRADES_VOLUME,
       NETFLOW,
       TO_TIMESTAMP  (TO_CHAR (MAX (CL_LAST_DT) OVER (PARTITION BY TICKER)),
                     'YYYYMMDDHH24MISS.FF')
           LAST_DT
  FROM (   SELECT CLIENTID,
                 SECURITYID
                     TICKER,
                 SUM (TRADE_QUANTITY * TRADE_PRICE)
                     TOTAL_TRADES_VOLUME,
                 SUM (
                     CASE
                         WHEN BUYSELL = 'B' THEN TRADE_QUANTITY * TRADE_PRICE
                         ELSE (-1) * TRADE_QUANTITY * TRADE_PRICE
                     END)
                     NETFLOW,
                 MAX (
                       TO_CHAR (TRADEDATE, 'YYYYMMDD') * 1000000
                     +  TRADETIME
                     + TRADEMICROSECONDS / 1000000)
                     CL_LAST_DT
            FROM MDP_TEST.V_SE_MV_ORDLOG_TOD_TEST OL -- MDP_TEST.V_SE_MV_ORDLOG_TOD_TEST1 --no UPDATEDT
           WHERE     TRUNC (SESSIONID) = TRUNC (SYSDATE)
                 AND BOARDID = 'TQBR'
                 --            and status in ('M', 'W', 'C', 'D')
                 AND SECURITYID IN   ('SBER', 'GAZP')
                 AND TRADENO IS NOT  NULL
        GROUP BY  CLIENTID, SECURITYID) LTS;
        
SELECT CLIENTID
                   FROM MDP_TEST.UNIF_CL_MT
                  WHERE UPPER (MARKET)  IN ('EQ', 'DLR') AND clientcode = '0433100000'
            FETCH FIRST 1 ROWS ONLY;

select * FROM MDP_TEST.UNIF_CL_MT;
select count(1),CLIENTCODE,UPPER (MARKET) from MDP_TEST.UNIF_CL_MT group by CLIENTCODE,UPPER (MARKET) having count(1) > 1 order by COUNT(1) desc;
            
SELECT /*+ FULL () */ CLIENTID
                   FROM MDP.UNIF_CL_MT
                  WHERE UPPER (MARKET) IN ('EQ', 'DLR') AND clientcode = '0433100000'
            FETCH FIRST 1 ROWS ONLY;
        
-- разница в таблицах UNIF_CL_MT в тесте и на бою

select CLIENTID,DETAILS,SUBDETAILS,CLIENTCODE,MARKET from MDP.UNIF_CL_MT
minus
select CLIENTID,DETAILS,SUBDETAILS,CLIENTCODE,MARKET from MDP_TEST.UNIF_CL_MT;

select count(1) from MDP.UNIF_CL_MT; --7 739 003
select count(1) from MDP_TEST.UNIF_CL_MT; --6 540 355

-- создание матпредставлений

CREATE MATERIALIZED VIEW MDP.MV_EQ_TRADES_ORDERS 
    (orders_rowid,trades_rowid,CONF_DATE,CONF_TIME,CONF_MICROSECONDS,CANCEL_DATE,CANCEL_TIME,
     CANCEL_MICROSECONDS,SESSIONID,ISMARKETMAKER,SECURITYID,BOARDID,
     ORDERNO,CONF_VOLUME,CANCEL_VOLUME,HIDDENVOLUME,CONF_RUBVALUE,
     CONF_PRICE,BUYSELL,CONF_PERIOD,STATUS,TRADEDATE,
     TRADETIME,TRADEMICROSECONDS,TRADENO,TRADE_QUANTITY,TRADE_PRICE,
     TRADE_RUBVALUE,TRADE_PERIOD,IS_DAYSESSION,CID)
PCTUSED    0
PCTFREE    5
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             128K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      KEEP
            CELL_FLASH_CACHE KEEP
           )
CACHE
INMEMORY MEMCOMPRESS FOR DML PRIORITY MEDIUM DISTRIBUTE AUTO NO DUPLICATE
REFRESH FAST START WITH TO_DATE('19042018 02:00:00','ddmmyyyy hh24:mi:ss')
NEXT SYSDATE+10/24/60
WITH ROWID
AS 
SELECT  /*+ NO_QUERY_TRANSFORMATION use_hash(t,o) ordered full(t) full(o) */
       o.ROWID
           orders_rowid,
       t.ROWID
           trades_rowid,
       O.ENTRYDATE
           AS CONF_DATE,
       O.ENTRYTIME
           AS CONF_TIME,
       O.ENTRYMICROSECONDS
           AS CONF_MICROSECONDS,
       O.AMENDDATE
           AS CANCEL_DATE,
       O.AMENDTIME
           AS CANCEL_TIME,
       O.AMENDMICROSECONDS
           AS CANCEL_MICROSECONDS,
       O.ENTRYDATE
           AS SESSIONID,
       O.ISMARKETMAKER,
       O.SECURITYID,
       O.BOARDID,
       O.ORDERNO,
       O.QUANTITY
           AS CONF_VOLUME,
       O.BALANCE
           AS CANCEL_VOLUME,
       O.QTYHIDDEN
           AS HIDDENVOLUME,
       O.VAL
           AS CONF_RUBVALUE,
       O.PRICE
           AS CONF_PRICE,
       O.BUYSELL,
       O.PERIOD
           AS CONF_PERIOD,
       O.STATUS,
       T.TRADEDATE,
       T.TRADETIME,
       T.TRADEMICROSECONDS,
       T.TRADENO,
       T.QUANTITY
           AS TRADE_QUANTITY,
       T.PRICE
           AS TRADE_PRICE,
       T.VAL
           TRADE_RUBVALUE,
       T.PERIOD
           TRADE_PERIOD,
       1
           AS IS_DAYSESSION,
       CASE
           WHEN O.CLIENTCODEID IS NULL THEN SUBSTR (O.FIRMID, 3, 12)
           ELSE TO_CHAR (O.CLIENTCODEID)
       END
           AS CID
    FROM SPUR_DAY.ORDERS O ,
       EQ.TRADES_BASE T  
WHERE T.ORDERNO(+) = O.ORDERNO AND
      T.TRADEDATE(+) = TO_DATE('19042018','ddmmyyyy') AND
      O.ENTRYDATE = TO_DATE('19042018','ddmmyyyy');
      
grant select on SPUR_DAY.ORDERS to MDP_TEST;
grant select on EQ.TRADES_BASE to MDP_TEST;
grant SELECT ANY TABLE to MDP;
grant SELECT ANY TABLE to MDP_TEST;
      
-- recreate mview
/*+ NO_QUERY_TRANSFORMATION use_hash(t,o) ordered full(t) full(o) dynamic_sampling(o 5) dynamic_sampling(t 5) */

--T.TRADEDATE = O.ENTRYDATE AND

--recreation of view (code for PL SQL procedure)

DROP MATERIALIZED VIEW MDP.MV_EQ_TRADES_ORDERS PRESERVE TABLE; 

CREATE MATERIALIZED VIEW MDP.MV_EQ_TRADES_ORDERS
ON PREBUILT TABLE WITH REDUCED PRECISION
REFRESH FAST ON DEMAND
START WITH TO_DATE('23042018 02:00:00','ddmmyyyy hh24:mi:ss')
NEXT SYSDATE+5/24/60
WITH ROWID
AS
    SELECT  /*+ NO_QUERY_TRANSFORMATION use_hash(t,o) ordered full(t) full(o) */
           O.ROWID
               ORDERS_ROWID,
           T.ROWID
               TRADES_ROWID,
           O.ENTRYDATE
               AS CONF_DATE,
           O.ENTRYTIME
               AS CONF_TIME,
           O.ENTRYMICROSECONDS
               AS CONF_MICROSECONDS,
           O.AMENDDATE
               AS CANCEL_DATE,
           O.AMENDTIME
               AS CANCEL_TIME,
           O.AMENDMICROSECONDS
               AS CANCEL_MICROSECONDS,
           O.ENTRYDATE
               AS SESSIONID,
           O.ISMARKETMAKER,
           O.SECURITYID,
           O.BOARDID,
           O.ORDERNO,
           O.QUANTITY
               AS CONF_VOLUME,
           O.BALANCE
               AS CANCEL_VOLUME,
           O.QTYHIDDEN
               AS HIDDENVOLUME,
           O.VAL
               AS CONF_RUBVALUE,
           O.PRICE
               AS CONF_PRICE,
           O.BUYSELL,
           O.PERIOD
               AS CONF_PERIOD,
           O.STATUS,
           T.TRADEDATE,
           T.TRADETIME,
           T.TRADEMICROSECONDS,
           T.TRADENO,
           T.QUANTITY
               AS TRADE_QUANTITY,
           T.PRICE
               AS TRADE_PRICE,
           T.VAL
               TRADE_RUBVALUE,
           T.PERIOD
               TRADE_PERIOD,
           1
               AS IS_DAYSESSION,
           CASE
               WHEN O.CLIENTCODEID IS NULL THEN SUBSTR (O.FIRMID, 3, 12)
               ELSE TO_CHAR (O.CLIENTCODEID)
           END
               AS CID
      FROM EQ.TRADES_BASE T, SPUR_DAY.ORDERS O
     WHERE     T.ORDERNO(+) = O.ORDERNO
           AND T.TRADEDATE(+) = TO_DATE ('23042018', 'ddmmyyyy')
           AND O.ENTRYDATE = TO_DATE ('23042018', 'ddmmyyyy');
           
set timing on echo on
EXEC DBMS_SNAPSHOT.REFRESH(LIST=>'MDP.MV_EQ_TRADES_ORDERS',METHOD=>'C');
EXEC DBMS_SNAPSHOT.REFRESH(LIST=>'MDP.MV_EQ_TRADES_ORDERS',METHOD=> '?');

-- end recreation of view (code for PL SQL procedure)

--!!! change with primary key refresh on WITH ROWID for FAST REFRESH
           
--ALTER MATERIALIZED VIEW MDP.MV_EQ_TRADES_ORDERS REFRESH FAST ON DEMAND START WITH TO_DATE('19-04-2018 02:00:00','dd-mm-yyyy hh24:mi:ss') NEXT SYSDATE+10/24/60 WITH ROWID;

select * from EQ.MV_TRADES_ORDERS;

EXEC DBMS_STATS.GATHER_TABLE_STATS ('EQ','TRADES_BASE', 'EQ_TRADES_BASE_P_20180417', GRANULARITY => 'PARTITION');

drop MATERIALIZED VIEW EQ.MV_TRADES_ORDERS_TEST ;
drop MATERIALIZED VIEW EQ.MV_TRADES_ORDERS ;
 
 grant select on spur_day_test.trades to OUTST_POLKOVNIKOVMO;
 grant select on spur_day_test.orders to OUTST_POLKOVNIKOVMO;
 
 CREATE MATERIALIZED VIEW LOG ON EQ.CURRENT_DATE
PCTUSED    0
PCTFREE    0
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             128K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      KEEP
            CELL_FLASH_CACHE KEEP
           )
NOCACHE
NOLOGGING
WITH ROWID
INCLUDING NEW VALUES
PURGE IMMEDIATE ASYNCHRONOUS;


CREATE MATERIALIZED VIEW SPUR_DAY_TEST.TRADES_ORDERS_TEST
REFRESH FAST ON DEMAND
AS
SELECT  /*+ use_hash(o,t) dynamic_sampling(o 5) dynamic_sampling(t 5) OPT_PARAM('PARALLEL_DEGREE_POLICY' 'ADAPTIVE') */
        O.ROWID ORDERS_ROWID,
        T.ROWID TRADES_ROWID,
       O.ENTRYDATE
           AS CONF_DATE,
       O.ENTRYTIME
           AS CONF_TIME,
       O.ENTRYMICROSECONDS
           AS CONF_MICROSECONDS,
       O.AMENDDATE
           AS CANCEL_DATE,
       O.AMENDTIME
           AS CANCEL_TIME,
       O.AMENDMICROSECONDS
           AS CANCEL_MICROSECONDS,
       O.ENTRYDATE
           AS SESSIONID,
       O.ISMARKETMAKER,
       O.SECURITYID,
       O.BOARDID,
       O.ORDERNO,
       O.QUANTITY
           AS CONF_VOLUME,
       O.BALANCE
           AS CANCEL_VOLUME,
       O.QTYHIDDEN
           AS HIDDENVOLUME,
       O.VAL
           AS CONF_RUBVALUE,
       O.PRICE
           AS CONF_PRICE,
       O.BUYSELL,
       O.PERIOD
           AS CONF_PERIOD,
       O.STATUS,
       T.TRADEDATE,
       T.TRADETIME,
       T.TRADEMICROSECONDS,
       T.TRADENO,
       T.QUANTITY
           AS TRADE_QUANTITY,
       T.PRICE
           AS TRADE_PRICE,
       T.VAL
           TRADE_RUBVALUE,
       T.PERIOD
           TRADE_PERIOD,
       1
           AS IS_DAYSESSION,
       CASE
           WHEN O.CLIENTCODEID IS NULL THEN SUBSTR (O.FIRMID, 3, 12)
           ELSE TO_CHAR (O.CLIENTCODEID)
       END
           AS CID
  FROM SPUR_DAY_TEST.ORDERS O,
       SPUR_DAY_TEST.TRADES T
WHERE O.ENTRYDATE = TO_DATE('16.04.2018','dd.mm.yyyy') AND T.TRADEDATE = TO_DATE('16.04.2018','dd.mm.yyyy') AND O.ENTRYDATE = T.TRADEDATE  AND T.ORDERNO = O.ORDERNO;

CREATE MATERIALIZED VIEW SPUR_DAY_TEST.TRADES_ORDERS_TEST
REFRESH fast ON demand
AS
SELECT  /*+ NO_QUERY_TRANSFORMATION use_hash(o,t) full(t) full(o) dynamic_sampling(o 5) dynamic_sampling(t 5) */
        o.rowid orders_rowid,
        t.rowid trades_rowid,
        c.rowid currd_rowid,
       O.ENTRYDATE
           AS CONF_DATE,
       O.ENTRYTIME
           AS CONF_TIME,
       O.ENTRYMICROSECONDS
           AS CONF_MICROSECONDS,
       O.AMENDDATE
           AS CANCEL_DATE,
       O.AMENDTIME
           AS CANCEL_TIME,
       O.AMENDMICROSECONDS
           AS CANCEL_MICROSECONDS,
       O.ENTRYDATE
           AS SESSIONID,
       O.ISMARKETMAKER,
       O.SECURITYID,
       O.BOARDID,
       O.ORDERNO,
       O.QUANTITY
           AS CONF_VOLUME,
       O.BALANCE
           AS CANCEL_VOLUME,
       O.QTYHIDDEN
           AS HIDDENVOLUME,
       O.VAL
           AS CONF_RUBVALUE,
       O.PRICE
           AS CONF_PRICE,
       O.BUYSELL,
       O.PERIOD
           AS CONF_PERIOD,
       O.STATUS,
       T.TRADEDATE,
       T.TRADETIME,
       T.TRADEMICROSECONDS,
       T.TRADENO,
       T.QUANTITY
           AS TRADE_QUANTITY,
       T.PRICE
           AS TRADE_PRICE,
       T.VAL
           TRADE_RUBVALUE,
       T.PERIOD
           TRADE_PERIOD,
       1
           AS IS_DAYSESSION,
       CASE
           WHEN O.CLIENTCODEID IS NULL THEN SUBSTR (O.FIRMID, 3, 12)
           ELSE TO_CHAR (O.CLIENTCODEID)
       END
           AS CID
  FROM SPUR_DAY_TEST.ORDERS O ,
       SPUR_DAY_TEST.TRADES T ,
       SPUR_DAY_TEST.CURRENT_DATE C
WHERE T.TRADEDATE = C.TRADEDATE and O.ENTRYDATE = C.TRADEDATE and T.ORDERNO = O.ORDERNO;

create table SPUR_DAY_TEST.CURRENT_DATE
(TRADEDATE DATE default trunc(sysdate),
UPDATEDT DATE default sysdate);

create table EQ.CURRENT_DATE
(TRADEDATE DATE default trunc(sysdate),
UPDATEDT DATE default sysdate) inmemory no memcompress;



select * from SPUR_DAY_TEST.CURRENT_DATE;

alter table SPUR_DAY_TEST.CURRENT_DATE modify TRADEDATE default trunc(sysdate);
alter table SPUR_DAY_TEST.CURRENT_DATE modify UPDATEDT default sysdate;

insert into  EQ.CURRENT_DATE(TRADEDATE) values(trunc(sysdate));



select max(ENTRYDATE) from SPUR_DAY_TEST.ORDERS;
select max(TRADEDATE) from SPUR_DAY_TEST.TRADES;

select max(ENTRYDATE) from SPUR_DAY.ORDERS;
select max(TRADEDATE) from SPUR_DAY.TRADES;

select * from SPUR_DAY_TEST.ORDERS partition for (trunc(sysdate)); 

set timing on echo on
drop MATERIALIZED VIEW SPUR_DAY_TEST.TRADES_ORDERS_TEST;

select count(1) from SPUR_DAY_TEST.TRADES T WHERE T.TRADEDATE = to_date('16.04.2018','dd.mm.yyyy');
select count(1) from SPUR_DAY_TEST.ORDERS O WHERE O.ENTRYDATE = to_date('16.04.2018','dd.mm.yyyy');

select max(tradetime) from SPUR_DAY_TEST.TRADES T WHERE T.TRADEDATE = to_date('16.04.2018','dd.mm.yyyy');
select max(entrytime) from SPUR_DAY_TEST.ORDERS O WHERE O.ENTRYDATE = to_date('16.04.2018','dd.mm.yyyy');


exec DBMS_MVIEW.EXPLAIN_MVIEW(mv=>'SPUR_DAY_TEST.TRADES_ORDERS_TEST');

select * from MV_CAPABILITIES_TABLE;


delete from MV_CAPABILITIES_TABLE;

exec DBMS_SNAPSHOT.REFRESH(LIST=>'SPUR_DAY_TEST.TRADES_ORDERS_TEST',METHOD=> '?',parallelism=>2);
exec DBMS_SNAPSHOT.REFRESH(LIST=>'SPUR_DAY_TEST.TRADES_ORDERS_TEST',METHOD=> '?');

select SYSDATE+30/24/60/60,SYSDATE+1/24/60,sysdate from dual;


SELECT  /*+ use_hash(o,t) full(t) full(o) dynamic_sampling(o 5) dynamic_sampling(t 5) OPT_PARAM('PARALLEL_DEGREE_POLICY' 'ADAPTIVE') */
        o.rowid orders_rowid,
        t.rowid trades_rowid,
        c.rowid currd_rowid,
       O.ENTRYDATE
           AS CONF_DATE,
       O.ENTRYTIME
           AS CONF_TIME,
       O.ENTRYMICROSECONDS
           AS CONF_MICROSECONDS,
       O.AMENDDATE
           AS CANCEL_DATE,
       O.AMENDTIME
           AS CANCEL_TIME,
       O.AMENDMICROSECONDS
           AS CANCEL_MICROSECONDS,
       O.ENTRYDATE
           AS SESSIONID,
       O.ISMARKETMAKER,
       O.SECURITYID,
       O.BOARDID,
       O.ORDERNO,
       O.QUANTITY
           AS CONF_VOLUME,
       O.BALANCE
           AS CANCEL_VOLUME,
       O.QTYHIDDEN
           AS HIDDENVOLUME,
       O.VAL
           AS CONF_RUBVALUE,
       O.PRICE
           AS CONF_PRICE,
       O.BUYSELL,
       O.PERIOD
           AS CONF_PERIOD,
       O.STATUS,
       T.TRADEDATE,
       T.TRADETIME,
       T.TRADEMICROSECONDS,
       T.TRADENO,
       T.QUANTITY
           AS TRADE_QUANTITY,
       T.PRICE
           AS TRADE_PRICE,
       T.VAL
           TRADE_RUBVALUE,
       T.PERIOD
           TRADE_PERIOD,
       1
           AS IS_DAYSESSION,
       CASE
           WHEN O.CLIENTCODEID IS NULL THEN SUBSTR (O.FIRMID, 3, 12)
           ELSE TO_CHAR (O.CLIENTCODEID)
       END
           AS CID
  FROM SPUR_DAY_TEST.ORDERS O ,
       SPUR_DAY_TEST.TRADES T ,
       SPUR_DAY_TEST.CURRENT_DATE C
WHERE T.TRADEDATE = C.TRADEDATE and O.ENTRYDATE = C.TRADEDATE and T.ORDERNO = O.ORDERNO;

--OPT_PARAM('PARALLEL_DEGREE_POLICY' 'ADAPTIVE')

select count(1) from (
SELECT  /*+  NO_QUERY_TRANSFORMATION use_hash(o,t) full(t) full(o) dynamic_sampling(o 5) dynamic_sampling(t 5) */
       o.ROWID
           orders_rowid,
       t.ROWID
           trades_rowid,
       c.ROWID
           currd_rowid,
       O.ENTRYDATE
           AS CONF_DATE,
       O.ENTRYTIME
           AS CONF_TIME,
       O.ENTRYMICROSECONDS
           AS CONF_MICROSECONDS,
       O.AMENDDATE
           AS CANCEL_DATE,
       O.AMENDTIME
           AS CANCEL_TIME,
       O.AMENDMICROSECONDS
           AS CANCEL_MICROSECONDS,
       O.ENTRYDATE
           AS SESSIONID,
       O.ISMARKETMAKER,
       O.SECURITYID,
       O.BOARDID,
       O.ORDERNO,
       O.QUANTITY
           AS CONF_VOLUME,
       O.BALANCE
           AS CANCEL_VOLUME,
       O.QTYHIDDEN
           AS HIDDENVOLUME,
       O.VAL
           AS CONF_RUBVALUE,
       O.PRICE
           AS CONF_PRICE,
       O.BUYSELL,
       O.PERIOD
           AS CONF_PERIOD,
       O.STATUS,
       T.TRADEDATE,
       T.TRADETIME,
       T.TRADEMICROSECONDS,
       T.TRADENO,
       T.QUANTITY
           AS TRADE_QUANTITY,
       T.PRICE
           AS TRADE_PRICE,
       T.VAL
           TRADE_RUBVALUE,
       T.PERIOD
           TRADE_PERIOD,
       1
           AS IS_DAYSESSION,
       CASE
           WHEN O.CLIENTCODEID IS NULL THEN SUBSTR (O.FIRMID, 3, 12)
           ELSE TO_CHAR (O.CLIENTCODEID)
       END
           AS CID
  FROM SPUR_DAY.ORDERS        O,
       EQ.TRADES_BASE        T,
       EQ.CURRENT_DATE  C
 WHERE     T.TRADEDATE = C.TRADEDATE
       AND O.ENTRYDATE = C.TRADEDATE
       AND T.ORDERNO = O.ORDERNO);
       
set timing on echo on
exec DBMS_SNAPSHOT.REFRESH(LIST=>'EQ.MV_TRADES_ORDERS',METHOD=>'C');
set timing on echo on
exec DBMS_SNAPSHOT.REFRESH(LIST=>'EQ.MV_TRADES_ORDERS',METHOD=> '?');
exec DBMS_SNAPSHOT.REFRESH(LIST=>'EQ.MV_TRADES_ORDERS',METHOD=> '?',parallelism=>2);
--exec DBMS_SNAPSHOT.REFRESH(LIST=>'EQ.MV_TRADES_ORDERS',METHOD=>'?');
--exec DBMS_SNAPSHOT.REFRESH(LIST=>'EQ.MV_TRADES_ORDERS',METHOD=> 'FULL');
exec DBMS_SNAPSHOT.REFRESH(LIST=>'EQ.MV_TRADES_ORDERS',METHOD=> '?',parallelism=>2);

-- view

select * from eq.v_trades_orders_mdp;
select count(1) from eq.v_trades_orders_mdp;
select max(tradetime) max_time,sysdate,'view' source from eq.v_trades_orders_mdp
union all
select max(tradetime),sysdate,'trades' from eq.trades_base where tradedate = trunc(sysdate);
create table trades_orders_mdp_test as select * from eq.v_trades_orders_mdp;

select count(1) from trades_orders_mdp_test;

delete from trades_orders_mdp_test;

drop table trades_orders_mdp_test;

insert /*+ APPEND */ into trades_orders_mdp_test select * from eq.v_trades_orders_mdp;
insert /*+ APPEND PARALLEL(2) */ into trades_orders_mdp_test select * from eq.v_trades_orders_mdp;


CREATE OR REPLACE FORCE VIEW EQ.V_TRADES_ORDERS_MDP
(
    CONF_DATE,
    CONF_TIME,
    CONF_MICROSECONDS,
    CANCEL_DATE,
    CANCEL_TIME,
    CANCEL_MICROSECONDS,
    SESSIONID,
    ISMARKETMAKER,
    SECURITYID,
    BOARDID,
    ORDERNO,
    CONF_VOLUME,
    CANCEL_VOLUME,
    HIDDENVOLUME,
    CONF_RUBVALUE,
    CONF_PRICE,
    BUYSELL,
    CONF_PERIOD,
    STATUS,
    TRADEDATE,
    TRADETIME,
    TRADEMICROSECONDS,
    TRADENO,
    TRADE_QUANTITY,
    TRADE_PRICE,
    TRADE_RUBVALUE,
    TRADE_PERIOD,
    IS_DAYSESSION,
    CID
)
BEQUEATH DEFINER
AS
    SELECT  /*+ NO_QUERY_TRANSFORMATION ordered use_hash(o,t) full(t) full(o) dynamic_sampling(o 5) dynamic_sampling(t 5) */
           O.ENTRYDATE
               AS CONF_DATE,
           O.ENTRYTIME
               AS CONF_TIME,
           O.ENTRYMICROSECONDS
               AS CONF_MICROSECONDS,
           O.AMENDDATE
               AS CANCEL_DATE,
           O.AMENDTIME
               AS CANCEL_TIME,
           O.AMENDMICROSECONDS
               AS CANCEL_MICROSECONDS,
           O.ENTRYDATE
               AS SESSIONID,
           O.ISMARKETMAKER,
           O.SECURITYID,
           O.BOARDID,
           O.ORDERNO,
           O.QUANTITY
               AS CONF_VOLUME,
           O.BALANCE
               AS CANCEL_VOLUME,
           O.QTYHIDDEN
               AS HIDDENVOLUME,
           O.VAL
               AS CONF_RUBVALUE,
           O.PRICE
               AS CONF_PRICE,
           O.BUYSELL,
           O.PERIOD
               AS CONF_PERIOD,
           O.STATUS,
           T.TRADEDATE,
           T.TRADETIME,
           T.TRADEMICROSECONDS,
           T.TRADENO,
           T.QUANTITY
               AS TRADE_QUANTITY,
           T.PRICE
               AS TRADE_PRICE,
           T.VAL
               TRADE_RUBVALUE,
           T.PERIOD
               TRADE_PERIOD,
           1
               AS IS_DAYSESSION,
           CASE
               WHEN O.CLIENTCODEID IS NULL THEN SUBSTR (O.FIRMID, 3, 12)
               ELSE TO_CHAR (O.CLIENTCODEID)
           END
               AS CID
      FROM EQ.TRADES_BASE T, SPUR_DAY.ORDERS O
     WHERE     T.TRADEDATE = TRUNC(SYSDATE)
           AND O.ENTRYDATE = TRUNC(SYSDATE)
           AND T.ORDERNO = O.ORDERNO;



-- игнорирование предиката после изменения порядка соединения (заявка ФОРС 795)

set timing on echo on linesize 250 pagesize 0
/*+ GATHER_PLAN_STATISTICS */ 

select t.tradedate, t.firmid, t.cash_type, t.cash_sub_type, replace (t.cash_type, '-', t.cash_sub_type) as cash_type,
          t.todaydebit, ct.MARKET_CODE, ct.REC_DATE_FROM, ct.REC_DATE_TO
          from finmodel.v_fmd_fix_eq t inner join  
                finmodel.v_se_cash_types_dim ct on replace(t.cash_type, '-', t.cash_sub_type) = ct.cash_type
          where t.tradedate = to_date('03.01.2018','dd.mm.yyyy') and t.FIRMID = 'MC0000500000' 
           and (t.tradedate >= ct.rec_date_from   and t.tradedate < ct.rec_date_to)                and  
          ct.cash_type_code in ('VAL', 'ADD_FEE', 'TRANSACTION_FEE', 'FIX_RP', 'FIX_EQ', 'FIX_AUCT') and ct.MARKET_CODE = 'RP';
          


--Теперь делаем маленькое изменение (просто переставляя помеченное зеленым), по логике то же самое, но почему-то выделенное желтым условие ораклом игнорится. 

alter session set max_dump_file_size = unlimited;
ALTER SESSION SET TRACEFILE_IDENTIFIER = "SESSION_bad_result";

ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';

-- трассировка выполнения для tkprof
ALTER SESSION SET EVENTS '10046 trace name context forever, level 1';


select t.tradedate,  t.firmid, t.cash_type, t.cash_sub_type, replace (t.cash_type, '-', t.cash_sub_type) as cash_type,
          t.todaydebit, ct.MARKET_CODE, ct.REC_DATE_FROM, ct.REC_DATE_TO
          from finmodel.v_fmd_fix_eq t, 
                finmodel.v_se_cash_types_dim ct 
          where t.tradedate = to_date('03.01.2018','dd.mm.yyyy')  and t.FIRMID = 'MC0000500000' 
           and (t.tradedate >= ct.rec_date_from   and t.tradedate < ct.rec_date_to)               and  
          ct.cash_type_code in ('VAL', 'ADD_FEE', 'TRANSACTION_FEE', 'FIX_RP', 'FIX_EQ', 'FIX_AUCT') and ct.MARKET_CODE = 'RP'
          and replace(t.cash_type, '-', t.cash_sub_type) = ct.cash_type;
          
alter system set events '10053 trace name context off';
alter SESSION set events '10046 trace name context off';


alter session set max_dump_file_size = unlimited;
ALTER SESSION SET TRACEFILE_IDENTIFIER = "SESSION_good_result";

ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';

-- трассировка выполнения для tkprof
ALTER SESSION SET EVENTS '10046 trace name context forever, level 1';

select t.tradedate, t.firmid, t.cash_type, t.cash_sub_type, replace (t.cash_type, '-', t.cash_sub_type) as cash_type,
          t.todaydebit,  ct.MARKET_CODE, ct.REC_DATE_FROM,  ct.REC_DATE_TO
          from  finmodel.v_fmd_fix_eq t inner join  
                finmodel.v_se_cash_types_dim ct on replace(t.cash_type, '-', t.cash_sub_type) = ct.cash_type
          where t.tradedate = to_date('03.01.2018','dd.mm.yyyy') and t.FIRMID = 'MC0000500000' 
           and (t.tradedate >= ct.rec_date_from   and t.tradedate < ct.rec_date_to)                and  
          ct.cash_type_code in ('VAL', 'ADD_FEE', 'TRANSACTION_FEE', 'FIX_RP', 'FIX_EQ', 'FIX_AUCT') and ct.MARKET_CODE = 'RP';
          
alter system set events '10053 trace name context off';
alter SESSION set events '10046 trace name context off';
          
finance_src.mv_ai_fix_eq
finmodel.mv_fmd_fix_eq

select * from dba_views where upper(TEXT_VC) like '%CASE TRIM%';
          

--exclude ORA-29275 when select from v$session because wrong action name from pl sql developer window
-- see trigger in G_ANALYTIC.TRG_AFTER_LOGON

select to_single_byte(TERMINAL) from v$session;
select sid,action from v$session --where TERMINAL is not null
 order by TERMINAL;
 
 select sid,dump(action),username from v$session where action is not null order by USERNAME;
 select sid,serial#,dump(action),username,TERMINAL,osuser,module,program,MACHINE,status,paddr from v$session where action is not null and username = 'G_ANALYTIC' order by paddr;
 select sid,action,username,TERMINAL,PROGRAM from v$session where action is not null and username = 'G_ANALYTIC' and TERMINAL in ('NUGAEVAA17')  order by sid;
 select sid,action,username,TERMINAL from v$session where action is not null and username = 'G_ANALYTIC' and TERMINAL not in ('NUGAEVAA17') order by TERMINAL;
 select sid,action,username from v$session where action is not null and username not in ('G_ANALYTIC')
 order by USERNAME;
  select * from v$process where addr = '0000001C31B91D60';
 
select * from nls_database_parameters where parameter='NLS_CHARACTERSET';


-- изменение назначения сверок для DWH и VDRF

--на Primary (когда недоступен Standby)

UPDATE COMPARE_ARDB.COMPARE_CONNECTIONS
   SET TNS = 'jdbc:oracle:thin:@(DESCRIPTION =
   (TRANSPORT_CONNECT_TIMEOUT=3)
    (ADDRESS_LIST =
      (FAILOVER=YES)
      (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan.moex.com)(PORT = 1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = var-scan.moex.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = DWH_PRIM)
    )
  )'
WHERE LINK = 'STB';

 UPDATE COMPARE_ARDB.COMPARE_CONNECTIONS
   SET TNS = 'jdbc:oracle:thin:@(DESCRIPTION =
   (TRANSPORT_CONNECT_TIMEOUT=3)
    (ADDRESS_LIST =
      (FAILOVER=YES)
      (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan2.moex.com)(PORT = 1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = var-scan2.moex.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = VDRF_PRIM)
    )
)'
WHERE LINK = '@CBMIRROR_PUB';


--на standby (по умолчанию)

UPDATE COMPARE_ARDB.COMPARE_CONNECTIONS
   SET TNS = 'jdbc:oracle:thin:@(DESCRIPTION =
   (TRANSPORT_CONNECT_TIMEOUT=3)
    (ADDRESS_LIST =
      (FAILOVER=YES)
      (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan.moex.com)(PORT = 1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = var-scan.moex.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = DWH_STB)
    )
  )'
WHERE LINK = 'STB';

 UPDATE COMPARE_ARDB.COMPARE_CONNECTIONS
   SET TNS = 'jdbc:oracle:thin:@(DESCRIPTION =
   (TRANSPORT_CONNECT_TIMEOUT=3)
    (ADDRESS_LIST =
      (FAILOVER=YES)
      (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan2.moex.com)(PORT = 1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = var-scan2.moex.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = VDRF_STB)
    )
)'
WHERE LINK = '@CBMIRROR_PUB';

-- оптимизация Ежедневной загрузки FINANCE_SRC.F_ATOM_ITEMS_FO_TRD см. http://jira.moex.com/browse/DWH-338

select * from LOADER_CASH.IN_REQUEST where req_id = 48 order by UPDATEDT desc;

--http://jira.moex.com/browse/DWH-323

CREATE OR REPLACE VIEW V_GET_EQ_ORD_TRD_DAY
(
    CONF_DATE,
    CONF_TIME,
    CONF_MICROSECONDS,
    CANCEL_DATE,
    CANCEL_TIME,
    CANCEL_MICROSECONDS,
    SESSIONID,
    CLIENTID,
    ISMARKETMAKER,
    SECURITYID,
    BOARDID,
    ORDERNO,
    CONF_VOLUME,
    CANCEL_VOLUME,
    HIDDENVOLUME,
    CONF_RUBVALUE,
    CONF_PRICE,
    BUYSELL,
    CONF_PERIOD,
    STATUS,
    TRADEDATE,
    TRADETIME,
    TRADEMICROSECONDS,
    TRADENO,
    TRADE_QUANTITY,
    TRADE_PRICE,
    TRADE_RUBVALUE,
    TRADE_PERIOD,
    IS_DAYSESSION,
    UPDATEDT
)
BEQUEATH DEFINER
AS
    SELECT o.entrydate
               AS conf_date,
           o.entrytime
               AS conf_time,
           o.entrymicroseconds
               AS conf_microseconds,
           o.amenddate
               AS cancel_date,
           o.amendtime
               AS cancel_time,
           o.amendmicroseconds
               AS cancel_microseconds,
           CASE
               WHEN NVL (t.tradetime, o.entrytime) >= 190000 THEN ss.D_N
               ELSE o.entrydate
           END
               AS SESSIONID,
           uni.clientid,
           o.ISMARKETMAKER,
           o.securityid,
           o.boardid,
           o.orderno,
           o.quantity
               AS conf_volume,
           o.balance
               AS cancel_volume,
           o.qtyhidden
               AS hiddenvolume,
           o.VAL
               AS conf_RUBVALUE,
           o.price
               AS conf_price,
           o.buysell,
           o.period
               AS conf_period,
           o.status,
           t.tradedate,
           t.tradetime,
           t.trademicroseconds,
           t.tradeno,
           t.quantity
               AS trade_quantity,
           t.price
               AS trade_price,
           t.val
               trade_RUBVALUE,
           t.period
               trade_period,
           CASE
               WHEN NVL (t.tradetime, o.entrytime) >= 190000 THEN 0
               ELSE 1
           END
               AS IS_DAYSESSION,
           SYSDATE
               AS updatedt
      FROM eq.orders_base                        o,
           eq.trades_base                        t,
           (SELECT D_N, TRUNC (EVE_D_N) AS EVE_D_N
              FROM internalrep.V_FOAR_FUT_SESSION) ss,
           (SELECT clientid, clientcode
              FROM MDP.UNIF_CL_MT
             WHERE market IN ('eq', 'dlr')) UNI,
           internaldm.v_MICEX_SESSIONS_CALENDAR  sc
     WHERE     1 = 1
           AND o.entrydate = sc.tradedate
           AND t.tradedate(+) = sc.tradedate
           AND t.orderno(+) = o.orderno
           AND ss.EVE_D_N(+) = o.entrydate
           AND (CASE
                    WHEN O.CLIENTCODEID IS NULL THEN SUBSTR (O.FIRMID, 3, 12)
                    ELSE TO_CHAR (O.CLIENTCODEID)
                END) =
               UNI.CLIENTCODE
           AND SC.ISFO = 1;

     
SELECT *
  FROM V_GET_EQ_ORD_TRD_DAY
 WHERE CONF_DATE = trunc(sysdate-1);
 
 SELECT *
  FROM mdp.V_GET_EQ_ORD_TRD_DAY
 WHERE CONF_DATE = trunc(sysdate-1);

 SELECT /*+ LEADING (spur.micex_sessions_calendar M) */ *
  FROM mdp.V_GET_EQ_ORD_TRD_DAY M
 WHERE M.CONF_DATE = (select  max(tradedate) max_trddate  from spur.micex_sessions_calendar where tradedate<trunc(sysdate));

with aa as (select  max(tradedate) max_trddate  from spur.micex_sessions_calendar where tradedate<trunc(sysdate))
select * from 
(SELECT /*+ LEADING (aa mdp.V_GET_EQ_ORD_TRD_DAY) */ SUM(trade_quantity * trade_price ) netflow FROM mdp.V_GET_EQ_ORD_TRD_DAY,aa
  WHERE CONF_DATE = aa.max_trddate
AND TRADE_QUANTITY IS NOT NULL AND TRADE_PRICE IS NOT NULL
  AND BUYSELL = 'B') - (SELECT /*+ LEADING (aa mdp.V_GET_EQ_ORD_TRD_DAY) */ SUM(trade_quantity * trade_price ) netflow FROM mdp.V_GET_EQ_ORD_TRD_DAY,aa
  WHERE CONF_DATE = aa.max_trddate
AND TRADE_QUANTITY IS NOT NULL AND TRADE_PRICE IS NOT NULL
  and buysell = 'S') as res from dual;
                     
select * from internaldm.v_MICEX_SESSIONS_CALENDAR;


SELECT   (SELECT SUM (TRADE_QUANTITY * TRADE_PRICE) NETFLOW
            FROM MDP.V_GET_EQ_ORD_TRD_DAY
           WHERE     CONF_DATE = (SELECT MAX (TRADEDATE)
                                    FROM SPUR.MICEX_SESSIONS_CALENDAR
                                   WHERE TRADEDATE < TRUNC (SYSDATE))
                 AND TRADE_QUANTITY IS NOT NULL
                 AND TRADE_PRICE IS NOT NULL
                 AND BUYSELL = 'B')
       - (SELECT SUM (TRADE_QUANTITY * TRADE_PRICE) NETFLOW
            FROM MDP.V_GET_EQ_ORD_TRD_DAY
           WHERE     CONF_DATE = (SELECT MAX (TRADEDATE)
                                    FROM SPUR.MICEX_SESSIONS_CALENDAR
                                   WHERE TRADEDATE < TRUNC (SYSDATE))
                 AND TRADE_QUANTITY IS NOT NULL
                 AND TRADE_PRICE IS NOT NULL
                 AND BUYSELL = 'S')
           AS RES
  FROM DUAL;
  
  
  
  /* Formatted on 05.12.2017 13:24:51 (QP5 v5.313) */
SELECT *
  FROM MDP.V_GET_EQ_ORD_TRD_DAY
 WHERE CONF_DATE = (SELECT MAX (TRADEDATE)
                      FROM SPUR.MICEX_SESSIONS_CALENDAR
                     WHERE TRADEDATE < TRUNC (SYSDATE));
                     
select * from internaldm.v_MICEX_SESSIONS_CALENDAR;

-- оптимизация сверки

 SELECT /*+ PARALLEL(4) */
    SUM(abs(to_number(substr(rawtohex(STANDARD_HASH(no
    || secid
    || time
    || quantity
    || wapricebuy
    || wapricesell
    || spread
    || duration,'MD5')),1,8),'XXXXXXXX'))) AS tablenumhash
FROM
spur.ol_futwabaspd
WHERE
    sess_id = 5398; --41sec
    
 SELECT /*+ PARALLEL(8) */
    SUM(abs(to_number(substr(rawtohex(STANDARD_HASH(no
    || secid
    || time
    || quantity
    || wapricebuy
    || wapricesell
    || spread
    || duration,'MD5')),1,8),'XXXXXXXX'))) AS tablenumhash
FROM
spur.ol_futwabaspd
WHERE
    sess_id = 5398; --21sec

 SELECT /*+ PARALLEL(10) */
    SUM(abs(to_number(substr(rawtohex(STANDARD_HASH(no
    || secid
    || time
    || quantity
    || wapricebuy
    || wapricesell
    || spread
    || duration,'MD5')),1,8),'XXXXXXXX'))) AS tablenumhash
FROM
spur.ol_futwabaspd
WHERE
    sess_id = 5398; --17

 SELECT /*+ PARALLEL(12) */
    SUM(abs(to_number(substr(rawtohex(STANDARD_HASH(no
    || secid
    || time
    || quantity
    || wapricebuy
    || wapricesell
    || spread
    || duration,'MD5')),1,8),'XXXXXXXX'))) AS tablenumhash
FROM
spur.ol_futwabaspd
WHERE
    sess_id = 5398; --14sec
    
 SELECT /*+ PARALLEL(16) */
    SUM(abs(to_number(substr(rawtohex(STANDARD_HASH(no
    || secid
    || time
    || quantity
    || wapricebuy
    || wapricesell
    || spread
    || duration,'MD5')),1,8),'XXXXXXXX'))) AS tablenumhash
FROM
spur.ol_futwabaspd
WHERE
    sess_id = 5398; --14sec
    
 SELECT /*+ PARALLEL(32) */
    SUM(abs(to_number(substr(rawtohex(STANDARD_HASH(no
    || secid
    || time
    || quantity
    || wapricebuy
    || wapricesell
    || spread
    || duration,'MD5')),1,8),'XXXXXXXX'))) AS tablenumhash
FROM
spur.ol_futwabaspd
WHERE
    sess_id = 5398; --15sec

-- http://jira.moex.com/browse/MDP-27

select * from MDP.V_LOR where day=to_date('09.04.2018','DD.MM.YYYY') and PROC='SE';
select * from MDP.V_LOR where day=trunc(sysdate) and PROC='SE';
select * from MDP.V_LOR where day=trunc(sysdate) and PROC='CU';
select * from MDP.V_LOR where day=to_date('10.04.2018','DD.MM.YYYY') and PROC='SE';
select * from MDP.V_LOR where day=to_date('09.04.2018','DD.MM.YYYY') and PROC='CU';
select * from MDP.V_LOR where day=to_date('21.11.2017','DD.MM.YYYY') and PROC='SE';
select * from MDP.V_LOR where day=to_date('20.11.2017','DD.MM.YYYY') and PROC='SE';
select * from MDP.V_LOR where day=to_date('17.11.2017','DD.MM.YYYY') and PROC='SE';

LOADER_COMPARE_ARDB3
begin MDP.INSERT_SE_ORD_TRD_ONLINE; end;
3csrbyhfgcb1a

select * from dba_users where USERNAME = 'LOADER_COMPARE_ARDB3';

SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID in ('28c7apt89py2n');
--BEGIN in_req_after_execute(34312, 0); END; с 21.11.2017 18:20:14,768 по 21.11.2017 18:47:11,993
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID in ('28c7apt89py2n');
--INSERT INTO se_ord_trd_log_online_temp ... с 21.11.2017 18:20:14,768 по 21.11.2017 18:20:54,888
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID in ('gzyxgn0nnyrxj');
--MERGE ... 
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID in ('b60ucbd4tvwrg');

SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID in ('5h8szssmk47h1');

SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'28c7apt89py2n',plan_hash_value=>2088432600,format=>'ALL')); --slow (21.11.2017)
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'5h8szssmk47h1',plan_hash_value=>2088432600,format=>'ALL')); --fast (17.11.2017)
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'0hk12gwbhycxa',plan_hash_value=>2088432600,format=>'ALL')); --fast (20.11.2017)

 

  SELECT *
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     USER_ID = 114
         AND SAMPLE_TIME BETWEEN TO_DATE ('21112017 18:39:00',
                                          'ddmmyyyy hh24:mi:ss')
                             AND TO_DATE ('21112017 18:50:00',
                                          'ddmmyyyy hh24:mi:ss')
                                       --   AND SQL_OPCODE = 189
ORDER BY SAMPLE_TIME;

  SELECT *
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     USER_ID = 114
         AND SAMPLE_TIME BETWEEN TO_DATE ('17112017 18:40:00',
                                          'ddmmyyyy hh24:mi:ss')
                             AND TO_DATE ('17112017 18:50:00',
                                          'ddmmyyyy hh24:mi:ss')
                                       --   AND SQL_OPCODE = 189
ORDER BY SAMPLE_TIME;

  SELECT *
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     USER_ID = 114
         AND SAMPLE_TIME BETWEEN TO_DATE ('20112017 18:40:00',
                                          'ddmmyyyy hh24:mi:ss')
                             AND TO_DATE ('20112017 18:50:00',
                                          'ddmmyyyy hh24:mi:ss')
                                       --   AND SQL_OPCODE = 189
ORDER BY SAMPLE_TIME;



select * from MDP.V_LOR where day=to_date('21.11.2017','DD.MM.YYYY') and PROC='SE';

select * from MDP.errlog where PROC = 'insert_cu_ord_trd_online' order by 1;

SELECT DBMS_STATS.get_prefs('GLOBAL_TEMP_TABLE_STATS') FROM dual;


INSERT INTO mdp.se_ord_trd_log_online_temp
(
conf_date,
conf_time,
conf_microseconds,
cancel_date ,
cancel_time,
cancel_microseconds,
SESSIONID,
ISMARKETMAKER,
securityid,
boardid,
orderno ,
conf_volume,
cancel_volume,
hiddenvolume,
conf_RUBVALUE,
conf_price,
buysell,
conf_period,
status,
tradedate ,
tradetime,
trademicroseconds,
tradeno,
trade_quantity,
trade_price,
trade_RUBVALUE,
trade_period,
IS_DAYSESSION,
cid
)
select 
       o.entrydate as conf_date
     , o.entrytime as conf_time
     , o.entrymicroseconds as conf_microseconds
     , o.amenddate as cancel_date 
     , o.amendtime as cancel_time
     , o.amendmicroseconds as cancel_microseconds
     , o.entrydate AS SESSIONID
     , o.ISMARKETMAKER
     , o.securityid
     , o.boardid
     , o.orderno 
     , o.quantity as conf_volume
     , o.balance as cancel_volume
     , o.qtyhidden as hiddenvolume
     , o.VAL as conf_RUBVALUE
     , o.price as conf_price
     , o.buysell
     , o.period as conf_period
     , o.status
     , t.tradedate 
     , t.tradetime
     , t.trademicroseconds
     , t.tradeno
     , t.quantity as trade_quantity
     , t.price as trade_price
     , t.val trade_RUBVALUE
     , t.period trade_period
     , 1 as IS_DAYSESSION
     , case when o.clientcodeid is null then substr(o.firmid,3,12) else to_char(o.clientcodeid) end as cid
from 
(select * from spur_day.orders partition (ORDERS_MINUS_1) where entrydate = trunc(sysdate-1)) o, 
EQ.trades_base partition (EQ_TRADES_BASE_P_20171121) t
where t.orderno(+) = o.orderno
 minus
select 
conf_date,
conf_time,
conf_microseconds,
cancel_date ,
cancel_time,
cancel_microseconds,
SESSIONID,
ISMARKETMAKER,
securityid,
boardid,
orderno ,
conf_volume,
cancel_volume,
hiddenvolume,
conf_RUBVALUE,
conf_price,
buysell,
conf_period,
status,
tradedate ,
tradetime,
trademicroseconds,
tradeno,
trade_quantity,
trade_price,
trade_RUBVALUE,
trade_period,
IS_DAYSESSION,
cid
from
mdp.se_ord_trd_log_online
where 
conf_date = trunc(sysdate-1);

SELECT * FROM dba_tab_statistics WHERE owner = 'MDP' AND table_name like 'SE_ORD_TRD_LOG_ONLINE%';

MDP	SE_ORD_TRD_LOG_ONLINE					TABLE	4108210	32537
MDP	SE_ORD_TRD_LOG_ONLINE_TEMP					TABLE								

MDP	SE_ORD_TRD_LOG_ONLINE					TABLE	4108210	32537	0	0	0	126	0	0			4108210	21/11/2017 20:13:12	YES	NO		YES	SHARED
MDP	SE_ORD_TRD_LOG_ONLINE_TEMP					TABLE													NO	NO			SHARED
MDP	SE_ORD_TRD_LOG_ONLINE_TEMP					TABLE	4118985	69716	0	0	0	118	0	0	0	0	4118985	22/11/2017 13:27:30	YES	NO			SESSION
				

BEGIN
  DBMS_STATS.set_table_prefs (
    ownname => 'MDP',
    tabname => 'SE_ORD_TRD_LOG_ONLINE_TEMP',
    pname   => 'GLOBAL_TEMP_TABLE_STATS',
    pvalue  => 'SHARED');
END;


select DBMS_STATS.GET_PREFS (ownname => 'MDP',tabname => 'SE_ORD_TRD_LOG_ONLINE_TEMP',pname   => 'GLOBAL_TEMP_TABLE_STATS') from dual;

EXEC DBMS_STATS.gather_table_stats('MDP','SE_ORD_TRD_LOG_ONLINE_TEMP');

MERGE /*+ GATHER_PLAN_STATISTICS */ INTO MDP.se_ord_trd_log_online ot
USING    
(
select 
conf_date,
conf_time,
conf_microseconds,
cancel_date ,
cancel_time,
cancel_microseconds,
SESSIONID,
ISMARKETMAKER,
securityid,
boardid,
orderno ,
conf_volume,
cancel_volume,
hiddenvolume,
conf_RUBVALUE,
conf_price,
buysell,
conf_period,
status,
tradedate ,
tradetime,
trademicroseconds,
tradeno,
trade_quantity,
trade_price,
trade_RUBVALUE,
trade_period,
IS_DAYSESSION,
cid
from MDP.se_ord_trd_log_online_temp) o
 ON 
 (ot.conf_date = to_date(to_char(trunc(sysdate-1),'YYYYMMDD'),'YYYYMMDD')
 and o.orderno = ot.orderno 
 and o.tradeno = ot.tradeno) 
 WHEN MATCHED 
THEN UPDATE SET 
ot.TRADE_PRICE=o.TRADE_PRICE,
ot.TRADE_RUBVALUE=o.TRADE_RUBVALUE,
ot.TRADE_PERIOD=o.TRADE_PERIOD,
ot.IS_DAYSESSION=o.IS_DAYSESSION,
ot.UPDATEDT=trunc(sysdate-1),
ot.CID=o.CID,
ot.CONF_TIME=o.CONF_TIME,
ot.CONF_MICROSECONDS=o.CONF_MICROSECONDS,
ot.CANCEL_DATE=o.CANCEL_DATE,
ot.CANCEL_TIME=o.CANCEL_TIME,
ot.CANCEL_MICROSECONDS=o.CANCEL_MICROSECONDS,
ot.SESSIONID=o.SESSIONID,
ot.ISMARKETMAKER=o.ISMARKETMAKER,
ot.SECURITYID=o.SECURITYID,
ot.BOARDID=o.BOARDID,
ot.CONF_VOLUME=o.CONF_VOLUME,
ot.CANCEL_VOLUME=o.CANCEL_VOLUME,
ot.HIDDENVOLUME=o.HIDDENVOLUME,
ot.CONF_RUBVALUE=o.CONF_RUBVALUE,
ot.CONF_PRICE=o.CONF_PRICE,
ot.BUYSELL=o.BUYSELL,
ot.CONF_PERIOD=o.CONF_PERIOD,
ot.STATUS=o.STATUS,
ot.TRADEDATE=o.TRADEDATE,
ot.TRADETIME=o.TRADETIME,
ot.TRADEMICROSECONDS=o.TRADEMICROSECONDS,
ot.TRADE_QUANTITY=o.TRADE_QUANTITY
WHEN NOT MATCHED 
THEN INSERT (TRADE_PRICE,
TRADE_RUBVALUE,
TRADE_PERIOD,
IS_DAYSESSION,
UPDATEDT,
CID,
CONF_DATE,
CONF_TIME,
CONF_MICROSECONDS,
CANCEL_DATE,
CANCEL_TIME,
CANCEL_MICROSECONDS,
SESSIONID,
ISMARKETMAKER,
SECURITYID,
BOARDID,
ORDERNO,
CONF_VOLUME,
CANCEL_VOLUME,
HIDDENVOLUME,
CONF_RUBVALUE,
CONF_PRICE,
BUYSELL,
CONF_PERIOD,
STATUS,
TRADEDATE,
TRADETIME,
TRADEMICROSECONDS,
TRADENO,
TRADE_QUANTITY
) VALUES (o.TRADE_PRICE,
o.TRADE_RUBVALUE,
o.TRADE_PERIOD,
o.IS_DAYSESSION,
trunc(sysdate-1),
o.CID,
o.CONF_DATE,
o.CONF_TIME,
o.CONF_MICROSECONDS,
o.CANCEL_DATE,
o.CANCEL_TIME,
o.CANCEL_MICROSECONDS,
o.SESSIONID,
o.ISMARKETMAKER,
o.SECURITYID,
o.BOARDID,
o.ORDERNO,
o.CONF_VOLUME,
o.CANCEL_VOLUME,
o.HIDDENVOLUME,
o.CONF_RUBVALUE,
o.CONF_PRICE,
o.BUYSELL,
o.CONF_PERIOD,
o.STATUS,
o.TRADEDATE,
o.TRADETIME,
o.TRADEMICROSECONDS,
o.TRADENO,
o.TRADE_QUANTITY);

Plan hash value: 518599860
 
-----------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name                       | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------------
|   0 | MERGE STATEMENT              |                            |     1 |   534 |   241  (25)| 00:00:01 |
|   1 |  MERGE                       | CU_ORD_TRD_LOG_ONLINE      |       |       |            |          |
|   2 |   VIEW                       |                            |       |       |            |          |
|*  3 |    HASH JOIN OUTER           |                            |     1 |   534 |   241  (25)| 00:00:01 |
|   4 |     TABLE ACCESS STORAGE FULL| CU_ORD_TRD_LOG_ONLINE_TEMP |     1 |   402 |     2   (0)| 00:00:01 |
|*  5 |     TABLE ACCESS STORAGE FULL| CU_ORD_TRD_LOG_ONLINE      |   146K|    18M|   238  (25)| 00:00:01 |
-----------------------------------------------------------------------------------------------------------



-- DAKR_MSSQL.DOWNLOADLASTMARKETDATA_EQ procedure

select * from DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME between to_date('02112017 09:15:00','ddmmyyyy hh24:mi:ss') and sysdate AND SESSION_ID = 1035 order by SAMPLE_TIME;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SAMPLE_TIME between to_date('02112017 09:15:00','ddmmyyyy hh24:mi:ss') and sysdate AND SESSION_ID = 1035 order by SAMPLE_TIME;

SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'6qv1yffcdx0p7',plan_hash_value=>635943195,format=>'ALL'));
RM_ASSETS_BASE
RM_MARKET_PRICERANGE_BASE

SQL_ID  6qv1yffcdx0p7, child number 0
-------------------------------------
INSERT INTO MARKETDATA SELECT TRADEDATE DATE1 , SECURITYID TICKER , 'F' 
MARKET , CLOSEPRICE PRICE , VOLUME VOLUME , VAL VOLUME_RUB , NUMTRADES 
TRADES , NULL INTEREST , '-' FUT_ISIN , NVL(S1,1) MARGIN_LVL1 , 
NVL(S2,1) MARGIN_LVL2 , NVL(S3,1) MARGIN_LVL3 , LK1 VOLUME_LVL1 , LK2 
VOLUME_LVL2 , TO_DATE('1900-01-01','YYYY-MM-DD') LASTTRADEDAY, NULL 
INTEREST_RUB, '-' TENOR, COLLATERAL COLLATERAL, FULLCOVERED 
SHORTSELLBAN, RATING INT_RATING FROM ( SELECT E.TRADEDATE , 
E.SECURITYID , E.CLOSEPRICE , E.VOLUME , E.VAL , E.NUMTRADES , L.S1 , 
L.S2 , L.S3 , L.LK1 , L.LK2, EQ.COLLATERAL, EQ.FULLCOVERED, R.RATING 
FROM INTERNALDM.V_EQ_SECHIST E JOIN INTERNALDM.V_EQ_SECS B ON 
E.SECURITYID = B.SECURITYID LEFT JOIN INTERNALDM.V_EQ_ASSETS EQ ON 
TRIM(E.SECURITYID) = TRIM(EQ.BASEASSETID) LEFT JOIN EQ_INT_RATINGS R ON 
TRIM(E.SECURITYID) = TRIM(R.SECURITYID) LEFT JOIN 
SPUR.V_P_DISCOUNTS_LIMITS L ON E.TRADEDATE = L.SETTLEDATE AND 
E.SECURITYID = L.SECURITYID WHERE E.TRADEDATE > :B1 AND E.BOARDID LIKE 
'TQ%' AND E.
 
Plan hash value: 635943195

-- отставание ONLINE 

--мониторинг

select m1.*, 
(select max(tradetime) from curr.trades_base where tradedate = trunc(sysdate-1) and tradetime < sys_time and tradetime >= 175000)
from MONONLINE m1
where 1=1
and tradedate = trunc(sysdate-1)
and sys_time >= 175000
and sys_time < 235900
and table_name  like '%CU'
and table_name like 'TR%'
order by id desc;


select m1.* 
from MONONLINE m1
where 1=1
and tradedate = trunc(sysdate-1)
and table_name not like '%CU'
and table_name like 'OR%'
order by id desc;

select count(*), substr(tradetime,1,4)
from eq.trades_base
where tradedate = trunc(sysdate-1) and tradetime < 213000 and tradetime >= 170000 
group by substr(tradetime,1,4) 
order by substr(tradetime,1,4) desc;

select count(*), substr(tradetime,1,4) from eq.trades_base
where tradedate = trunc(sysdate-1) and amendtime is not null
group by substr(tradetime,1,4)
--order by substr(tradetime,1,4) desc
order by 1 desc;

select AMENDTIME,tradetime from curr.trades_base where tradedate = trunc(sysdate-1) and AMENDTIME is not null order by AMENDTIME;
select AMENDTIME,tradetime from eq.trades_base where tradedate = trunc(sysdate-1) and AMENDTIME is not null order by AMENDTIME;

  SELECT *
    FROM MONONLINE
   WHERE 1 = 1 AND TRADEDATE >= TRUNC (SYSDATE - 1) AND TABLE_NAME LIKE 'OR%'
ORDER BY ID DESC;

  SELECT TABLE_NAME,TO_CHAR (TRADEDATE, 'ddmmyyyy') || ' ' || MAX_TRDATE
             CURR_TIME_CHAR,
         TO_DATE (TO_CHAR (TRADEDATE, 'ddmmyyyy') || ' ' || MAX_TRDATE,
                  'ddmmyyyy hh24miss')
             CURR_TIME,
         TO_DATE (TO_CHAR (TRADEDATE, 'ddmmyyyy') || ' ' || SYS_TIME,
                  'ddmmyyyy hh24miss')
             DB_TIME,
         TO_CHAR (TRADEDATE, 'ddmmyyyy') || ' ' || SYS_TIME
             DB_TIME_CHAR,
         LAG,
           (  TO_DATE (TO_CHAR (TRADEDATE, 'ddmmyyyy') || ' ' || MAX_TRDATE,
                       'ddmmyyyy hh24miss')
            - TO_DATE (TO_CHAR (TRADEDATE, 'ddmmyyyy') || ' ' || SYS_TIME,
                       'ddmmyyyy hh24miss'))
         * 24
         * 60
         * 60
             DIFF_SECONDS
    FROM MONONLINE
   WHERE 1 = 1 AND TRADEDATE >= TRUNC (SYSDATE - 1) AND            (  TO_DATE (TO_CHAR (TRADEDATE, 'ddmmyyyy') || ' ' || MAX_TRDATE,
                       'ddmmyyyy hh24miss')
            - TO_DATE (TO_CHAR (TRADEDATE, 'ddmmyyyy') || ' ' || SYS_TIME,
                       'ddmmyyyy hh24miss'))
         * 24
         * 60
         * 60 > 1
ORDER BY ID DESC;

-- мониторинг из БД за последние 8 часов

  SELECT TRADETIME,AMENDTIME,AMENDDATE,
         SCN_TO_TIMESTAMP (ORA_ROWSCN)
             DB_TS,
         TO_TIMESTAMP (
                TO_CHAR (SYSDATE, 'ddmmyyyy')
             || ' '
             || CASE
                    WHEN LENGTH (TRADETIME) < 6
                    THEN
                        TO_CHAR (0) || TO_CHAR (TRADETIME)
                    ELSE
                        TO_CHAR (TRADETIME)
                END,
             'ddmmyyyy hh24miss')
             TRADE_TS,
           SCN_TO_TIMESTAMP (ORA_ROWSCN)
         - TO_TIMESTAMP (
                  TO_CHAR (SYSDATE, 'ddmmyyyy')
               || ' '
               || CASE
                      WHEN LENGTH (TRADETIME) < 6
                      THEN
                          TO_CHAR (0) || TO_CHAR (TRADETIME)
                      ELSE
                          TO_CHAR (TRADETIME)
                  END,
               'ddmmyyyy hh24miss')
             TIME_LAG
    FROM CURR.TRADES_BASE
   WHERE        TRADEDATE = TRUNC (SYSDATE)
            AND SCN_TO_TIMESTAMP (ORA_ROWSCN) >= SYSDATE - 8 / 24
            AND AMENDTIME IS NULL
            AND (EXTRACT (
                    HOUR FROM (  SCN_TO_TIMESTAMP (ORA_ROWSCN)
                               - TO_TIMESTAMP (
                                        TO_CHAR (SYSDATE, 'ddmmyyyy')
                                     || ' '
                                     || CASE
                                            WHEN LENGTH (TRADETIME) < 6
                                            THEN
                                                   TO_CHAR (0)
                                                || TO_CHAR (TRADETIME)
                                            ELSE
                                                TO_CHAR (TRADETIME)
                                        END,
                                     'ddmmyyyy hh24miss'))) >=
                1
         OR EXTRACT (
                MINUTE FROM (  SCN_TO_TIMESTAMP (ORA_ROWSCN)
                             - TO_TIMESTAMP (
                                      TO_CHAR (SYSDATE, 'ddmmyyyy')
                                   || ' '
                                   || CASE
                                          WHEN LENGTH (TRADETIME) < 6
                                          THEN
                                                 TO_CHAR (0)
                                              || TO_CHAR (TRADETIME)
                                          ELSE
                                              TO_CHAR (TRADETIME)
                                      END,
                                   'ddmmyyyy hh24miss'))) >=
            5)
/*GROUP BY TRADETIME,
         SCN_TO_TIMESTAMP (ORA_ROWSCN),
         TO_TIMESTAMP (
                TO_CHAR (SYSDATE, 'ddmmyyyy')
             || ' '
             || CASE
                    WHEN LENGTH (TRADETIME) < 6
                    THEN
                        TO_CHAR (0) || TO_CHAR (TRADETIME)
                    ELSE
                        TO_CHAR (TRADETIME)
                END,
             'ddmmyyyy hh24miss'),
           SCN_TO_TIMESTAMP (ORA_ROWSCN)
         - TO_TIMESTAMP (
                  TO_CHAR (SYSDATE, 'ddmmyyyy')
               || ' '
               || CASE
                      WHEN LENGTH (TRADETIME) < 6
                      THEN
                          TO_CHAR (0) || TO_CHAR (TRADETIME)
                      ELSE
                          TO_CHAR (TRADETIME)
                  END,
               'ddmmyyyy hh24miss')
HAVING COUNT(1) >= 10 */
ORDER BY TRADETIME DESC;

-- оптимизация

select * from V_EQ_TRADES_ONLINE_TEST;
select count(*) from V_EQ_TRADES_ONLINE_TEST WHERE TradeNo = 2761990569+801 AND BuySell = 'B';

-- сравнение с неуникальным индексом и с уникальным

declare
v_num number;
begin
for i in 1..1000
 loop
  select count(*) into v_num from spur_day.trades WHERE TradeNo = 2761990469+201+i AND BuySell = 'B';
 end loop;
end;

declare
v_num number;
begin
for i in 1..1000
 loop
  select /*+ INDEX_RS_DESC(@"SEL$1" "TRADES"@"SEL$1" ("TRADES"."TRADENO" "TRADES"."BUYSELL")) */ count(*) into v_num from spur_day.trades WHERE TradeNo = 2761990569+401+i AND BuySell = 'B';
 end loop;
end;

fxyh2jbc9wb5s

select /*+ INDEX_RS_DESC(@"SEL$1" "TRADES"@"SEL$1" ("TRADES"."TRADENO" "TRADES"."BUYSELL")) */ count(*) from spur_day.trades WHERE TradeNo = 2761990569+401 AND BuySell = 'B';

select * from DBA_HIST_SQLTEXT WHERE SQL_ID in ('fxyh2jbc9wb5s','dfc1bajwpgz68','d6823ndznbavn');

UPDATE trades SET Status = :Status, ReportNo = :ReportNo, SettleDate = :SettleDate,Settled = :Settled, Price = :Price, AccInt = :AccInt,  Val = :Val, Amount = :Amount, Balance = :Balance, RprtComm = :RprtComm, AmendTime = :AmendTime, BankAccID = :BankAccID, Confirmed = :Confirmed,  ConfirmReport = :ConfirmReport, ConfirmTime = :ConfirmTime, ClearingType = :ClearingType, TRDACCID = :TrdAccId, CPTrdaccID = :CPTrdaccID,  BankId = :BankId, SettleTime = :SettleTime, ClearingTime = :ClearingTime, PenaltyValue = :PenaltyValue,  ClearingFirmID = :ClearingFirmID, ClearingBankAccID = :ClearingBankAccID WHERE TradeNo = :TradeNo AND BuySell = :BuySell;
UPDATE trades SET Status = :Status, ReportNo = :ReportNo, Confirmed = :Confirmed, ConfirmReport = :ConfirmReport,  ConfirmTime = :ConfirmTime, ClearingType = :ClearingType, CompVal = :CompVal, SettleTime = :SettleTime, AmendDate = :AmendDate,  ClearingTime = :ClearingTime, PenaltyValue = :PenaltyValue, ClearingFirmID = :ClearingFirmID,  ClearingBankAccID = :ClearingBankAccID WHERE TradeNo = :TradeNo AND BuySell = :BuySell;
UPDATE ORDERS SET EntryDate = :EntryDate, EntryTime = :EntryTime, EntryMicroseconds = :EntryMicroseconds,  ActivationDate = :ActivationDate, ActivationTime = :ActivationTime, SecurityID = :SecurityID,  BoardID = :BoardID, UserID = :UserID, FirmID = :FirmID, TrdaccID = :TrdaccID, BuySell = :BuySell, Typ = :Typ, Status = :Status,  Period = :Period, Price = :Price, Quantity = :Quantity, QtyHidden = :QtyHidden, Balance = :Balance, ExpiryDate = :ExpiryDate,  AmendDate = :AmendDate, AmendTime = :AmendTime, AmendMicroseconds = :AmendMicroseconds, LinkedOrder = :LinkedOrder,  CustodianID = :CustodianID, CounterPartyID = :CounterPartyID, CPFirmID = :CPFirmID, BrokerRef = :BrokerRef,  MatchRef = :MatchRef, IsMarketMaker= :IsMarketMaker, Yield= :Yield, Price2= :Price2, RepoRate = :RepoRate, RefundRate = :RefundRate, Val= :Val,  ExchangeID = :ExchangeID, SettleCode = :SettleCode, SettleDate = :SettleDate, LinkedQuote = :LinkedQuote,AccInt = :AccInt,  GatewayID = :GatewayID, OriginValue = :OriginValue, Baseprice = :BasePrice, SystemRef = :SystemRef, BankId = :BankId, BankAccId = :BankAccId,  IsStabiliser = :IsStabiliser, SettleDate1 = :SettleDate1 WHERE OrderNo = :OrderNo and EntryDate = :EntryDate;

--spur_day
--trades

select max(TRADETIME) from spur_day.trades where TRADEDATE = trunc(sysdate);

bad_SQL_ID fxyh2jbc9wb5s

UPDATE /*+ INDEX_RS_DESC(@"UPD$1" "TRADES"@"UPD$1" ("TRADES"."TRADENO" "TRADES"."BUYSELL")) */ trades SET Status = :Status, ReportNo = :ReportNo, SettleDate = :SettleDate,Settled = :Settled, Price = :Price, AccInt = :AccInt,  Val = :Val, Amount = :Amount, Balance = :Balance, RprtComm = :RprtComm, AmendTime = :AmendTime, BankAccID = :BankAccID, Confirmed = :Confirmed,  ConfirmReport = :ConfirmReport, ConfirmTime = :ConfirmTime, ClearingType = :ClearingType, TRDACCID = :TrdAccId, CPTrdaccID = :CPTrdaccID,  BankId = :BankId, SettleTime = :SettleTime, ClearingTime = :ClearingTime, PenaltyValue = :PenaltyValue,  ClearingFirmID = :ClearingFirmID, ClearingBankAccID = :ClearingBankAccID WHERE TradeNo = :TradeNo AND BuySell = :BuySell;

good_SQL_ID = bgkdzdtqs49wy, good_SQL_PLAN = 638144143

bad_SQL_ID dfc1bajwpgz68	

UPDATE /*+ INDEX_RS_DESC(@"UPD$1" "TRADES"@"UPD$1" ("TRADES"."TRADENO" "TRADES"."BUYSELL")) */ trades SET Status = :Status, ReportNo = :ReportNo, Confirmed = :Confirmed, ConfirmReport = :ConfirmReport,  ConfirmTime = :ConfirmTime, ClearingType = :ClearingType, CompVal = :CompVal, SettleTime = :SettleTime, AmendDate = :AmendDate,  ClearingTime = :ClearingTime, PenaltyValue = :PenaltyValue, ClearingFirmID = :ClearingFirmID,  ClearingBankAccID = :ClearingBankAccID WHERE TradeNo = :TradeNo AND BuySell = :BuySell;

good_SQL_ID = cxczknzq6thzg, good_SQL_PLAN = 638144143

sql_id = fxyh2jbc9wb5s	
final plan_hash = 17426557

--spur_day
--orders

d6823ndznbavn

UPDATE ORDERS SET EntryDate = :EntryDate, EntryTime = :EntryTime, EntryMicroseconds = :EntryMicroseconds, ActivationDate = :ActivationDate, ActivationTime = :ActivationTime, SecurityID = :SecurityID, BoardID = :BoardID, UserID = :UserID, FirmID = :FirmID, TrdaccID = :TrdaccID, BuySell = :BuySell, Typ = :Typ, Status = :Status, Period = :Period, Price = :Price, Quantity = :Quantity, QtyHidden = :QtyHidden, Balance = :Balance, ExpiryDate = :ExpiryDate, AmendDate = :AmendDate, AmendTime = :AmendTime, AmendMicroseconds = :AmendMicroseconds, LinkedOrder = :LinkedOrder, CustodianID = :CustodianID, CounterPartyID = :CounterPartyID, CPFirmID = :CPFirmID, BrokerRef = :BrokerRef, MatchRef = :MatchRef, IsMarketMaker= :IsMarketMaker, Yield= :Yield, Price2= :Price2, RepoRate = :RepoRate, RefundRate = :RefundRate, Val= :Val, ExchangeID = :ExchangeID, SettleCode = :SettleCode, SettleDate = :SettleDate, LinkedQuote = :LinkedQuote,AccInt = :AccInt, GatewayID = :GatewayID, OriginValue = :OriginValue, Baseprice = :BasePrice, SystemRef = :SystemRef, BankId = :BankId, BankAccId = :BankAccId, IsStabiliser = :IsStabiliser, SettleDate1 = :SettleDate1 WHERE OrderNo = :OrderNo and EntryDate = :EntryDate;

plans_hash: 2280706611,3514996002

SELECT * FROM TABLE (DBMS_XPLAN.DISPLAY_CURSOR ('d6823ndznbavn',0, 'ADVANCED'));

-- updates of spur_day (EQ user)

  SELECT *
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     SQL_ID = 'fxyh2jbc9wb5s'
         AND USER_ID = 88
         AND SAMPLE_TIME BETWEEN TO_DATE ('30102017 18:00:00',
                                          'ddmmyyyy hh24:mi:ss')
                             AND TO_DATE ('30102017 19:30:00',
                                          'ddmmyyyy hh24:mi:ss')
ORDER BY SAMPLE_TIME;

UPDATE SPUR_DAY.TRADES
   SET STATUS = :STATUS,
       REPORTNO = :REPORTNO,
       SETTLEDATE = :SETTLEDATE,
       SETTLED = :SETTLED,
       PRICE = :PRICE,
       ACCINT = :ACCINT,
       VAL = :VAL,
       AMOUNT = :AMOUNT,
       BALANCE = :BALANCE,
       RPRTCOMM = :RPRTCOMM,
       AMENDTIME = :AMENDTIME,
       BANKACCID = :BANKACCID,
       CONFIRMED = :CONFIRMED,
       CONFIRMREPORT = :CONFIRMREPORT,
       CONFIRMTIME = :CONFIRMTIME,
       CLEARINGTYPE = :CLEARINGTYPE,
       TRDACCID = :TRDACCID,
       CPTRDACCID = :CPTRDACCID,
       BANKID = :BANKID,
       SETTLETIME = :SETTLETIME,
       CLEARINGTIME = :CLEARINGTIME,
       PENALTYVALUE = :PENALTYVALUE,
       CLEARINGFIRMID = :CLEARINGFIRMID,
       CLEARINGBANKACCID = :CLEARINGBANKACCID
 WHERE TRADENO = :TRADENO AND BUYSELL = :BUYSELL;
 
 --after change synonym into V_TRADES_ONLINE IN EQ

-- bad sql stmt SQL_ID dfc1bajwpgz68 (~18% DB time)
UPDATE trades SET Status = :Status, ReportNo = :ReportNo, Confirmed = :Confirmed, ConfirmReport = :ConfirmReport, ConfirmTime = :ConfirmTime, ClearingType = :ClearingType, CompVal = :CompVal, SettleTime = :SettleTime, AmendDate = :AmendDate, ClearingTime = :ClearingTime, PenaltyValue = :PenaltyValue, ClearingFirmID = :ClearingFirmID, ClearingBankAccID = :ClearingBankAccID WHERE TradeNo = :TradeNo AND BuySell = :BuySell;
-- hinted sql stmt 1wq4xcckb1125
UPDATE /*+ INDEX_RS_DESC(@"SEL$DA9F4B51" "TRADES_BASE"@"SEL$1" ("TRADES_BASE"."TRADENO" "TRADES_BASE"."BUYSELL")) */ trades SET Status = :Status, ReportNo = :ReportNo, Confirmed = :Confirmed, ConfirmReport = :ConfirmReport, ConfirmTime = :ConfirmTime, ClearingType = :ClearingType, CompVal = :CompVal, SettleTime = :SettleTime, AmendDate = :AmendDate, ClearingTime = :ClearingTime, PenaltyValue = :PenaltyValue, ClearingFirmID = :ClearingFirmID, ClearingBankAccID = :ClearingBankAccID WHERE TradeNo = :TradeNo AND BuySell = :BuySell;

-- bad sql stmt SQL_ID fxyh2jbc9wb5s (~10% DB time) 
UPDATE trades SET Status = :Status, ReportNo = :ReportNo, SettleDate = :SettleDate, Settled = :Settled, Price = :Price, AccInt = :AccInt, Val = :Val, Amount = :Amount, Balance = :Balance, RprtComm = :RprtComm, AmendTime = :AmendTime, BankAccID = :BankAccID, Confirmed = :Confirmed, ConfirmReport = :ConfirmReport, ConfirmTime = :ConfirmTime, ClearingType = :ClearingType, TRDACCID = :TrdAccId, CPTrdaccID = :CPTrdaccID, BankId = :BankId, SettleTime = :SettleTime, ClearingTime = :ClearingTime, PenaltyValue = :PenaltyValue, ClearingFirmID = :ClearingFirmID, ClearingBankAccID = :ClearingBankAccID WHERE TradeNo = :TradeNo AND BuySell = :BuySell;
-- hinted sql stmt 7w1758fj62y5q
UPDATE /*+ INDEX_RS_DESC(@"SEL$DA9F4B51" "TRADES_BASE"@"SEL$1" ("TRADES_BASE"."TRADENO" "TRADES_BASE"."BUYSELL")) */trades SET Status = :Status, ReportNo = :ReportNo, SettleDate = :SettleDate, Settled = :Settled, Price = :Price, AccInt = :AccInt, Val = :Val, Amount = :Amount, Balance = :Balance, RprtComm = :RprtComm, AmendTime = :AmendTime, BankAccID = :BankAccID, Confirmed = :Confirmed, ConfirmReport = :ConfirmReport, ConfirmTime = :ConfirmTime, ClearingType = :ClearingType, TRDACCID = :TrdAccId, CPTrdaccID = :CPTrdaccID, BankId = :BankId, SettleTime = :SettleTime, ClearingTime = :ClearingTime, PenaltyValue = :PenaltyValue, ClearingFirmID = :ClearingFirmID, ClearingBankAccID = :ClearingBankAccID WHERE TradeNo = :TradeNo AND BuySell = :BuySell;

 -- merges of spur_day (EQ user)
 
   SELECT *
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     SQL_ID = '0hvrzuvpkrm4p'
         AND USER_ID = 89
         AND SAMPLE_TIME BETWEEN TO_DATE ('01112017 00:00:00',
                                          'ddmmyyyy hh24:mi:ss')
                             AND TO_DATE ('01112017 23:59:59',
                                          'ddmmyyyy hh24:mi:ss')
ORDER BY SAMPLE_TIME;
 
  
 --

SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID = '5jqtwnrv8mwzm' and SAMPLE_TIME >= sysdate-1 order by SAMPLE_TIME;

sid =5077     serial= 14483    5jqtwnrv8mwzm

delete from CLIENTCODES_BASE_ENC_MIR where 1=1 and ("L_ID") in (select "L_ID" from (select "ACCOUNTDETAILS","BANKLICENSE","CLIENTCODE","CLIENTCODEID","COUNTRYCODE","CROSSTRADING","DATECLOSE","DATEOPEN","DETAILS","DETAILS_ENC","DOCID","FIRMID","INDINVACCOUNT","INSERTDATE","ISBANK","ISCURRENCYLICENSE","ISINSURER","I_LEVEL","L_ID","MASTERCODE","Q_INVESTOR","REPRESENTATIVE","REQ_ID","SECTION","STATUS","ST_ACTUAL","SUBDETAILS","SUBDETAILS_ENC","SUBTYP","TIMECLOSE","TIMEOPEN","TYP","UPDATEDATE","UPDATEDT" from CLIENTCODES_BASE_ENC_MIR WHERE 1=1 and updatedt between to_date('27102017154100','DDMMYYYYHH24MISS') and to_date('31102017002500','DDMMYYYYHH24MISS') minus select "ACCOUNTDETAILS","BANKLICENSE","CLIENTCODE","CLIENTCODEID","COUNTRYCODE","CROSSTRADING","DATECLOSE","DATEOPEN","DETAILS","DETAILS_ENC","DOCID","FIRMID","INDINVACCOUNT","INSERTDATE","ISBANK","ISCURRENCYLICENSE","ISINSURER","I_LEVEL","L_ID","MASTERCODE","Q_INVESTOR","REPRESENTATIVE","REQ_ID","SECTION","STATUS","ST_ACTUAL","SUBDETAILS","SUBDETAILS_ENC","SUBTYP","TIMECLOSE","TIMEOPEN","TYP","UPDATEDATE","UPDATEDT" from EQ.CLIENTCODES_BASE_ENC WHERE 1=1 and updatedt between to_date('27102017154100','DDMMYYYYHH24MISS') and to_date('31102017002500','DDMMYYYYHH24MISS')));

DELETE FROM EQ.CLIENTCODES_BASE_ENC_MIR
      WHERE     1 = 1
            AND ("L_ID") IN
                    (SELECT "L_ID"
                       FROM (SELECT "ACCOUNTDETAILS",
                                    "BANKLICENSE",
                                    "CLIENTCODE",
                                    "CLIENTCODEID",
                                    "COUNTRYCODE",
                                    "CROSSTRADING",
                                    "DATECLOSE",
                                    "DATEOPEN",
                                    "DETAILS",
                                    "DETAILS_ENC",
                                    "DOCID",
                                    "FIRMID",
                                    "INDINVACCOUNT",
                                    "INSERTDATE",
                                    "ISBANK",
                                    "ISCURRENCYLICENSE",
                                    "ISINSURER",
                                    "I_LEVEL",
                                    "L_ID",
                                    "MASTERCODE",
                                    "Q_INVESTOR",
                                    "REPRESENTATIVE",
                                    "REQ_ID",
                                    "SECTION",
                                    "STATUS",
                                    "ST_ACTUAL",
                                    "SUBDETAILS",
                                    "SUBDETAILS_ENC",
                                    "SUBTYP",
                                    "TIMECLOSE",
                                    "TIMEOPEN",
                                    "TYP",
                                    "UPDATEDATE",
                                    "UPDATEDT"
                               FROM EQ.CLIENTCODES_BASE_ENC_MIR
                              WHERE     1 = 1
                                    AND UPDATEDT BETWEEN TO_DATE (
                                                             '27102017154100',
                                                             'DDMMYYYYHH24MISS')
                                                     AND TO_DATE (
                                                             '31102017002500',
                                                             'DDMMYYYYHH24MISS')
                             MINUS
                             SELECT "ACCOUNTDETAILS",
                                    "BANKLICENSE",
                                    "CLIENTCODE",
                                    "CLIENTCODEID",
                                    "COUNTRYCODE",
                                    "CROSSTRADING",
                                    "DATECLOSE",
                                    "DATEOPEN",
                                    "DETAILS",
                                    "DETAILS_ENC",
                                    "DOCID",
                                    "FIRMID",
                                    "INDINVACCOUNT",
                                    "INSERTDATE",
                                    "ISBANK",
                                    "ISCURRENCYLICENSE",
                                    "ISINSURER",
                                    "I_LEVEL",
                                    "L_ID",
                                    "MASTERCODE",
                                    "Q_INVESTOR",
                                    "REPRESENTATIVE",
                                    "REQ_ID",
                                    "SECTION",
                                    "STATUS",
                                    "ST_ACTUAL",
                                    "SUBDETAILS",
                                    "SUBDETAILS_ENC",
                                    "SUBTYP",
                                    "TIMECLOSE",
                                    "TIMEOPEN",
                                    "TYP",
                                    "UPDATEDATE",
                                    "UPDATEDT"
                               FROM EQ.CLIENTCODES_BASE_ENC
                              WHERE     1 = 1
                                    AND UPDATEDT BETWEEN TO_DATE (
                                                             '27102017154100',
                                                             'DDMMYYYYHH24MISS')
                                                     AND TO_DATE (
                                                             '31102017002500',
                                                             'DDMMYYYYHH24MISS')));

--SMART scan slower then full scan

select * from V$BH where OBJD in (select OBJECT_ID from dba_objects where object_name in ('OTC_INITIAL_MARGIN_BASE','VW_CONTRACT_OTC_BASE','SEL_LOG') and OWNER <> 'NAVIA');
select * from V$BH where OBJD in (select OBJECT_ID from dba_objects where object_name in ('CU_ORD_TRD_LOG_ONLINE'));
select * from dba_objects where object_name in ('OTC_INITIAL_MARGIN_BASE','VW_CONTRACT_OTC_BASE','SEL_LOG') and OWNER <> 'NAVIA';
select OWNER,TABLE_NAME,BUFFER_POOL,FLASH_CACHE,CELL_FLASH_CACHE from dba_tables where table_name in ('OTC_INITIAL_MARGIN_BASE','VW_CONTRACT_OTC_BASE','SEL_LOG') and OWNER <> 'NAVIA';
alter session set cell_offload_processing = false;
alter session set cell_offload_processing = true;

alter session set max_dump_file_size = unlimited;
ALTER SESSION SET TRACEFILE_IDENTIFIER = "SESSION_666";

ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';

  SELECT T.*,
         (SELECT SUM (M.INITIALMARGIN)
            FROM OUTST_LEONOVDV.OTC_INITIAL_MARGIN_BASE M
           WHERE M.CONTRACT_ID IN (SELECT CLEARING_CONTRACT_ID
                                     FROM OUTST_LEONOVDV.VW_CONTRACT_OTC_BASE C
                                    WHERE C.CUSTID = T.CUSTID))
             AS COLLATERAL_VALUE
    FROM OUTST_LEONOVDV.SEL_LOG T
ORDER BY COLLATERAL_VALUE;

alter system set events '10053 trace name context off';

select * from OUTST_LEONOVDV.OTC_INITIAL_MARGIN_BASE;
select * from OUTST_LEONOVDV.VW_CONTRACT_OTC_BASE;
select * from OUTST_LEONOVDV.SEL_LOG;

ALTER SESSION SET EVENTS '10046 trace name context forever, level 12';

  SELECT T.*,
         (SELECT SUM (M.INITIALMARGIN)
            FROM OUTST_LEONOVDV.OTC_INITIAL_MARGIN_BASE M
           WHERE M.CONTRACT_ID IN (SELECT CLEARING_CONTRACT_ID
                                     FROM OUTST_LEONOVDV.VW_CONTRACT_OTC_BASE C
                                    WHERE C.CUSTID = T.CUSTID))
             AS COLLATERAL_VALUE
    FROM OUTST_LEONOVDV.SEL_LOG T
ORDER BY COLLATERAL_VALUE;

alter system set events '10046 trace name context off';

select * from dba_objects where OBJECT_NAME = 'VW_CONTRACT_OTC_BASE';
select * from x$bh where obj = 7017212; 

--

--http://jira.moex.com/browse/ORACLE-33

SQL_ID = '3qrrta84928pc'

MERGE INTO FO_BF O USING ( SELECT SESSIONID , CLIENTID , TICKER , ORDERS_COUNT , TOTAL_TRADES_VOLUME , NETFLOW , TO_CHAR(TO_TIMESTAMP(TO_CHAR(MAX(CL_LAST_DT) OVER (PARTITION BY TICKER)), 'YYYYMMDDHH24MISS.FF'), 'YYYY-MM-DD HH24:MI:SS.FF') LAST_DT FROM ( SELECT TO_DATE(:B2 ) AS SESSIONID , CLIENTID , SUBSTR(SHORTNAME, 1, 2) AS TICKER , COUNT(DISTINCT NUMB_ORDER) ORDERS_COUNT , SUM(CASE WHEN ACTION = 'TRADE' THEN KOL ELSE NULL END) TOTAL_TRADES_VOLUME , SUM(CASE WHEN ACTION = 'TRADE' AND DIR = 'B' THEN KOL WHEN ACTION = 'TRADE' AND DIR = 'S' THEN (-1)*KOL ELSE NULL END) NETFLOW , MAX(CAST(TO_CHAR(DAT_TIME, 'YYYYMMDDhh24miss') AS NUMBER)+ MSEC/1000) CL_LAST_DT FROM INTERNALMDP.V_FO_ORDLOG OL JOIN ( SELECT SECURITYID , SHORTNAME FROM INTERNALMDP.V_INSTRUMENTS WHERE SUBSTR(SHORTNAME, 1, 2) IN ('Si', 'RI', 'BR', 'SR') AND MARKET = 'FORTS-FU' AND SECURITY_TYPE != 'Календарные спреды' AND SHORTNAME NOT LIKE '%vm' ) I ON I.SECURITYID = OL.ISIN WHERE SESS_ID = :B1 GROUP BY CLIENTID, SUBSTR(SHORTNAME, 1, 2) ) CL_GRP ) N ON (O.SESSIONID = N.SESSIONID AND O.CLIENTID = N.CLIENTID AND O.TICKER = N.TICKER) WHEN MATCHED THEN UPDATE SET O.ORDERS_COUNT = N.ORDERS_COUNT, O.TOTAL_TRADES_VOLUME = N.TOTAL_TRADES_VOLUME, O.NETFLOW = N.NETFLOW, O.LAST_DT = N.LAST_DT WHEN NOT MATCHED THEN INSERT (SESSIONID, CLIENTID, TICKER, ORDERS_COUNT, TOTAL_TRADES_VOLUME, NETFLOW, LAST_DT) VALUES (N.SESSIONID, N.CLIENTID, N.TICKER, N.ORDERS_COUNT, N.TOTAL_TRADES_VOLUME, N.NETFLOW, N.LAST_DT)

sid = 5091, serial = 31139, username = LOADER_DATALOGIA

SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SESSION_ID = 5091 and SESSION_SERIAL# = 31139 and SAMPLE_TIME >= sysdate-5 order by SAMPLE_TIME;

select * from dba_objects where object_id = 6996070;

select count(1) from MDATA_MDDEV_HADOOP.FO_BF partition(PTODAY);

index at CLR_INVESTR_BASE must be invisible !!!

--backup RO tablespaces

SELECT 'BACKUP TAG RO_TS_ FILESPERSET 1 TABLESPACE '||LISTAGG (TABLESPACE_NAME, ',') WITHIN GROUP (ORDER BY TABLESPACE_NAME) ||';'
           TSNAMES
  FROM DBA_TABLESPACES
 WHERE STATUS = 'READ ONLY' ORDER BY TABLESPACE_NAME;

select * from dba_tablespaces;

--

set echo on timing on
--alter table LDWH.TMP_ORDER_FO move;

-- TEMP monitiring new

select * from 
(  SELECT SYSDATE                                     CURR_TIME,
              A.USERNAME,
              A.MACHINE,
              MAX (ROUND ((B.BLOCKS * 8192) / 1024 / 1024)) MB_USED,
              ROUND(MAX (ROUND (B.BLOCKS * 8192))/SUM(T.BYTES),2)*100 PERSENT_TEMP_USED,
              B.TABLESPACE,
              SUM(T.BYTES)/1024/1024 TOTAL_MB_IN_TEMP,
              A.SID,
              A.SERIAL#,
              A.STATUS,
              A.LOGON_TIME,
              A.PROGRAM,
              A.EVENT,
              A.WAIT_CLASS,
              A.PREV_EXEC_START,
              A.TIME_REMAINING_MICRO,
              A.SECONDS_IN_WAIT,
              A.BLOCKING_SESSION_STATUS,
              A.OSUSER,
              C.SQL_ID,
              C.SQL_TEXT
         FROM V$SESSION A, V$SORT_USAGE B, V$SQLAREA C,V$TEMPFILE T
        WHERE     B.TABLESPACE LIKE '%TEMP'
              AND A.SADDR = B.SESSION_ADDR
              AND C.ADDRESS = A.SQL_ADDRESS
              AND C.HASH_VALUE = A.SQL_HASH_VALUE
              AND T.TS# = B.TS#
              AND   B.BLOCKS
                  * (SELECT BLOCK_SIZE
                       FROM DBA_TABLESPACES
                      WHERE TABLESPACE_NAME = B.TABLESPACE) > 10 * 1024 * 1024
     GROUP BY SYSDATE,
              A.USERNAME,
              A.MACHINE,
              B.TABLESPACE,
              A.SID,
              A.SERIAL#,
              A.STATUS,
              A.LOGON_TIME,
              A.PROGRAM,
              A.EVENT,
              A.WAIT_CLASS,
              A.PREV_EXEC_START,
              A.TIME_REMAINING_MICRO,
              A.SECONDS_IN_WAIT,
              A.BLOCKING_SESSION_STATUS,
              A.OSUSER,
              C.SQL_ID,
              C.SQL_TEXT)
    ORDER BY MB_USED DESC;

--

select count(1)  from    "MDP"."V_GET_CU_ORD_TRD_DAY_TEST"    where 
conf_date = to_date('10102017','DDMMYYYY');

select /*+ NAPARALLEL */ count(1)  from    "MDP"."V_GET_CU_ORD_TRD_DAY"    where 
conf_date = to_date('10102017','DDMMYYYY');

select /*+ dynamic_sampling(0) */ count(1)  from    "MDP"."V_GET_CU_ORD_TRD_DAY"    where 
conf_date = to_date('10102017','DDMMYYYY');

alter session set optimizer_dynamic_sampling=0;

CREATE OR REPLACE FORCE VIEW MDP.V_GET_CU_ORD_TRD_DAY_TEST
(
    CONF_DATE,
    CONF_TIME,
    CONF_MICROSECONDS,
    CANCEL_DATE,
    CANCEL_TIME,
    CANCEL_MICROSECONDS,
    SESSIONID,
    CLIENTID,
    ISMARKETMAKER,
    SECURITYID,
    BOARDID,
    ORDERNO,
    CONF_VOLUME,
    CANCEL_VOLUME,
    HIDDENVOLUME,
    CONF_RUBVALUE,
    CONF_PRICE,
    BUYSELL,
    CONF_PERIOD,
    STATUS,
    TRADEDATE,
    TRADETIME,
    TRADEMICROSECONDS,
    TRADENO,
    TRADE_QUANTITY,
    TRADE_PRICE,
    TRADE_RUBVALUE,
    TRADE_PERIOD,
    IS_DAYSESSION,
    UPDATEDT
)
BEQUEATH DEFINER
AS
    SELECT /*+ NOPARALLEL (t) */ o.entrydate
               AS conf_date,
           o.entrytime
               AS conf_time,
           o.entrymicroseconds
               AS conf_microseconds,
           o.amenddate
               AS cancel_date,
           o.amendtime
               AS cancel_time,
           o.amendmicroseconds
               AS cancel_microseconds,
           CASE
               WHEN NVL (t.tradetime, o.entrytime) >= 190000 THEN ss.D_N
               ELSE o.entrydate
           END
               AS SESSIONID,
           uni.clientid,
           o.ISMARKETMAKER,
           o.securityid,
           o.boardid,
           o.orderno,
           o.quantity
               AS conf_volume,
           o.balance
               AS cancel_volume,
           o.qtyhidden
               AS hiddenvolume,
           o.VAL
               AS conf_RUBVALUE,
           o.price
               AS conf_price,
           o.buysell,
           o.period
               AS conf_period,
           o.status,
           t.tradedate,
           t.tradetime,
           t.trademicroseconds,
           t.tradeno,
           t.quantity
               AS trade_quantity,
           t.price
               AS trade_price,
           t.val
               trade_RUBVALUE,
           t.period
               trade_period,
           CASE
               WHEN NVL (t.tradetime, o.entrytime) >= 190000 THEN 0
               ELSE 1
           END
               AS IS_DAYSESSION,
           SYSDATE
               AS updatedt
      FROM CURR.orders_base                      o,
           CURR.trades_base                      t,
           (SELECT D_N, TRUNC (EVE_D_N) AS EVE_D_N
              FROM internalrep.V_FOAR_FUT_SESSION) ss,
           (SELECT clientid, clientcode
              FROM MDP.UNIF_CL_MT
             WHERE market IN ('cu', 'dlr')) UNI,
           internaldm.v_MICEX_SESSIONS_CALENDAR  sc
     WHERE     1 = 1
           AND o.entrydate = sc.tradedate
           AND t.tradedate(+) = sc.tradedate
           AND t.orderno(+) = o.orderno
           AND ss.EVE_D_N(+) = o.entrydate
           AND (CASE
                    WHEN O.CLIENTCODEID IS NULL THEN SUBSTR (O.FIRMID, 3, 12)
                    ELSE TO_CHAR (O.CLIENTCODEID)
                END) =
               UNI.CLIENTCODE
           AND SC.ISCU = 1                               --Rusakov 20170905;;
;

--PROCEDURE MDATA_MDDEV_HADOOP.FO_LAST_PRICE_PCD

select
            distinct 
            i.ticker
            , to_char(trunc(sysdate-2), 'YYYYMMDD') sessionid
            , first_value(price) over (partition by i.ticker, sess_id order by tradeid desc) last_price
        from internalmdp.v_fo_tradelog tl
        join (
            select 
                securityid
                , substr(shortname, 1, 2) ticker 
            from INTERNALMDP.V_INSTRUMENTS
            where substr(shortname, 1, 2) in ('Si', 'RI', 'BR', 'SR')
                and market = 'FORTS-FU' 
                and security_type != 'Календарные спреды' 
                and shortname not like '%vm'
        ) i on i.securityid = tl.isin
        where nosystem in (0, 2)
            and id_repo = 0
            and sess_id in (select sess_id from internalmdp.v_fo_sess_list where trunc(d_n) = trunc(sysdate-2));
            
--sql_id = '3my89acu4kf0z'

select * from INTERNALREP.V_FOAR_FUT_DEAL1 where 1=1; 
set timing on
select count(1) from internalmdp.v_fo_tradelog where sess_id in (select sess_id from internalmdp.v_fo_sess_list where trunc(d_n) = trunc(sysdate - 1));
select count(1) from internalmdp.v_fo_tradelog where sess_id in (select sess_id from internalmdp.v_fo_sess_list where trunc(d_n) = trunc(sysdate - 1));

WITH
        CLIENTS
        AS
            (SELECT cl.ID, cl.CLIENT_CODE
               FROM internaldm.v_forts_investr cl)
    SELECT TR.DAT_TIME,
           TR.MSEC,
           TR.SESS_ID,
           TR.ISIN,
           C1.ID      AS CLIENTID_BUY,
           C2.ID      AS CLIENTID_SELL,
           TR.CENA    AS PRICE,
           TR.KOL     AS VOLUME,
           TR.ID_DEAL AS TRADEID,
           N_ORDER_PK AS NUMB_ORDER_BUY,
           N_ORDER_PR AS NUMB_ORDER_SELL,
           NOSYSTEM,
           ID_REPO
      FROM INTERNALREP.V_FOAR_FUT_DEAL1  TR
           LEFT JOIN internaldm.v_forts_session ss
               ON (TR.sess_id = ss.sess_id)
           LEFT JOIN CLIENTS C1 ON (C1.CLIENT_CODE = TR.KOD_PK)
           LEFT JOIN CLIENTS C2 ON (C2.CLIENT_CODE = TR.KOD_PR)
     WHERE TR.SESS_ID >= 4436;
     
-- оптимизированная версия (optimized) INTERNALMDP.V_FO_TRADELOG

SELECT *
  FROM (WITH
            CLIENTS1
            AS
                (SELECT CL.ID, CL.CLIENT_CODE
                   FROM INTERNALDM.V_FORTS_INVESTR CL),
            CLIENTS2
            AS
                (SELECT CL.ID, CL.CLIENT_CODE
                   FROM INTERNALDM.V_FORTS_INVESTR CL)
        SELECT TR.DAT_TIME,
               TR.MSEC,
               TR.SESS_ID,
               TR.ISIN,
               C1.ID      AS CLIENTID_BUY,
               C2.ID      AS CLIENTID_SELL,
               TR.CENA    AS PRICE,
               TR.KOL     AS VOLUME,
               TR.ID_DEAL AS TRADEID,
               N_ORDER_PK AS NUMB_ORDER_BUY,
               N_ORDER_PR AS NUMB_ORDER_SELL,
               NOSYSTEM,
               ID_REPO
          FROM INTERNALREP.V_FOAR_FUT_DEAL1  TR
               LEFT JOIN INTERNALDM.V_FORTS_SESSION SS
                   ON (TR.SESS_ID = SS.SESS_ID)
               LEFT JOIN CLIENTS1 C1 ON (C1.CLIENT_CODE = TR.KOD_PK)
               LEFT JOIN CLIENTS2 C2 ON (C2.CLIENT_CODE = TR.KOD_PR)
         WHERE TR.SESS_ID >= 4436)
 WHERE SESS_ID IN (SELECT SESS_ID
                     FROM INTERNALMDP.V_FO_SESS_LIST
                    WHERE TRUNC (D_N) = TRUNC (SYSDATE - 1));

--Зависимости для расчета 2 и 3 нормативов

WITH
    R
    AS
        (SELECT TRIM ('        INTERNALDM.V_CURR_ASSETS                 ') A
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_CURR_CURRENCY                        ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_CURR_DIARYTRD                          ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_CURR_RMS_PRICERANGE                         ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_CURR_RMS_RATE                         ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_CURR_RM_ASSETS                       ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_CURR_RM_MARKET_PRICERANGE                        ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_CURR_RM_PERCENT_PRICERANGE                       ')
           FROM DUAL
         UNION
         SELECT TRIM ('        INTERNALDM.V_CURR_SECS                     ')
           FROM DUAL
         UNION
         SELECT TRIM ('        INTERNALDM.V_EQ_ASSETS                      ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_EQ_CCP_BONDCALC                    ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_EQ_CCP_INDICATIVE                   ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_EQ_CCP_PRICERANGE                 ')
           FROM DUAL
         UNION
         SELECT TRIM ('        INTERNALDM.V_EQ_CCP_SECS                 ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_EQ_CCP_SETTLEMENTPRICE                    ')
           FROM DUAL
         UNION
         SELECT TRIM ('        INTERNALDM.V_EQ_DIARYTRD                ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_EQ_RM_ASSETS                            ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_EQ_RM_BONDCALC                     ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_EQ_RM_MARKET_INDICES                       ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_EQ_RM_MARKET_PRICERANGE                             ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_EQ_RM_PERCENT_PRICERANGE                            ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_EQ_SECS                          ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALREP.V_FORTS_CLR_FUT_SESS_SETTL                  ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALREP.V_FORTS_FUT_INSTRUMENTS                     ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALREP.V_FORTS_FUT_SESS_CONTENTS                ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALREP.V_FORTS_FUT_VCB                          ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALREP.V_FORTS_OPT_SESS_CONTENTS                 ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALREP.V_FORTS_SESSION                           ')
           FROM DUAL
         UNION
         SELECT TRIM ('        INTERNALDM.V_CURR_ASSETS                 ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_CURR_RM_PERCENT_INDICES                 ')
           FROM DUAL
         UNION
         SELECT TRIM ('        INTERNALDM.V_EQ_ASSETS                      ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_EQ_ASSETTYPES                            ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_EQ_RM_BONDCALC                     ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_EQ_RM_PERCENT_INDICES                      ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_EQ_SECS                          ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALREP.V_FORTS_CLR_FUT_SESS_SETTL                  ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALREP.V_FORTS_FUT_INSTRUMENTS                     ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALREP.V_FORTS_OPT_SESS_CONTENTS                 ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALREP.V_FORTS_SESSION                           ')
           FROM DUAL
         UNION
         SELECT TRIM ('        INTERNALREP.V_FORTS_VALAT                ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALDM.V_CURR_DIARYTRD                          ')
           FROM DUAL
         UNION
         SELECT TRIM ('        INTERNALDM.V_EQ_DIARYTRD                ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALREP.V_FORTS_FUT_BOND_ISIN                           ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALREP.V_FORTS_FUT_BOND_REGISTRY                 ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALREP.V_FORTS_FUT_INSTRUMENTS                     ')
           FROM DUAL
         UNION
         SELECT TRIM (
                    '        INTERNALREP.V_FORTS_SESSION                           ')
           FROM DUAL),
    T
    AS
        (SELECT OWNER IOWNER, OBJECT_NAME IOBJ
           FROM DBA_OBJECTS
          WHERE OBJECT_NAME = 'DATA_SET_API' AND OWNER = 'ST_DATA_SET')
  SELECT O,
             N
         
    FROM (SELECT REPLACE (SUBSTR (B, 1, INSTR (B, '.') - 1), CHR (9))
                     O,
                 REPLACE (
                     REPLACE (REPLACE (REPLACE (B, 'EQ.'), 'CURR.'), 'FORTS.'),
                     CHR (9))
                     N
            FROM (SELECT REPLACE (
                             REPLACE (
                                 REPLACE (
                                     REPLACE (REPLACE (A, 'INTERNALDM.V_'),
                                              'INTERNALREP.V_'),
                                     'EQ_',
                                     'EQ.'),
                                 'CURR_',
                                 'CURR.'),
                             'FORTS_',
                             'FORTS.')
                             B
                    FROM R)
          UNION
          SELECT REFERENCED_OWNER                                    O,
                 REFERENCED_NAME N
            FROM (    SELECT DISTINCT REFERENCED_NAME, REFERENCED_OWNER
                        FROM DBA_DEPENDENCIES D, T
                  START WITH D.OWNER = T.IOWNER AND D.NAME = T.IOBJ
                  CONNECT BY     PRIOR REFERENCED_OWNER = D.OWNER
                             AND PRIOR REFERENCED_NAME = D.NAME
                             AND PRIOR REFERENCED_TYPE = D.TYPE)
           WHERE REFERENCED_OWNER NOT IN ('INTERNALREP',
                                          'SYS',
                                          'INTERNALDM',
                                          'ST_DATA_SET',
                                          'G_RISK_MONITORING',
                                        --  'MOSCOW_EXCHANGE',
                                       --   'MDMWORK',
                                          'PUBLIC'))
-- where o like '%EQ%'
ORDER BY 1, 2;

-- DDL via DB_LINK
--Пример вызова функции READ_REMOTE_DDL для DDL удаленного объекта (тут ZCYC_BASE_BASE имя таблицы, CBMIRROR имя схемы, ARDBLINK имя линка)

SELECT TABLE_NAME,
       READ_REMOTE_DDL ('TABLE',
                        'ZCYC_BASE_BASE',
                        'CBMIRROR',
                        'ARDBLINK')
  FROM ALL_TABLES@ARDBLINK
WHERE TABLE_NAME = 'ZCYC_BASE_BASE';

-- http://jira.moex.com/browse/ORACLE-25

HP_FA_ACCOUNTS_LM

POST_LOAD_CFT

SELECT *
  FROM LOADER_MARKETS.REQ_LOG
 WHERE TYPE LIKE '%HP_FA_ACCOUNTS_LM%' order by 1 desc;

INSERT INTO CFTUSER.HP_FA_ACCOUNTS_LM (UPDATEDT,
                                       CODE,
                                       ACTUAL_DATE,
                                       BRANCH_ID,
                                       DEP_MAN_ID,
                                       ACCOUNT_MAN_ID,
                                       CURRENCY_ID,
                                       BALSTATUS_ID,
                                       ACCOUNT_NO,
                                       ACCOUNT_NAME,
                                       NOTE,
                                       OPEN_DATE,
                                       CLOSE_DATE,
                                       OLTP_CREATE_DATE,
                                       OLTP_CHANGE_DATE,
                                       OLTP_USER_ID,
                                       OLTP_SUBJECT_ID,
                                       BALACCOUNT_ID,
                                       ACCOUNT_CLOSED,
                                       ACC_CIPHER,
                                       ACCOUNT_OLTP_CODE,
                                       FLAG_ID,
                                       MARKETTYPE_ID,
                                       REQ_ID)
    SELECT SYSDATE UPDATEDT,
           CODE,
           ACTUAL_DATE,
           BRANCH_ID,
           DEP_MAN_ID,
           ACCOUNT_MAN_ID,
           CURRENCY_ID,
           BALSTATUS_ID,
           ACCOUNT_NO,
           ACCOUNT_NAME,
           NOTE,
           OPEN_DATE,
           CLOSE_DATE,
           OLTP_CREATE_DATE,
           OLTP_CHANGE_DATE,
           OLTP_USER_ID,
           OLTP_SUBJECT_ID,
           BALACCOUNT_ID,
           ACCOUNT_CLOSED,
           ACC_CIPHER,
           ACCOUNT_OLTP_CODE,
           FLAG_ID,
           MARKETTYPE_ID,
           78390
      FROM ARDB_USER.V_HP_FA_ACCOUNTS T1
     WHERE T1.FLAG_ID = 58749;
     
     select * FROM ARDB_USER.V_HP_FA_ACCOUNTS where FLAG_ID = 63178;

select min(FLAG_ID) FROM ARDB_USER.V_HP_FA_ACCOUNTS;
select max(FLAG_ID) FROM ARDB_USER.V_HP_FA_ACCOUNTS;

select distinct ACTUAL_DATE,FLAG_ID FROM ARDB_USER.V_HP_FA_ACCOUNTS order by 1,2;
/*
14.07.2017	63178
04.08.2017	63606
05.08.2017	63631
05.09.2017	64256
05.09.2017	64264
17.09.2017	64501
24.09.2017	64655
29.09.2017	64757
29.09.2017	64763


64695
64135
63751
*/

select * FROM ARDB_USER.V_HP_FA_ACCOUNTS where FLAG_ID between 58749-100 and 58749+100;

-- прерывается импорт валютного рынка в промежуток 20-00 - 21-30 !!!

SELECT count(1) FROM SPUR_DAY_CU.TRADES WHERE TRADEDATE BETWEEN TRUNC(SYSDATE-3) and TRUNC(SYSDATE-1); --542282

SELECT count(1) FROM CURR.TRADES_BASE WHERE TRADEDATE BETWEEN TRUNC(SYSDATE-3) and TRUNC(SYSDATE-1); --542282

SELECT MAX(TRADETIME),TRADEDATE FROM SPUR_DAY_CU.TRADES WHERE TRADEDATE BETWEEN TRUNC(SYSDATE-3) and TRUNC(SYSDATE-1) group by TRADEDATE order by 2;

-- SR 3-14971082761 

-- Вы запускаете вот это:

exec dbms_stats.set_param('trace', 4+8+16+64+128+1024+2048+32768);

exec dbms_stats.gather_table_stats('FORTS_AR','FUT_ORDLOG', ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE, GRANULARITY=>'GLOBAL AND PARTITION');

--трейс /u01/app/oracle/diag/rdbms/spur/spur1/trace/spur1_ora_307174.trc
--новый /u01/app/oracle/diag/rdbms/spur/spur1/trace/spur1_ora_276890.trc

exec dbms_stats.set_param('trace', null);

--Ждете, пока отработает до конца. Создаете другой сеанс. И еще раз запускаете то же самое:

exec dbms_stats.set_param('trace', 4+8+16+64+128+1024+2048+32768);

exec dbms_stats.gather_table_stats('FORTS_AR','FUT_ORDLOG', ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE, GRANULARITY=>'GLOBAL AND PARTITION');

exec dbms_stats.set_param('trace', null);

--трейс /u01/app/oracle/diag/rdbms/spur/spur1/trace/spur1_ora_46257.trc
-- повторный /u01/app/oracle/diag/rdbms/spur/spur1/trace/spur1_ora_333254.trc

--собираем 2 раза
--второй трейс spurstb_ora_264642.trc
-- трейс по OPT_ORDLOG spurstb_ora_214962.trc.gz
-- трейс по EQ_TRADES_BASE spurstb_ora_319696.trc.gz в нем предупреждения вида
--WARNING: kcbz_log_block_read - failed to record BRR for 763/68723 (0xbec10c73) SCN 0x946.b76e598a SEQ 1

-- move data of UNIFIED AUDIT TRAIL

--работы с 29.05.2018

set timing on echo on

select count(1) from audsys."CLI_SWP$915e9058$1$1";

exec DBMS_AUDIT_MGMT.transfer_unified_audit_records; 

select count(1) from audsys."CLI_SWP$915e9058$1$1"; --2771696 at 15:40 29.05.2018, 2747073 at 09:54 30.05.2018

select min(EVENT_TIMESTAMP),max(EVENT_TIMESTAMP) from AUDSYS.AUD$UNIFIED; --29.11.2017 22:00:01,580699	30.11.2017 0:15:50,194870, 30.11.2017 22:00:03,339138 12.12.2017 15:08:07,522719 at 10:22 30.05.2018
select count(1) from AUDSYS.AUD$UNIFIED; --92423 at 15:39 29.05.2018 --всего должно быть 4ГБ для 2,8 млн строк, 1025038 at 09:54 30.05.2018

select round(sum(BYTES)/1024/1024/1024,1) GB,TABLESPACE_NAME from dba_segments where SEGMENT_NAME = 'AUD$UNIFIED' and OWNER = 'AUDSYS' group by TABLESPACE_NAME; --3211264 at 14:55 29.05.2018, 7405568 at 14:59 29.05.2018, 1,7GB at 09:54 30.05.2018
select sum(BYTES) from dba_segments where SEGMENT_NAME = 'CLI_SWP$915e9058$1$1'; --2834300928 at 15:36 29.05.2018
select sum(BYTES) from dba_segments where SEGMENT_NAME = 'SYS_LOB0000020477C00014$$'; --81315168256 at 15:38 29.05.2018
select * from dba_lobs where TABLE_NAME = 'CLI_SWP$915e9058$1$1';  

--2773464 at 14:47 29.05.2018

set timing on echo on
begin 
while 1=1 loop 
DBMS_AUDIT_MGMT.TRANSFER_UNIFIED_AUDIT_RECORDS; 
end loop; 
end; 
/

/*
Вывод:

операцию на нашей БД можно не продолжать, т.к. операция переноса в нашем случае из 1 записи в старой нереляционной таблице создает 38 записей в новой, 
что при имеющемся у нас объеме записей аудита (политика хранения - 6 месяцев) и сохраняющейся динамике приведет к тому, что полный перенос создаст 
таблицу с ~ 110 - 120 млн строк и 200+ ГБ размером (текущий размер нереляционной таблицы + лобов по ней - примерно 100ГБ, 
реляционная должна быть однозначно меньше при корректном переносе данных в нее).
 
*/
-- конец работ с 29.05.2018
--

set timing on feedback on termout on 

exec dbms_audit_mgmt.flush_unified_audit_trail;

exec dbms_audit_mgmt.transfer_unified_audit_records;

select count(*) from audsys.aud$unified; 

set timing on feedback on termout on 

begin

    DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL;

    for i in 1..2422777 loop

           DBMS_AUDIT_MGMT.TRANSFER_UNIFIED_AUDIT_RECORDS;

    end loop;

end;

/
commit;

-- code from Doc ID 2212196.1

begin

    DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL;

    while 1=1 loop

           DBMS_AUDIT_MGMT.TRANSFER_UNIFIED_AUDIT_RECORDS;

    end loop;

end;

/

-- records from old audit table (not moved yet)
select count(*) from audsys."CLI_SWP$915e9058$1$1" where flush_time > (select to_date('19/09/2017 16:40:08', 'dd/mm/yyyy hh24:mi:ss') from dual); --158650 for 13.10.2017
select count(*) from audsys.aud$unified; --43606879 -records in old unified audit trail table, 45519546 -recors in new unified audit trail table for 13.10.2017
select count(1) from unified_audit_trail;--44378557 (20.09.2017)
select * from dba_segments where SEGMENT_NAME = 'AUD$UNIFIED'; --149 801 664 512
select min(EVENT_TIMESTAMP),max(EVENT_TIMESTAMP) from AUDSYS.AUD$UNIFIED partition(SYS_P234501); --05.03.2017 10:18:21,928084	23.03.2017 13:33:51,925645 --05.03.2017 10:18:21,928084	23.03.2017 13:33:51,925645
  SELECT TRUNC (EVENT_TIMESTAMP), COUNT (1)
    FROM AUDSYS.AUD$UNIFIED PARTITION (SYS_P234501)
GROUP BY TRUNC (EVENT_TIMESTAMP)
ORDER BY COUNT (1) DESC;
select sum(BYTES)/sum(MAXBYTES) from dba_data_files where TABLESPACE_NAME = 'SYSAUX'; --417645707264
select * from dba_data_files where TABLESPACE_NAME = 'SYSAUX'; --417645707264

-- LDWH.TMP_POS_CLIENT_ISSUE indexes

select distinct "_SYST_ID",TRADE_DATE  from LDWH.TMP_POS_CLIENT_ISSUE order by "_SYST_ID";

--delete /*+ FULL (a) */ from LDWH.TMP_POS_CLIENT_ISSUE a where a."_SYST_ID" between :l_min_SYST_ID and :l_max_SYST_ID;

--delete from LDWH.TMP_POS_CLIENT_ISSUE a where a."_SYST_ID" between :l_min_SYST_ID and :l_max_SYST_ID;

select * from LDWH.errlog where proc like '%POS_CLIENT_ISSUE_RF_TMP_TABLE%' order by 1;

select distinct TRADE_DATE  from LDWH.TMP_POS_CLIENT_ISSUE order by TRADE_DATE;

--http://jira.moex.com/browse/ORACLE-26

-- выбор плана из истории выполнения (хеш плана не изменился)
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'ag2svmafw678f',plan_hash_value=>149127924,format=>'ALL')); --sysdate-2
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'cd3qr7vu8arw4',plan_hash_value=>149127924,format=>'ALL')); --sysdate-1
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'75g7xvt6bk87x',plan_hash_value=>149127924,format=>'ALL')); --today

MERGE INTO FINANCE_SRC.F_ATOM_ITEMS_FO_TRD_BASE A
     USING (SELECT  /*+ RESULT_CACHE */
                   *
              FROM (SELECT 'A' AS ST_ACTUAL,
                           ADJUSTED_COMM,
                           AMOUNT,
                           AMOUNT_PRICE,
                           ATOM_ID,
                           BUYSELL,
                           CLIENTCODEID,
                           CLIENT_LOGIN,
                           CODE_RTS,
                           COEFF,
                           CP_CLIENTCODEID,
                           FIRMID,
                           ID_DEAL_MULTILEG,
                           INTER_BROKER,
                           ISIN_ID,
                           IS_HEDGE,
                           IS_TRUST,
                           MAKER_TAKER,
                           MIN_TRADENO,
                           MOMENT,
                           NOSYSTEM,
                           RZ_COMM,
                           SEGMENT_CODE,
                           SESS_ID,
                           STRIKE,
                           TRADEDATE,
                           TRADE_COMM,
                           TRADE_COUNT,
                           TRADE_STATUS,
                           VAL
                      FROM FINANCE_SRC.F_ATOM_ITEMS_FO_TRD_LM
                     WHERE NOT (1 = 0)
                    MINUS
                    SELECT ST_ACTUAL,
                           ADJUSTED_COMM,
                           AMOUNT,
                           AMOUNT_PRICE,
                           ATOM_ID,
                           BUYSELL,
                           CLIENTCODEID,
                           CLIENT_LOGIN,
                           CODE_RTS,
                           COEFF,
                           CP_CLIENTCODEID,
                           FIRMID,
                           ID_DEAL_MULTILEG,
                           INTER_BROKER,
                           ISIN_ID,
                           IS_HEDGE,
                           IS_TRUST,
                           MAKER_TAKER,
                           MIN_TRADENO,
                           MOMENT,
                           NOSYSTEM,
                           RZ_COMM,
                           SEGMENT_CODE,
                           SESS_ID,
                           STRIKE,
                           TRADEDATE,
                           TRADE_COMM,
                           TRADE_COUNT,
                           TRADE_STATUS,
                           VAL
                      FROM FINANCE_SRC.F_ATOM_ITEMS_FO_TRD_BASE
                     WHERE TRADEDATE BETWEEN (SELECT MIN (BMIN.TRADEDATE)
                                                FROM FINANCE_SRC.F_ATOM_ITEMS_FO_TRD_LM
                                                     BMIN)
                                         AND (SELECT MAX (BMAX.TRADEDATE)
                                                FROM FINANCE_SRC.F_ATOM_ITEMS_FO_TRD_LM
                                                     BMAX))) B
        ON (   '|'
            || TO_CHAR (A.TRADEDATE, 'DDMMYYYY')
            || '|'
            || TO_CHAR (A.MOMENT, 'DDMMYYYY')
            || '|'
            || A.BUYSELL
            || '|'
            || TO_CHAR (A.TRADE_STATUS)
            || '|'
            || A.SEGMENT_CODE
            || '|'
            || TO_CHAR (A.SESS_ID)
            || '|'
            || TO_CHAR (A.ISIN_ID)
            || '|'
            || A.FIRMID
            || '|'
            || A.CLIENTCODEID
            || '|'
            || A.CP_CLIENTCODEID
            || '|'
            || TO_CHAR (A.NOSYSTEM)
            || '|'
            || TO_CHAR (A.IS_HEDGE)
            || '|'
            || TO_CHAR (A.IS_TRUST)
            || '|'
            || TO_CHAR (A.INTER_BROKER)
            || '|'
            || A.MAKER_TAKER
            || '|'
            || A.CLIENT_LOGIN
            || '|'
            || A.CODE_RTS
            || '|'
            || TO_CHAR (A.ID_DEAL_MULTILEG)
            || '|'
            || TO_CHAR (A.STRIKE)
            || '|'
            || TO_CHAR (A.COEFF)
            || '|' =
               '|'
            || TO_CHAR (B.TRADEDATE, 'DDMMYYYY')
            || '|'
            || TO_CHAR (B.MOMENT, 'DDMMYYYY')
            || '|'
            || B.BUYSELL
            || '|'
            || TO_CHAR (B.TRADE_STATUS)
            || '|'
            || B.SEGMENT_CODE
            || '|'
            || TO_CHAR (B.SESS_ID)
            || '|'
            || TO_CHAR (B.ISIN_ID)
            || '|'
            || B.FIRMID
            || '|'
            || B.CLIENTCODEID
            || '|'
            || B.CP_CLIENTCODEID
            || '|'
            || TO_CHAR (B.NOSYSTEM)
            || '|'
            || TO_CHAR (B.IS_HEDGE)
            || '|'
            || TO_CHAR (B.IS_TRUST)
            || '|'
            || TO_CHAR (B.INTER_BROKER)
            || '|'
            || B.MAKER_TAKER
            || '|'
            || B.CLIENT_LOGIN
            || '|'
            || B.CODE_RTS
            || '|'
            || TO_CHAR (B.ID_DEAL_MULTILEG)
            || '|'
            || TO_CHAR (B.STRIKE)
            || '|'
            || TO_CHAR (B.COEFF)
            || '|')
WHEN MATCHED
THEN
    UPDATE SET
        A.ST_ACTUAL = B.ST_ACTUAL,
        A.UPDATEDT = TO_DATE ('14.09.2017 09:05:53', 'DD.MM.YYYY HH24:MI:SS'),
        A.REQ_ID = 31426,
        A.ADJUSTED_COMM = B.ADJUSTED_COMM,
        A.AMOUNT = B.AMOUNT,
        A.AMOUNT_PRICE = B.AMOUNT_PRICE,
        A.ATOM_ID = B.ATOM_ID,
        A.MIN_TRADENO = B.MIN_TRADENO,
        A.RZ_COMM = B.RZ_COMM,
        A.TRADE_COMM = B.TRADE_COMM,
        A.TRADE_COUNT = B.TRADE_COUNT,
        A.VAL = B.VAL
WHEN NOT MATCHED
THEN
    INSERT     (A.L_ID,
                A.ST_ACTUAL,
                A.UPDATEDT,
                A.REQ_ID,
                A.ADJUSTED_COMM,
                A.AMOUNT,
                A.AMOUNT_PRICE,
                A.ATOM_ID,
                A.BUYSELL,
                A.CLIENTCODEID,
                A.CLIENT_LOGIN,
                A.CODE_RTS,
                A.COEFF,
                A.CP_CLIENTCODEID,
                A.FIRMID,
                A.ID_DEAL_MULTILEG,
                A.INTER_BROKER,
                A.ISIN_ID,
                A.IS_HEDGE,
                A.IS_TRUST,
                A.MAKER_TAKER,
                A.MIN_TRADENO,
                A.MOMENT,
                A.NOSYSTEM,
                A.RZ_COMM,
                A.SEGMENT_CODE,
                A.SESS_ID,
                A.STRIKE,
                A.TRADEDATE,
                A.TRADE_COMM,
                A.TRADE_COUNT,
                A.TRADE_STATUS,
                A.VAL)
        VALUES (FINANCE_SRC.F_ATOM_ITEMS_FO_TR_BASE_SEQ_ID.NEXTVAL,
                'A',
                TO_DATE ('14.09.2017 09:05:53', 'DD.MM.YYYY HH24:MI:SS'),
                31426,
                B.ADJUSTED_COMM,
                B.AMOUNT,
                B.AMOUNT_PRICE,
                B.ATOM_ID,
                B.BUYSELL,
                B.CLIENTCODEID,
                B.CLIENT_LOGIN,
                B.CODE_RTS,
                B.COEFF,
                B.CP_CLIENTCODEID,
                B.FIRMID,
                B.ID_DEAL_MULTILEG,
                B.INTER_BROKER,
                B.ISIN_ID,
                B.IS_HEDGE,
                B.IS_TRUST,
                B.MAKER_TAKER,
                B.MIN_TRADENO,
                B.MOMENT,
                B.NOSYSTEM,
                B.RZ_COMM,
                B.SEGMENT_CODE,
                B.SESS_ID,
                B.STRIKE,
                B.TRADEDATE,
                B.TRADE_COMM,
                B.TRADE_COUNT,
                B.TRADE_STATUS,
                B.VAL);


-- QUERY in 11g and 12c different result

--вариант решения для запроса к ORDERS_MRKT и ZZ_TEST_HIERARCHY
alter session set optimizer_features_enable = '12.1.0.1';

--вариант решения для запроса к ZZ_TEST_HIERARCHY
alter session set "_optimizer_reduce_groupby_key" = false;

select * from v$sql where SQL_TEXT like '%g_analytic.ZZ_TEST_HIERARCHY%';

select * from v$sql where SQL_TEXT like '%ORDERS_MRKT%';

select to_char(tt.d_date, 'YYYY-MM')
      ,tt.mrkt
      ,sum(tt.cnt_ord)
from   (select t.d_date
              ,t.mrkt
              ,sum(t.cnt_ord) cnt_ord
        from   G_ANALYTIC.ORDERS_MRKT t
        group  by t.d_date
                 ,t.mrkt                
                 ) tt
group  by to_char(tt.d_date, 'YYYY-MM')
         ,tt.mrkt;

select aaa.name
      ,aaa.root_name
      ,bb.leaf
from   (select *
        from   (select a.name
                      ,CONNECT_BY_root a.name as root_name
                      ,CONNECT_BY_isleaf as isleaf
                from   g_analytic.ZZ_TEST_HIERARCHY a
                CONNECT BY PRIOR a.id = a.pid) aa
        where  aa.isleaf = 1) aaa
       
      ,(select b.name
              ,CONNECT_BY_isleaf as leaf
        from   g_analytic.ZZ_TEST_HIERARCHY b
        CONNECT BY PRIOR b.id = b.pid
        start  with b.pid is null) bb
where  aaa.root_name = bb.name(+)
group  by aaa.name
         ,aaa.root_name
         ,bb.leaf;
         
select * from g_analytic.ZZ_TEST_HIERARCHY order by 1;

select *
        from   (select a.name
                      ,CONNECT_BY_root a.name as root_name
                      ,CONNECT_BY_isleaf as isleaf
                from   g_analytic.ZZ_TEST_HIERARCHY a
                CONNECT BY PRIOR a.id = a.pid) aa
        where  aa.isleaf = 1
minus
select *
        from   (select a.name
                      ,CONNECT_BY_root a.name as root_name
                      ,CONNECT_BY_isleaf as isleaf
                from   analitic.ZZ_TEST_HIERARCHY@spur30 a
                CONNECT BY PRIOR a.id = a.pid) aa
        where  aa.isleaf = 1;
        
select b.name
              ,CONNECT_BY_isleaf as leaf
        from   g_analytic.ZZ_TEST_HIERARCHY b
        CONNECT BY PRIOR b.id = b.pid
        start  with b.pid is null
minus
select b.name
              ,CONNECT_BY_isleaf as leaf
        from   analitic.ZZ_TEST_HIERARCHY@spur30 b
        CONNECT BY PRIOR b.id = b.pid
        start  with b.pid is null;
        
create table res12 as
select aaa.name
      ,aaa.root_name
      ,bb.leaf
from   (select *
        from   (select a.name
                      ,CONNECT_BY_root a.name as root_name
                      ,CONNECT_BY_isleaf as isleaf
                from   g_analytic.ZZ_TEST_HIERARCHY a
                CONNECT BY PRIOR a.id = a.pid) aa
            where  aa.isleaf = 1) aaa
      ,(select b.name
              ,CONNECT_BY_isleaf as leaf
        from   g_analytic.ZZ_TEST_HIERARCHY b
        CONNECT BY PRIOR b.id = b.pid
        start  with b.pid is null) bb
where  aaa.root_name = bb.name(+)
group  by aaa.name
         ,aaa.root_name
         ,bb.leaf;

--PROCEDURE MDP.INSERT_CU_ORD_TR_DAY_V

--INSERT_CU_ORD_TR_DAY_V
--V_GET_CU_ORD_TRD_DAY

--my stmt

SELECT /*+ LEADING (O) */  O.ENTRYDATE
           AS CONF_DATE,
       O.ENTRYTIME AS CONF_TIME,
       O.ENTRYMICROSECONDS
           AS CONF_MICROSECONDS,
       O.AMENDDATE
           AS CANCEL_DATE,
       O.AMENDTIME
           AS CANCEL_TIME,
       O.AMENDMICROSECONDS
           AS CANCEL_MICROSECONDS,
       CASE
           WHEN NVL (T.TRADETIME, O.ENTRYTIME) >= 190000  THEN SS.D_N
           ELSE O.ENTRYDATE
       END
           AS SESSIONID,
       UNI.CLIENTID,
       O.ISMARKETMAKER,
       O.SECURITYID,
       O.BOARDID,
       O.ORDERNO,
       O.QUANTITY
           AS CONF_VOLUME,
       O.BALANCE
           AS CANCEL_VOLUME,
       O.QTYHIDDEN
           AS HIDDENVOLUME,
       O.VAL
           AS CONF_RUBVALUE,
       O.PRICE
           AS CONF_PRICE,
       O.BUYSELL,
       O.PERIOD
           AS CONF_PERIOD,
       O.STATUS,
       T.TRADEDATE,
       T.TRADETIME,
       T.TRADEMICROSECONDS,
       T.TRADENO,
       T.QUANTITY
           AS TRADE_QUANTITY,
       T.PRICE
           AS TRADE_PRICE,
       T.VAL
           TRADE_RUBVALUE,
       T.PERIOD
           TRADE_PERIOD,
       CASE WHEN NVL (T.TRADETIME, O.ENTRYTIME) >= 190000 THEN 0 ELSE 1 END
           AS  IS_DAYSESSION,
       --     (case when o.clientcodeid is null then substr(o.firmid,3,12) else to_char(o.clientcodeid) end) as cid,
       SYSDATE
  FROM CURR.ORDERS_BASE O,-- PARTITION (CURR_ORDERS_BASE_P_20170905)  O,
       CURR.TRADES_BASE T,--PARTITION (CURR_TRADES_BASE_P_20170905)  T,
       (SELECT D_N, TRUNC (EVE_D_N) AS EVE_D_N
          FROM INTERNALREP.V_FOAR_FUT_SESSION)  SS,
       (SELECT CLIENTID, CLIENTCODE
          FROM MDP.UNIF_CL_MT
         WHERE MARKET IN ('cu', 'dlr'))  UNI
 WHERE     1 = 1
       AND T.TRADEDATE = trunc(sysdate-2)
       AND T.TRADEDATE = O.ENTRYDATE
       AND T.ORDERNO(+) =  O.ORDERNO
       AND SS.EVE_D_N(+) =  O.ENTRYDATE
       AND (CASE
                WHEN O.CLIENTCODEID IS NULL THEN SUBSTR (O.FIRMID, 3, 12)
                ELSE TO_CHAR (O.CLIENTCODEID)
            END) =
           UNI.CLIENTCODE;

--stmt from procedure

SELECT O.ENTRYDATE
           AS CONF_DATE,
       O.ENTRYTIME
           AS CONF_TIME,
       O.ENTRYMICROSECONDS
           AS CONF_MICROSECONDS,
       O.AMENDDATE
           AS CANCEL_DATE,
       O.AMENDTIME
           AS CANCEL_TIME,
       O.AMENDMICROSECONDS AS CANCEL_MICROSECONDS,
       CASE
           WHEN NVL (T.TRADETIME, O.ENTRYTIME) >= 190000 THEN SS.D_N
           ELSE O.ENTRYDATE
       END
           AS SESSIONID,
       UNI.CLIENTID,
       O.ISMARKETMAKER,
       O.SECURITYID,
       O.BOARDID,
       O.ORDERNO,
       O.QUANTITY
           AS CONF_VOLUME,
       O.BALANCE
           AS CANCEL_VOLUME,
       O.QTYHIDDEN
           AS HIDDENVOLUME,
       O.VAL
           AS CONF_RUBVALUE,
       O.PRICE
           AS CONF_PRICE,
       O.BUYSELL,
       O.PERIOD
           AS CONF_PERIOD,
       O.STATUS,
       T.TRADEDATE,
       T.TRADETIME,
       T.TRADEMICROSECONDS,
       T.TRADENO,
       T.QUANTITY          AS TRADE_QUANTITY,
       T.PRICE
           AS TRADE_PRICE,
       T.VAL
           TRADE_RUBVALUE,
       T.PERIOD
           TRADE_PERIOD,
       CASE WHEN NVL (T.TRADETIME, O.ENTRYTIME) >=  190000 THEN 0 ELSE 1 END
           AS IS_DAYSESSION,
       --     (case when o.clientcodeid is null then substr(o.firmid,3,12) else to_char(o.clientcodeid) end) as cid,
       SYSDATE
  FROM CURR.ORDERS_BASE PARTITION (CURR_ORDERS_BASE_P_20170905)  O,
       CURR.TRADES_BASE PARTITION (CURR_TRADES_BASE_P_20170905)  T,
       (SELECT D_N, TRUNC (EVE_D_N) AS EVE_D_N
          FROM INTERNALREP.V_FOAR_FUT_SESSION) SS,
       (SELECT CLIENTID, CLIENTCODE
          FROM MDP.UNIF_CL_MT
         WHERE MARKET IN ('cu', 'dlr'))  UNI
 WHERE     1 = 1
       AND T.ORDERNO(+) = O.ORDERNO
       AND SS.EVE_D_N(+) = O.ENTRYDATE
       AND (CASE
                WHEN O.CLIENTCODEID IS NULL THEN SUBSTR (O.FIRMID, 3, 12)
                ELSE TO_CHAR (O.CLIENTCODEID)
            END) =
           UNI.CLIENTCODE;

-- проблема Кручинина

sql id 5zpcy29sgx73k
Plan Hash Value 4181419376
INSERT INTO FINANCE_INT.INT_TRADES_COMM

-- use dbms_metadata.get_ddl in PL SQL

CREATE OR REPLACE FUNCTION ERROR_INVALID_VIEW (vOBJECT_NAME varchar2 default 'V_EQ_RM_BONDCALC_HCNG', vOWNER varchar2 default 'INTERNALDM') RETURN CLOB authid current_user IS
vOBJECT CLOB; 
begin
vOBJECT:=dbms_metadata.get_ddl('VIEW','V_EQ_RM_BONDCALC_HCNG','INTERNALDM');
end;

-- rebuild indexes online

SELECT 'ALTER INDEX '|| INDEX_OWNER||'.'||INDEX_NAME||' REBUILD COMPRESS ADVANCED LOW PCTFREE 5 ONLINE;' from dual;

-- перегрузка SE ордерлогов для Форексис (24.07.2017)

create table SE_ORDLOG_BASE_VTD406_test as select * from SE_ORDLOG_BASE_VTD406 where 1=0;
create table SE_TRADELOG_BASE_VTD406_test as select * from SE_TRADELOG_BASE_VTD406 where 1=0;

update SE_ORDLOG_BASE_VTD406_test set TRADEDATE = to_date('20170130','yyyymmdd');
commit;
update SE_TRADELOG_BASE_VTD406_test set TRADEDATE = to_date('20170130','yyyymmdd');

SELECT * FROM SE_TRADELOG_BASE_VTD406_TEST WHERE TRADENO = 2671317366
UNION ALL
SELECT * FROM SE_TRADELOG_BASE_VTD406 WHERE TRADENO = 2671317366;

select * from SE_ORDLOG_BASE_VTD406_test where REALORDERNO = 15913794327
union all
select * from SE_ORDLOG_BASE_VTD406 where REALORDERNO = 15913794327;

select * from SE_ORDLOG_BASE_VTD406_test where ORDERNO = 325167 --
union all
select * from SE_ORDLOG_BASE_VTD406 where TRADEDATE = to_date('20170130','yyyymmdd') and ORDERNO = 325167;

select * from SE_ORDLOG_BASE_VTD406_test where TIME like '102126112%';


-- Удаление BASE таблиц из схемы G_ANALYTIC

/* Formatted on 21.07.2017 11:14:01 (QP5 v5.300) */
  SELECT DISTINCT i.TABLE_OWNER,
                  i.TABLE_NAME,
                  i.INDEX_OWNER,
                  i.INDEX_NAME,
                  ROUND(S.BYTES/1024/1024) MB
    FROM DBA_IND_COLUMNS I, DBA_SEGMENTS S
   WHERE i.COLUMN_NAME = 'L_ID'
   AND I.INDEX_OWNER = S.OWNER
   AND I.INDEX_NAME = S.SEGMENT_NAME
   AND S.BYTES/1024/1024 > 50
ORDER BY i.TABLE_OWNER, i.TABLE_NAME, ROUND(S.BYTES/1024/1024) DESC;

SELECT * FROM DBA_SEGMENTS;

select max(TRADEDATE) from ANALYTIC_DATA.FORTS_DATA_MART_BASE;
select max(TRADEDATE) from G_ANALYTIC.FORTS_DATA_MART_BASE;

SELECT *
  FROM DBA_OBJECTS
 WHERE     OWNER LIKE '%ANALYTIC%'
       AND (   OBJECT_NAME LIKE '%_BASE'
            OR OBJECT_NAME LIKE '%_LM'
            OR OBJECT_NAME LIKE '%_HCNG')
       AND OBJECT_TYPE = 'TABLE' order by OBJECT_NAME,OWNER;
       
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

-- запрос для Сухова

ALTER SESSION SET NLS_DATE_FORMAT = 'dd.mm.yyyy';
select * from (
select /*+ NOPARALLEL (a c d) */ i.tradedate, a.boardid, a.firmid, a.securityid, f.description, g.typ AS acctype, n.shortname AS currency,
case when a.buysell = 'B' and a.typ = 'R' then 'Requirements'
when a.buysell = 'B' and a.typ = 'r' then 'Obligations' end as direction,
sum(case when a.buysell = 'B' and a.typ = 'R' then -coalesce(returnvalue, case when a.typ= 'r' then a.amount else c.amount end) end) as amountobligations,
sum(case when a.buysell = 'B' and a.typ = 'r' then coalesce(returnvalue, case when a.typ= 'r' then a.amount else c.amount end) end) as amountrequire
--
from 
internaldm.V_micex_sessions_calendar i cross join
eq.trades_base A
join eq.boards_base b on a.boardid = b.boardid
and b.typ = 'REPO'
join eq.trades_base C on a.tradedate = c.tradedate
and a.orderno = c.orderno 
and a.buysell <> c.buysell 
and a.buysell = 'B'
and a.typ in ('R', 'r')
join eq.trades_base D on a.tradedate = D.tradedate
and a.tradeno = D.tradeno 
and a.buysell <> d.buysell 
join eq.secs_base E on a.securityid = e.securityid
join eq.sectypes_base F on e.sectype = f.id
join eq.bankaccs_base G on a.bankaccid = g.id  
left join  eq.RepoTradeHist_base m
on a.tradedate = 
(select max(tradedate) from eq.RepoTradeHist_base a
where a.tradedate <= i.tradedate and a.tradeno = m.tradeno)
and m.tradeno = a.tradeno
join eq.currency_base n
on a.currencyid = n.currencyid
where (a.duedate <= i.tradedate and a.typ = 'R' and  
      c.duedate > i.tradedate and c.typ = 'r')
      or      
      (a.duedate > i.tradedate and a.typ = 'r' and  
      c.duedate <= i.tradedate and c.typ = 'R')
group by
CUBE (
i.tradedate, 
a.boardid, a.firmid, a.securityid, f.description, g.typ, n.shortname,
case when a.buysell = 'B' and a.typ = 'R' then 'Requirements'
when a.buysell = 'B' and a.typ = 'r' then 'Obligations' end 
)) where tradedate = '02.02.2017';

--  Переход ПО для ОД ВР на exadata

--запрос 2_.sql (на spur - 26 mins)

--результаты проверки:
--1) index invisible - 1:51h, 209029 rows
--2) CURR.TRADES_BASE instead of INTERNALDM.V_CURR_TRADES (remove union) - 50 mins, 209029 rows
--3) remove noparallel for table CURR.TRADES_BASE (parallel was 2) - 4:45h, 209029 rows, 209029 rows

select distinct /*+ NO_QUERY_TRANSFORMATION */ TRADEDATE,
                FIRMID,
                FIRMNAME,
                FIRMLATNAME,
                CLFIRMID,
                CLFIRMNAME,
                CLFIRMLATNAME,
                EXTSETTLECODE,
                TRDACCBID,
                TRDACCTYP,
                ADDSESSION,
                SESSIONNAME,
                SESSIONNAMEEN,
                CURRENCYID,
                CURRENCYNAME,
                COCURRENCYID,
                COCURRENCYNAME,
                SECURITYID,
                SECURITYSNAME,
                FACEVALUE,
                SETTLEDATE,
                TRADEGROUP,
                PSECURITYID,
                PSECURITYSNAME,
                TRADENO,
                BUYSELL,
                ORDERNO,
                TRADEDERIV,
                TRADETIMERES,
                TRADETYPE,
                DECIMALS,
                PRICE,
                QUANTITY,
                VAL,
                PERIOD,
                CPFIRMIDCUX,
                SETTLECODE,
                USERID,
                USEREXCHANGEID,
                TRDACCID,
                BROKERREF,
                EXTREF,
                EXHCOMM,
                ITSCOMM,
                CLRCOMM,
                COMMISSION,
                CLIENTCODE,
                DETAILS,
                SUBDETAILS,
                REPOTRADENO,
                BOARDID,
                BOARDNAME,
                BOARDLATNAME,
                SYS_DATE,
                SYS_TIME,
                SYS_TIMEMS
  from (select *
          from (select BASE_T.TRADEDATE,
                       TO_CHAR(TO_TIMESTAMP(SUBSTR(TO_CHAR(1000000 + BASE_T.TRADETIME), 2),
                                            'hh24miss'), 'hh24:mi:ss') as TRADETIMERES,
                       trim(TRAILING '0' from
                            TO_CHAR(TO_TIMESTAMP(SUBSTR(TO_CHAR(1000000 + BASE_T.TRADETIME),
                                                        2) ||
                                                 SUBSTR(TO_CHAR(1000000 +
                                                                BASE_T.TRADEMICROSECONDS), 2),
                                                 'hh24missff'), 'hh24:mi:ss.ff')) as TRADETIMEMSRES,
                       BASE_T.FIRMID,
                       FIRMS.INN as FIRMINN,
                       FIRMS.NAME as FIRMNAME,
                       FIRMS.LATNAME as FIRMLATNAME,
                       CLFIRMS.FIRMID as CLFIRMID,
                       CLFIRMS.INN as CLFIRMINN,
                       CLFIRMS.NAME as CLFIRMNAME,
                       CLFIRMS.LATNAME as CLFIRMLATNAME,
                       BANKACC.REALACCOUNT as EXTSETTLECODE,
                       SECS.SECURITYID,
                       SECS.SHORTNAME as SECURITYSNAME,
                       NVL(SECS.ISDERIVATIVE, INSTR.ISDERIVATIVE) as TRADEDERIV,
                       CURRENCY.CURRENCYID,
                       CURRENCY.NAME as CURRENCYNAME,
                       COCURRENCY.CURRENCYID as COCURRENCYID,
                       COCURRENCY.NAME as COCURRENCYNAME,
                       SECHIST.FACEVALUE,
                       SECHIST.DECIMALS,
                       BASE_T.SETTLEDATE,
                       BASE_T.TRADENO,
                       BASE_T.BUYSELL,
                       BASE_T.TRDACCID,
                       BASE_T.ORDERNO,
                       BASE_T.TYP as TRADETYPE,
                       BASE_T.PRICE,
                       BASE_T.QUANTITY,
                       BASE_T.VAL,
                       BASE_T.CPFIRMID,
                       case BASE_T.BOARDID
                         when 'CETS' then
                          ''
                         when 'FUTS' then
                          ''
                         else
                          'NCC0000100000'
                       end as CPFIRMIDCUX,
                       CPFIRMS.INN as CPFIRMINN,
                       CPFIRMS.NAME as CPFIRMNAME,
                       CPFIRMS.LATNAME as CPFIRMLATNAME,
                       BASE_T.PERIOD,
                       BASE_T.SETTLECODE,
                       BASE_T.USERID,
                       BASE_T.USEREXCHANGEID,
                       BASE_T.BROKERREF,
                       BASE_T.EXTREF,
                       BASE_T.EXHCOMM,
                       BASE_T.ITSCOMM,
                       BASE_T.CLRCOMM,
                       BASE_T.COMMISSION,
                       CLIENTCODES.CLIENTCODE,
                       CLIENTCODES.TYP as CLIENTCODESTYP,
                       CLIENTCODES.DETAILS,
                       CLIENTCODES.SUBDETAILS,
                       BASE_T.PARENTTRADENO as REPOTRADENO,
                       BOARDS.BOARDID,
                       BOARDS.NAME as BOARDNAME,
                       BOARDS.LATNAME as BOARDLATNAME,
                       BASE_T.AMOUNT,
                       TRDACC.TYP as TRDACCTYP,
                       TRDACC.BANKACCID as TRDACCBID,
                       CCLIENTCODES.CLIENTCODE as CLIENTCODEBENEF,
                       CCLIENTCODES.TYP as CLIENTCODESTYPBENEF,
                       CCLIENTCODES.DETAILS as DETAILSBENEF,
                       CCLIENTCODES.SUBDETAILS as SUBDETAILSBENEF,
                       PTRADES.SECURITYID as PSECURITYID,
                       PTRADES.SHORTNAME as PSECURITYSNAME,
                       BASE_T.ADDSESSION,
                       replace(replace(BASE_T.ADDSESSION, 'N', 'Основная сессия'), 'Y',
                               'Дополнительная сессия') as SESSIONNAME,
                       replace(replace(BASE_T.ADDSESSION, 'N', 'Main Trading session'), 'Y',
                               'Additional Trading session') as SESSIONNAMEEN,
                       case BASE_T.TYP
                         when 'S' then
                          'S'
                         when 'W' then
                          'S'
                         else
                          'T'
                       end as TRADEGROUP,
                       BASE_T.TRADEDATE as SYS_DATE,
                       BASE_T.TRADETIME as SYS_TIME,
                       BASE_T.TRADEMICROSECONDS as SYS_TIMEMS,
                       TO_TIMESTAMP(TO_CHAR(BASE_T.TRADEDATE, 'dd.mm.yyyy') ||
                                    SUBSTR(TO_CHAR(1000000 + BASE_T.TRADETIME), 2) ||
                                    SUBSTR(TO_CHAR(1000000 + BASE_T.TRADEMICROSECONDS), 2),
                                    'dd.mm.yyyyhh24missff') as FILTER_FULLTIME
                  from INTERNALDM.V_CURR_TRADES BASE_T,
                       INTERNALDM.V_CURR_CLIENTCODES CLIENTCODES,
                       INTERNALDM.V_CURR_FIRMS FIRMS,
                       INTERNALDM.V_CURR_TRDACC TRDACC,
                       INTERNALDM.V_CURR_FIRMS CPFIRMS,
                       INTERNALDM.V_CURR_BANKACC BANKACC,
                       INTERNALDM.V_CURR_BANKACCS BANKACCS,
                       INTERNALDM.V_CURR_FIRMS CLFIRMS,
                       INTERNALDM.V_CURR_BOARDS BOARDS,
                       INTERNALDM.V_CURR_SECS SECS,
                       INTERNALDM.V_CURR_CURRENCY CURRENCY,
                       INTERNALDM.V_CURR_CURRENCY COCURRENCY,
                       INTERNALDM.V_CURR_SECHIST SECHIST,
                       INTERNALDM.V_CURR_TRADES CTRADES,
                       INTERNALDM.V_CURR_CLIENTCODES CCLIENTCODES,
                       INTERNALDM.V_CURR_INSTR INSTR,
                       (select SECS.SECURITYID,
                               SECS.SHORTNAME,
                               BASE_T.TRADENO,
                               BASE_T.BUYSELL
                          from INTERNALDM.V_CURR_TRADES BASE_T, INTERNALDM.V_CURR_SECS SECS
                         where BASE_T.SECURITYID = SECS.SECURITYID and
                               TRADEDATE between TO_DATE('01.01.2012', 'dd.mm.yyyy') and
                               TO_DATE('31.12.2013', 'dd.mm.yyyy')) PTRADES
                 where BASE_T.FIRMID = FIRMS.FIRMID and
                       BASE_T.FIRMID = TRDACC.FIRMID and
                       BASE_T.TRDACCID = TRDACC.TRDACCID and
                       CPFIRMS.FIRMID = BASE_T.CPFIRMID and
                       (BANKACCS.FIRMID = BASE_T.FIRMID and BANKACCS.ID = TRDACC.BANKACCID) and
                       BANKACC.BANKACCID = BANKACCS.CLEARINGBANKACCID and
                       BASE_T.TRADENO = CTRADES.TRADENO and
                       BASE_T.BUYSELL != CTRADES.BUYSELL and
                       BASE_T.TRADEDATE = CTRADES.TRADEDATE and
                       BASE_T.CLEARINGFIRMID = CLFIRMS.FIRMID and
                       BASE_T.SECURITYID = SECS.SECURITYID and
                       BASE_T.BOARDID = BOARDS.BOARDID and
                       SECS.FACEUNIT = CURRENCY.CURRENCYID and
                       SECS.CURRENCYID = COCURRENCY.CURRENCYID and
                       SECHIST.BOARDID in ('CETS', 'FUTS', 'FUTN') and
                       SECHIST.TRADEDATE = BASE_T.TRADEDATE and
                       SECHIST.SECURITYID = BASE_T.SECURITYID and
                       BASE_T.CLIENTCODEID = CLIENTCODES.CLIENTCODEID(+) and
                       CTRADES.CLIENTCODEID = CCLIENTCODES.CLIENTCODEID(+) and
                       PTRADES.TRADENO(+) = BASE_T.PARENTTRADENO and
                       (PTRADES.BUYSELL != BASE_T.BUYSELL or PTRADES.BUYSELL is null) and
                       SECS.INSTRID = INSTR.INSTRID and
                       BASE_T.STATUS != 'C' and
                       BANKACCS.ST_ACTUAL = 'A' and
                       BANKACC.ST_ACTUAL = 'A' and
                       trim(BANKACC.CURRENCYID) is null and
                       BASE_T.TRADEDATE between TO_DATE('01.01.2012', 'dd.mm.yyyy') and
                       TO_DATE('31.12.2013', 'dd.mm.yyyy') and
                       BASE_T.FIRMID in ('MB0038600000') and
                       BASE_T.BOARDID in ('AETS', 'CETS', 'CNGD')) T
         where 1 = 1
         order by TRADENO) T;
         
--4) rewrittenn query - 1 min 20 s (replace INTERNALDM.V_CURR_TRADES with CURR.TRADES_BASE)

select distinct TRADEDATE,
                FIRMID,
                FIRMNAME,
                FIRMLATNAME,
                CLFIRMID,
                CLFIRMNAME,
                CLFIRMLATNAME,
                EXTSETTLECODE,
                TRDACCBID,
                TRDACCTYP,
                ADDSESSION,
                SESSIONNAME,
                SESSIONNAMEEN,
                CURRENCYID,
                CURRENCYNAME,
                COCURRENCYID,
                COCURRENCYNAME,
                SECURITYID,
                SECURITYSNAME,
                FACEVALUE,
                SETTLEDATE,
                TRADEGROUP,
                PSECURITYID,
                PSECURITYSNAME,
                TRADENO,
                BUYSELL,
                ORDERNO,
                TRADEDERIV,
                TRADETIMERES,
                TRADETYPE,
                DECIMALS,
                PRICE,
                QUANTITY,
                VAL,
                PERIOD,
                CPFIRMIDCUX,
                SETTLECODE,
                USERID,
                USEREXCHANGEID,
                TRDACCID,
                BROKERREF,
                EXTREF,
                EXHCOMM,
                ITSCOMM,
                CLRCOMM,
                COMMISSION,
                CLIENTCODE,
                DETAILS,
                SUBDETAILS,
                REPOTRADENO,
                BOARDID,
                BOARDNAME,
                BOARDLATNAME,
                SYS_DATE,
                SYS_TIME,
                SYS_TIMEMS
  from (select *
          from (select BASE_T.TRADEDATE,
                       TO_CHAR(TO_TIMESTAMP(SUBSTR(TO_CHAR(1000000 + BASE_T.TRADETIME), 2),
                                            'hh24miss'), 'hh24:mi:ss') as TRADETIMERES,
                       trim(TRAILING '0' from
                            TO_CHAR(TO_TIMESTAMP(SUBSTR(TO_CHAR(1000000 + BASE_T.TRADETIME),
                                                        2) ||
                                                 SUBSTR(TO_CHAR(1000000 +
                                                                BASE_T.TRADEMICROSECONDS), 2),
                                                 'hh24missff'), 'hh24:mi:ss.ff')) as TRADETIMEMSRES,
                       BASE_T.FIRMID,
                       FIRMS.INN as FIRMINN,
                       FIRMS.NAME as FIRMNAME,
                       FIRMS.LATNAME as FIRMLATNAME,
                       CLFIRMS.FIRMID as CLFIRMID,
                       CLFIRMS.INN as CLFIRMINN,
                       CLFIRMS.NAME as CLFIRMNAME,
                       CLFIRMS.LATNAME as CLFIRMLATNAME,
                       BANKACC.REALACCOUNT as EXTSETTLECODE,
                       SECS.SECURITYID,
                       SECS.SHORTNAME as SECURITYSNAME,
                       NVL(SECS.ISDERIVATIVE, INSTR.ISDERIVATIVE) as TRADEDERIV,
                       CURRENCY.CURRENCYID,
                       CURRENCY.NAME as CURRENCYNAME,
                       COCURRENCY.CURRENCYID as COCURRENCYID,
                       COCURRENCY.NAME as COCURRENCYNAME,
                       SECHIST.FACEVALUE,
                       SECHIST.DECIMALS,
                       BASE_T.SETTLEDATE,
                       BASE_T.TRADENO,
                       BASE_T.BUYSELL,
                       BASE_T.TRDACCID,
                       BASE_T.ORDERNO,
                       BASE_T.TYP as TRADETYPE,
                       BASE_T.PRICE,
                       BASE_T.QUANTITY,
                       BASE_T.VAL,
                       BASE_T.CPFIRMID,
                       case BASE_T.BOARDID
                         when 'CETS' then
                          ''
                         when 'FUTS' then
                          ''
                         else
                          'NCC0000100000'
                       end as CPFIRMIDCUX,
                       CPFIRMS.INN as CPFIRMINN,
                       CPFIRMS.NAME as CPFIRMNAME,
                       CPFIRMS.LATNAME as CPFIRMLATNAME,
                       BASE_T.PERIOD,
                       BASE_T.SETTLECODE,
                       BASE_T.USERID,
                       BASE_T.USEREXCHANGEID,
                       BASE_T.BROKERREF,
                       BASE_T.EXTREF,
                       BASE_T.EXHCOMM,
                       BASE_T.ITSCOMM,
                       BASE_T.CLRCOMM,
                       BASE_T.COMMISSION,
                       CLIENTCODES.CLIENTCODE,
                       CLIENTCODES.TYP as CLIENTCODESTYP,
                       CLIENTCODES.DETAILS,
                       CLIENTCODES.SUBDETAILS,
                       BASE_T.PARENTTRADENO as REPOTRADENO,
                       BOARDS.BOARDID,
                       BOARDS.NAME as BOARDNAME,
                       BOARDS.LATNAME as BOARDLATNAME,
                       BASE_T.AMOUNT,
                       TRDACC.TYP as TRDACCTYP,
                       TRDACC.BANKACCID as TRDACCBID,
                       CCLIENTCODES.CLIENTCODE as CLIENTCODEBENEF,
                       CCLIENTCODES.TYP as CLIENTCODESTYPBENEF,
                       CCLIENTCODES.DETAILS as DETAILSBENEF,
                       CCLIENTCODES.SUBDETAILS as SUBDETAILSBENEF,
                       PTRADES.SECURITYID as PSECURITYID,
                       PTRADES.SHORTNAME as PSECURITYSNAME,
                       BASE_T.ADDSESSION,
                       replace(replace(BASE_T.ADDSESSION, 'N', 'Основная сессия'), 'Y',
                               'Дополнительная сессия') as SESSIONNAME,
                       replace(replace(BASE_T.ADDSESSION, 'N', 'Main Trading session'), 'Y',
                               'Additional Trading session') as SESSIONNAMEEN,
                       case BASE_T.TYP
                         when 'S' then
                          'S'
                         when 'W' then
                          'S'
                         else
                          'T'
                       end as TRADEGROUP,
                       BASE_T.TRADEDATE as SYS_DATE,
                       BASE_T.TRADETIME as SYS_TIME,
                       BASE_T.TRADEMICROSECONDS as SYS_TIMEMS,
                       TO_TIMESTAMP(TO_CHAR(BASE_T.TRADEDATE, 'dd.mm.yyyy') ||
                                    SUBSTR(TO_CHAR(1000000 + BASE_T.TRADETIME), 2) ||
                                    SUBSTR(TO_CHAR(1000000 + BASE_T.TRADEMICROSECONDS), 2),
                                    'dd.mm.yyyyhh24missff') as FILTER_FULLTIME
                  from CURR.TRADES_BASE BASE_T,
                       INTERNALDM.V_CURR_CLIENTCODES CLIENTCODES,
                       INTERNALDM.V_CURR_FIRMS FIRMS,
                       INTERNALDM.V_CURR_TRDACC TRDACC,
                       INTERNALDM.V_CURR_FIRMS CPFIRMS,
                       INTERNALDM.V_CURR_BANKACC BANKACC,
                       INTERNALDM.V_CURR_BANKACCS BANKACCS,
                       INTERNALDM.V_CURR_FIRMS CLFIRMS,
                       INTERNALDM.V_CURR_BOARDS BOARDS,
                       INTERNALDM.V_CURR_SECS SECS,
                       INTERNALDM.V_CURR_CURRENCY CURRENCY,
                       INTERNALDM.V_CURR_CURRENCY COCURRENCY,
                       INTERNALDM.V_CURR_SECHIST SECHIST,
                       CURR.TRADES_BASE CTRADES,
                       INTERNALDM.V_CURR_CLIENTCODES CCLIENTCODES,
                       INTERNALDM.V_CURR_INSTR INSTR,
                       (select SECS.SECURITYID,
                               SECS.SHORTNAME,
                               BASE_T.TRADENO,
                               BASE_T.BUYSELL
                          from CURR.TRADES_BASE BASE_T, INTERNALDM.V_CURR_SECS SECS
                         where BASE_T.SECURITYID = SECS.SECURITYID and
                               TRADEDATE between TO_DATE('01.01.2012', 'dd.mm.yyyy') and
                               TO_DATE('30.12.2013', 'dd.mm.yyyy')) PTRADES
                 where BASE_T.FIRMID = FIRMS.FIRMID and
                       BASE_T.FIRMID = TRDACC.FIRMID and
                       BASE_T.TRDACCID = TRDACC.TRDACCID and
                       CPFIRMS.FIRMID = BASE_T.CPFIRMID and
                       (BANKACCS.FIRMID = BASE_T.FIRMID and BANKACCS.ID = TRDACC.BANKACCID) and
                       BANKACC.BANKACCID = BANKACCS.CLEARINGBANKACCID and
                       BASE_T.TRADENO = CTRADES.TRADENO and
                       BASE_T.BUYSELL != CTRADES.BUYSELL and
                       BASE_T.TRADEDATE = CTRADES.TRADEDATE and
                       BASE_T.CLEARINGFIRMID = CLFIRMS.FIRMID and
                       BASE_T.SECURITYID = SECS.SECURITYID and
                       BASE_T.BOARDID = BOARDS.BOARDID and
                       SECS.FACEUNIT = CURRENCY.CURRENCYID and
                       SECS.CURRENCYID = COCURRENCY.CURRENCYID and
                       SECHIST.BOARDID in ('CETS', 'FUTS', 'FUTN') and
                       SECHIST.TRADEDATE = BASE_T.TRADEDATE and
                       SECHIST.SECURITYID = BASE_T.SECURITYID and
                       BASE_T.CLIENTCODEID = CLIENTCODES.CLIENTCODEID(+) and
                       CTRADES.CLIENTCODEID = CCLIENTCODES.CLIENTCODEID(+) and
                       PTRADES.TRADENO(+) = BASE_T.PARENTTRADENO and
                       (PTRADES.BUYSELL != BASE_T.BUYSELL or PTRADES.BUYSELL is null) and
                       SECS.INSTRID = INSTR.INSTRID and
                       BASE_T.STATUS != 'C' and
                       BANKACCS.ST_ACTUAL = 'A' and
                       BANKACC.ST_ACTUAL = 'A' and
                       trim(BANKACC.CURRENCYID) is null and
                       BASE_T.TRADEDATE between TO_DATE('01.01.2012', 'dd.mm.yyyy') and
                       TO_DATE('30.12.2013', 'dd.mm.yyyy') and
                       BASE_T.FIRMID in ('MB0038600000') and
                       BASE_T.BOARDID in ('AETS', 'CETS', 'CNGD')) T
         where 1 = 1
         order by TRADENO) T;
         
--my version (the same result)

WITH PTRADES
     AS (SELECT SECS.SECURITYID,
                SECS.SHORTNAME,
                BASE_T.TRADENO,
                BASE_T.BUYSELL
           FROM INTERNALDM.V_CURR_TRADES BASE_T, INTERNALDM.V_CURR_SECS SECS
          WHERE     BASE_T.SECURITYID = SECS.SECURITYID
                AND TRADEDATE BETWEEN TO_DATE ('01.01.2012', 'dd.mm.yyyy')
                                  AND TO_DATE ('31.12.2013', 'dd.mm.yyyy')),
     BASE_T
     AS (SELECT T.TRADEDATE,
                T.TRADENO,
                T.ORDERNO,
                T.FIRMID,
                T.TYP,
                T.VAL,
                T.QUANTITY,
                T.SETTLEDATE,
                T.PRICE,
                T.ADDSESSION,
                T.AMOUNT,
                T.TRDACCID,
                T.TRADETIME,
                T.BUYSELL,
                T.CLIENTCODEID,
                T.CPFIRMID,
                T.PARENTTRADENO,
                T.SECURITYID,
                T.BOARDID,
                T.CLEARINGFIRMID,
                T.TRADEMICROSECONDS,
                T.PERIOD,
                T.SETTLECODE,
                T.USERID,
                T.USEREXCHANGEID,
                T.BROKERREF,
                T.EXTREF,
                T.EXHCOMM,
                T.ITSCOMM,
                T.CLRCOMM,
                T.COMMISSION,
                S.FACEVALUE,
                S.DECIMALS
           FROM INTERNALDM.V_CURR_TRADES T, INTERNALDM.V_CURR_SECHIST S
          WHERE     T.TRADEDATE BETWEEN TO_DATE ('01.01.2012', 'dd.mm.yyyy')
                                    AND TO_DATE ('31.12.2013', 'dd.mm.yyyy')
                AND T.FIRMID IN ('MB0038600000')
                AND T.BOARDID IN ('AETS', 'CETS', 'CNGD')
                AND T.STATUS != 'C'
                AND S.BOARDID IN ('CETS', 'FUTS', 'FUTN')
                AND S.TRADEDATE = T.TRADEDATE
                AND S.SECURITYID = T.SECURITYID)
SELECT DISTINCT TRADEDATE,
                FIRMID,
                FIRMNAME,
                FIRMLATNAME,
                CLFIRMID,
                CLFIRMNAME,
                CLFIRMLATNAME,
                EXTSETTLECODE,
                TRDACCBID,
                TRDACCTYP,
                ADDSESSION,
                SESSIONNAME,
                SESSIONNAMEEN,
                CURRENCYID,
                CURRENCYNAME,
                COCURRENCYID,
                COCURRENCYNAME,
                SECURITYID,
                SECURITYSNAME,
                FACEVALUE,
                SETTLEDATE,
                TRADEGROUP,
                PSECURITYID,
                PSECURITYSNAME,
                TRADENO,
                BUYSELL,
                ORDERNO,
                TRADEDERIV,
                TRADETIMERES,
                TRADETYPE,
                DECIMALS,
                PRICE,
                QUANTITY,
                VAL,
                PERIOD,
                CPFIRMIDCUX,
                SETTLECODE,
                USERID,
                USEREXCHANGEID,
                TRDACCID,
                BROKERREF,
                EXTREF,
                EXHCOMM,
                ITSCOMM,
                CLRCOMM,
                COMMISSION,
                CLIENTCODE,
                DETAILS,
                SUBDETAILS,
                REPOTRADENO,
                BOARDID,
                BOARDNAME,
                BOARDLATNAME,
                SYS_DATE,
                SYS_TIME,
                SYS_TIMEMS
  FROM (  SELECT *
            FROM (SELECT BASE_T.TRADEDATE,
                         TO_CHAR (
                             TO_TIMESTAMP (
                                 SUBSTR (TO_CHAR (1000000 + BASE_T.TRADETIME),
                                         2),
                                 'hh24miss'),
                             'hh24:mi:ss')
                             AS TRADETIMERES,
                         TRIM (
                             TRAILING '0' FROM TO_CHAR (
                                                   TO_TIMESTAMP (
                                                          SUBSTR (
                                                              TO_CHAR (
                                                                    1000000
                                                                  + BASE_T.TRADETIME),
                                                              2)
                                                       || SUBSTR (
                                                              TO_CHAR (
                                                                    1000000
                                                                  + BASE_T.TRADEMICROSECONDS),
                                                              2),
                                                       'hh24missff'),
                                                   'hh24:mi:ss.ff'))
                             AS TRADETIMEMSRES,
                         BASE_T.FIRMID,
                         FIRMS.INN              AS FIRMINN,
                         FIRMS.NAME             AS FIRMNAME,
                         FIRMS.LATNAME          AS FIRMLATNAME,
                         CLFIRMS.FIRMID         AS CLFIRMID,
                         CLFIRMS.INN            AS CLFIRMINN,
                         CLFIRMS.NAME           AS CLFIRMNAME,
                         CLFIRMS.LATNAME        AS CLFIRMLATNAME,
                         BANKACC.REALACCOUNT    AS EXTSETTLECODE,
                         SECS.SECURITYID,
                         SECS.SHORTNAME         AS SECURITYSNAME,
                         NVL (SECS.ISDERIVATIVE, INSTR.ISDERIVATIVE)
                             AS TRADEDERIV,
                         CURRENCY.CURRENCYID,
                         CURRENCY.NAME          AS CURRENCYNAME,
                         COCURRENCY.CURRENCYID  AS COCURRENCYID,
                         COCURRENCY.NAME        AS COCURRENCYNAME,
                         BASE_T.FACEVALUE,
                         BASE_T.DECIMALS,
                         BASE_T.SETTLEDATE,
                         BASE_T.TRADENO,
                         BASE_T.BUYSELL,
                         BASE_T.TRDACCID,
                         BASE_T.ORDERNO,
                         BASE_T.TYP             AS TRADETYPE,
                         BASE_T.PRICE,
                         BASE_T.QUANTITY,
                         BASE_T.VAL,
                         BASE_T.CPFIRMID,
                         CASE BASE_T.BOARDID
                             WHEN 'CETS' THEN ''
                             WHEN 'FUTS' THEN ''
                             ELSE 'NCC0000100000'
                         END
                             AS CPFIRMIDCUX,
                         CPFIRMS.INN            AS CPFIRMINN,
                         CPFIRMS.NAME           AS CPFIRMNAME,
                         CPFIRMS.LATNAME        AS CPFIRMLATNAME,
                         BASE_T.PERIOD,
                         BASE_T.SETTLECODE,
                         BASE_T.USERID,
                         BASE_T.USEREXCHANGEID,
                         BASE_T.BROKERREF,
                         BASE_T.EXTREF,
                         BASE_T.EXHCOMM,
                         BASE_T.ITSCOMM,
                         BASE_T.CLRCOMM,
                         BASE_T.COMMISSION,
                         CLIENTCODES.CLIENTCODE,
                         CLIENTCODES.TYP        AS CLIENTCODESTYP,
                         CLIENTCODES.DETAILS,
                         CLIENTCODES.SUBDETAILS,
                         BASE_T.PARENTTRADENO   AS REPOTRADENO,
                         BOARDS.BOARDID,
                         BOARDS.NAME            AS BOARDNAME,
                         BOARDS.LATNAME         AS BOARDLATNAME,
                         BASE_T.AMOUNT,
                         TRDACC.TYP             AS TRDACCTYP,
                         TRDACC.BANKACCID       AS TRDACCBID,
                         CCLIENTCODES.CLIENTCODE AS CLIENTCODEBENEF,
                         CCLIENTCODES.TYP       AS CLIENTCODESTYPBENEF,
                         CCLIENTCODES.DETAILS   AS DETAILSBENEF,
                         CCLIENTCODES.SUBDETAILS AS SUBDETAILSBENEF,
                         PTRADES.SECURITYID     AS PSECURITYID,
                         PTRADES.SHORTNAME      AS PSECURITYSNAME,
                         BASE_T.ADDSESSION,
                         REPLACE (
                             REPLACE (BASE_T.ADDSESSION,
                                      'N',
                                      'Основная сессия'),
                             'Y',
                             'Дополнительная сессия')
                             AS SESSIONNAME,
                         REPLACE (
                             REPLACE (BASE_T.ADDSESSION,
                                      'N',
                                      'Main Trading session'),
                             'Y',
                             'Additional Trading session')
                             AS SESSIONNAMEEN,
                         CASE BASE_T.TYP
                             WHEN 'S' THEN 'S'
                             WHEN 'W' THEN 'S'
                             ELSE 'T'
                         END
                             AS TRADEGROUP,
                         BASE_T.TRADEDATE       AS SYS_DATE,
                         BASE_T.TRADETIME       AS SYS_TIME,
                         BASE_T.TRADEMICROSECONDS AS SYS_TIMEMS,
                         TO_TIMESTAMP (
                                TO_CHAR (BASE_T.TRADEDATE, 'dd.mm.yyyy')
                             || SUBSTR (TO_CHAR (1000000 + BASE_T.TRADETIME),
                                        2)
                             || SUBSTR (
                                    TO_CHAR (
                                        1000000 + BASE_T.TRADEMICROSECONDS),
                                    2),
                             'dd.mm.yyyyhh24missff')
                             AS FILTER_FULLTIME
                    FROM BASE_T,
                         PTRADES,
                         INTERNALDM.V_CURR_CLIENTCODES CLIENTCODES,
                         INTERNALDM.V_CURR_FIRMS      FIRMS,
                         INTERNALDM.V_CURR_TRDACC     TRDACC,
                         INTERNALDM.V_CURR_FIRMS      CPFIRMS,
                         INTERNALDM.V_CURR_BANKACC    BANKACC,
                         INTERNALDM.V_CURR_BANKACCS   BANKACCS,
                         INTERNALDM.V_CURR_FIRMS      CLFIRMS,
                         INTERNALDM.V_CURR_BOARDS     BOARDS,
                         INTERNALDM.V_CURR_SECS       SECS,
                         INTERNALDM.V_CURR_CURRENCY   CURRENCY,
                         INTERNALDM.V_CURR_CURRENCY   COCURRENCY,
                         INTERNALDM.V_CURR_TRADES     CTRADES,
                         INTERNALDM.V_CURR_CLIENTCODES CCLIENTCODES,
                         INTERNALDM.V_CURR_INSTR      INSTR
                   WHERE     BASE_T.FIRMID = FIRMS.FIRMID
                         AND BASE_T.FIRMID = TRDACC.FIRMID
                         AND BASE_T.TRDACCID = TRDACC.TRDACCID
                         AND CPFIRMS.FIRMID = BASE_T.CPFIRMID
                         AND (    BANKACCS.FIRMID = BASE_T.FIRMID
                              AND BANKACCS.ID = TRDACC.BANKACCID)
                         AND BANKACC.BANKACCID = BANKACCS.CLEARINGBANKACCID
                         AND BASE_T.TRADENO = CTRADES.TRADENO
                         AND BASE_T.BUYSELL != CTRADES.BUYSELL
                         AND BASE_T.TRADEDATE = CTRADES.TRADEDATE
                         AND BASE_T.CLEARINGFIRMID = CLFIRMS.FIRMID
                         AND BASE_T.SECURITYID = SECS.SECURITYID
                         AND BASE_T.BOARDID = BOARDS.BOARDID
                         AND SECS.FACEUNIT = CURRENCY.CURRENCYID
                         AND SECS.CURRENCYID = COCURRENCY.CURRENCYID
                         AND BASE_T.CLIENTCODEID = CLIENTCODES.CLIENTCODEID(+)
                         AND CTRADES.CLIENTCODEID =
                                 CCLIENTCODES.CLIENTCODEID(+)
                         AND PTRADES.TRADENO(+) = BASE_T.PARENTTRADENO
                         AND (   PTRADES.BUYSELL != BASE_T.BUYSELL
                              OR PTRADES.BUYSELL IS NULL)
                         AND SECS.INSTRID = INSTR.INSTRID
                         AND BANKACCS.ST_ACTUAL = 'A'
                         AND BANKACC.ST_ACTUAL = 'A'
                         AND TRIM (BANKACC.CURRENCYID) IS NULL) T
           WHERE 1 = 1
        ORDER BY TRADENO) T;

-- пример анализа выполнения реквеста в схеме загрузчика

SELECT * FROM LOADER_CB2.in_request WHERE id = 6673;

--exec LOADER_CB2.EQ_CURR_ORDERS_TO_MIRROR(6673);

   SELECT *
     FROM LOADER_CB2.in_params
    WHERE req_id = (SELECT req_id
                      FROM LOADER_CB2.in_request
                     WHERE id = 6673);
                     
select to_char(trunc(sysdate-5) , 'DD.MM.YYYY') from dual;

set timing on
--exec EQ.CURR_ORDERS_TO_MIRROR(TO_DATE('15.04.2017', 'dd.mm.yyyy'));

select TO_DATE('15.04.2017', 'dd.mm.yyyy') from dual;

-- http://jira.moex.com/browse/DKSMON-290

SELECT * FROM TNSNAMES;

SELECT REPLACE (
           REPLACE (
               REPLACE (REPLACE (DESCRIPTOR, '(ADDRESS =', ' (ADDRESS ='),
                        '(CONNECT_DATA =',
                        '  (CONNECT_DATA ='),
               '(SERVER = ',
               '   (SERVER = '),
           '(SERVICE_NAME =',
           '   (SERVICE_NAME =')
  FROM TNSNAMES;
  
select * from TNS_NAMES;

-- задача по избавлению от индексов по UPDATEDT для слежения за модификациями таблиц (Юрлов)

select * from dba_tab_modifications where TABLE_OWNER = 'CURR' and TABLE_NAME = 'CASH_BASE';
select * from dba_tab_modifications where TABLE_OWNER = 'FORTS_CLEARING' and TABLE_NAME = 'CLIENT_RESULT_MONEY_BASE' and PARTITION_NAME IS NULL;

-- по проблемной работе процедуры CURR.SYNC_SWAP_REP
-- http://jira.moex.com/browse/DWH-150

SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID = 'fu9p6aq6p7adc';

--1 top level sql, started at 29.03.2017 3:27:44.675 sid = 2238 serial = 55915
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID = '3ckkykds5bfvj'; --BEGIN in_req_after_execute(:1 , :2 ); END;
--2 started at 29.03.2017 3:28:04.798
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID = 'fu9p6aq6p7adc'; --SELECT /*+ dynamic_sampling(0) */ TRADE_NO1, TRADE_NO2, TRADEDATE...
--3 started at 29.03.2017 3:28:14.818
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID = '3tg7m5wza5bkd'; --INSERT /*+ APPEND_VALUES */ INTO CURR.SWAP_REP ( TRADE_NO1, TRADE_NO2, TRADEDATE...
--4 started at 29.03.2017 3:28:24.838
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID = 'avss38ab0a9w3'; --SELECT NO, W1, M1, M3, M6, M12, M36 FROM V_ST_BLM_RATES01 WHERE RATE = :B2 AND CURDATE = :B1
--5 started at 29.03.2017 6:21:23.255
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID = 'fu9p6aq6p7adc'; --SELECT /*+ dynamic_sampling(0) */ TRADE_NO1, TRADE_NO2, TRADEDATE...
--6 29.03.2017 6:21:33.275
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID = 'avss38ab0a9w3'; --SELECT NO, W1, M1, M3, M6, M12, M36 FROM V_ST_BLM_RATES01 WHERE RATE = :B2 AND CURDATE = :B1
--6 29.03.2017 6:42:17.686
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID = '2ks93fcqk1pyv'; --UPDATE SWAP_REP SET SWAP_RATE = ROUND(SPUR.GETSWAPRATE( SWAP_DIFFERENCE, PRICE_STEP1, BASE_CURRENCY_ID, TRADEDATE, SETTLE_DATE1, SETTLE_DATE2),6) WHERE ROWID = :B1
--7 29.03.2017 6:42:27.716
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID = 'avss38ab0a9w3'; --SELECT NO, W1, M1, M3, M6, M12, M36 FROM V_ST_BLM_RATES01 WHERE RATE = :B2 AND CURDATE = :B1
--8 29.03.2017 6:53:39.950
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID = '2ks93fcqk1pyv'; --UPDATE SWAP_REP SET SWAP_RATE = ROUND(SPUR.GETSWAPRATE( SWAP_DIFFERENCE, PRICE_STEP1, BASE_CURRENCY_ID, TRADEDATE, SETTLE_DATE1, SETTLE_DATE2),6) WHERE ROWID = :B1
--9 29.03.2017 6:53:50.950
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID = 'avss38ab0a9w3'; --SELECT NO, W1, M1, M3, M6, M12, M36 FROM V_ST_BLM_RATES01 WHERE RATE = :B2 AND CURDATE = :B1
--10 29.03.2017 7:12:53.661
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID = '0u267h92jqnqh'; --CALL CALL_EQ_CURR_SWAP_REP_TO_MIRRO(273596)
--11 29.03.2017 7:13:03.671
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID = 'avss38ab0a9w3'; --SELECT NO, W1, M1, M3, M6, M12, M36 FROM V_ST_BLM_RATES01 WHERE RATE = :B2 AND CURDATE = :B1
--12 29.03.2017 7:30:26.896
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID = '2ks93fcqk1pyv'; --UPDATE SWAP_REP SET SWAP_RATE = ROUND(SPUR.GETSWAPRATE( SWAP_DIFFERENCE, PRICE_STEP1, BASE_CURRENCY_ID, TRADEDATE, SETTLE_DATE1, SETTLE_DATE2),6) WHERE ROWID = :B1

--problem statement

SELECT                         
    NO,
    W1,
    M1,
    M3,
    M6,
    M12,
    M36
  FROM spur.V_ST_BLM_RATES01
  WHERE RATE  = 'USD_LIBOR'
  AND CURDATE = trunc(sysdate-1);
  
  spur.V_ST_BLM_RATES02
  
 --problem view spur.V_ST_BLM_RATES02

SELECT NO, W1, M1, M3, M6, M12, M36 FROM spur.V_ST_BLM_RATES01 WHERE RATE = :B2 AND CURDATE = trunc(sysdate-1);

select * from eq.errlog where proc like 'CURR.SYNC_SWAP_REP%' and UPDATEDT > trunc(sysdate -7) order by proc,1;

select /*+ dynamic_sampling(0) RESULT_CACHE */ count(*) from
(SELECT TRADE_NO1,
       TRADE_NO2,
       TRADEDATE,
       SETTLE_DATE1,
       SETTLE_DATE2,
       LEN_IN_TRADE_DAYS,
       SECURITY_ID,
       SECURITY_ID1,
       SECURITY_ID2,
       DEAL_CURRENCY_ID,
       BASE_CURRENCY_ID,
       ROUND (PROVIDED_VOLUME, 2) AS PROVIDED_VOLUME,
       ROUND (RETURNED_VOLUME, 2) AS RETURNED_VOLUME,
       ROUND (BASE_VOLUME, 2)     AS BASE_VOLUME,
       ROUND (PRICE_STEP1, 6)     AS PRICE_STEP1,
       ROUND (PRICE_STEP2, 6)     AS PRICE_STEP2,
       ROUND (SWAP_DIFFERENCE, 6) AS SWAP_DIFFERENCE,
       ROUND (SPUR.GETSWAPRATE (ROUND (SWAP_DIFFERENCE, 6),
                                ROUND (PRICE_STEP1, 6),
                                BASE_CURRENCY_ID,
                                TRADEDATE,
                                SETTLE_DATE1,
                                SETTLE_DATE2),
              6)
           AS SWAP_RATE,
       CREDITOR_FIRM_ID,
       DEBITOR_FIRM_ID,
       CREDITOR_CLIENT_CODE,
       DEBITOR_CLIENT_CODE,
       TYP,
       SETTLE_CODE1,
       SETTLE_CODE2,
       BOARDID,
       SESSIONNO
  FROM (  SELECT DISTINCT
                 MAX (CASE WHEN TRDPART = 1 THEN TRADENO END)  AS TRADE_NO1,
                 MAX (CASE WHEN TRDPART = 2 THEN TRADENO END)  AS TRADE_NO2,
                 MAX (TRADEDATE)                               AS TRADEDATE,
                 MAX (CASE WHEN TRDPART = 1 THEN SETTLEDATE END)
                     AS SETTLE_DATE1,
                 MAX (CASE WHEN TRDPART = 2 THEN SETTLEDATE END)
                     AS SETTLE_DATE2,
                 TO_NUMBER (NULL)
                     AS LEN_IN_TRADE_DAYS,
                 MAX (CASE WHEN TRDPART = 0 THEN SECURITYID END) AS SECURITY_ID,
                 MAX (CASE WHEN TRDPART = 1 THEN SECURITYID END)
                     AS SECURITY_ID1,
                 MAX (CASE WHEN TRDPART = 2 THEN SECURITYID END)
                     AS SECURITY_ID2,
                 MAX (CURRENCYID)
                     AS DEAL_CURRENCY_ID,
                 MAX (FACEUNIT)
                     AS BASE_CURRENCY_ID,
                 MAX (CASE WHEN TRDPART = 1 THEN VAL END)
                     AS PROVIDED_VOLUME,
                 MAX (CASE WHEN TRDPART = 2 THEN VAL END)
                     AS RETURNED_VOLUME,
                 MAX (CASE WHEN TRDPART = 1 THEN QUANTITY END) AS BASE_VOLUME,
                 MAX (CASE WHEN TRDPART = 1 THEN PRICE END)    AS PRICE_STEP1,
                 MAX (CASE WHEN TRDPART = 2 THEN PRICE END)    AS PRICE_STEP2,
                     MAX (CASE WHEN TRDPART = 1 THEN QUANTITY END)
                   / MAX (CASE WHEN TRDPART = 2 THEN VAL END)
                 -   MAX (CASE WHEN TRDPART = 1 THEN QUANTITY END)
                   / MAX (CASE WHEN TRDPART = 1 THEN VAL END)
                     AS SWAP_DIFFERENCE,
                 (CASE
                      WHEN    (MAX (
                                   CASE
                                       WHEN TRDPART = 1 AND BUYSELL = 'B'
                                       THEN
                                           VAL
                                   END) >=
                                   MAX (
                                       CASE
                                           WHEN TRDPART = 2 AND BUYSELL = 'S'
                                           THEN
                                               VAL
                                       END))
                           OR (MAX (
                                   CASE
                                       WHEN TRDPART = 1 AND BUYSELL = 'S'
                                       THEN
                                           VAL
                                   END) <
                                   MAX (
                                       CASE
                                           WHEN TRDPART = 2 AND BUYSELL = 'B'
                                           THEN
                                               VAL
                                       END))
                      THEN
                          MAX (FIRMID)
                      ELSE
                          MAX (FIRMID2)
                  END)
                     AS CREDITOR_FIRM_ID,
                 (CASE
                      WHEN    (MAX (
                                   CASE
                                       WHEN TRDPART = 1 AND BUYSELL = 'B'
                                       THEN
                                           VAL
                                   END) <
                                   MAX (
                                       CASE
                                           WHEN TRDPART = 2 AND BUYSELL = 'S'
                                           THEN
                                               VAL
                                       END))
                           OR (MAX (
                                   CASE
                                       WHEN TRDPART = 1 AND BUYSELL = 'S'
                                       THEN
                                           VAL
                                   END) >=
                                   MAX (
                                       CASE
                                           WHEN TRDPART = 2 AND BUYSELL = 'B'
                                           THEN
                                               VAL
                                       END))
                      THEN
                          MAX (FIRMID)
                      ELSE
                          MAX (FIRMID2)
                  END)
                     AS DEBITOR_FIRM_ID,
                 (CASE
                      WHEN    (MAX (
                                   CASE
                                       WHEN TRDPART = 1 AND BUYSELL = 'B'
                                       THEN
                                           VAL
                                   END) >=
                                   MAX (
                                       CASE
                                           WHEN TRDPART = 2 AND BUYSELL = 'S'
                                           THEN
                                               VAL
                                       END))
                           OR (MAX (
                                   CASE
                                       WHEN TRDPART = 1 AND BUYSELL = 'S'
                                       THEN
                                           VAL
                                   END) <
                                   MAX (
                                       CASE
                                           WHEN TRDPART = 2 AND BUYSELL = 'B'
                                           THEN
                                               VAL
                                       END))
                      THEN
                          MAX (CLIENTCODEID)
                      ELSE
                          MAX (CLIENTCODEID2)
                  END)
                     AS CREDITOR_CLIENT_CODE,
                 (CASE
                      WHEN    (MAX (
                                   CASE
                                       WHEN TRDPART = 1 AND BUYSELL = 'B'
                                       THEN
                                           VAL
                                   END) <
                                   MAX (
                                       CASE
                                           WHEN TRDPART = 2 AND BUYSELL = 'S'
                                           THEN
                                               VAL
                                       END))
                           OR (MAX (
                                   CASE
                                       WHEN TRDPART = 1 AND BUYSELL = 'S'
                                       THEN
                                           VAL
                                   END) >=
                                   MAX (
                                       CASE
                                           WHEN TRDPART = 2 AND BUYSELL = 'B'
                                           THEN
                                               VAL
                                       END))
                      THEN
                          MAX (CLIENTCODEID)
                      ELSE
                          MAX (CLIENTCODEID2)
                  END)
                     AS DEBITOR_CLIENT_CODE,
                 CASE WHEN MAX (STYP) = 2 THEN 'W' ELSE 'S' END AS TYP,
                 MAX (CASE WHEN TRDPART = 1 THEN SETTLECODE END)
                     AS SETTLE_CODE1,
                 MAX (CASE WHEN TRDPART = 2 THEN SETTLECODE END)
                     AS SETTLE_CODE2,
                 MAX (BOARDID)                                 AS BOARDID,
                 MAX (SESSIONNO)                               AS SESSIONNO,
                 CASE
                     WHEN MAX (CASE WHEN TRDPART = 0 THEN BUYSELL END) = 'B'
                     THEN
                         MAX (ORDERNO)
                     ELSE
                         MAX (ORDERNO2)
                 END
                     AS ORDERNO -- Поле для обеспечения уникальности (DISTINCT!). В итоговом отчете не используется!
            FROM (SELECT TRUNC (
                               (  ROW_NUMBER ()
                                  OVER (
                                      ORDER BY
                                          A.TRADEDATE, A.ORDERNO, A.TRADENO)
                                - 1)
                             / 3)
                             AS RN,
                         A.*
                    FROM (SELECT MAX (
                                     CASE
                                         WHEN A.TYP IN ('S', 'W') THEN 'Y'
                                         ELSE 'N'
                                     END)
                                 OVER (PARTITION BY A.ORDERNO)
                                     AS ISSWAP,
                                 CASE
                                     WHEN     A.TYP IN ('S', 'W')
                                          AND (   (    C.SETTLECODE = 'T1'
                                                   AND MAX (
                                                           CASE
                                                               WHEN    INSTRID LIKE
                                                                           'SWF%'
                                                                    OR INSTRID LIKE
                                                                           'SWS%'
                                                               THEN
                                                                   'Y'
                                                               ELSE
                                                                   'N'
                                                           END)
                                                       OVER (
                                                           PARTITION BY A.ORDERNO) =
                                                           'N')
                                               OR (   C.SETTLECODE LIKE 'F%'
                                                   OR     C.SETTLECODE = 'T2'
                                                      AND MAX (
                                                              CASE
                                                                  WHEN    INSTRID LIKE
                                                                              'SWF%'
                                                                       OR INSTRID LIKE
                                                                              'SWS%'
                                                                  THEN
                                                                      'Y'
                                                                  ELSE
                                                                      'N'
                                                              END)
                                                          OVER (
                                                              PARTITION BY A.ORDERNO) =
                                                              'Y'))
                                     THEN
                                         2
                                     WHEN     A.TYP IN ('S', 'W')
                                          AND (   (    C.SETTLECODE = 'T0'
                                                   AND MAX (
                                                           CASE
                                                               WHEN    INSTRID LIKE
                                                                           'SWF%'
                                                                    OR INSTRID LIKE
                                                                           'SWS%'
                                                               THEN
                                                                   'Y'
                                                               ELSE
                                                                   'N'
                                                           END)
                                                       OVER (
                                                           PARTITION BY A.ORDERNO) =
                                                           'N')
                                               OR (    C.SETTLECODE = 'T1'
                                                   AND MAX (
                                                           CASE
                                                               WHEN    INSTRID LIKE
                                                                           'SWF%'
                                                                    OR INSTRID LIKE
                                                                           'SWS%'
                                                               THEN
                                                                   'Y'
                                                               ELSE
                                                                   'N'
                                                           END)
                                                       OVER (
                                                           PARTITION BY A.ORDERNO) =
                                                           'Y'))
                                     THEN
                                         1
                                     ELSE
                                         0
                                 END
                                     AS TRDPART,
                                 CASE
                                     WHEN A.TYP = 'S' THEN 1
                                     WHEN A.TYP = 'W' THEN 2
                                 END
                                     AS STYP,
                                 C.FACEUNIT,
                                 C.CURRENCYID,
                                 A.TRADEDATE,
                                 A.TRADENO,
                                 A.ORDERNO,
                                 A.SECURITYID,
                                 A.BUYSELL,
                                 A.PRICE,
                                 A.QUANTITY,
                                 A.VAL,
                                 A.SETTLEDATE,
                                 A.DUEDATE,
                                 A.SETTLECODE,
                                 A.BOARDID,
                                 A.SESSIONNO,
                                 A.TYP,
                                 A.FIRMID,
                                 A.CLIENTCODEID,
                                 B.ORDERNO    AS ORDERNO2,
                                 B.FIRMID     AS FIRMID2,
                                 B.CLIENTCODEID AS CLIENTCODEID2
                            FROM CURR.V_TRADES_BASE A,
                                 CURR.V_TRADES_BASE B,
                                 CURR.SECS_BASE    C
                           WHERE     A.TRADEDATE = TRUNC (SYSDATE - 1)
                                 AND B.TRADEDATE = TRUNC (SYSDATE - 1)
                                 AND A.TRADENO = B.TRADENO
                                 AND A.BUYSELL <> B.BUYSELL
                                 AND A.STATUS = 'M'
                                 AND A.CONFIRMED = 'C'
                                 AND A.SETTLED = 'U'
                                 AND A.SECURITYID = C.SECURITYID) A
                   WHERE ISSWAP = 'Y')
        GROUP BY RN));

-- problem with MIX,MAX functions at FORTS_AR.OPT_ORDLOG 

ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';

--problem solved with this

select   /*+ opt_param('_fix_control','5611962:0') */ MIN(SESS_ID) FROM FORTS_AR.OPT_ORDLOG  WHERE NUMB_ORDER BETWEEN 831121 AND 882281;
alter session set optimizer_use_invisible_indexes = true;
SELECT /*+ opt_param('_fix_control','5611962:0') opt_param('optimizer_use_invisible_indexes' 'true') INDEX_SS(FUT_ORDLOG) */  MIN(SESS_ID),MAX(SESS_ID)  FROM FORTS_AR.FUT_ORDLOG  WHERE NUMB_ORDER BETWEEN 73231  AND 73231;

alter system set events '10053 trace name context off';

select * from FORTS_AR.FUT_ORDLOG partition(FUT_ORDLOG_5240);

select MAX(SESS_ID) FROM FORTS_AR.OPT_ORDLOG  WHERE NUMB_ORDER BETWEEN 831121 AND 882281;
select MAX(-(-SESS_ID)) FROM FORTS_AR.OPT_ORDLOG  WHERE NUMB_ORDER BETWEEN 831121 AND 882281;
select MIN(SESS_ID) FROM FORTS_AR.OPT_ORDLOG  WHERE NUMB_ORDER BETWEEN 831121 AND 882281;
select -MIN(-SESS_ID) FROM FORTS_AR.OPT_ORDLOG  WHERE NUMB_ORDER BETWEEN 831121 AND 882281;

--alter session set "_optimizer_skip_scan_enabled"=true;

SELECT s.sid,
       s.serial#,
       pa.value || '/' || LOWER(SYS_CONTEXT('userenv','instance_name')) ||    
       '_ora_' || p.spid || '.trc' AS trace_file
FROM   v$session s,
       v$process p,
       v$parameter pa
WHERE  pa.name = 'user_dump_dest'
AND    s.paddr = p.addr
AND    s.audsid = SYS_CONTEXT('USERENV', 'SESSIONID');

alter session set max_dump_file_size = unlimited;
ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';
alter system set events '10053 trace name context off';


select /*+ INDEX(a UIDX_OPT_ORDLOG) */ MAX(a.SESS_ID) FROM FORTS_AR.OPT_ORDLOG a  WHERE a.NUMB_ORDER BETWEEN 831121 AND 882281;
select /*+ INDEX_SS(a UIDX_OPT_ORDLOG) */ MAX(a.SESS_ID) FROM FORTS_AR.OPT_ORDLOG a  WHERE a.NUMB_ORDER BETWEEN 831121 AND 882281;
select /*+ NO_QUERY_TRANSFORMATION INDEX_SS_DESC(a UIDX_OPT_ORDLOG)*/ MAX(a.SESS_ID) FROM FORTS_AR.OPT_ORDLOG a  WHERE a.NUMB_ORDER BETWEEN 831121 AND 882281;
select /*+ NO_GATHER_OPTIMIZER_STATISTICS */ MAX(a.SESS_ID) FROM FORTS_AR.OPT_ORDLOG a  WHERE a.NUMB_ORDER BETWEEN 831121 AND 882281;

SELECT MIN(SESS_ID),MAX(SESS_ID) FROM FORTS_AR.OPT_ORDLOG WHERE NUMB_ORDER BETWEEN 831121 AND 1479604

SELECT MIN(SESS_ID) FROM FORTS_AR.OPT_ORDLOG WHERE NUMB_ORDER BETWEEN 831121 AND 1479604;
SELECT MAX(SESS_ID) FROM FORTS_AR.OPT_ORDLOG WHERE NUMB_ORDER BETWEEN 831121 AND 1479604;
select MAX(SESS_ID)  FROM FORTS_AR.OPT_ORDLOG  WHERE NUMB_ORDER BETWEEN 25407577099-100 AND 25407577099+1000;
select MIN(SESS_ID)  FROM FORTS_AR.OPT_ORDLOG  WHERE NUMB_ORDER BETWEEN 25407577099-100 AND 25407577099+1000;
select MAX(-(-SESS_ID))  FROM FORTS_AR.OPT_ORDLOG  WHERE NUMB_ORDER BETWEEN 25407577099-100 AND 25407577099+1000;
SELECT MAX(SESS_ID),MAX(NUMB_ORDER) FROM FORTS_AR.OPT_ORDLOG-- WHERE NUMB_ORDER BETWEEN 831121 AND 1479604;

SELECT MAX(SESS_ID),MAX(NUMB_ORDER) FROM FORTS_AR.OPT_ORDLOG WHERE NUMB_ORDER BETWEEN 831121 AND 1479604;
SELECT MAX(SESS_ID) FROM FORTS_AR.OPT_ORDLOG;
SELECT MIN(NUMB_ORDER) FROM FORTS_AR.OPT_ORDLOG WHERE SESS_ID = 5241;

SELECT MIN(-SESS_ID) FROM FORTS_AR.OPT_ORDLOG WHERE NUMB_ORDER BETWEEN 831121 AND 1479604;
SELECT MIN(SESS_ID) FROM FORTS_AR.OPT_ORDLOG WHERE NUMB_ORDER BETWEEN 831121 AND 1479604;

select * from FORTS_AR.OPT_ORDLOG WHERE SESS_ID = 5241;
select * from FORTS_AR.OPT_ORDLOG WHERE SESS_ID = 5237;

set timing on
EXEC DBMS_STATS.GATHER_TABLE_STATS ('FORTS_AR','OPT_ORDLOG', 'OPT_ORDLOG_5242', GRANULARITY => 'PARTITION', cascade => TRUE); 

-- ora-600 error when update tabke (Karpov)

alter session set "_optimizer_cost_based_transformation" = OFF;

update DQ.logical_constr l set l.constr_desc = '1612151401.FK'||
(select case when n1=n2 then to_char(n1) else to_char(n1)||'-'||to_char(n2) end
from
(select min(NUM) as n1,max(NUM) as n2 from karpov.buffer_EXCEL be WHERE "_"='1612151401' AND X=TO_CHAR(object_Id) and Z=TO_CHAR(AK_CONSTR_ID) 
and exists (select null from
               DQ.field_constr fc, DQ.table_field tf where tf.attr_id = fc.attr_id and fc.constr_id = l.constr_id and tf.attr_name=be.H)
))
where constr_desc = 'EXCEL=1612151401';

select * from all_objects where lower(object_name) = 'field_constr';


-- UNIFIED AUDIT

BEGIN 
IF 
NOT DBMS_AUDIT_MGMT.IS_CLEANUP_INITIALIZED(DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD) 
THEN 
DBMS_AUDIT_MGMT.INIT_CLEANUP( 
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD, 
default_cleanup_interval => 24 /* hours */); 
END IF; 
END; 
/ 


BEGIN 
IF 
NOT DBMS_AUDIT_MGMT.IS_CLEANUP_INITIALIZED(DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED) 
THEN 
DBMS_AUDIT_MGMT.INIT_CLEANUP( 
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED, 
default_cleanup_interval => 24 /* hours */); 
END IF; 
END; 
/ 


BEGIN 
IF 
NOT DBMS_AUDIT_MGMT.IS_CLEANUP_INITIALIZED(DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS) 
THEN 
DBMS_AUDIT_MGMT.INIT_CLEANUP( 
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED, 
default_cleanup_interval => 24 /* hours */); 
END IF; 
END; 
/ 


BEGIN 
DBMS_AUDIT_MGMT.INIT_CLEANUP( 
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL, 
DEFAULT_CLEANUP_INTERVAL => 24 ); 
END; 

select * from DBA_AUDIT_MGMT_CONFIG_PARAMS where parameter_name ='DEFAULT CLEAN UP INTERVAL'; 

begin 
DBMS_AUDIT_MGMT.INIT_CLEANUP( 
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD, -- aud$ 
DEFAULT_CLEANUP_INTERVAL => 24 ); 
end; 
/ 

begin 
DBMS_AUDIT_MGMT.INIT_CLEANUP( 
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED, -- unified audit Trail 
DEFAULT_CLEANUP_INTERVAL => 24 ); 
end; 
/ 


begin 
DBMS_AUDIT_MGMT.INIT_CLEANUP( 
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS, -- OS and XML audit files 
DEFAULT_CLEANUP_INTERVAL => 24 ); 
end; 
/ 

CREATE OR REPLACE procedure ARDB_USER.set_archive_retention (retention in number default 365) as
begin
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
last_archive_time => SYSDATE - retention);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
last_archive_time => SYSDATE - retention);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP (
AUDIT_TRAIL_TYPE  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD,
LAST_ARCHIVE_TIME => SYSDATE - retention);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,
LAST_ARCHIVE_TIME => SYSDATE - retention/8,
rac_instance_number => 1);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,
LAST_ARCHIVE_TIME => SYSDATE - retention/8,
rac_instance_number => 1);
end;
/

begin
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
last_archive_time => SYSDATE - 365);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
last_archive_time => SYSDATE - 365);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP (
AUDIT_TRAIL_TYPE  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD,
LAST_ARCHIVE_TIME => SYSDATE - 365);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,
LAST_ARCHIVE_TIME => SYSDATE - 365/8,
rac_instance_number => 1);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,
LAST_ARCHIVE_TIME => SYSDATE - 365/8,
rac_instance_number => 1);
end;
/

-- not unique indexes for big tables (http://jira.moex.com/browse/DWH-122)

--partitioned tables

  SELECT *
    FROM DBA_INDEXES
   WHERE     UNIQUENESS <> 'UNIQUE'
         AND OWNER NOT IN ('BI_METADATA',
                           'SPUR_DAY_CU_TEST',
                           'SPUR_DAY_TEST',
                           'SPUR_DAY_CU',
                           'SPUR_DAY',
                           'SYSTEM',
                           'SYS',
                           'AUDSYS')
         AND NUM_ROWS > 100000
         AND (TABLE_OWNER, TABLE_NAME) IN (SELECT OWNER, TABLE_NAME
                                             FROM DBA_TABLES
                                            WHERE PARTITIONED = 'YES')
ORDER BY OWNER, INDEX_NAME;

--not partitioned tables > 1GB

  SELECT *
    FROM DBA_INDEXES
   WHERE     UNIQUENESS <> 'UNIQUE'
         AND OWNER NOT IN ('BI_METADATA',
                           'SPUR_DAY_CU_TEST',
                           'SPUR_DAY_TEST',
                           'SPUR_DAY_CU',
                           'SPUR_DAY',
                           'SYSTEM',
                           'SYS',
                           'AUDSYS')
         AND (TABLE_OWNER, TABLE_NAME) IN
                 (SELECT T.OWNER, T.TABLE_NAME
                    FROM DBA_TABLES T, DBA_SEGMENTS S
                   WHERE     T.OWNER = S.OWNER
                         AND T.TABLE_NAME = S.SEGMENT_NAME
                         AND T.PARTITIONED = 'NO'
                         AND S.SEGMENT_TYPE = 'TABLE'
                         AND S.BYTES >= 1024 * 1024 * 1024)
ORDER BY OWNER, INDEX_NAME;

SELECT T.OWNER, T.TABLE_NAME
  FROM DBA_TABLES T, DBA_SEGMENTS S
 WHERE     T.OWNER = S.OWNER
       AND T.TABLE_NAME = S.SEGMENT_NAME
       AND T.OWNER NOT LIKE 'SYS%'
       AND T.PARTITIONED = 'NO'
       AND S.SEGMENT_TYPE = 'TABLE'
       AND S.BYTES >= 1024 * 1024 * 1024; 
       
-- all indexes from list

SELECT OWNER,INDEX_NAME,TABLE_OWNER,TABLE_NAME,COMPRESSION,TABLESPACE_NAME,SAMPLE_SIZE,LAST_ANALYZED,VISIBILITY FROM
(SELECT *
  FROM DBA_INDEXES
 WHERE     UNIQUENESS <> 'UNIQUE'
       AND OWNER NOT IN ('BI_METADATA',
                         'SPUR_DAY_CU_TEST',
                         'SPUR_DAY_TEST',
                         'SPUR_DAY_CU',
                         'SPUR_DAY',
                         'SYSTEM',
                         'SYS',
                         'AUDSYS')
       AND NUM_ROWS > 100000
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
                         'SYSTEM',
                         'SYS',
                         'AUDSYS')
       AND (TABLE_OWNER, TABLE_NAME) IN
               (SELECT T.OWNER, T.TABLE_NAME
                  FROM DBA_TABLES T, DBA_SEGMENTS S
                 WHERE     T.OWNER = S.OWNER
                       AND T.TABLE_NAME = S.SEGMENT_NAME
                       AND T.PARTITIONED = 'NO'
                       AND S.SEGMENT_TYPE = 'TABLE'
                       AND S.BYTES >= 1024 * 1024 * 1024))
ORDER BY OWNER, INDEX_NAME;

insert into INDEX_DDL_BACKUP_DWH122 (INDEX_OWNER,INDEX_NAME,TABLE_OWNER,TABLE_NAME,UNIQUNESS,COMPRESSION,INDEX_VISIBLE,INDEX_DDL)
SELECT OWNER,INDEX_NAME,TABLE_OWNER,TABLE_NAME,UNIQUENESS,COMPRESSION,VISIBILITY,dbms_metadata.get_ddl(object_type=>'INDEX',name=>INDEX_NAME,schema=>OWNER) FROM
(SELECT *
  FROM DBA_INDEXES
 WHERE     UNIQUENESS <> 'UNIQUE'
       AND OWNER NOT IN ('BI_METADATA',
                         'SPUR_DAY_CU_TEST',
                         'SPUR_DAY_TEST',
                         'SPUR_DAY_CU',
                         'SPUR_DAY',
                         'SYSTEM',
                         'SYS',
                         'AUDSYS')
       AND NUM_ROWS > 100000
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
                         'SYSTEM',
                         'SYS',
                         'AUDSYS')
       AND (TABLE_OWNER, TABLE_NAME) IN
               (SELECT T.OWNER, T.TABLE_NAME
                  FROM DBA_TABLES T, DBA_SEGMENTS S
                 WHERE     T.OWNER = S.OWNER
                       AND T.TABLE_NAME = S.SEGMENT_NAME
                       AND T.PARTITIONED = 'NO'
                       AND S.SEGMENT_TYPE = 'TABLE'
                       AND S.BYTES >= 1024 * 1024 * 1024))
ORDER BY OWNER, INDEX_NAME;

select * from INDEX_DDL_BACKUP_DWH122;

UPDATE INDEX_DDL_BACKUP_DWH122 I
   SET I.STATE_CHANGE =
              'CREATED '
           || (SELECT I.INDEX_NAME,D.CREATED
                 FROM DBA_OBJECTS D, INDEX_DDL_BACKUP_DWH122 I
                WHERE     D.OBJECT_TYPE = 'INDEX'
                      AND D.SUBOBJECT_NAME IS NULL
                      AND I.INDEX_NAME = D.OBJECT_NAME
                      AND I.INDEX_OWNER = D.OWNER ORDER BY 2 desc);
                      
select * from DBA_OBJECTS where OBJECT_TYPE = 'INDEX' and SUBOBJECT_NAME IS NULL;

select 'alter index '||INDEX_OWNER||'.'||INDEX_NAME||' monitoring usage;' from INDEX_DDL_BACKUP_DWH122;

select dbms_metadata.get_ddl (object_type=>'INDEX',name=>'HP_FA_ACCOUNTS_ACCNO_IDX',schema=>'CFTUSER') from dual;
select dbms_metadata.get_ddl (object_type=>'INDEX',name=>'ORDERS_CURR_UIDX',schema=>'CURR') from dual;

-- constraints at curr,eq

-- failed to run (ran 22 hours)

set timing on
ALTER TABLE CURR.ORDERS_BASE ADD 
CONSTRAINT ORDERS_BASE_PK 
 PRIMARY KEY (ENTRYDATE, ORDERNO)
 USING INDEX CURR.ORDERS_CURR_UIDX
 ENABLE
 VALIDATE;
 
 set timing on
ALTER TABLE EQ.ORDERS_BASE ADD 
CONSTRAINT ORDERS_BASE_PK 
 PRIMARY KEY (ENTRYDATE, ORDERNO)
 USING INDEX EQ.ORDERS_EQ_UIDX
 ENABLE
 VALIDATE;
 
 -- not run yet
 
  set timing on
ALTER TABLE EQ.TRADES_BASE ADD 
CONSTRAINT TRADES_BASE_PK 
 PRIMARY KEY (TRADEDATE, TRADENO, BUYSELL)
 USING INDEX EQ.TRADES_EQ_UIDX
 ENABLE
 VALIDATE;
 
  set timing on
ALTER TABLE EQ.ORDLOG_BASE ADD 
CONSTRAINT ORDLOG_BASE_PK 
 PRIMARY KEY (TRADEDATE, NO)
 USING INDEX EQ.ORDLOG_EQ_UIDX
 ENABLE
 VALIDATE;

-- письмо Славы от 06.02.2017

with aa as (select distinct FIRMID from   
(SELECT FIRMID FROM INTERNALDM.V_EQ_HOLD
UNION
SELECT FIRMID FROM MDMWORK.V_ASTS_UR_EQ
UNION
SELECT /*+ FULL PARALLEL(8) */ FIRMID FROM EQ.ORDERS_BASE
UNION
SELECT /*+ FULL PARALLEL(8) */ FIRMID FROM EQ.TRADES_BASE))
select count(1) from aa;

SELECT FIRMID FROM MDMWORK.V_ASTS_UR_EQ;

-- changes

made indexes EQ.RM_PERCENT_PRICERANG_BASE_UIDX and EQ.RM_PERCENT_PR_BASE_2_IDX invisible 
for MERGE INTO EQ.RM_PERCENT_PRICERANGE_BASE A ... work faster (now ~ 10 min)

-- FLASHBACK at FORTS_CLEARING SL_ORGANISATION_BASE and DEAL_BASE

select count(1) from FORTS_CLEARING.SL_ORGANISATION_BASE;

select * from FORTS_CLEARING.SYS_FBA_HIST_188363 where IDORGANISATION = 353900 order by UPDATEDT desc;

select max(STARTSCN) from FORTS_CLEARING.SYS_FBA_HIST_188363;
select max(ENDSCN) from FORTS_CLEARING.SYS_FBA_HIST_188363;

select scn_to_timestamp(10169560783470) from dual;

-- for SL_ORGANISATION_BASE
select * from FORTS_CLEARING.SYS_FBA_HIST_188363;
select count(1),sysdate from FORTS_CLEARING.SYS_FBA_HIST_188363;  --7571325	19.01.2017 19:10:51
select count(1),sysdate from FORTS_CLEARING.SYS_FBA_HIST_188363;  --7571325	20.01.2017 9:10:58

--for DEAL_BASE
select count(1),sysdate from FORTS_CLEARING.SYS_FBA_HIST_215510; --3730703	19.01.2017 19:32:32
select count(1),sysdate from FORTS_CLEARING.SYS_FBA_HIST_215510; --6693367	20.01.2017 9:11:14

/* Formatted on 19.01.2017 19:12:41 (QP5 v5.300) */
INSERT /*+ append */
      INTO  SYS_MFBA_NHIST_215510
    SELECT /*+ leading(r) use_nl(v)  NO_PARALLEL(r) PARALLEL(v,DEFAULT)  */
          V.ROWID                    "RID",
           V.VERSIONS_STARTSCN       "STARTSCN",
           V.VERSIONS_ENDSCN         "ENDSCN",
           V.VERSIONS_XID            "XID",
           V.VERSIONS_OPERATION      "OPERATION",
           V."ID"                    "ID",
           V."ID_DEAL"               "ID_DEAL",
           V."SYST_ID"               "SYST_ID",
           V."IDORG_PK"              "IDORG_PK",
           V."IDORG_PR"              "IDORG_PR",
           V."ISIN"                  "ISIN",
           V."TYPE_PK"               "TYPE_PK",
           V."TYPE_PR"               "TYPE_PR",
           V."AMOUNT"                "AMOUNT",
           V."PRICE"                 "PRICE",
           V."DATETIME"              "DATETIME",
           V."N_USER_PK"             "N_USER_PK",
           V."FIO_PK"                "FIO_PK",
           V."N_USER_PR"             "N_USER_PR",
           V."FIO_PR"                "FIO_PR",
           V."IS_EXP"                "IS_EXP",
           V."N_ORDER_PK"            "N_ORDER_PK",
           V."N_ORDER_PR"            "N_ORDER_PR",
           V."SBOR_PK"               "SBOR_PK",
           V."SBOR_PR"               "SBOR_PR",
           V."COMMENT_PK"            "COMMENT_PK",
           V."COMMENT_PR"            "COMMENT_PR",
           V."DU_PK"                 "DU_PK",
           V."DU_PR"                 "DU_PR",
           V."EXT_ID_PK"             "EXT_ID_PK",
           V."EXT_ID_PR"             "EXT_ID_PR",
           V."POS"                   "POS",
           V."STATUS_PK"             "STATUS_PK",
           V."STATUS_PR"             "STATUS_PR",
           V."KOD_PK"                "KOD_PK",
           V."KOD_PR"                "KOD_PR",
           V."ID_REPO"               "ID_REPO",
           V."SBOR_PK_EXCH_PAY"      "SBOR_PK_EXCH_PAY",
           V."SBOR_PK_CLEAR_PAY"     "SBOR_PK_CLEAR_PAY",
           V."SBOR_PK_EXCH_PAY_NDS"  "SBOR_PK_EXCH_PAY_NDS",
           V."SBOR_PK_CLEAR_PAY_NDS" "SBOR_PK_CLEAR_PAY_NDS",
           V."SBOR_PR_EXCH_PAY"      "SBOR_PR_EXCH_PAY",
           V."SBOR_PR_CLEAR_PAY"     "SBOR_PR_CLEAR_PAY",
           V."SBOR_PR_EXCH_PAY_NDS"  "SBOR_PR_EXCH_PAY_NDS",
           V."SBOR_PR_CLEAR_PAY_NDS" "SBOR_PR_CLEAR_PAY_NDS",
           V."SDEAL_PAY_EVE"         "SDEAL_PAY_EVE",
           V."SDEAL_PAY_MON"         "SDEAL_PAY_MON",
           V."REPLID"                "REPLID",
           V."STATUS_EXT"            "STATUS_EXT",
           V."VM_PK"                 "VM_PK",
           V."VM_PR"                 "VM_PR",
           V."REPLREV"               "REPLREV",
           V."UPDATEDT"              "UPDATEDT",
           V."REQ_ID"                "REQ_ID",
           V."L_ID"                  "L_ID",
           V."ST_ACTUAL"             "ST_ACTUAL",
           V."MSEC"                  "MSEC",
           V."XSTATUS_PK"            "XSTATUS_PK"
      FROM (  SELECT *
                FROM SYS_MFBA_NROW
            ORDER BY RID) R,
           "FORTS_CLEARING"."DEAL_BASE"
           VERSIONS BETWEEN SCN :1 AND MAXVALUE  V
     WHERE V.ROWID = R.RID;

-- P2_PROXY_LOG_BASE2016

set timing on
CREATE UNIQUE INDEX FORTS_REPAAR.P2_PROXY_LOG_BASE2016_UIDX ON FORTS_REPAAR.P2_PROXY_LOG_BASE2016
(DATE_TIME,P2_REPLY_CODE,SEQ_ID, RAW_ORDER_ID)
LOGGING LOCAL NOPARALLEL INDEXING PARTIAL COMPRESS ADVANCED LOW;

ERROR at line 1:
ORA-14226: unique index may not be PARTIAL

CREATE INDEX FORTS_REPAAR.P2_PROXY_LOG_BASE2016_UIDX ON FORTS_REPAAR.P2_PROXY_LOG_BASE2016
(SEQ_ID, RAW_ORDER_ID)
LOCAL INDEXING PARTIAL COMPRESS ADVANCED LOW;

select to_date('20170124','YYYYMMDD') from dual;

-- add subpartitions into partitions
set timing on
declare 
v_suppart_count NUMBER;
v_partname VARCHAR2(60);
v_sql VARCHAR2(4000);
begin
 for rec_part in
 (select * from dba_tab_partitions where NUM_ROWS > 0 and SUBPARTITION_COUNT = 1 and TABLE_NAME = 'P2_PROXY_LOG_BASE2016' order by PARTITION_POSITION)
 (select * from dba_tab_partitions where SUBPARTITION_COUNT = 1 and TABLE_NAME = 'P2_PROXY_LOG_BASE2016' and 
 to_date(REGEXP_REPLACE(PARTITION_NAME,'P2_PROXY_LOG_BASE_',''),'YYYYMMDD') between to_date('20161001','YYYYMMDD') and to_date('20170124','YYYYMMDD')  order by PARTITION_POSITION)
  loop
   v_partname:=rec_part.PARTITION_NAME;
   dbms_output.put_line(v_partname);
   v_sql :='select count(distinct P2_REPLY_CODE) from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 partition('||v_partname||')';
   dbms_output.put_line(v_sql);
   EXECUTE IMMEDIATE v_sql INTO v_suppart_count;
   dbms_output.put_line('add '||v_suppart_count||' subpartitions into '||v_partname||' partition');
   for rec in 1..v_suppart_count
    loop
     v_sql:='ALTER TABLE FORTS_REPAAR.P2_PROXY_LOG_BASE2016 MODIFY PARTITION '||v_partname||' ADD SUBPARTITION NO INMEMORY';
     execute immediate v_sql;
    end loop;
    v_sql:='ALTER TABLE FORTS_REPAAR.P2_PROXY_LOG_BASE2016 MODIFY DEFAULT ATTRIBUTES FOR PARTITION '||v_partname||' NO INMEMORY ILM ADD POLICY COMPRESS FOR ARCHIVE HIGH SEGMENT AFTER 1 MONTHS OF CREATION';
    execute immediate v_sql;
    DBMS_STATS.GATHER_TABLE_STATS ('FORTS_REPAAR','P2_PROXY_LOG_BASE2016', v_partname, GRANULARITY => 'SUBPARTITION');
    dbms_output.put_line('finished with '||v_partname||' partition');
    commit;
  end loop;
  commit;
end;

select * from dba_segments where SEGMENT_NAME = 'P2_PROXY_LOG_BASE2016' order by PARTITION_NAME;

SELECT COUNT (1)
  FROM FORTS_REPAAR.P2_PROXY_LOG_BASE2016
       PARTITION (P2_PROXY_LOG_BASE_20150712);
       
select * from forts_repaar.errlog where proc like '%PR_VTD_263%' order by 1 desc;
       
select * from dba_tab_subpartitions where PARTITION_NAME = 'P2_PROXY_LOG_BASE_20150710' order by SUBPARTITION_NAME;
select * from dba_tab_subpartitions where PARTITION_NAME = 'P2_PROXY_LOG_BASE_20150713';
select * from dba_tab_subpartitions where PARTITION_NAME like 'P2_PROXY_LOG_BASE_201701%';
select * from dba_tab_partitions where PARTITION_NAME like 'P2_PROXY_LOG_BASE_%';
select * from dba_tab_partitions where PARTITION_NAME like 'P2_PROXY_ERROR_BASE_%';
select * from dba_tab_subpartitions where SUBPARTITION_NAME = 'SYS_SUBP42548';
select * from dba_tab_subpartitions where to_date(REGEXP_REPLACE(PARTITION_NAME,'P2_PROXY_LOG_BASE_',''),'YYYYMMDD')
between to_date('20161028','YYYYMMDD') and to_date('20161124','YYYYMMDD');
select * from dba_segments where SEGMENT_NAME = 'P2_PROXY_LOG_BASE2016' and PARTITION_NAME = 'SYS_SUBP42528';

SELECT COUNT (1),p2_reply_code,trunc(DATE_TIME)
  FROM FORTS_REPAAR.P2_PROXY_LOG_BASE2016
 WHERE DATE_TIME BETWEEN TO_DATE ('12.07.2015', 'DD.MM.YYYY')
                     AND TO_DATE (
                                TO_CHAR (
                                    TO_DATE ('12.07.2015', 'DD.MM.YYYY'),
                                    'MMDDYYYY')
                             || '235959',
                             'DDMMYYYYHH24MISS') group by p2_reply_code,trunc(DATE_TIME) order by 3 desc;
                             
  SELECT COUNT (1), P2_REPLY_CODE
    FROM FORTS_REPAAR.P2_PROXY_LOG_BASE2016
   WHERE DATE_TIME BETWEEN TO_DATE ('12.07.2015', 'DD.MM.YYYY')
                       AND TO_DATE (
                                  TO_CHAR (
                                      TO_DATE ('12.07.2015', 'DD.MM.YYYY'),
                                      'MMDDYYYY')
                               || '235959',
                               'DDMMYYYYHH24MISS')
GROUP BY P2_REPLY_CODE
ORDER BY 1 DESC; --2238882519

  SELECT COUNT (1) FROM FORTS_REPAAR.P2_PROXY_LOG_BASE2016;--7136477939
  
    SELECT count(1)
    FROM FORTS_REPAAR.P2_PROXY_LOG_BASE2016
   WHERE DATE_TIME BETWEEN TO_DATE ('12.08.2015', 'DD.MM.YYYY')
                       AND TO_DATE (
                                  TO_CHAR (
                                      TO_DATE ('12.08.2015', 'DD.MM.YYYY'),
                                      'MMDDYYYY')
                               || '235959',
                               'DDMMYYYYHH24MISS');
                               
    SELECT count(1)
    FROM FORTS_REPAAR.P2_PROXY_LOG_BASE2016
   WHERE DATE_TIME BETWEEN TO_DATE ('12.07.2015', 'DD.MM.YYYY') AND TO_DATE ('12.07.2015 23:59:59', 'DD.MM.YYYY HH24:MI:SS');
   
    SELECT *
    FROM FORTS_REPAAR.P2_PROXY_LOG_BASE2016
   WHERE DATE_TIME BETWEEN TO_DATE ('12.07.2015', 'DD.MM.YYYY') AND TO_DATE ('12.07.2015 23:59:59', 'DD.MM.YYYY HH24:MI:SS');
                             
SELECT COUNT (1),p2_reply_code,trunc(DATE_TIME)
  FROM FORTS_REPAAR.P2_PROXY_LOG_BASE2016
 WHERE DATE_TIME BETWEEN TO_DATE ('12.07.2015', 'DD.MM.YYYY')
                     AND TO_DATE ('12.07.2015 23:59:59', 'DD.MM.YYYY HH24:MI:SS') group by p2_reply_code,trunc(DATE_TIME) order by 3 desc;
                     
SELECT COUNT (1),p2_reply_code
  FROM FORTS_REPAAR.P2_PROXY_LOG_BASE2016
 WHERE DATE_TIME BETWEEN TO_DATE ('14.07.2015', 'DD.MM.YYYY')
                     AND TO_DATE ('14.07.2015 23:59:59', 'DD.MM.YYYY HH24:MI:SS') group by p2_reply_code order by 1;
                     
SELECT COUNT (1),p2_reply_code,trunc(DATE_TIME)
  FROM FORTS_REPAAR.P2_PROXY_LOG_BASE2016
 WHERE DATE_TIME BETWEEN TO_DATE ('13.07.2015', 'DD.MM.YYYY')
                     AND TO_DATE ('13.07.2015 23:59:59', 'DD.MM.YYYY HH24:MI:SS') group by p2_reply_code,trunc(DATE_TIME) order by p2_reply_code;
                     
SELECT COUNT (1),p2_reply_code,trunc(DATE_TIME)
  FROM FORTS_REPAAR.P2_PROXY_LOG_BASE2016
 WHERE DATE_TIME BETWEEN TO_DATE ('07.07.2015', 'DD.MM.YYYY')
                     AND TO_DATE ('07.07.2015 23:59:59', 'DD.MM.YYYY HH24:MI:SS') group by p2_reply_code,trunc(DATE_TIME) order by p2_reply_code;
                     
                     
                     
                     
                     
                                          
                     
                     
  SELECT COUNT (1), P2_REPLY_CODE, TRUNC (DATE_TIME)
    FROM FORTS_REPAAR.P2_PROXY_LOG_BASE2016
   WHERE     DATE_TIME >= TRUNC (TO_DATE ('14.07.2015', 'DD.MM.YYYY'))
         AND DATE_TIME < TRUNC (TO_DATE ('14.07.2015', 'DD.MM.YYYY') + 1)
GROUP BY P2_REPLY_CODE, TRUNC (DATE_TIME)
ORDER BY 3 DESC;

-- modify PROCEDURE MANUAL_STATISTICS_GATHER

  SELECT H.OWNER,
         H.OBJECT_NAME,
         H.SUBOBJECT_NAME,
         H.TRACK_TIME,
         S.STALE_STATS,
         S.STATTYPE_LOCKED,
         S.LAST_ANALYZED
    FROM DBA_HEAT_MAP_SEG_HISTOGRAM H, DBA_TAB_STATISTICS S
   WHERE     (H.OWNER, H.OBJECT_NAME) IN (     SELECT OBJECT_OWNER, OBJECT_NAME
                                                 FROM MANUAL_STATISTICS
                                             ORDER BY LAST_COLLECTION_TIME DESC
                                          FETCH FIRST 5 ROWS ONLY)
         AND H.SEGMENT_WRITE = 'YES'
         AND H.TRACK_TIME <= ADD_MONTHS (SYSDATE, -6)
         AND H.OWNER = S.OWNER
         AND H.OBJECT_NAME = S.TABLE_NAME
         AND H.SUBOBJECT_NAME = S.PARTITION_NAME
         AND (S.STATTYPE_LOCKED IS NULL OR S.STATTYPE_LOCKED <> 'ALL')
         AND STALE_STATS <> 'YES'
ORDER BY H.OWNER, H.OBJECT_NAME, H.TRACK_TIME;

  SELECT 'DBMS_STATS.LOCK_PARTITION_STATS(ownname=>'''||H.OWNER||''',tabname=>'''||H.OBJECT_NAME||''',partname=>'''||H.SUBOBJECT_NAME||''')'
    FROM DBA_HEAT_MAP_SEG_HISTOGRAM H, DBA_TAB_STATISTICS S
   WHERE     (H.OWNER, H.OBJECT_NAME) IN (     SELECT OBJECT_OWNER, OBJECT_NAME
                                                 FROM MANUAL_STATISTICS
                                             ORDER BY LAST_COLLECTION_TIME DESC
                                          FETCH FIRST 5 ROWS ONLY)
         AND H.SEGMENT_WRITE = 'YES'
         AND H.TRACK_TIME <= ADD_MONTHS (SYSDATE, -6)
         AND H.OWNER = S.OWNER
         AND H.OBJECT_NAME = S.TABLE_NAME
         AND H.SUBOBJECT_NAME = S.PARTITION_NAME
         AND (S.STATTYPE_LOCKED IS NULL OR S.STATTYPE_LOCKED <> 'ALL')
         AND STALE_STATS <> 'YES'
ORDER BY H.OWNER, H.OBJECT_NAME, H.TRACK_TIME;


SELECT *
  FROM DBA_TAB_STATISTICS
 WHERE     TABLE_NAME = 'ORDLOG_BASE'
       AND OWNER = 'EQ'
       AND (STALE_STATS <> 'NO' OR STALE_STATS IS NULL);

  SELECT 'DBMS_STATS.UNLOCK_PARTITION_STATS(ownname=>'''||OWNER||''',tabname=>'''||TABLE_NAME||''',partname=>'''||PARTITION_NAME||''')'
    FROM DBA_TAB_STATISTICS
   WHERE     STATTYPE_LOCKED = 'ALL'
         AND STALE_STATS = 'YES'
         AND (OWNER, TABLE_NAME) IN (     SELECT OBJECT_OWNER, OBJECT_NAME
                                            FROM MANUAL_STATISTICS
                                        ORDER BY LAST_COLLECTION_TIME DESC
                                     FETCH FIRST 5 ROWS ONLY)
ORDER BY OWNER,TABLE_NAME,PARTITION_NAME FETCH FIRST 100 ROWS ONLY;

select * from HEAT_MAP_MANUAL h,DBA_TAB_STATISTICS S where 
H.OWNER = S.OWNER
AND H.OBJECT_NAME = S.TABLE_NAME
AND H.SUBOBJECT_NAME = S.PARTITION_NAME
AND (S.STATTYPE_LOCKED IS NULL OR S.STATTYPE_LOCKED <> 'ALL');

                                   
SELECT * FROM DBA_TAB_STATISTICS WHERE STATTYPE_LOCKED IS NULL OR STATTYPE_LOCKED <> 'ALL';
                                   
SELECT OBJECT_OWNER,OBJECT_NAME FROM MANUAL_STATISTICS ORDER BY LAST_COLLECTION_TIME DESC FETCH FIRST 5 ROWS ONLY;

select * from errlog order by 1 desc;

-- manual ILM for tables with FLASHBACK 

SELECT * FROM DBA_HEAT_MAP_SEG_HISTOGRAM WHERE OBJECT_NAME = 'DEAL_BASE' AND SEGMENT_WRITE <> 'NO' ORDER BY 4;

SELECT SUBOBJECT_NAME,TO_NUMBER(REGEXP_REPLACE(SUBOBJECT_NAME,'[A-Z,_]',''))-60 AS PART_NUM
  FROM DBA_HEAT_MAP_SEG_HISTOGRAM
 WHERE     OBJECT_NAME = 'DEAL_BASE'
       AND SEGMENT_WRITE = 'YES'
       AND TRACK_TIME =
              (  SELECT MAX (TRACK_TIME)
                   FROM DBA_HEAT_MAP_SEG_HISTOGRAM
                  WHERE OBJECT_NAME = 'DEAL_BASE' AND SEGMENT_WRITE = 'YES'
               GROUP BY OBJECT_NAME);

SELECT OWNER,OBJECT_NAME,SUBOBJECT_NAME,TRACK_TIME
    FROM DBA_HEAT_MAP_SEG_HISTOGRAM
   WHERE     OBJECT_NAME = 'DEAL_BASE'
         AND OWNER = 'FORTS_CLEARING'
         AND SEGMENT_WRITE = 'YES'
         AND OBJECT_NAME || SUBOBJECT_NAME IN
                 (SELECT D.SEGMENT_NAME || D.PARTITION_NAME
                    FROM DBA_SEGMENTS D, ALL_TAB_PARTITIONS P
                   WHERE     D.PARTITION_NAME = P.PARTITION_NAME
                         AND D.SEGMENT_NAME = P.TABLE_NAME
                         AND D.SEGMENT_NAME = 'DEAL_BASE'
                         AND D.BLOCKS >= 1024 * 3)
ORDER BY 4 DESC;

SELECT H.OWNER,H.OBJECT_NAME,H.SUBOBJECT_NAME,H.TRACK_TIME,D.BYTES,D.EXTENTS
    FROM DBA_HEAT_MAP_SEG_HISTOGRAM H,DBA_SEGMENTS D
   WHERE     H.OBJECT_NAME = 'DEAL_BASE'
         AND H.OWNER = 'FORTS_CLEARING'
         AND H.SEGMENT_WRITE = 'YES'
         AND D.SEGMENT_NAME = H.OBJECT_NAME
         AND D.OWNER = H.OWNER
         AND D.PARTITION_NAME = H.SUBOBJECT_NAME
         AND H.OBJECT_NAME || SUBOBJECT_NAME IN
                 (SELECT D.SEGMENT_NAME || D.PARTITION_NAME
                    FROM DBA_SEGMENTS D, ALL_TAB_PARTITIONS P
                   WHERE     D.PARTITION_NAME = P.PARTITION_NAME
                         AND D.SEGMENT_NAME = P.TABLE_NAME
                         AND D.SEGMENT_NAME = 'DEAL_BASE'
                         AND D.BLOCKS >= 1024 * 3)
ORDER BY 4 DESC;

INSERT INTO HEAT_MAP_MANUAL SELECT OWNER,OBJECT_NAME,SUBOBJECT_NAME,TRACK_TIME
    FROM DBA_HEAT_MAP_SEG_HISTOGRAM
   WHERE     OBJECT_NAME = 'DEAL_BASE'
         AND OWNER = 'FORTS_CLEARING'
         AND SEGMENT_WRITE = 'YES'
         AND OBJECT_NAME || SUBOBJECT_NAME IN
                 (SELECT D.SEGMENT_NAME || D.PARTITION_NAME
                    FROM DBA_SEGMENTS D, ALL_TAB_PARTITIONS P
                   WHERE     D.PARTITION_NAME = P.PARTITION_NAME
                         AND D.SEGMENT_NAME = P.TABLE_NAME
                         AND D.SEGMENT_NAME = 'DEAL_BASE'
                         AND D.BLOCKS >= 1024 * 3)
ORDER BY 4 DESC;
 
  SELECT OWNER,
         OBJECT_NAME,
         SUBOBJECT_NAME,
         MAX (TRACK_TIME) MAX_WRITE_TIME
    FROM HEAT_MAP_MANUAL
GROUP BY OWNER, OBJECT_NAME, SUBOBJECT_NAME
  HAVING MAX (TRACK_TIME) BETWEEN ADD_MONTHS (SYSDATE, -1) -14 AND ADD_MONTHS (SYSDATE, -1)
ORDER BY TO_NUMBER(REGEXP_REPLACE(SUBOBJECT_NAME,'[A-Z,_]','')) DESC;

  SELECT 'alter table '||OWNER||'.'||OBJECT_NAME||' move partition '||SUBOBJECT_NAME||' colunm store compress for archive high'
    FROM HEAT_MAP_MANUAL
GROUP BY OWNER, OBJECT_NAME, SUBOBJECT_NAME
  HAVING MAX (TRACK_TIME) < ADD_MONTHS (SYSDATE, -1)
ORDER BY TO_NUMBER(REGEXP_REPLACE(SUBOBJECT_NAME,'[A-Z,_]','')) DESC;

select max(SYST_ID) from forts_clearing.deal_base;
               
select * from forts_clearing.deal_base partition(DEAL_BASE_4563);
select count(*) from forts_clearing.deal_base partition(DEAL_BASE_4563); --839062  --234881024B
select * from forts_clearing.deal_base partition(DEAL_BASE_4478);
select count(*) from forts_clearing.deal_base partition(DEAL_BASE_4478); --1231438 --59768832B

select p.PARTITION_NAME,round(p.NUM_ROWS/nullif(p.BLOCKS,0)) rows_per_blk,round(d.BYTES/1024/1024) MB,d.EXTENTS from dba_segments d,all_tab_partitions p where d.PARTITION_NAME = p.PARTITION_NAME and d.SEGMENT_NAME = p.TABLE_NAME and d.SEGMENT_NAME = 'DEAL_BASE' and d.BLOCKS >= 1024*3 order by to_number(regexp_replace(d.PARTITION_NAME,'[A-Z,_]','')) ;

  SELECT DISTINCT P.PARTITION_NAME,
                  ROUND (P.NUM_ROWS / NULLIF (P.BLOCKS, 0)) ROWS_PER_BLK,
                  ROUND (D.BYTES / 1024 / 1024)           MB,
                  D.EXTENTS,
                  ROUND(ROUND (D.BYTES / 1024 / 1024)/D.EXTENTS) AVG_MB_PER_EXTENT
    FROM DBA_SEGMENTS D, ALL_TAB_PARTITIONS P, HEAT_MAP_MANUAL H
   WHERE     H.OWNER = D.OWNER
         AND H.OBJECT_NAME = P.TABLE_NAME
         AND H.SUBOBJECT_NAME = D.PARTITION_NAME
         AND D.PARTITION_NAME = P.PARTITION_NAME
         AND D.OWNER = P.TABLE_OWNER
         AND D.SEGMENT_NAME = P.TABLE_NAME
         AND ROUND(ROUND (D.BYTES / 1024 / 1024)/D.EXTENTS) < 8
         AND ROUND (P.NUM_ROWS / NULLIF (P.BLOCKS, 0)) <
                 (SELECT AVG (ROWS_PER_BLK) / 2
                    FROM (SELECT DISTINCT
                                 P.PARTITION_NAME,
                                 ROUND (P.NUM_ROWS / NULLIF (P.BLOCKS, 0))
                                     ROWS_PER_BLK,
                                 ROUND (D.BYTES / 1024 / 1024) MB,
                                 D.EXTENTS
                            FROM DBA_SEGMENTS      D,
                                 ALL_TAB_PARTITIONS P,
                                 HEAT_MAP_MANUAL   H
                           WHERE     H.OWNER = D.OWNER
                                 AND H.OBJECT_NAME = P.TABLE_NAME
                                 AND H.SUBOBJECT_NAME = D.PARTITION_NAME
                                 AND D.PARTITION_NAME = P.PARTITION_NAME
                                 AND D.OWNER = P.TABLE_OWNER
                                 AND D.SEGMENT_NAME = P.TABLE_NAME))
        AND NOT EXISTS (SELECT * FROM ERRLOG WHERE proc like '%'||'ILM_MANUAL'||'%' and MSG LIKE '%'||P.PARTITION_NAME||'%')
ORDER BY 3 DESC FETCH FIRST 10 ROWS ONLY;
       
select * from HEAT_MAP_MANUAL;




select d.OWNER,d.SEGMENT_NAME,d.PARTITION_NAME,d.BYTES,p.COMPRESS_FOR from dba_segments d,all_tab_partitions p where d.PARTITION_NAME = p.PARTITION_NAME and d.SEGMENT_NAME = p.TABLE_NAME and d.SEGMENT_NAME = 'DEAL_BASE' and d.PARTITION_NAME in ('DEAL_BASE_2676','DEAL_BASE_2774');

select * from dba_objects where object_name =  'DEAL_BASE' order by to_number(regexp_replace(SUBOBJECT_NAME,'[A-Z,_]','')) ;

alter table FORTS_CLEARING.DEAL_BASE move partition	DEAL_BASE_4543 ONLINE COLUMN STORE COMPRESS FOR ARCHIVE HIGH UPDATE INDEXES;

-- cash base flashback question

Select * from curr.errlog where proc like 'CASH_UPDBASE%' order by 1 desc;
Select * from eq.errlog where proc like 'CASH_UPDBASE%' order by 1 desc;

select * from curr.cash_base /*as of timestamp sysdate - 1*/ where TODAYDATE = trunc(sysdate - 61) --and L_ID = 276369023 ;

select distinct(trunc(UPDATEDT)),count(*) from curr.cash_base group by trunc(UPDATEDT) order by 1;
select count(*) from curr.cash_base; --27580480

select min(TODAYDATE) from curr.cash_base;

select OWNER,SEGMENT_NAME,round(bytes/1024/1024/1024,2) GB from dba_segments where segment_name = 'CASH_BASE';

-- modify historical partitions for tables with FLASHBACK and HCC

exec DBMS_FLASHBACK_ARCHIVE.disassociate_fba(owner_name=>'FORTS_CLEARING',table_name=>'DEAL_BASE');
Alter table FORTS_CLEARING.DEAL_BASE move partition DEAL_BASE_1 row store compress basic update indexes online ;
exec DBMS_FLASHBACK_ARCHIVE.reassociate_fba(owner_name=>'FORTS_CLEARING',table_name=>'DEAL_BASE');

exec DBMS_FLASHBACK_ARCHIVE.disassociate_fba(owner_name=>'EQ',table_name=>'CASH_BASE');

select * from DBA_FLASHBACK_ARCHIVE_TABLES ORDER BY 2,1;

ALTER TABLE "EQ"."SYS_FBA_HIST_424490" ADD ("CLEARINGBANKACCID" VARCHAR2(12));
ALTER TABLE "EQ"."SYS_FBA_HIST_424490" ADD ("CLEARINGFIRMID" VARCHAR2(12));

exec DBMS_FLASHBACK_ARCHIVE.reassociate_fba(owner_name=>'EQ',table_name=>'CASH_BASE');

-- NOT PARTITIONED INDEXES ON BIG (>1GB) PARTITIONED TABLES

SELECT * FROM DBA_INDEXES WHERE PARTITIONED = 'NO' AND TABLE_OWNER||TABLE_NAME IN
(SELECT OWNER||SEGMENT_NAME
    FROM DBA_SEGMENTS
   WHERE SEGMENT_TYPE IN ('TABLE PARTITION')
   AND SEGMENT_NAME NOT LIKE 'SYS_FBA_HIST_%'
   AND OWNER <> 'SYS'
GROUP BY OWNER, SEGMENT_NAME
  HAVING ROUND (SUM (BYTES) / 1024 / 1024 / 1024, 0) > 1
) ORDER BY 1,2;

-- views in INTERNAL* schemas for tables in list

select * from all_dependencies where REFERENCED_NAME in ('FUT_ORDERS_BASE','SESSION_BASE') and OWNER LIKE 'INTERNAL%';

select * from all_objects where object_name = 'SVN_OBJ_IMPLEMENTATION';

--alter table FORTS_REPAAR.P2_PROXY_LOG_BASE2016_TEST move;

select max(sess_date) from MARKET_JOIN.LKC_ORDER;

select * from FORTS_REPAAR.P2_PROXY_LOG_BASE where DATE_TIME_MSEC > 999;
select min(DATE_TIME) from FORTS_REPAAR.P2_PROXY_LOG_BASE;

select * from FORTS_REPAAR.P2_PROXY_LOG_BASE2016_TEST where P2_REPLY_CODE is null;
select * from FORTS_REPAAR.P2_PROXY_LOG_BASE2016_TEST where RAW_ORDER_ID = '20160111115352961_fgc0cm_bc14357_0x80007c9cdd4c9f3c';

create table forts_repaar.P2_PROXY_LOG_BASE2016_test tablespace P2_PROXY_LOG_2015 as select * from forts_repaar.P2_PROXY_LOG_BASE2016;
create table forts_repaar.P2_PROXY_ERROR_BASE2016_test tablespace P2_PROXY_LOG_2015 as select * from forts_repaar.P2_PROXY_ERROR_BASE2016;
SELECT * FROM DBA_AUDIT_TRAIL WHERE OBJ_NAME LIKE '%ASSETS%';
SELECT * FROM DBA_PRIV_AUDIT_OPTS WHERE PRIVILEGE = 'ALTER ANY TABLE';

SELECT MAX(REPLREV)  FROM FUT_ORDERS_LOG  WHERE updatedt >= (SELECT MAX(updatedt) FROM FUT_ORDERS_LOG)  ;

select * from v$sql where UPPER(SQL_TEXT) like '%FORTS_JAVA_LM.FUT_ORDERS_LOG%';

select * from DBA_HIST_ACTIVE_SESS_HISTORY where sql_id  = 'am3u72a1357bk'; 

select * from dba_users where user_id = 124;

select * from DBA_HIST_SQLTEXT where sql_id  = 'am3u72a1357bk'; 

select * from DBA_HIST_ASM_BAD_DISK order by SNAP_ID;

select distinct(trunc(DATE_TIME)) from FORTS_REPAAR.P2_PROXY_LOG_LM;
select distinct(trunc(DATETIME)) from FORTS_CLEARING.DEAL_LM;

select * from INTERNALREP.V_FORTS_FUTURES_PARAMS_TOD;

select * FROM forts_java_lm.FUTURES_PARAMS;

select * from v$session where sid in (1111,334); 

select * from dba_segments where segment_name = 'DEAL_BASE' and partition_name like '%4486';
SELECT SEGMENT_NAME,SEGMENT_TYPE,ROUND(BYTES/1024/1024/1024,3) GB,INMEMORY,TABLESPACE_NAME FROM DBA_SEGMENTS WHERE SEGMENT_NAME LIKE 'P2_PROXY_%_BASE%' ORDER BY 3 DESC;

-- market JOIN

select market_code,max(sess_date) from MARKET_JOIN.lkc_order where MARKET_CODE = 'FO' group by market_code;
select market_code,max(sess_date) from MARKET_JOIN.lkc_order where MARKET_CODE = 'SE' group by market_code;
select max(sess_date) from MARKET_JOIN.lkc_order where MARKET_CODE = 'CU';
select count(MARKET_CODE) from MARKET_JOIN.lkc_order where MARKET_CODE = 'FO' and SESS_DATE = sysdate - 6;
select count(1),MARKET_CODE from MARKET_JOIN.lkc_order where SESS_DATE between trunc(sysdate-6) and trunc(sysdate-5) group by MARKET_CODE;
select * from MARKET_JOIN.lkc_order where SESS_DATE between trunc(sysdate-8) and trunc(sysdate-5) and ORDER_NO = 16390872357;
select count(1) from MARKET_JOIN.lkc_order where SESS_DATE between trunc(sysdate-30) and trunc(sysdate) and FIRMID = 'MB0189400000';
select count(1) from MARKET_JOIN.lkc_order where SESS_DATE between trunc(sysdate-30) and trunc(sysdate) and MARKET_CODE = 'FO' and DIRECTION = 'B';
select count(1) from MARKET_JOIN.lkc_order where SESS_DATE between trunc(sysdate-30) and trunc(sysdate) and DIRECTION = 'B' and INSTR_CODE = 'SU46014RMFS5';

--alter table FORTS_CLEARING.DEAL_BASE move partition DEAL_BASE_4486 row store compress advanced update indexes --online ;
select * from FORTS_CLEARING.DEAL_BASE partition(DEAL_BASE_4486);
select * from dba_segments where segment_name = 'DEAL_LM';
select SYST_ID,count(1) from FORTS_CLEARING.DEAL_LM group by SYST_ID;

select * from dba_indexes where index_name = 'PLEDGE_ACCOUNT_BASE_PKLDI'; 
select * from all_objects  where object_name = 'PLEDGE_ACCOUNT_BASE_PKLDI';

SELECT *
  FROM ALL_INDEXES
 WHERE     INDEX_NAME||OWNER NOT IN (SELECT DISTINCT INDEX_NAME||INDEX_OWNER
                                FROM DBA_IND_PARTITIONS
                               WHERE INDEX_OWNER NOT LIKE 'SYS%')
       AND 
       TABLE_NAME||TABLE_OWNER IN (SELECT DISTINCT TABLE_NAME||TABLE_OWNER
                            FROM DBA_TAB_PARTITIONS
                           WHERE TABLE_OWNER NOT LIKE 'SYS%')
       AND OWNER NOT LIKE 'SYS%' ORDER BY 1 DESC,2,3;
       
exec DBMS_STATS.LOCK_PARTITION_STATS(ownname=>'CBMIRROR',tabname=>'TRADES_BASE',partname=>'EQ_TRADES_BASE_P_20051107');

select * from all_objects where object_name = upper('curr_cl');

select min(DATE_TIME),max(DATE_TIME) from FORTS_REPAAR.P2_PROXY_LOG_BASE;
select count(1),to_char(trunc(DATE_TIME)) from FORTS_REPAAR.P2_PROXY_LOG_LM group by trunc(DATE_TIME)
union all
select count(1),'all_rows' from FORTS_REPAAR.P2_PROXY_LOG_LM order by 2;
select count(1) from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 partition(P2_PROXY_LOG_BASE_20160112);
select distinct trunc(DATE_TIME) from FORTS_REPAAR.P2_PROXY_LOG_BASE2016
--partition(P2_PROXY_LOG_BASE_20160112) 
subpartition(SYS_SUBP42234);
select count(1) from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 subpartition(SYS_SUBP42234); --44084552
select distinct P2_REPLY_CODE from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 partition(P2_PROXY_LOG_BASE_20160121) order by 1;
select P2_REPLY_CODE, count(1) from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 subpartition(SYS_SUBP42234) group by P2_REPLY_CODE order by 2 desc;
select P2_LOGIN, count(1) from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 subpartition(SYS_SUBP42234) group by P2_LOGIN order by 2 desc;
select count(1) from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 subpartition(SYS_SUBP42219);
select * from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 subpartition(SYS_SUBP42224);
select * from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 partition(P2_PROXY_LOG_BASE_20160121);
select count(1) from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 where P2_REPLY_CODE = 332 and DATE_TIME >= to_date('20160121','yyyymmdd') and DATE_TIME < to_date('20160122','yyyymmdd') ;
select count(1) from FORTS_REPAAR.P2_PROXY_ERROR_BASE2016;
select count(1),trunc(DATE_TIME),P2_REPLY_CODE from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 group by trunc(DATE_TIME),P2_REPLY_CODE order by 1 desc;-- and DATE_TIME >= to_date('20160121','yyyymmdd') and DATE_TIME < to_date('20160122','yyyymmdd');
select * from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 where P2_REPLY_CODE = 2;
select * from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 where DATE_TIME >= to_date('20160121','yyyymmdd') and DATE_TIME < to_date('20160122','yyyymmdd') and NUMB_ORDER = 19128589923;
select * from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 where DATE_TIME >= to_date('20160121','yyyymmdd') and DATE_TIME < to_date('20160122','yyyymmdd') and P2_LOGIN = 'fgr0bm_q';
select * from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 where DATE_TIME >= to_date('20160121','yyyymmdd') and DATE_TIME < to_date('20160122','yyyymmdd') and seq_id = 4536370;
select * from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 where NUMB_ORDER = 19128589923;
select * from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 where RAW_ORDER_ID = '20160121100005585_fgr0bm_q_0x8000001a96d89bf1';
select * from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 where RAW_ORDER_ID = '20160121100025140_fg76ct_rl4_0x800003943b49e305' and P2_REPLY_CODE = 0;
select * from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 where RAW_ORDER_ID = '20160113102541986_fgc0rm_c0itin_0x80003e5008a67d84' and P2_REPLY_CODE = 2; 
select * from FORTS_REPAAR.P2_PROXY_LOG_BASE2016_TEST
minus
select * from FORTS_REPAAR.P2_PROXY_LOG_BASE2016 where DATE_TIME >= to_date('20160226','yyyymmdd') and DATE_TIME < to_date('20160227','yyyymmdd') or (DATE_TIME >= to_date('20160629','yyyymmdd') and DATE_TIME < to_date('20160630','yyyymmdd'));
--insert into FORTS_REPAAR.P2_PROXY_LOG_BASE2016 select * from FORTS_REPAAR.P2_PROXY_LOG_BASE2016_TEST;
select min(date_time),max(date_time) from FORTS_REPAAR.P2_PROXY_ERROR_BASE
union all
select min(date_time),max(date_time) from FORTS_REPAAR.P2_PROXY_ERROR_BASE2016;

select min(date_time),max(date_time) from FORTS_REPAAR.P2_PROXY_LOG_BASE2016
union all
select min(date_time),max(date_time) from FORTS_REPAAR.P2_PROXY_ERROR_BASE2016;
