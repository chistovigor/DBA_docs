-- подозрительные запросы от мониторинга (быстрый и медленный с одинаковыми планами)

select * from COMPARE_ARDB.V_MBT3 where DAY = trunc(sysdate) and CODE = 'С99_CUT' and substr(R1,0,2) <>  'Ok' and (substr(NEW_R1,0,2) <> 'Ok' or NEW_R1 is null); --fast - <1 sec
select * from COMPARE_ARDB.V_MBT3 where DAY = trunc(sysdate) and CODE = 'A99_CUT' and substr(R1,0,2) <>  'Ok' and (substr(NEW_R1,0,2) <> 'Ok' or NEW_R1 is null); --7 sec
--select * from COMPARE_ARDB.V_MBT6 where DAY = trunc(sysdate) and CODE = 'A99_CUT' and substr(R1,0,2) <>  'Ok' and (substr(NEW_R1,0,2) <> 'Ok' or NEW_R1 is null); --7 sec
select * from COMPARE_ARDB.V_MBT3 where DAY = trunc(sysdate) and CODE = 'A99_EQT' and substr(R1,0,2) <>  'Ok' and (substr(NEW_R1,0,2) <> 'Ok' or NEW_R1 is null); --slow (not executed during 1 min)

--VIEW V__ARDBLINK3
--FUNCTION COMPARE_ARDB._GET_LOG_INFO (remove commit; and  from function _GET_LOG_INFO)

select * from COMPARE_ARDB.V__ARDBLINK3_6;

select    CODE,count(1) from               
(SELECT a.RUN_ID,
                             a.ORDER_NUM,
                             r.CODE,
                             a.R1,
                             A.UPDATEDT,
                             r.parameters,
                             a.IN_PREDICATE1,
                             a.TABLE_NAME,
                             MAX (NVL (r2.UPDATEDT, a.UPDATEDT))
                                 AS LAST_UPDATEDT
                        FROM compare_ardb.CHECK_TABLES_LOG a
                             INNER JOIN compare_ardb.CHECK_RUN_LOG r ON r.run_id = a.run_id
                             LEFT JOIN compare_ardb.CHECK_RUN_LOG r2
                                 ON r2.code =
                                       TO_CHAR (a.run_id)
                                    || '.'
                                    || TO_CHAR (a.order_num)
                       WHERE     r.CODE NOT IN ('x', 'TABLES')
                             AND r.CODE NOT LIKE '%.%'
                    GROUP BY a.RUN_ID,
                             a.ORDER_NUM,
                             r.CODE,
                             a.R1,
                             A.UPDATEDT,
                             R.parameters,
                             a.IN_PREDICATE1,
                             a.TABLE_NAME) group by code order by 2 desc;
                             
declare
l_RV varchar2(4000) := '';
p_CODE varchar2(10) DEFAULT 'A99_CUT';
p_updatedt date default sysdate;
p_count number default 6049; --столько кодов в таблицах CHECK_RUN_LOG и CHECK_TABLES_LOG
begin
for i in 1..p_count loop  
   select
    (
    select to_char(insertdt,COMPARE_ARDB."_GET_DATE_FORMAT"(insertdt, p_updatedt))
           ||'..'||
           case when instr(parameters,'RUN}')>0 then '.' else to_char(updatedt,COMPARE_ARDB."_GET_DATE_FORMAT"(updatedt, insertdt)) end
           ||' ('||
           to_char(to_number_x(substr(parameters,instr(parameters,'<',-1)+1,length(parameters)-instr(parameters,'<',-1)-1)))
           ||')'
      from CHECK_RUN_LOG@CBVIEWP r
	 where code = p_CODE
       and parameters like '{CORRECT%'
       and insertdt in (select max(insertdt) from CHECK_RUN_LOG@CBVIEWP r1 where r1.code=r.code and r1.parameters like '{CORRECT%')
     ) into l_RV from dual;
   -- commit;
end loop;
end;

--

ALTER SESSION SET NLS_DATE_FORMAT = 'dd.mm.yyyy';

-- вопрос Хафизова

SELECT /*+ FULL PARALLEL */ * FROM internalrep.v_cu_cln_ord_count WHERE REPDATE = TO_DATE('14.10.2016','DD.MM.YYYY') AND lower(name) like '%риком%';

  SELECT EVDATE2D
  FROM spur.V_M_TRADES_DAY_CALENDAR
  WHERE EVDATE = TO_DATE('14.10.2016','DD.MM.YYYY') ;
  
      SELECT ENTRYDATE,
      COUNT(1) AS ORDCOUNT,CLIENTCODEID
    FROM CURR.V_ORDERS_BASE 
    WHERE ENTRYDATE BETWEEN TO_DATE('12.10.2016','DD.MM.YYYY') AND TO_DATE('14.10.2016','DD.MM.YYYY')
    AND CLIENTCODEID in (select CLIENTCODEID from internaldm.v_curr_clientcodes where FIRMID = 'MB0088200000')
    GROUP BY ENTRYDATE,CLIENTCODEID ;
    
select * from internaldm.v_curr_firms where lower(name) like '%риком%';
select * from internaldm.v_curr_clientcodes where FIRMID = 'MB0088200000';
select * from TABLE (spur.tf_clnordcount (TO_DATE('14.10.2016','DD.MM.YYYY'), 1272363, 'CU')) ;

--ORA-27603: Cell storage I/O error

SELECT "ID","ST_ACTUAL","UPDATEDT","REPLID","REPLREV","REPLACT","ID_DEAL","SESS_ID","ISIN_ID","PRICE","AMOUNT","MOMENT","CODE_SELL","CODE_BUY","ID_ORD_SELL","EXT_ID_SELL","COMMENT_SELL","TRUST_SELL","STATUS_SELL","ID_ORD_BUY","EXT_ID_BUY","COMMENT_BUY","TRUST_BUY","STATUS_BUY","POS","NOSYSTEM","ID_REPO","HEDGE_SELL","HEDGE_BUY","FEE_SELL","FEE_BUY","LOGIN_SELL","LOGIN_BUY","CODE_RTS_SELL","CODE_RTS_BUY","ID_DEAL_MULTILEG","XSTATUS_SELL","XSTATUS_BUY" FROM "FORTS_JAVA"."FUTDEAL_BASE" "FUTDEAL_BASE" WHERE "UPDATEDT"=TO_DATE(' 2016-12-22 00:07:59', 'syyyy-mm-dd hh24:mi:ss') AND "SESS_ID"=5183;

-- Jira DWH-92: http://jira.moex.com/browse/DWH-92

SELECT MARKET_CODE,MAX(SESS_DATE) AS MAX_SESS_DATE FROM MARKET_JOIN.LKC_ORDER WHERE SESS_DATE > SYSDATE -10 GROUP BY MARKET_CODE ;
SELECT MARKET_CODE,MAX(SESS_DATE) AS MAX_SESS_DATE FROM MARKET_JOIN.LKC_ORDER GROUP BY MARKET_CODE ;

select max(SESS_DATE) from MARKET_JOIN.LKC_ORDER where MARKET_CODE = 'FO';
select max(SESS_DATE) from MARKET_JOIN.LKC_ORDER where MARKET_CODE = 'SE';
select max(SESS_DATE) from MARKET_JOIN.LKC_ORDER where MARKET_CODE = 'BL';
select max(SESS_DATE) from MARKET_JOIN.LKC_ORDER where MARKET_CODE = 'CU';

--G_BORISOVAGV --problem SQL

WITH sess AS
(
  SELECT * FROM internaldm.v_forts_session
  WHERE end BETWEEN TO_DATE('08.12.2016', 'DD.MM.YYYY') AND TO_DATE('09.12.2016', 'DD.MM.YYYY')+1 
  OR begin BETWEEN TO_DATE('08.12.2016', 'DD.MM.YYYY') AND TO_DATE('09.12.2016', 'DD.MM.YYYY')+1
)
, buy AS (
  SELECT distinct INV.CLIENT_CODE, INV.INN, TR.SESS_ID FROM internaldm.v_forts_investr INV
  LEFT JOIN internaldm.v_forts_trades_fu TR ON TR.CODE_BUY = INV.CLIENT_CODE
  where TR.sess_id = sess.sess_id 
  AND TR.CODE_BUY NOT LIKE 'Z700000'
  --)
  ),
sell AS
( 
  SELECT distinct INV.CLIENT_CODE, INV.INN, TR.SESS_ID FROM internaldm.v_forts_investr INV
  LEFT JOIN internaldm.v_forts_trades_fu TR ON TR.CODE_SELL = INV.CLIENT_CODE
  LEFT JOIN SESS ON TR.sess_id = SESS.sess_id
 where TR.sess_id = sess.sess_id 
 AND TR.CODE_SELL NOT LIKE 'Z700000'
)
,
rts_buy AS
( SELECT distinct FIR.CLIENT_CODE, FIR.NAME, FIR.RTS_CODE, TR.SESS_ID FROM internaldm.v_forts_firms FIR
 LEFT JOIN internaldm.v_forts_trades_fu TR ON TR.CODE_RTS_BUY = FIR.RTS_CODE
 LEFT JOIN SESS ON TR.sess_id = SESS.sess_id
where TR.sess_id = sess.sess_id
),
rts_sell AS
( SELECT distinct FIR.CLIENT_CODE, FIR.NAME, FIR.RTS_CODE, TR.SESS_ID FROM internaldm.v_forts_firms FIR
LEFT JOIN internaldm.v_forts_trades_fu TR ON TR.CODE_RTS_SELL = FIR.RTS_CODE
LEFT JOIN SESS ON TR.sess_id = SESS.sess_id
where TR.sess_id = sess.sess_id
),
instr AS
(
SELECT distinct FU.ISIN_ID, FU.NAME, TR.SESS_ID  FROM internaldm.V_FORTS_INSTRUMENTS_FU FU
LEFT JOIN internaldm.v_forts_trades_fu TR ON TR.ISIN_ID = FU.ISIN_ID
LEFT JOIN SESS ON TR.sess_id = SESS.sess_id
where TR.sess_id = sess.sess_id
)
SELECT TR.MOMENT, TR.ID_DEAL, TR.ID_ORD_BUY, TR.ID_ORD_SELL, TR.ISIN_ID, INSTR.NAME, TR.PRICE*AMOUNT, TR.CODE_BUY, RTS_BUY.NAME as NAME_BUY, RTS_SELL.NAME as NAME_SELL, BUY.INN as INN_BUY, TR.CODE_SELL, SELL.INN as INN_SELL, TR.CODE_RTS_SELL, TR.CODE_RTS_BUY 
FROM internaldm.v_forts_trades_fu TR
LEFT JOIN BUY ON (TR.CODE_BUY = BUY.CLIENT_CODE AND TR.sess_id = BUY.sess_id)
LEFT JOIN SELL ON (TR.CODE_SELL = SELL.CLIENT_CODE AND TR.sess_id = SELL.sess_id) 
LEFT JOIN RTS_BUY ON (TR.CODE_RTS_BUY = RTS_BUY.RTS_CODE AND TR.sess_id = RTS_BUY.sess_id) 
LEFT JOIN RTS_SELL ON (TR.CODE_RTS_SELL = RTS_SELL.RTS_CODE AND TR.sess_id = RTS_BUY.sess_id) 
LEFT JOIN INSTR ON (TR.ISIN_ID = INSTR.ISIN_ID AND TR.sess_id = INSTR.sess_id) 
LEFT JOIN SESS ON TR.sess_id = SESS.sess_id
LEFT JOIN internaldm.v_forts_clr_positions_fu POSITIONS ON ((TR.CODE_BUY = POSITIONS.CLIENT_CODE OR TR.CODE_SELL = POSITIONS.CLIENT_CODE) AND TR.sess_id = POSITIONS.sess_id)
WHERE 
BUY.INN = SELL.INN
AND TR.sess_id = sess.sess_id 
AND TR.CODE_BUY = BUY.CLIENT_CODE
AND TR.CODE_SELL = SELL.CLIENT_CODE
AND TR.CODE_RTS_BUY = RTS_BUY.RTS_CODE
AND TR.CODE_RTS_SELL = RTS_SELL.RTS_CODE
AND TR.ISIN_ID = INSTR.ISIN_ID
--AND TR1.ID_DEAL = '1630153273'
AND (TR.PRICE*TR.AMOUNT) >= 200000
--AND BUY.INN NOT LIKE '#826 U 5976015'
AND POSITIONS.POS_END = '0'
AND TR.NOSYSTEM <> '0' --- Признак адресной сделки
ORDER BY TR.ID_DEAL;

/* + NO_PARALLEL */Select c.CCPYN, c.DealLen, c.securityid, count (c.securityid), sum(c.val2 * c.reporate)/ sum (c.val2) as WeightedRate, sum (c.val2) as Amount
FROM (
  Select a.boardid, a.securityid, a.val2, a.reporate, a.settledate, b.settledate, a.settledate - b.settledate as DealLen,
    case
      when a.boardid in (   'FBCE',  'RPUO',
                            'FBCU',  'RPEO',
                            'RPMA',  'RPEU',
                            'RPMO',  'FBCB',
                            'RPUA',  'FBFX',
                            'TADM'
                            )
                            then 'N'
          else 'Y'
        end as CCPYN
  from internaldm.V_EQ_TRADES a
  INNER JOIN internaldm.V_EQ_TRADES b
    ON a.tradeno = b.REPOTRADENO
    Where a.tradedate >= '01.10.2016'  and a.tradedate <= '05.12.2016'
        and a.boardid in (
                        'GCRP', 'EQRP',  'RPMA',
                        'GCOM', 'EQRE',  'RPMO',
                        'GCSW', 'EQRD',  'RPUA',
                        'GCSM', 'EQWP',  'RPUO',
                        'GCTM', 'EQWE',  'RPEO',
                        'GCOW', 'EQWD',  'RPEU',
                        'PSGC', 'PSRE',  'FBCB',
                        'FBCE', 'PSRD',  'FBFX',
                        'FBCU', 'PSRP',  'TADM'
                        )
      and a.STATUS = 'M'
      and substr(a.currencyid, 1, 3) IN ('RUR', 'RUB')
      and a.SECURITYID IN ('RU000A0JW4Z1', 'RU000A0JWKG5', 'RU000A0JWKF7' ) -- КСУ
      and a.BUYSELL = 'B'
      and a.typ IN ('r', 'h', 'j')
      and b.typ IN ('R', 'H', 'J')
      and b.tradedate >= '01.10.2016'  and b.tradedate <= '05.12.2016'
      and b.BUYSELL = 'B'
    ) c
--Where c.DealLen >= 7
Group by c.CCPYN, c.DealLen, c.securityid;

/* + NO_PARALLEL */select  tt.tradedate as TRADEDATE,
        tt.tradetime as TRADETIME,
        tt.TRADEMICROSECONDS as MICROSECONDS,
        to_char(tt.tradeno) as TRADENO,
        tt.clientcodeid as CLIENTCODEID,
        tt.FIRMID as FIRMID,
        tt.SECURITYID as INSTRUMENT,
        tt.price as PRICE,
        tt.quantity as QUANTITY,
        tt.val as TRADEVALUE,
        tt.BUYSELL as BUYSELL
from internaldm.v_curr_trades tt
inner join G_STRATEG_DEVEL.CURR_CL cc on
          (cc.clientcodeid = tt.clientcodeid
          and cc.clgroup = 'FIZ'
          and tt.typ in ('T','N')
          and tt.boardid in ('CETS', 'CNGD', 'FUTS')
          and tt.status = 'M'
          and tt.tradedate between '01.12.15' and '31.12.15'
          )
group by tt.tradedate,
          tt.tradetime,
          tt.TRADEMICROSECONDS,
          to_char(tt.tradeno),
          tt.clientcodeid,
          tt.FIRMID,
          tt.SECURITYID,
          tt.price,
          tt.quantity,
          tt.val,
          tt.BUYSELL;
          
/* Formatted on 29-11-2016 9:07:55 (QP5 v5.294) */
MERGE INTO FORTS_CLEARING.DEAL_BASE PARTITION(DEAL_BASE_4486) A
     USING (SELECT 'A'               AS ST_ACTUAL,
                   AMOUNT,
                   TRIM (COMMENT_PK) AS COMMENT_PK,
                   TRIM (COMMENT_PR) AS COMMENT_PR,
                   DATETIME,
                   DU_PK,
                   DU_PR,
                   EXT_ID_PK,
                   EXT_ID_PR,
                   TRIM (FIO_PK)     AS FIO_PK,
                   TRIM (FIO_PR)     AS FIO_PR,
                   ID,
                   IDORG_PK,
                   IDORG_PR,
                   ID_DEAL,
                   ID_REPO,
                   ISIN,
                   IS_EXP,
                   TRIM (KOD_PK)     AS KOD_PK,
                   TRIM (KOD_PR)     AS KOD_PR,
                   MSEC,
                   N_ORDER_PK,
                   N_ORDER_PR,
                   TRIM (N_USER_PK)  AS N_USER_PK,
                   TRIM (N_USER_PR)  AS N_USER_PR,
                   POS,
                   PRICE,
                   REPLID,
                   REPLREV,
                   REQ_ID,
                   SBOR_PK,
                   SBOR_PK_CLEAR_PAY,
                   SBOR_PK_CLEAR_PAY_NDS,
                   SBOR_PK_EXCH_PAY,
                   SBOR_PK_EXCH_PAY_NDS,
                   SBOR_PR,
                   SBOR_PR_CLEAR_PAY,
                   SBOR_PR_CLEAR_PAY_NDS,
                   SBOR_PR_EXCH_PAY,
                   SBOR_PR_EXCH_PAY_NDS,
                   SDEAL_PAY_EVE,
                   SDEAL_PAY_MON,
                   STATUS_EXT,
                   STATUS_PK,
                   STATUS_PR,
                   SYST_ID,
                   TRIM (TYPE_PK)    AS TYPE_PK,
                   TRIM (TYPE_PR)    AS TYPE_PR,
                   VM_PK,
                   VM_PR,
                   XSTATUS_PK
              FROM FORTS_CLEARING.DEAL_LM
             WHERE     NOT (ID IS NULL OR SYST_ID IS NULL)
                   AND SYST_ID BETWEEN 4485 AND 4485
            MINUS
            SELECT ST_ACTUAL,
                   AMOUNT,
                   TRIM (COMMENT_PK) AS COMMENT_PK,
                   TRIM (COMMENT_PR) AS COMMENT_PR,
                   DATETIME,
                   DU_PK,
                   DU_PR,
                   EXT_ID_PK,
                   EXT_ID_PR,
                   TRIM (FIO_PK)     AS FIO_PK,
                   TRIM (FIO_PR)     AS FIO_PR,
                   ID,
                   IDORG_PK,
                   IDORG_PR,
                   ID_DEAL,
                   ID_REPO,
                   ISIN,
                   IS_EXP,
                   TRIM (KOD_PK)     AS KOD_PK,
                   TRIM (KOD_PR)     AS KOD_PR,
                   MSEC,
                   N_ORDER_PK,
                   N_ORDER_PR,
                   TRIM (N_USER_PK)  AS N_USER_PK,
                   TRIM (N_USER_PR)  AS N_USER_PR,
                   POS,
                   PRICE,
                   REPLID,
                   REPLREV,
                   REQ_ID,
                   SBOR_PK,
                   SBOR_PK_CLEAR_PAY,
                   SBOR_PK_CLEAR_PAY_NDS,
                   SBOR_PK_EXCH_PAY,
                   SBOR_PK_EXCH_PAY_NDS,
                   SBOR_PR,
                   SBOR_PR_CLEAR_PAY,
                   SBOR_PR_CLEAR_PAY_NDS,
                   SBOR_PR_EXCH_PAY,
                   SBOR_PR_EXCH_PAY_NDS,
                   SDEAL_PAY_EVE,
                   SDEAL_PAY_MON,
                   STATUS_EXT,
                   STATUS_PK,
                   STATUS_PR,
                   SYST_ID,
                   TRIM (TYPE_PK)    AS TYPE_PK,
                   TRIM (TYPE_PR)    AS TYPE_PR,
                   VM_PK,
                   VM_PR,
                   XSTATUS_PK
              FROM FORTS_CLEARING.DEAL_BASE
             WHERE SYST_ID BETWEEN 4485 AND 4485) B
        ON (A.ID = B.ID AND A.SYST_ID = B.SYST_ID)
WHEN MATCHED
THEN
   UPDATE SET
      A.ST_ACTUAL = B.ST_ACTUAL,
      A.UPDATEDT = TO_DATE ('28.11.2016 12:21:01', 'DD.MM.YYYY HH24:MI:SS'),
      A.AMOUNT = B.AMOUNT,
      A.COMMENT_PK = B.COMMENT_PK,
      A.COMMENT_PR = B.COMMENT_PR,
      A.DATETIME = B.DATETIME,
      A.DU_PK = B.DU_PK,
      A.DU_PR = B.DU_PR,
      A.EXT_ID_PK = B.EXT_ID_PK,
      A.EXT_ID_PR = B.EXT_ID_PR,
      A.FIO_PK = B.FIO_PK,
      A.FIO_PR = B.FIO_PR,
      A.IDORG_PK = B.IDORG_PK,
      A.IDORG_PR = B.IDORG_PR,
      A.ID_DEAL = B.ID_DEAL,
      A.ID_REPO = B.ID_REPO,
      A.ISIN = B.ISIN,
      A.IS_EXP = B.IS_EXP,
      A.KOD_PK = B.KOD_PK,
      A.KOD_PR = B.KOD_PR,
      A.MSEC = B.MSEC,
      A.N_ORDER_PK = B.N_ORDER_PK,
      A.N_ORDER_PR = B.N_ORDER_PR,
      A.N_USER_PK = B.N_USER_PK,
      A.N_USER_PR = B.N_USER_PR,
      A.POS = B.POS,
      A.PRICE = B.PRICE,
      A.REPLID = B.REPLID,
      A.REPLREV = B.REPLREV,
      A.REQ_ID = B.REQ_ID,
      A.SBOR_PK = B.SBOR_PK,
      A.SBOR_PK_CLEAR_PAY = B.SBOR_PK_CLEAR_PAY,
      A.SBOR_PK_CLEAR_PAY_NDS = B.SBOR_PK_CLEAR_PAY_NDS,
      A.SBOR_PK_EXCH_PAY = B.SBOR_PK_EXCH_PAY,
      A.SBOR_PK_EXCH_PAY_NDS = B.SBOR_PK_EXCH_PAY_NDS,
      A.SBOR_PR = B.SBOR_PR,
      A.SBOR_PR_CLEAR_PAY = B.SBOR_PR_CLEAR_PAY,
      A.SBOR_PR_CLEAR_PAY_NDS = B.SBOR_PR_CLEAR_PAY_NDS,
      A.SBOR_PR_EXCH_PAY = B.SBOR_PR_EXCH_PAY,
      A.SBOR_PR_EXCH_PAY_NDS = B.SBOR_PR_EXCH_PAY_NDS,
      A.SDEAL_PAY_EVE = B.SDEAL_PAY_EVE,
      A.SDEAL_PAY_MON = B.SDEAL_PAY_MON,
      A.STATUS_EXT = B.STATUS_EXT,
      A.STATUS_PK = B.STATUS_PK,
      A.STATUS_PR = B.STATUS_PR,
      A.TYPE_PK = B.TYPE_PK,
      A.TYPE_PR = B.TYPE_PR,
      A.VM_PK = B.VM_PK,
      A.VM_PR = B.VM_PR,
      A.XSTATUS_PK = B.XSTATUS_PK
WHEN NOT MATCHED
THEN
   INSERT     (A.L_ID,
               A.ST_ACTUAL,
               A.UPDATEDT,
               A.AMOUNT,
               A.COMMENT_PK,
               A.COMMENT_PR,
               A.DATETIME,
               A.DU_PK,
               A.DU_PR,
               A.EXT_ID_PK,
               A.EXT_ID_PR,
               A.FIO_PK,
               A.FIO_PR,
               A.ID,
               A.IDORG_PK,
               A.IDORG_PR,
               A.ID_DEAL,
               A.ID_REPO,
               A.ISIN,
               A.IS_EXP,
               A.KOD_PK,
               A.KOD_PR,
               A.MSEC,
               A.N_ORDER_PK,
               A.N_ORDER_PR,
               A.N_USER_PK,
               A.N_USER_PR,
               A.POS,
               A.PRICE,
               A.REPLID,
               A.REPLREV,
               A.REQ_ID,
               A.SBOR_PK,
               A.SBOR_PK_CLEAR_PAY,
               A.SBOR_PK_CLEAR_PAY_NDS,
               A.SBOR_PK_EXCH_PAY,
               A.SBOR_PK_EXCH_PAY_NDS,
               A.SBOR_PR,
               A.SBOR_PR_CLEAR_PAY,
               A.SBOR_PR_CLEAR_PAY_NDS,
               A.SBOR_PR_EXCH_PAY,
               A.SBOR_PR_EXCH_PAY_NDS,
               A.SDEAL_PAY_EVE,
               A.SDEAL_PAY_MON,
               A.STATUS_EXT,
               A.STATUS_PK,
               A.STATUS_PR,
               A.SYST_ID,
               A.TYPE_PK,
               A.TYPE_PR,
               A.VM_PK,
               A.VM_PR,
               A.XSTATUS_PK)
       VALUES (FORTS_CLEARING.DEAL_BASE_SEQ_ID.NEXTVAL,
               'A',
               TO_DATE ('28.11.2016 12:21:01', 'DD.MM.YYYY HH24:MI:SS'),
               B.AMOUNT,
               B.COMMENT_PK,
               B.COMMENT_PR,
               B.DATETIME,
               B.DU_PK,
               B.DU_PR,
               B.EXT_ID_PK,
               B.EXT_ID_PR,
               B.FIO_PK,
               B.FIO_PR,
               B.ID,
               B.IDORG_PK,
               B.IDORG_PR,
               B.ID_DEAL,
               B.ID_REPO,
               B.ISIN,
               B.IS_EXP,
               B.KOD_PK,
               B.KOD_PR,
               B.MSEC,
               B.N_ORDER_PK,
               B.N_ORDER_PR,
               B.N_USER_PK,
               B.N_USER_PR,
               B.POS,
               B.PRICE,
               B.REPLID,
               B.REPLREV,
               B.REQ_ID,
               B.SBOR_PK,
               B.SBOR_PK_CLEAR_PAY,
               B.SBOR_PK_CLEAR_PAY_NDS,
               B.SBOR_PK_EXCH_PAY,
               B.SBOR_PK_EXCH_PAY_NDS,
               B.SBOR_PR,
               B.SBOR_PR_CLEAR_PAY,
               B.SBOR_PR_CLEAR_PAY_NDS,
               B.SBOR_PR_EXCH_PAY,
               B.SBOR_PR_EXCH_PAY_NDS,
               B.SDEAL_PAY_EVE,
               B.SDEAL_PAY_MON,
               B.STATUS_EXT,
               B.STATUS_PK,
               B.STATUS_PR,
               B.SYST_ID,
               B.TYPE_PK,
               B.TYPE_PR,
               B.VM_PK,
               B.VM_PR,
               B.XSTATUS_PK);
               
               
WITH ORDLOG
     AS (SELECT DT  AS OBDATE,
                TM  AS OBTIME,
                SECURITYID,
                ACTION,
                ORDERNO,
                VOL AS VOLUME,
                VOLHIDDEN,
                BUYSELL,
                PRICE,
                CLIENTID,
                PERIOD
           FROM (SELECT ENTRYDATE AS DT,
                           TO_CHAR (ENTRYTIME, 'FM000000')
                        || TO_CHAR (ENTRYMICROSECONDS, 'FM000000')
                           AS TM,
                        SECURITYID,
                        1         AS ACTION,
                        ORDERNO,
                        QUANTITY  AS VOL,
                        (CASE WHEN QTYHIDDEN = 0 THEN NULL ELSE QTYHIDDEN END)
                           AS VOLHIDDEN,
                        BUYSELL,
                        PRICE,
                        NULL      AS TRADENO,
                        (CASE
                            WHEN CLIENTCODEID IS NULL
                            THEN
                               TO_CHAR (FIRMID) || TO_CHAR ('_null')
                            ELSE
                                  TO_CHAR (FIRMID)
                               || TO_CHAR ('_')
                               || TO_CHAR (CLIENTCODEID)
                         END)
                           AS CLIENTID,
                        PERIOD
                   FROM INTERNALDM.V_EQ_ORDERS
                  WHERE     ENTRYDATE BETWEEN '04.01.16' AND '28.10.16'
                        AND BOARDID = 'EQOB'
                        AND STATUS IN ('M', 'W', 'C')
                 UNION ALL
                 SELECT AMENDDATE AS DT,
                           TO_CHAR (AMENDTIME, 'FM000000')
                        || TO_CHAR (AMENDMICROSECONDS, 'FM000000')
                           AS TM,
                        SECURITYID,
                        3         AS ACTION,
                        ORDERNO,
                        BALANCE   AS VOL,
                        NULL      AS VOLHIDDEN,
                        BUYSELL,
                        PRICE,
                        NULL      AS TRADENO,
                        (CASE
                            WHEN CLIENTCODEID IS NULL
                            THEN
                               TO_CHAR (FIRMID) || TO_CHAR ('_null')
                            ELSE
                                  TO_CHAR (FIRMID)
                               || TO_CHAR ('_')
                               || TO_CHAR (CLIENTCODEID)
                         END)
                           AS CLIENTID,
                        PERIOD
                   FROM INTERNALDM.V_EQ_ORDERS
                  WHERE     ENTRYDATE BETWEEN '04.01.16' AND '28.10.16'
                        AND BOARDID = 'EQOB'
                        AND STATUS IN ('M', 'W', 'C')
                        AND BALANCE > 0
                 UNION ALL
                 SELECT TRADEDATE AS DT,
                           TO_CHAR (TRADETIME, 'FM000000')
                        || TO_CHAR (TRADEMICROSECONDS, 'FM000000')
                           AS TM,
                        SECURITYID,
                        2         AS ACTION,
                        ORDERNO,
                        QUANTITY  AS VOL,
                        NULL      AS VOLHIDDEN,
                        BUYSELL,
                        PRICE,
                        TRADENO,
                        (CASE
                            WHEN CLIENTCODEID IS NULL
                            THEN
                               TO_CHAR (FIRMID) || TO_CHAR ('_null')
                            ELSE
                                  TO_CHAR (FIRMID)
                               || TO_CHAR ('_')
                               || TO_CHAR (CLIENTCODEID)
                         END)
                           AS CLIENTID,
                        PERIOD
                   FROM INTERNALDM.V_EQ_TRADES
                  WHERE     TRADEDATE BETWEEN '04.01.16' AND '28.10.16'
                        AND BOARDID = 'EQOB')),
     ACTS
     AS (  SELECT CLIENTID, ACTION, COUNT (ORDERNO) AS NUM1
             FROM ORDLOG
            WHERE ACTION = 1
         GROUP BY CLIENTID, ACTION),
     TC
     AS (  SELECT (CASE
                      WHEN CLIENTCODEID IS NULL
                      THEN
                         TO_CHAR (FIRMID) || TO_CHAR ('_null')
                      ELSE
                            TO_CHAR (FIRMID)
                         || TO_CHAR ('_')
                         || TO_CHAR (CLIENTCODEID)
                   END)
                     AS CLIENTID
             FROM INTERNALDM.V_EQ_TRADES
            WHERE TRADEDATE BETWEEN '01.01.16' AND '28.10.16'
         GROUP BY FIRMID, CLIENTCODEID
         ORDER BY SUM (VAL) DESC),
     TOPCLIENTS AS (SELECT TC.*, ROWNUM AS RATE FROM TC)
  SELECT TOPCLIENTS.*, ACTS.ACTION, ACTS.NUM1
    FROM TOPCLIENTS LEFT JOIN ACTS ON ACTS.CLIENTID = TOPCLIENTS.CLIENTID
ORDER BY TOPCLIENTS.RATE;

WITH SESS
     AS (SELECT SESS_ID
           FROM INTERNALDM.V_FORTS_SESSION
          WHERE    END BETWEEN TO_DATE ('30.09.2016', 'DD.MM.YYYY')
                           AND TO_DATE ('01.10.2016', 'DD.MM.YYYY') + 1
                OR BEGIN BETWEEN TO_DATE ('30.09.2016', 'DD.MM.YYYY')
                             AND TO_DATE ('01.10.2016', 'DD.MM.YYYY') + 1),
     BUY
     AS (SELECT *
           FROM INTERNALDM.V_FORTS_INVESTR
          WHERE CLIENT_CODE IN (SELECT CODE_BUY
                                  FROM INTERNALDM.V_FORTS_TRADES_FU
                                 WHERE SESS_ID IN (SELECT SESS_ID
                                                     FROM SESS))),
     SELL
     AS (SELECT *
           FROM INTERNALDM.V_FORTS_INVESTR
          WHERE CLIENT_CODE IN (SELECT CODE_SELL
                                  FROM INTERNALDM.V_FORTS_TRADES_FU
                                 WHERE SESS_ID IN (SELECT SESS_ID
                                                     FROM SESS))),
     RTS_BUY
     AS (SELECT *
           FROM INTERNALDM.V_FORTS_FIRMS
          WHERE RTS_CODE IN (SELECT CODE_RTS_BUY
                               FROM INTERNALDM.V_FORTS_TRADES_FU
                              WHERE SESS_ID IN (SELECT SESS_ID
                                                  FROM SESS))),
     RTS_SELL
     AS (SELECT *
           FROM INTERNALDM.V_FORTS_FIRMS
          WHERE RTS_CODE IN (SELECT CODE_RTS_SELL
                               FROM INTERNALDM.V_FORTS_TRADES_FU
                              WHERE SESS_ID IN (SELECT SESS_ID
                                                  FROM SESS))),
     INSTR
     AS (SELECT *
           FROM INTERNALDM.V_FORTS_INSTRUMENTS_FU
          WHERE ISIN_ID IN (SELECT ISIN_ID
                              FROM INTERNALDM.V_FORTS_TRADES_FU
                             WHERE SESS_ID IN (SELECT SESS_ID
                                                 FROM SESS)))
SELECT DISTINCT TR.ID_DEAL,
                TR.MOMENT,
                TR.ID_ORD_BUY,
                TR.ID_ORD_SELL,
                TR.ISIN_ID,
                INSTR.NAME,
                TR.PRICE * AMOUNT AS VAL,
                TR.CODE_BUY,
                RTS_BUY.NAME,
                RTS_SELL.NAME     AS NAME_SELL,
                BUY.INN           AS INN_BUY,
                BUY.NAME          AS NAME_BUY,
                TR.CODE_SELL,
                SELL.INN          AS INN_SELL,
                SELL.NAME,
                TR.CODE_RTS_SELL,
                TR.CODE_RTS_BUY
  FROM INTERNALDM.V_FORTS_TRADES_FU TR
       LEFT JOIN BUY ON (CODE_BUY = BUY.CLIENT_CODE)
       LEFT JOIN SELL ON (CODE_SELL = SELL.CLIENT_CODE)
       LEFT JOIN RTS_BUY ON (CODE_RTS_BUY = RTS_BUY.RTS_CODE)
       LEFT JOIN RTS_SELL ON (CODE_RTS_SELL = RTS_SELL.RTS_CODE)
       LEFT JOIN INSTR ON (TR.ISIN_ID = INSTR.ISIN_ID)
 --LEFT JOIN internaldm.v_forts_clr_positions_fu POSITIONS ON ((TR.CODE_BUY = POSITIONS.CLIENT_CODE OR TR.CODE_SELL = POSITIONS.CLIENT_CODE) AND TR.sess_id = POSITIONS.sess_id)
 WHERE     TR.CODE_BUY IN
              (SELECT TR1.CODE_SELL
                 FROM INTERNALDM.V_FORTS_TRADES_FU TR1
                      LEFT JOIN BUY ON (CODE_BUY = BUY.CLIENT_CODE)
                      LEFT JOIN SELL ON (CODE_SELL = SELL.CLIENT_CODE)
                      LEFT JOIN RTS_BUY ON (CODE_RTS_BUY = RTS_BUY.RTS_CODE)
                      LEFT JOIN RTS_SELL
                         ON (CODE_RTS_SELL = RTS_SELL.RTS_CODE)
                      LEFT JOIN INSTR ON (TR.ISIN_ID = INSTR.ISIN_ID)
                WHERE     TR1.CODE_BUY = TR.CODE_SELL
                      AND TR.ISIN_ID = TR1.ISIN_ID
                      AND TR.ID_DEAL <> TR1.ID_DEAL
                      AND TR1.SESS_ID IN (SELECT SESS_ID
                                            FROM SESS))
       AND TR.SESS_ID IN (SELECT SESS_ID
                            FROM SESS);

INSERT INTO TEMP1_BUY
   SELECT *
     FROM INTERNALDM.V_FORTS_INVESTR
    WHERE CLIENT_CODE IN (SELECT CODE_BUY
                            FROM INTERNALDM.V_FORTS_TRADES_FU
                           WHERE SESS_ID = 5126);

INSERT INTO TEMP1_SELL
   SELECT *
     FROM INTERNALDM.V_FORTS_INVESTR
    WHERE CLIENT_CODE IN (SELECT CODE_SELL
                            FROM INTERNALDM.V_FORTS_TRADES_FU
                           WHERE SESS_ID = 5126);

INSERT INTO TEMP1_RTS_BUY
   SELECT *
     FROM INTERNALDM.V_FORTS_FIRMS
    WHERE RTS_CODE IN (SELECT CODE_RTS_BUY
                         FROM INTERNALDM.V_FORTS_TRADES_FU
                        WHERE SESS_ID = 5126);

INSERT INTO TEMP1_RTS_SELL
   SELECT *
     FROM INTERNALDM.V_FORTS_FIRMS
    WHERE RTS_CODE IN (SELECT CODE_RTS_SELL
                         FROM INTERNALDM.V_FORTS_TRADES_FU
                        WHERE SESS_ID = 5126);

INSERT INTO TEMP1_INSTR
   SELECT *
     FROM INTERNALDM.V_FORTS_INSTRUMENTS_FU
    WHERE ISIN_ID IN (SELECT ISIN_ID
                        FROM INTERNALDM.V_FORTS_TRADES_FU
                       WHERE SESS_ID = 5126);

INSERT INTO TEMP1_TRADES
   SELECT *
     FROM INTERNALDM.V_FORTS_TRADES_FU
    WHERE SESS_ID = 5126;

SELECT COUNT (1) FROM TEMP1_BUY;

SELECT COUNT (1) FROM TEMP1_SELL;

SELECT COUNT (1) FROM TEMP1_RTS_BUY;

SELECT COUNT (1) FROM TEMP1_RTS_SELL;

SELECT COUNT (1) FROM TEMP1_INSTR;

SELECT COUNT (1) FROM TEMP1_TRADES; --1419566
--delete from temp1_trades;

SELECT * FROM TEMP1_TRADES;

SELECT COUNT (DISTINCT A.ID_DEAL)
  FROM TEMP1_TRADES A, TEMP1_TRADES B
 WHERE     A.ID_DEAL <> B.ID_DEAL
       AND A.CODE_BUY = B.CODE_BUY
       AND A.ISIN_ID = B.ISIN_ID;


WITH AAA
     AS (SELECT DISTINCT TR.ID_DEAL,
                         TR.MOMENT,
                         TR.ID_ORD_BUY,
                         TR.ID_ORD_SELL,
                         TR.ISIN_ID,
                         TEMP1_INSTR.NAME,
                         TR.PRICE * AMOUNT   AS VAL,
                         TR.CODE_BUY,
                         TEMP1_RTS_BUY.NAME,
                         TEMP1_RTS_SELL.NAME AS NAME_SELL,
                         TEMP1_BUY.INN       AS INN_BUY,
                         TEMP1_BUY.NAME      AS NAME_BUY,
                         TR.CODE_SELL,
                         TEMP1_SELL.INN      AS INN_SELL,
                         TEMP1_SELL.NAME,
                         TR.CODE_RTS_SELL,
                         TR.CODE_RTS_BUY
           FROM TEMP1_TRADES TR,
                TEMP1_BUY,
                TEMP1_SELL,
                TEMP1_RTS_BUY,
                TEMP1_RTS_SELL,
                TEMP1_INSTR
          WHERE     TR.CODE_BUY = TEMP1_BUY.CLIENT_CODE(+)
                AND TR.CODE_SELL = TEMP1_SELL.CLIENT_CODE(+)
                AND TR.CODE_RTS_BUY = TEMP1_RTS_BUY.RTS_CODE(+)
                AND TR.CODE_RTS_SELL = TEMP1_RTS_SELL.RTS_CODE(+)
                AND TR.ISIN_ID = TEMP1_INSTR.ISIN_ID(+)),
     BBB
     AS (SELECT COUNT (DISTINCT TR.ID_DEAL) --DISTINCT TR.ID_DEAL,TR.ISIN_ID,TR.CODE_BUY --442874066
           FROM TEMP1_TRADES TR,
                TEMP1_BUY,
                TEMP1_SELL,
                TEMP1_RTS_BUY,
                TEMP1_RTS_SELL,
                TEMP1_INSTR
          WHERE     TR.CODE_BUY = TEMP1_BUY.CLIENT_CODE(+)
                AND TR.CODE_SELL = TEMP1_SELL.CLIENT_CODE(+)
                AND TR.CODE_RTS_BUY = TEMP1_RTS_BUY.RTS_CODE(+)
                AND TR.CODE_RTS_SELL = TEMP1_RTS_SELL.RTS_CODE(+)
                AND TR.ISIN_ID = TEMP1_INSTR.ISIN_ID(+))
SELECT COUNT (AAA.ID_DEAL)
  FROM AAA, BBB
 WHERE     AAA.ID_DEAL <> BBB.ID_DEAL
       AND AAA.CODE_BUY = BBB.CODE_BUY
       AND AAA.ISIN_ID = BBB.ISIN_ID;

SELECT DISTINCT TR.ID_DEAL,
                TR.MOMENT,
                TR.ID_ORD_BUY,
                TR.ID_ORD_SELL,
                TR.ISIN_ID,
                TEMP1_INSTR.NAME,
                TR.PRICE * AMOUNT   AS VAL,
                TR.CODE_BUY,
                TEMP1_RTS_BUY.NAME,
                TEMP1_RTS_SELL.NAME AS NAME_SELL,
                TEMP1_BUY.INN       AS INN_BUY,
                TEMP1_BUY.NAME      AS NAME_BUY,
                TR.CODE_SELL,
                TEMP1_SELL.INN      AS INN_SELL,
                TEMP1_SELL.NAME,
                TR.CODE_RTS_SELL,
                TR.CODE_RTS_BUY
  FROM TEMP1_TRADES TR
       LEFT JOIN TEMP1_BUY ON (TR.CODE_BUY = TEMP1_BUY.CLIENT_CODE)
       LEFT JOIN TEMP1_SELL ON (TR.CODE_SELL = TEMP1_SELL.CLIENT_CODE)
       LEFT JOIN TEMP1_RTS_BUY ON (TR.CODE_RTS_BUY = TEMP1_RTS_BUY.RTS_CODE)
       LEFT JOIN TEMP1_RTS_SELL
          ON (TR.CODE_RTS_SELL = TEMP1_RTS_SELL.RTS_CODE)
       LEFT JOIN TEMP1_INSTR ON (TR.ISIN_ID = TEMP1_INSTR.ISIN_ID)
 WHERE TR.CODE_BUY IN (SELECT TR1.CODE_SELL
                         FROM TEMP1_TRADES
                        WHERE TR.ID_DEAL <> TR1.ID_DEAL);

WITH SESS
     AS (SELECT SESS_ID
           FROM INTERNALDM.V_FORTS_SESSION
          WHERE    END BETWEEN TO_DATE ('30.09.2016', 'DD.MM.YYYY')
                           AND TO_DATE ('01.10.2016', 'DD.MM.YYYY') + 1
                OR BEGIN BETWEEN TO_DATE ('30.09.2016', 'DD.MM.YYYY')
                             AND TO_DATE ('01.10.2016', 'DD.MM.YYYY') + 1)
SELECT DISTINCT TR.ID_DEAL,
                TR.MOMENT,
                TR.ID_ORD_BUY,
                TR.ID_ORD_SELL,
                TR.ISIN_ID,
                TEMP1_INSTR.NAME,
                TR.PRICE * AMOUNT   AS VAL,
                TR.CODE_BUY,
                TEMP1_RTS_BUY.NAME,
                TEMP1_RTS_SELL.NAME AS NAME_SELL,
                TEMP1_BUY.INN       AS INN_BUY,
                TEMP1_BUY.NAME      AS NAME_BUY,
                TR.CODE_SELL,
                TEMP1_SELL.INN      AS INN_SELL,
                TEMP1_SELL.NAME,
                TR.CODE_RTS_SELL,
                TR.CODE_RTS_BUY
  FROM INTERNALDM.V_FORTS_TRADES_FU TR
       LEFT JOIN TEMP1_BUY ON (TR.CODE_BUY = TEMP1_BUY.CLIENT_CODE)
       LEFT JOIN TEMP1_SELL ON (TR.CODE_SELL = TEMP1_SELL.CLIENT_CODE)
       LEFT JOIN TEMP1_RTS_BUY ON (TR.CODE_RTS_BUY = TEMP1_RTS_BUY.RTS_CODE)
       LEFT JOIN TEMP1_RTS_SELL
          ON (TR.CODE_RTS_SELL = TEMP1_RTS_SELL.RTS_CODE)
       LEFT JOIN TEMP1_INSTR ON (TR.ISIN_ID = TEMP1_INSTR.ISIN_ID)
 --LEFT JOIN internaldm.v_forts_clr_positions_fu POSITIONS ON ((TR.CODE_BUY = POSITIONS.CLIENT_CODE OR TR.CODE_SELL = POSITIONS.CLIENT_CODE) AND TR.sess_id = POSITIONS.sess_id)
 WHERE     TR.CODE_BUY IN
              (SELECT TR1.CODE_SELL
                 FROM INTERNALDM.V_FORTS_TRADES_FU TR1
                WHERE     TR1.CODE_BUY IN (SELECT DISTINCT CLIENT_CODE
                                             FROM TEMP1_BUY)
                      AND TR.ISIN_ID IN (SELECT DISTINCT ISIN_ID
                                           FROM TEMP1_INSTR)
                      AND TR.ID_DEAL <> TR1.ID_DEAL
                      AND TR1.SESS_ID IN (TR.SESS_ID))
       AND TR.SESS_ID IN (SELECT SESS_ID
                            FROM SESS);


SELECT ENTRYDATE                                                      AS DT,
       TO_CHAR (ENTRYTIME) || TO_CHAR (ENTRYMICROSECONDS, 'FM000000') AS TM,
       SECURITYID,
       1
          AS ACTION,
       ORDERNO,
       QUANTITY                                                       AS VOL,
       (CASE WHEN QTYHIDDEN = 0 THEN NULL ELSE QTYHIDDEN END)
          AS VOLHIDDEN,
       BUYSELL,
       PRICE,
       NULL
          AS TRADENO,
       (CASE
           WHEN CLIENTCODEID IS NULL THEN SUBSTR (FIRMID, 3, 12)
           ELSE TO_CHAR (CLIENTCODEID)
        END)
          AS CLIENTID
  FROM INTERNALDM.V_CURR_ORDERS
 WHERE     ENTRYDATE = '30.09.2016'
       AND BOARDID = 'CETS'
       AND STATUS IN ('M',
                      'W',
                      'C',
                      'D')
       AND FIRMID = 'MB0003300000'
UNION ALL
SELECT AMENDDATE                                                      AS DT,
       TO_CHAR (AMENDTIME) || TO_CHAR (AMENDMICROSECONDS, 'FM000000') AS TM,
       SECURITYID,
       3
          AS ACTION,
       ORDERNO,
       BALANCE                                                        AS VOL,
       NULL
          AS VOLHIDDEN,
       BUYSELL,
       PRICE,
       NULL
          AS TRADENO,
       (CASE
           WHEN CLIENTCODEID IS NULL THEN SUBSTR (FIRMID, 3, 12)
           ELSE TO_CHAR (CLIENTCODEID)
        END)
          AS CLIENTID
  FROM INTERNALDM.V_CURR_ORDERS
 WHERE     ENTRYDATE = '30.09.2016'
       AND BOARDID = 'CETS'
       AND STATUS IN ('M',
                      'W',
                      'C',
                      'D')
       AND BALANCE > 0
       AND FIRMID = 'MB0003300000';

  SELECT B.CCPYN,
         B.DEALLEN,
         B.SECURITYID,
         COUNT (B.SECURITYID),
         SUM (B.VAL2 * B.REPORATE) / SUM (B.VAL2) AS WEIGHTEDRATE,
         SUM (B.VAL2)                           AS AMOUNT
    FROM (SELECT A.BOARDID,
                 A.SECURITYID,
                 A.VAL2,
                 A.REPORATE,
                 A.SETTLEDATE,
                 B.SETTLEDATE,
                 A.SETTLEDATE - B.SETTLEDATE AS DEALLEN,
                 CASE
                    WHEN A.BOARDID IN ('FBCE',
                                       'RPUO',
                                       'FBCU',
                                       'RPEO',
                                       'RPMA',
                                       'RPEU',
                                       'RPMO',
                                       'FBCB',
                                       'RPUA',
                                       'FBFX',
                                       'TADM')
                    THEN
                       'N'
                    ELSE
                       'Y'
                 END
                    AS CCPYN
            FROM INTERNALDM.V_EQ_TRADES A
                 INNER JOIN INTERNALDM.V_EQ_TRADES B
                    ON A.TRADENO = B.REPOTRADENO
           WHERE     A.TRADEDATE >= '01.10.2016'
                 AND A.TRADEDATE <= '16.11.2016'
                 AND A.BOARDID IN ('GCRP',
                                   'EQRP',
                                   'RPMA',
                                   'GCOM',
                                   'EQRE',
                                   'RPMO',
                                   'GCSW',
                                   'EQRD',
                                   'RPUA',
                                   'GCSM',
                                   'EQWP',
                                   'RPUO',
                                   'GCTM',
                                   'EQWE',
                                   'RPEO',
                                   'GCOW',
                                   'EQWD',
                                   'RPEU',
                                   'PSGC',
                                   'PSRE',
                                   'FBCB',
                                   'FBCE',
                                   'PSRD',
                                   'FBFX',
                                   'FBCU',
                                   'PSRP',
                                   'TADM')
                 AND A.STATUS = 'M'
                 AND SUBSTR (A.CURRENCYID, 1, 3) IN ('RUR', 'RUB')
                 AND A.BUYSELL = 'B'
                 AND A.TYP IN ('r', 'h', 'j')
                 AND B.TYP IN ('R', 'H', 'J')
                 AND B.TRADEDATE >= '01.10.2016'
                 AND B.TRADEDATE <= '16.11.2016'
                 AND B.BUYSELL = 'B') B
   WHERE B.DEALLEN <> 0
GROUP BY B.CCPYN, B.DEALLEN, B.SECURITYID;

SELECT CASE
          WHEN A.BOARDID IN ('FBCE',
                             'RPUO',
                             'FBCU',
                             'RPEO',
                             'RPMA',
                             'RPEU',
                             'RPMO',
                             'FBCB',
                             'RPUA',
                             'FBFX',
                             'TADM')
          THEN
             'N'
          ELSE
             'Y'
       END
          AS CCPYN,
       A.SETTLEDATE - B.SETTLEDATE AS DEALLEN,
       A.BOARDID,
       A.SECURITYID,
       A.VAL2,
       A.REPORATE
  FROM INTERNALDM.V_EQ_TRADES A
       INNER JOIN INTERNALDM.V_EQ_TRADES B ON A.TRADENO = B.REPOTRADENO
 WHERE     A.TRADEDATE >= '01.10.2016'
       AND A.TRADEDATE <= '16.11.2016'
       AND A.BOARDID IN ('GCRP',
                         'EQRP',
                         'RPMA',
                         'GCOM',
                         'EQRE',
                         'RPMO',
                         'GCSW',
                         'EQRD',
                         'RPUA',
                         'GCSM',
                         'EQWP',
                         'RPUO',
                         'GCTM',
                         'EQWE',
                         'RPEO',
                         'GCOW',
                         'EQWD',
                         'RPEU',
                         'PSGC',
                         'PSRE',
                         'FBCB',
                         'FBCE',
                         'PSRD',
                         'FBFX',
                         'FBCU',
                         'PSRP',
                         'TADM')
       AND A.STATUS = 'M'
       AND SUBSTR (A.CURRENCYID, 1, 3) IN ('EUR')
       AND A.BUYSELL = 'B'
       AND A.TYP IN ('r', 'h', 'j')
       AND B.TYP IN ('R', 'H', 'J')
       AND B.TRADEDATE >= '01.10.2016'
       AND B.TRADEDATE <= '16.11.2016'
       AND B.BUYSELL = 'B'
       AND A.SETTLEDATE - B.SETTLEDATE >= 7;

WITH ORDLOG
     AS (  SELECT DT AS OBDATE,
                  TM AS OBTIME,
                  SECURITYID,
                  ACTION,
                  ORDERNO,
                  VOL AS VOLUME,
                  VOLHIDDEN,
                  BUYSELL,
                  PRICE,
                  CLIENTID
             FROM (SELECT ENTRYDATE AS DT,
                             TO_CHAR (ENTRYTIME)
                          || TO_CHAR (ENTRYMICROSECONDS, 'FM000000')
                             AS TM,
                          SECURITYID,
                          1       AS ACTION,
                          ORDERNO,
                          QUANTITY AS VOL,
                          (CASE WHEN QTYHIDDEN = 0 THEN NULL ELSE QTYHIDDEN END)
                             AS VOLHIDDEN,
                          BUYSELL,
                          PRICE,
                          NULL    AS TRADENO,
                          (CASE
                              WHEN CLIENTCODEID IS NULL
                              THEN
                                 SUBSTR (FIRMID, 3, 12)
                              ELSE
                                 TO_CHAR (CLIENTCODEID)
                           END)
                             AS CLIENTID
                     FROM INTERNALDM.V_CURR_ORDERS
                    WHERE     ENTRYDATE = TO_DATE ('14.11.2016', 'dd.mm.yyyy')
                          AND BOARDID = 'CETS'
                          AND STATUS IN ('M',
                                         'W',
                                         'C',
                                         'D')
                          AND FIRMID = 'MB0003300000'
                   UNION ALL
                   SELECT AMENDDATE AS DT,
                             TO_CHAR (AMENDTIME)
                          || TO_CHAR (AMENDMICROSECONDS, 'FM000000')
                             AS TM,
                          SECURITYID,
                          3       AS ACTION,
                          ORDERNO,
                          BALANCE AS VOL,
                          NULL    AS VOLHIDDEN,
                          BUYSELL,
                          PRICE,
                          NULL    AS TRADENO,
                          (CASE
                              WHEN CLIENTCODEID IS NULL
                              THEN
                                 SUBSTR (FIRMID, 3, 12)
                              ELSE
                                 TO_CHAR (CLIENTCODEID)
                           END)
                             AS CLIENTID
                     FROM INTERNALDM.V_CURR_ORDERS
                    WHERE     ENTRYDATE = TO_DATE ('14.11.2016', 'dd.mm.yyyy')
                          AND BOARDID = 'CETS'
                          AND STATUS IN ('M',
                                         'W',
                                         'C',
                                         'D')
                          AND BALANCE > 0
                          AND FIRMID = 'MB0003300000'
                   UNION ALL
                   SELECT TRADEDATE AS DT,
                             TO_CHAR (TRADETIME)
                          || TO_CHAR (TRADEMICROSECONDS, 'FM000000')
                             AS TM,
                          SECURITYID,
                          2       AS ACTION,
                          ORDERNO,
                          QUANTITY AS VOL,
                          NULL    AS VOLHIDDEN,
                          BUYSELL,
                          PRICE,
                          TRADENO,
                          (CASE
                              WHEN CLIENTCODEID IS NULL
                              THEN
                                 SUBSTR (FIRMID, 3, 12)
                              ELSE
                                 TO_CHAR (CLIENTCODEID)
                           END)
                             AS CLIENTID
                     FROM INTERNALDM.V_CURR_TRADES
                    WHERE     TRADEDATE = TO_DATE ('14.11.2016', 'dd.mm.yyyy')
                          AND BOARDID = 'CETS'
                          AND TYP = 'T'
                          AND FIRMID = 'MB0003300000')
         ORDER BY DT,
                  TM,
                  ACTION,
                  TRADENO,
                  ORDERNO)
SELECT *
  FROM ORDLOG;


SELECT A.BOARDID,
       A.SECURITYID,
       A.VAL2,
       A.REPORATE,
       A.SETTLEDATE,
       B.SETTLEDATE,
       B.SETTLEDATE - A.SETTLEDATE AS DEALLEN,
       CASE
          WHEN A.BOARDID IN ('FBCE',
                             'RPUO',
                             'FBCU',
                             'RPEO',
                             'RPMA',
                             'RPEU',
                             'RPMO',
                             'FBCB',
                             'RPUA',
                             'FBFX',
                             'TADM')
          THEN
             'N'
          ELSE
             'Y'
       END
          AS CCPYN
  FROM INTERNALDM.V_EQ_TRADES A
       INNER JOIN INTERNALDM.V_EQ_TRADES B ON A.TRADENO = B.REPOTRADENO
 WHERE     A.TRADEDATE >= TO_DATE ('01.10.2016', 'dd.mm.yyyy')
       AND A.BOARDID IN ('GCRP',
                         'EQRP',
                         'RPMA',
                         'GCOM',
                         'EQRE',
                         'RPMO',
                         'GCSW',
                         'EQRD',
                         'RPUA',
                         'GCSM',
                         'EQWP',
                         'RPUO',
                         'GCTM',
                         'EQWE',
                         'RPEO',
                         'GCOW',
                         'EQWD',
                         'RPEU',
                         'PSGC',
                         'PSRE',
                         'FBCB',
                         'FBCE',
                         'PSRD',
                         'FBFX',
                         'FBCU',
                         'PSRP',
                         'TADM')
       AND A.STATUS = 'M'
       AND SUBSTR (A.CURRENCYID, 1, 3) IN ('RUR', 'RUB')
       AND A.BUYSELL = 'B'
       AND A.TYP IN ('r', 'h', 'j')
       AND B.TYP IN ('R', 'H', 'J')
       AND B.TRADEDATE >= TO_DATE ('03.10.2016', 'dd.mm.yyyy')
       AND B.BUYSELL = 'B';