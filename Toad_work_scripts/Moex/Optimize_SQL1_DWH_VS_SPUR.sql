select * from OUTST_LEONOVDV.POLK_TEST_SQL_PERFORM;

SELECT * FROM SQLTXADMIN.sqlt$_log_v order by 1 desc;

--1  --START sqltxtrxec.sql 4p15rmrcb2utx

biggest object FINMODEL.MV_FMD_TRADES_EQ

--201 

SELECT repdate,

   regn

  ,orgname

  ,curr_ncc_clearing_access AS curr_acc

  ,stock_main_ncc_clearing AS eq_main_acc

  ,can_repo_ck AS eq_repock_acc

  ,otc_access AS otc_acc

  ,forts_ncc_clearing_access AS forts_acc

  ,TO_CHAR(cap / 1000, 'fm999G990D0') AS cap

  ,TO_CHAR(uk / 1000, 'fm999G990D0') AS uk

  ,TO_CHAR(cap / DECODE(uk, 0, NULL, uk), 'fm999G990D0')

     AS cap_to_uk_ratio

FROM SPUR.v_mcp_ko_indexes_rep

WHERE cap > 0

AND cap < uk

AND repdate = ((trunc(sysdate - 40, 'MM')));

INP_REPORT_BANK_function
GET_ORG_ACCESS_TABLE
data_limits
REPORT_CALENDAR
SELECT VALUE FROM V_MAX_KAP_BANK_2014 WHERE ORGID = :B1 ;
v_kap
uds.organization

--301

select * from prot.IK_Megaview_Cur_Year;

BEE_STAT_TRANSFER
LOWER(CONNECTION_STATUS)
select DBMS_STATS.CREATE_EXTENDED_STATS('PROT','BEE_STAT_TRANSFER','(LOWER(CONNECTION_STATUS))') from dual;
select DBMS_STATS.CREATE_EXTENDED_STATS('PROT','BEE_STAT_TRANSFER','(LOWER(call_status))') from dual;
select DBMS_STATS.CREATE_EXTENDED_STATS('PROT','BEE_STAT_TRANSFER','(TO_NUMBER (TO_CHAR (call_time, ''HH24'')))') from dual;
exec DBMS_STATS.drop_extended_stats('PROT','BEE_STAT_TRANSFER','(LOWER(CONNECTION_STATUS))');

SELECT * FROM dba_stat_extensions WHERE  table_name = 'BEE_STAT_TRANSFER';



ik_ivr_stat_spec_evry_day
bee_ivr_stat
	PROT.BEE_STAT_TRANSFER
BEE_EMPLOYEES
BEE_EMPOT

select * from v$sql where sql_text like '%G_ANALYTIC.view_se_bl_trades_cube%';

--Таб 47mp8amrbk4qj /*+ PARALLEL(6) */ 