-- fix the problem with wrong UNUSABLE INDEXES because of table expansion (see SR 3-17481542421) 

alter session set "_optimizer_table_expansion"=false;

-- fix the problem with work of RESULT_CASHE when non deterministic function were used (for example, SYSDATE)

--replace trunc(sysdate) with

CREATE OR REPLACE FUNCTION GET_SYSDATE
    RETURN DATE
    DETERMINISTIC
AS
BEGIN
    RETURN TRUNC (SYSDATE);
END;


--ORA-02304 diring impdp object types with remap schema (see Doc ID 351519.1)

--when using DBMS_DATAPUMP API (see http://oradb-srv.wlv.ac.uk/E16655_01/server.121/e17639/dp_api.htm , http://www.orapro.net/media/67/collab11_pdp_whitepaper.pdf)

 DBMS_DATAPUMP.METADATA_TRANSFORM (HANDLE   => V_JOB_HANDLE,
                                          NAME     => 'OID',
                                          VALUE    => 0);
                                          
--when using impdp use parameter
TRANSFORM=oid:n

--ORA-04023 while SELECT FROM view

--run (Doc ID 1610514.1)
@?/rdbms/admin/utldtchk.sql;

--for all objects from output recompile them

-- Query with Analytic Windowing Function, Such as ROW_NUMBER OVER PARTITION BY, is Slower in Release 12.1.0.2 (Doc ID 2118138.1)
--https://blog.dbi-services.com/oracle-rownum-vs-rownumber-and-12c-fetch-first/

select * from
  (
  select count(1) over (partition by BAL_DATE,ACCOUNT_NO,OPEN_DATE) as f1, t.* from 
  
  
 (
with q0 as (SELECT /*+ OPT_PARAM('_fix_control' '14826303:OFF') */ ACCOUNT_NO,OPEN_DATE,CODE from (select ACCOUNT_NO,OPEN_DATE,CODE,row_number() over (partition by ACCOUNT_NO,OPEN_DATE order by ACTUAL_DATE desc) as f1 from CFTUSER.HP_FA_ACCOUNTS_BASE) where f1=1) 
 
 select 
t.ACTUAL_DATE as BAL_DATE,
acc.ACCOUNT_NO,
acc.OPEN_DATE,
case when t.BALSTATUS_ID = 'P' then t.PASSIV_NM else t.ACTIV_NM end as QTY_END,
case when t.BALSTATUS_ID = 'P' then t.PASSIV_EQ else t.ACTIV_EQ end as VAL_POS_END,
t.UPDATEDT
from 
CFTUSER.HP_FA_ACC_REST_OLTP_DY_BASE t
inner join q0 acc on acc.CODE=t.ACCOUNT_ID 
where t.ST_ACTUAL='A' and t.ACTUAL_DATE between to_date('01.01.2014','DD.MM.YYYY') and to_date('10.02.2014','DD.MM.YYYY'))
  t 
  ) where f1>1;

