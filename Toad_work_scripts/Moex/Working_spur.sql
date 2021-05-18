-- open user accounts

select USERNAME,CREATED from dba_users where ACCOUNT_STATUS = 'OPEN' and USERNAME not like 'SYS%' order by 1;

-- ASH

SELECT * FROM SESSION_INFO; --when v$session select fails with partial multibyte character error
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SQL_ID = '6gby6vtz7rw4h' order by 1;
select * from DBA_HIST_ACTIVE_SESS_HISTORY where SESSION_ID = 1061 and SAMPLE_TIME between sysdate-2/24 and sysdate;
SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID = '3vcrn45xyy8uu' order by SAMPLE_TIME and SAMPLE_TIME >= sysdate-1 order by SAMPLE_TIME;
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_ID = '0uvw9r1vkt70b';
SELECT * FROM DBA_HIST_SQLTEXT WHERE SQL_TEXT LIKE 'MERGE INTO SL_ORGANISATION_BASE%';
SELECT * FROM DBA_HIST_SQLSTAT WHERE SQL_ID = '3vcrn45xyy8uu' order by SNAP_ID;
SELECT * FROM DBA_HIST_SNAPSHOT where SNAP_ID = 26724;--order by 1;
SELECT * FROM DBA_HIST_SQL_PLAN WHERE SQL_ID = 'gdgrbgh55ta4v' order by id;
SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SESSION_ID = 2349;
SELECT * FROM DBA_HIST_SQLTEXT WHERE lower(SQL_TEXT) like '%select /*+ dynamic_sampling(0) */%';
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE SESSION_ID = 1061 and SAMPLE_TIME between sysdate-2/24 and sysdate;
SELECT * FROM V$ACTIVE_SESSION_HISTORY WHERE EVENT = 'enq: TX - row lock contention' and SAMPLE_TIME between sysdate-2/24 and sysdate;


--

SELECT DISTINCT TABLESPACE_NAME
  FROM DBA_SEGMENTS
 WHERE OWNER IN ('LOADER_NCC',
                 'LOADER_VFD',
                 'REPGATE',
                 'REPGATE_API',
                 'REPGATE_COGNOS_DATA',
                 'REPGATE_DATA',
                 'REPGATE_FMD_DATA',
                 'REPGATE_OEBS_DATA',
                 'REPGATE_TEST',
                 'REPGATE_TEST_API',
                 'REPGATE_TEST_DATA');

-- tablespace usage metric 

select * from DBA_TABLESPACE_USAGE_METRICS where TABLESPACE_NAME = 'FINANCE_SRC';

-- DB connection rate by user

  SELECT USERNAME, USERHOST, COUNT (1),TRUNC(TIMESTAMP) DAY,ACTION_NAME,TO_CHAR(TIMESTAMP,'hh24') HOUR
    FROM DBA_AUDIT_TRAIL
   WHERE TIMESTAMP >= TRUNC (SYSDATE)-1 AND ACTION_NAME LIKE 'LOG%'
GROUP BY USERNAME, USERHOST,TRUNC(TIMESTAMP),TO_CHAR(TIMESTAMP,'hh24'),ACTION_NAME
HAVING COUNT (1) > 100
ORDER BY COUNT (1) DESC;

select sum(aa),DAY,USERNAME from
(select sum(cnt) aa,DAY,USERNAME,ACTION_NAME from
  (SELECT USERNAME, USERHOST, COUNT (1) cnt,TRUNC(TIMESTAMP) DAY,ACTION_NAME,TO_CHAR(TIMESTAMP,'hh24') HOUR
    FROM DBA_AUDIT_TRAIL
   WHERE TIMESTAMP >= TRUNC (SYSDATE)-7 AND ACTION_NAME LIKE 'LOG%'
GROUP BY USERNAME, USERHOST,TRUNC(TIMESTAMP),TO_CHAR(TIMESTAMP,'hh24'),ACTION_NAME
HAVING COUNT (1) >= 10)
HAVING ACTION_NAME = 'LOGON'
group by DAY,USERNAME,ACTION_NAME)
group by DAY,USERNAME
HAVING sum(aa) > 3600
ORDER BY DAY,sum(aa) DESC;

SELECT * FROM DBA_AUDIT_TRAIL WHERE TIMESTAMP > SYSDATE-2/24;

SELECT * FROM DBA_AUDIT_TRAIL WHERE TIMESTAMP > SYSDATE-30 AND USERNAME = 'MAYKOVAV';

-- session and processes

SELECT COUNT(1) FROM V$PROCESS;
  
SHO PARAMETER PROCESS
  
SELECT COUNT(1) FROM V$SESSION ;
select * from v$session;

select * from session_info; --when v$session select fails with partial multibyte character error

SELECT COUNT(1),STATUS,SCHEMANAME,PROGRAM,MACHINE FROM V$SESSION GROUP BY  STATUS,SCHEMANAME,PROGRAM,MACHINE ORDER BY 1 DESC;

-- DB size

  SELECT OWNER, SEGMENT_TYPE, ROUND (SUM (BYTES) / 1024 / 1024 / 1024, 0) GB
    FROM DBA_SEGMENTS
   WHERE OWNER NOT LIKE 'SYS%'
GROUP BY OWNER, SEGMENT_TYPE
  HAVING ROUND (SUM (BYTES) / 1024 / 1024 / 1024, 2) > 5
ORDER BY 1,2,3 DESC;
 
--MAYKOVAV

select * from DBA_HIST_SQLTEXT where SQL_ID in (select distinct(SQL_ID) from DBA_HIST_ACTIVE_SESS_HISTORY where USER_ID = 576);

select distinct SQL_TEXT from v$sql where SQL_ID in (select distinct(SQL_ID) from DBA_HIST_ACTIVE_SESS_HISTORY where USER_ID = 576);

SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID in (select distinct(SQL_ID) from DBA_HIST_ACTIVE_SESS_HISTORY where USER_ID = 576); 

select * from dba_users where USERNAME = 'MAYKOVAV';

select * from DBA_HIST_ACTIVE_SESS_HISTORY where USER_ID = 576;

select distinct(SQL_ID) from DBA_HIST_ACTIVE_SESS_HISTORY where USER_ID = 576;

select TRDACCTYPE, Description from internaldm.v_curr_TRDACCTYPES order by Description; 
select count(*) from internaldm.v_curr_CLIENTCODES where 1=1 and ( regexp_like (upper(clientcodeid),'.*44521.*') or regexp_like (upper(clientcode),'.*44521.*') or regexp_like (upper(details),'.*44521.*') or regexp_like (upper(subdetails),'.*44521.*') )  and firmid in ('MB0007400000' ); 
select count(*) from internaldm.v_curr_CLIENTCODES where 1=1 and ( regexp_like (upper(clientcodeid),'.*540612.*') or regexp_like (upper(clientcode),'.*540612.*') or regexp_like (upper(details),'.*540612.*') or regexp_like (upper(subdetails),'.*540612.*') );
select count(*) from internaldm.v_curr_CLIENTCODES where 1=1 and ( regexp_like (upper(clientcodeid),'.*5406121.*') or regexp_like (upper(clientcode),'.*5406121.*') or regexp_like (upper(details),'.*5406121.*') or regexp_like (upper(subdetails),'.*5406121.*') );
select count(*) from internaldm.v_curr_CLIENTCODES where 1=1 and ( regexp_like (upper(clientcodeid),'.*54061.*') or regexp_like (upper(clientcode),'.*54061.*') or regexp_like (upper(details),'.*54061.*') or regexp_like (upper(subdetails),'.*54061.*') ) ;
select count(*) from internaldm.v_curr_CLIENTCODES where 1=1 and ( regexp_like (upper(clientcodeid),'.*5406121446.*') or regexp_like (upper(clientcode),'.*5406121446.*') or regexp_like (upper(details),'.*5406121446.*') or regexp_like (upper(subdetails),'.*5406121446.*') );

--SMART scan slower then full scan

alter session set max_dump_file_size = unlimited;
ALTER SESSION SET TRACEFILE_IDENTIFIER = "SESSION_666";

ALTER SESSION SET EVENTS '10046 trace name context forever, level 12';

  SELECT T.*,
         (SELECT SUM (M.INITIALMARGIN)
            FROM OTC_INITIAL_MARGIN_BASE M
           WHERE M.CONTRACT_ID IN (SELECT CLEARING_CONTRACT_ID
                                     FROM VW_CONTRACT_OTC_BASE C
                                    WHERE C.CUSTID = T.CUSTID))
             AS COLLATERAL_VALUE
    FROM SEL_LOG T
ORDER BY COLLATERAL_VALUE;

alter system set events '10046 trace name context off';

OTC_INITIAL_MARGIN_BASE





