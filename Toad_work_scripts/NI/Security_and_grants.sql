-- clear schema

set linesize 250 pagesize 10000 heading off

prompt set feedback on
prompt spool clean_schema.log

  SELECT 'DROP ' || OBJECT_TYPE || ' ' || OWNER || '.' || OBJECT_NAME || ';' as sql_cmd
    FROM DBA_OBJECTS
   WHERE OWNER IN ('PROACT', 'PROACTRU') AND OBJECT_TYPE not in ('LOB','INDEX')
ORDER BY OWNER, OBJECT_TYPE, OBJECT_NAME;

prompt spool off
prompt exit

-- sensitive data inside DB

 SELECT OWNER,TABLE_NAME,COLUMN_NAME,DATA_LENGTH,NUM_DISTINCT
    FROM DBA_TAB_COLUMNS
   WHERE     OWNER = 'IRIS'
         AND COLUMN_NAME IN ('CARDNUMBER',
                             'CARD_NUMBER',
                             'CARDNUMBER2',
                             'TRACK_2_DATA',
                             'TRACK_2',
                             'T1_CVV',
                             'T2_CVV',
                             'CARD_EXPIRY',
                             'TRACKVALUE',
                             'TRACK',
                             'TRACK_DETAILID',
                             'FIRSTCARDNUMBER',
                             'PRIMARYCARDNUMBER',
                             'PIN')
         AND NUM_DISTINCT > 0
ORDER BY 1, 2, 3;

-- change profile to set the same password for expired case

ALTER PROFILE APPLICATION_PROFILE LIMIT
  SESSIONS_PER_USER UNLIMITED
  CPU_PER_SESSION UNLIMITED
  CPU_PER_CALL UNLIMITED
  CONNECT_TIME UNLIMITED
  IDLE_TIME UNLIMITED
  LOGICAL_READS_PER_SESSION UNLIMITED
  LOGICAL_READS_PER_CALL UNLIMITED
  COMPOSITE_LIMIT UNLIMITED
  PRIVATE_SGA UNLIMITED
  FAILED_LOGIN_ATTEMPTS 6
  PASSWORD_LIFE_TIME UNLIMITED
  PASSWORD_REUSE_TIME UNLIMITED--45
  PASSWORD_REUSE_MAX UNLIMITED--15
  PASSWORD_LOCK_TIME UNLIMITED
  PASSWORD_GRACE_TIME UNLIMITED--7
  PASSWORD_VERIFY_FUNCTION NULL;--VERIFY_FUNCTION;

-- Права пользователя и его ролей из БД через DBMS_METADATA

SELECT DBMS_METADATA.GET_DDL('USER','G_ERMAKOVAV') FROM DUAL; 
SELECT DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT','G_ERMAKOVAV') FROM DUAL;
SELECT DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT','G_ERMAKOVAV') FROM DUAL;
SELECT DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT','G_ANALYTIC') FROM DUAL; --???
-- для всех ролей пользователя (из вывода ROLE_GRANT)
SELECT DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT','R_ERMAKOVAV') FROM DUAL;
SELECT DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT','R_ERMAKOVAV') FROM DUAL;
SELECT DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT','R_ERMAKOVAV') FROM DUAL;

-- права для создания MVIEW на таблицах в чужой схеме

GRANT CREATE MATERIALIZED VIEW TO FINANCE_SRC; --CAN BE GRANTED VIA ROLE
GRANT GLOBAL QUERY REWRITE, ON COMMIT REFRESH to FINANCE_SRC;
GRANT SELECT ON DEST_SCHEMA.DEST_TABLE to FINANCE_SRC; --DIRECTLY

-- list of all db users

SELECT * FROM DBA_USERS order by account_status desc,user_id;

-- list of privileges

SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE in ('KETANB','SHAHBAZM') ORDER BY 1,2,3; --direct 
SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE in ('KETANB','SHAHBAZM') ORDER BY 1,2; --roles
SELECT * FROM DBA_TAB_PRIVS WHERE TABLE_NAME = 'V_EQ_GCPOOLASSET_HCNG' ORDER BY 1,2;
SELECT * FROM DBA_TAB_PRIVS WHERE TABLE_NAME = 'V_ISSUE_TODAY' AND GRANTOR = 'MDM_VIEWS' ORDER BY 1,2;
SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTED_ROLE = 'R_INFOSEC_31' ORDER BY 1;
SELECT * FROM ROLE_ROLE_PRIVS WHERE ROLE = 'R_INFOSEC_31' ORDER BY 2;

-- objects granted to roles of user

SELECT R.ROLE,TP.OWNER,TP.TABLE_NAME,TP.TYPE,TP.PRIVILEGE,TP.GRANTABLE
  FROM DBA_ROLE_PRIVS RP, DBA_ROLES R, DBA_TAB_PRIVS TP
 WHERE     RP.GRANTEE = 'MDATA_MDDEV_HADOOP'
       AND RP.GRANTED_ROLE = R.ROLE
       AND R.ORACLE_MAINTAINED <> 'Y'
       AND R.ROLE = TP.GRANTEE
       ORDER BY R.ROLE,TP.OWNER,TP.TYPE,TP.TABLE_NAME;

-- доступы пользователей к объектым из групп безопасности и через какие роли они даны

SELECT *
  FROM DBA_TAB_PRIVS
 WHERE GRANTEE IN 'R_SAMOYLOVAV';
 
-- ROLES WITH GRANTS TO VIEWS IN LIST 

  SELECT *
    FROM DBA_TAB_PRIVS
   WHERE TABLE_NAME IN ('V_EQ_TRADES',
                        'V_EQ_ORDERS',
                        'V_CURR_TRADES',
                        'V_CURR_ORDERS')
ORDER BY 1, 2, 3;

-- ROLES WITH GRANTS TO VIEWS IN LIST VIA ROLE

SELECT *
  FROM ROLE_ROLE_PRIVS
 WHERE GRANTED_ROLE IN (SELECT DISTINCT GRANTEE
                          FROM DBA_TAB_PRIVS
                         WHERE TABLE_NAME IN ('V_EQ_TRADES',
                                              'V_EQ_ORDERS',
                                              'V_CURR_TRADES',
                                              'V_CURR_ORDERS'));

-- USERS WITH GRANTS TO VIEWS IN LIST VIA ROLE

SELECT *
  FROM DBA_ROLE_PRIVS
 WHERE GRANTED_ROLE IN (SELECT DISTINCT GRANTEE
                          FROM DBA_TAB_PRIVS
                         WHERE TABLE_NAME IN ('V_EQ_TRADES',
                                              'V_EQ_ORDERS',
                                              'V_CURR_TRADES',
                                              'V_CURR_ORDERS')) ORDER BY 1;                                          
                                            
-- !!! USERS WITH GRANTS TO VIEWS IN LIST DIRECTLY OR VIA ROLE

  SELECT DISTINCT USERNAME
    FROM (SELECT RP.GRANTEE           USERNAME,
                 'WITH_ROLE ' || R.ROLE GRANTED,
                 P.OWNER,
                 P.TABLE_NAME,
                 P.GRANTOR,
                 P.PRIVILEGE,
                 P.GRANTABLE,
                 P.HIERARCHY,
                 P.TYPE
            FROM DBA_TAB_PRIVS P, DBA_ROLES R, DBA_ROLE_PRIVS RP
           WHERE     P.TABLE_NAME = 'V_CURR_RMS_DMUSAGE'
                 AND P.OWNER = 'INTERNALDM'
                 AND P.GRANTEE = R.ROLE
                 AND RP.GRANTED_ROLE = R.ROLE
          UNION
          SELECT U.USERNAME,
                 'DIRECTLY',
                 P.OWNER,
                 P.TABLE_NAME,
                 P.GRANTOR,
                 P.PRIVILEGE,
                 P.GRANTABLE,
                 P.HIERARCHY,
                 P.TYPE
            FROM DBA_USERS U, DBA_TAB_PRIVS P
           WHERE     P.TABLE_NAME = 'V_CURR_RMS_DMUSAGE'
                 AND P.OWNER = 'INTERNALDM'
                 AND P.GRANTEE = U.USERNAME
                 AND U.ACCOUNT_STATUS = 'OPEN')
  /* WHERE USERNAME NOT IN ('DMV',
                          'EXT_DB_ICDB',
                          'FINMODEL',
                          'FINANCE_INT',
                          'FINANCE_SRC',
                          'FINMODEL_MT',
                          'SYS',
                          'TLDWH',
                          'LDWH',
                          'UNLOADUSER_DATA',
                          'MSTR_BI_DATA',
                          'MSTR_BI',
                          'INTERNALREP_DEV',
                          'INTERNALREP') */
ORDER BY 1,
         3,
         4,
         2;
  
-- ROLES granted to DB (exclude AD users)

SELECT O.USERNAME,
       R.GRANTED_ROLE  DIRECT_ROLE,
       RR.GRANTED_ROLE ROLE_GRANTED_TO_DIRECT_ROLE
  FROM ROLE_ROLE_PRIVS RR, DBA_ROLE_PRIVS R, DBA_USERS O
 WHERE     O.USERNAME = R.GRANTEE
       AND RR.ROLE = R.GRANTED_ROLE
       AND O.USERNAME NOT IN (SELECT DISTINCT DB_USER
                                FROM V_OVD_MAPPINGS)
       AND O.USERNAME NOT IN ('SYS',
                              'SYSTEM',
                              'SYSBACKUP',
                              'XDB',
                              'APEX_050000',
                              'OUTLN',
                              'ARDB_USER',
                              'ARDBUSER')
UNION
SELECT DISTINCT
       O.USERNAME, R.GRANTED_ROLE DIRECT_ROLE, 'THIS ROLE GRANTED DIRECTLY'
  FROM DBA_ROLE_PRIVS R, DBA_USERS O
 WHERE     O.USERNAME = R.GRANTEE
       AND O.USERNAME NOT IN ('SYS',
                              'SYSTEM',
                              'SYSBACKUP',
                              'XDB',
                              'APEX_050000',
                              'OUTLN',
                              'ARDB_USER',
                              'ARDBUSER')
ORDER BY 1, 2, 3;

-- список НЕ AD пользователей с определенной ролью

  SELECT *
    FROM (SELECT O.USERNAME,
                 R.GRANTED_ROLE DIRECT_ROLE,
                 RR.GRANTED_ROLE ROLE_GRANTED_TO_DIRECT_ROLE
            FROM ROLE_ROLE_PRIVS RR, DBA_ROLE_PRIVS R, DBA_USERS O
           WHERE     O.USERNAME = R.GRANTEE
                 AND RR.ROLE = R.GRANTED_ROLE
                 AND O.USERNAME NOT IN (SELECT DISTINCT DB_USER
                                          FROM V_OVD_MAPPINGS)
                 AND O.USERNAME NOT IN ('SYS',
                                        'SYSTEM',
                                        'SYSBACKUP',
                                        'XDB',
                                        'APEX_050000',
                                        'OUTLN',
                                        'ARDB_USER',
                                        'ARDBUSER')
          UNION
          SELECT DISTINCT
                 O.USERNAME,
                 R.GRANTED_ROLE DIRECT_ROLE,
                 'THIS ROLE GRANTED DIRECTLY'
            FROM DBA_ROLE_PRIVS R, DBA_USERS O
           WHERE     O.USERNAME = R.GRANTEE
                 AND O.USERNAME NOT IN ('SYS',
                                        'SYSTEM',
                                        'SYSBACKUP',
                                        'XDB',
                                        'APEX_050000',
                                        'OUTLN',
                                        'ARDB_USER',
                                        'ARDBUSER')
                 AND O.USERNAME NOT IN (SELECT DISTINCT DB_USER
                                          FROM V_OVD_MAPPINGS))
   WHERE    DIRECT_ROLE = 'ROLE_INTERNALDM_FULL'
         OR ROLE_GRANTED_TO_DIRECT_ROLE = 'ROLE_INTERNALDM_FULL'
ORDER BY 1, 2, 3;

  SELECT *
    FROM DBA_TAB_PRIVS
   WHERE GRANTEE IN ('R_REDJEPOVTY', 'G_REDJEPOVTY')
   AND OWNER = 'INTERNALREP' AND TABLE_NAME LIKE 'V_FORTS%'
ORDER BY 1, 2;

-- writes the unified audit trail records in the SGA queue to disk

exec DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL;

select DBMS_AUDIT_MGMT.GET_AUDIT_COMMIT_DELAY from dual;

-- AUDIT DATA LOCATION (TABLESPACE) 

SELECT PARTITION_NAME, TABLESPACE_NAME FROM DBA_TAB_PARTITIONS WHERE TABLE_OWNER = 'AUDSYS';
SELECT LOB_PARTITION_NAME, TABLESPACE_NAME FROM DBA_LOB_PARTITIONS WHERE TABLE_OWNER = 'AUDSYS';

-- analyze audit data

-- UNIFIED AUDIT (used now!)

-- анализ размера LOB файлов АУДИТА

  SELECT MIN (MIN_TIME)
    FROM AUDSYS."CLI_SWP$915e9058$1$1" PARTITION (HIGH_PART)
   WHERE SID# = 535 AND SERIAL# = 24370
ORDER BY MIN_SCN;

-- записи аудита за последнее время с размером лобов для них

  SELECT COUNT (1),
         ROUND(SUM (DBMS_LOB.GETLENGTH (LOG_PIECE)) / 1024 / 1024,3) MB,
         TRUNC (MIN_TIME, 'MI')
    FROM AUDSYS."CLI_SWP$915e9058$1$1" PARTITION (HIGH_PART)
GROUP BY TRUNC (MIN_TIME, 'MI')
ORDER BY TRUNC (MIN_TIME, 'MI') DESC;

SELECT DBMS_LOB.GETLENGTH (LOG_PIECE),LOG_PIECE FROM AUDSYS."CLI_SWP$915e9058$1$1" PARTITION (HIGH_PART) WHERE TRUNC (MIN_TIME, 'MI') = to_date('23/08/2017 12:55:00','dd/mm/yyyy hh24:mi:ss') order by MAX_SCN;

-- за последнюю минуту
SELECT * FROM AUDSYS."CLI_SWP$915e9058$1$1" PARTITION (HIGH_PART) WHERE MIN_TIME >= sysdate - 3/24/60 order by MAX_SCN;

-- вывод и анализ сессий - рекордменов по размеру записей аудита (в МБ)

SELECT ROUND (SUM (DBMS_LOB.GETLENGTH (LOG_PIECE)) / 1024 / 1024) MB, SID#, SERIAL# FROM AUDSYS."CLI_SWP$915e9058$1$1" PARTITION (HIGH_PART) GROUP BY SID#, SERIAL# order by 1 desc;

  SELECT DISTINCT A.SID#,A.SERIAL#,TRUNC(MTIME,'HH24'),A.MB,B.MACHINE,B.MODULE,B.PROGRAM,B.USER_ID,U.USERNAME
    FROM (  SELECT ROUND (
                       SUM (DBMS_LOB.GETLENGTH (LOG_PIECE)) / 1024 / 1024)
                       MB,
                   SID#,
                   SERIAL#,
                   TRUNC (MIN_TIME, 'DD') MTIME
              FROM AUDSYS."CLI_SWP$915e9058$1$1" PARTITION (HIGH_PART)
          GROUP BY SID#, SERIAL#,TRUNC (MIN_TIME, 'DD') HAVING ROUND (SUM (DBMS_LOB.GETLENGTH (LOG_PIECE)) / 1024 / 1024) > 0) A,
         DBA_HIST_ACTIVE_SESS_HISTORY B, DBA_USERS U
   WHERE A.SID# = B.SESSION_ID AND A.SERIAL# = B.SESSION_SERIAL# AND TRUNC(B.SAMPLE_TIME,'DD') =  A.MTIME AND U.USER_ID = B.USER_ID
ORDER BY A.MB DESC,TRUNC(MTIME,'HH24');

--текущий размер лобов

  SELECT *
    FROM DBA_SEGMENTS
   WHERE SEGMENT_NAME = 'SYS_LOB0000020477C00014$$'
ORDER BY PARTITION_NAME; --24334499840	2970520	535 --24737153024	3019672	541 --24737153024	3019672	541

-- политики UNIFIED аудита

  SELECT *
    FROM AUDIT_UNIFIED_POLICIES
   WHERE (AUDIT_OPTION LIKE 'ALTER%'
          OR AUDIT_OPTION LIKE 'DROP%'
          OR AUDIT_OPTION LIKE 'CREATE%')
          --AND AUDIT_OPTION LIKE '%ANY%'
          AND AUDIT_OPTION_TYPE = 'STANDARD ACTION'
ORDER BY AUDIT_OPTION, POLICY_NAME;

-- изменения в ETL таблицах за сегодня (нет в UNIFIED_AUDIT_REPORT)

  SELECT * FROM UNIFIED_AUDIT_TRAIL
   WHERE     EVENT_TIMESTAMP >= TRUNC(SYSDATE)
         AND UNIFIED_AUDIT_POLICIES = 'AUDIT_CHANGE_ETL_TABLES'
ORDER BY EVENT_TIMESTAMP;

--
  SELECT COUNT (*),
         UNIFIED_AUDIT_POLICIES,
         USERHOST,
         DBUSERNAME,
         RETURN_CODE,
         ACTION_NAME
    FROM UNIFIED_AUDIT_TRAIL
GROUP BY UNIFIED_AUDIT_POLICIES,
         USERHOST,
         DBUSERNAME,
         RETURN_CODE,
         ACTION_NAME
ORDER BY 1 DESC,
         DBUSERNAME,
         RETURN_CODE,
         ACTION_NAME;
         
-- количество событий по политикам аудита по часам за текущий день

  SELECT TRUNC (EVENT_TIMESTAMP, 'HH24'),count(1),DBUSERNAME,USERHOST,UNIFIED_AUDIT_POLICIES
    FROM UNIFIED_AUDIT_TRAIL
   WHERE     EVENT_TIMESTAMP >=
                 TRUNC(SYSDATE)
         AND UNIFIED_AUDIT_POLICIES in ('AUDIT_SELECT_ON_INTERNALDM_REP','AUDIT_CHANGE_ETL_TABLES')
GROUP BY TRUNC (EVENT_TIMESTAMP, 'HH24'),DBUSERNAME,USERHOST,UNIFIED_AUDIT_POLICIES
ORDER BY 1,2 DESC; 

-- количество событий по политикам аудита по часам за предыдущий день из таблицы UNIFIED_AUDIT_REPORT (быстро)

  SELECT TRUNC (EVENT_TIMESTAMP, 'HH24'),count(1),DBUSERNAME,USERHOST,UNIFIED_AUDIT_POLICIES
    FROM UNIFIED_AUDIT_REPORT
   WHERE     EVENT_TIMESTAMP >=
                 TRUNC(SYSDATE-1)
         --AND UNIFIED_AUDIT_POLICIES in ('AUDIT_SELECT_ON_INTERNALDM_REP','AUDIT_CHANGE_ETL_TABLES')
GROUP BY TRUNC (EVENT_TIMESTAMP, 'HH24'),DBUSERNAME,USERHOST,UNIFIED_AUDIT_POLICIES
ORDER BY 1,2 DESC; 

  SELECT TRUNC (EVENT_TIMESTAMP, 'DD'),count(1),DBUSERNAME,USERHOST,UNIFIED_AUDIT_POLICIES
    FROM UNIFIED_AUDIT_REPORT
   WHERE     EVENT_TIMESTAMP >=
                 TRUNC(SYSDATE-1)
         --AND UNIFIED_AUDIT_POLICIES in ('AUDIT_SELECT_ON_INTERNALDM_REP','AUDIT_CHANGE_ETL_TABLES')
GROUP BY TRUNC (EVENT_TIMESTAMP, 'DD'),DBUSERNAME,USERHOST,UNIFIED_AUDIT_POLICIES
ORDER BY 1,2 DESC; 
         
  SELECT AUDIT_TYPE,
         SESSIONID,
         OS_USERNAME,
         EVENT_TIMESTAMP,
         USERHOST,
         TERMINAL,
         DBUSERNAME,
         EXTERNAL_USERID,
         AUTHENTICATION_TYPE,
         ACTION_NAME,
         CLIENT_PROGRAM_NAME,
         OS_PROCESS,
         TRANSACTION_ID,
         SCN,
         OBJECT_SCHEMA,
         OBJECT_NAME,
         --CAST (SUBSTR (SQL_TEXT, 1, 4000) AS VARCHAR2 (4000)) SQL_TEXT,
         --CAST (SUBSTR (SQL_BINDS, 1, 4000) AS VARCHAR2 (4000)) SQL_BINDS,
         SQL_TEXT,
         SQL_BINDS,
         SYSTEM_PRIVILEGE_USED,
         ROLE,
         UNIFIED_AUDIT_POLICIES
    FROM UNIFIED_AUDIT_TRAIL
   WHERE     EVENT_TIMESTAMP >= TRUNC(SYSDATE)
         AND UNIFIED_AUDIT_POLICIES = 'AUDIT_SELECT_ON_INTERNALDM_REP'
ORDER BY SCN;

SELECT * FROM UNIFIED_AUDIT_REPORT WHERE EVENT_TIMESTAMP >= TRUNC(SYSDATE-1) AND UNIFIED_AUDIT_POLICIES NOT IN ('AUDIT_SELECT_ON_INTERNALDM_REP','AUDIT_CHANGE_ETL_TABLES') ORDER BY EVENT_TIMESTAMP;
SELECT * FROM UNIFIED_AUDIT_REPORT WHERE UPPER(SQL_TEXT) LIKE '%EQ_CURR_ORDERS_TO_MIRROR%' AND EVENT_TIMESTAMP >= TRUNC(SYSDATE-2) ORDER BY EVENT_TIMESTAMP;
SELECT * FROM UNIFIED_AUDIT_REPORT WHERE UNIFIED_AUDIT_POLICIES = 'ORA_SECURECONFIG' AND EVENT_TIMESTAMP >= TRUNC(SYSDATE-2) ORDER BY EVENT_TIMESTAMP;
SELECT /*+ INDEX (UNIFIED_AUDIT_REPORT UNIFIED_AUDIT_REPORT_TIME_IDX) */ * FROM UNIFIED_AUDIT_REPORT WHERE UPPER(SQL_TEXT) LIKE '%N23_RF_ID_SEQ%' AND EVENT_TIMESTAMP >= TRUNC(SYSDATE-5) ORDER BY EVENT_TIMESTAMP;
         
SELECT MIN(EVENT_TIMESTAMP) FROM UNIFIED_AUDIT_TRAIL;
SELECT * FROM UNIFIED_AUDIT_TRAIL;
SELECT * FROM UNIFIED_AUDIT_TRAIL where EVENT_TIMESTAMP >= TRUNC(SYSDATE-1);
SELECT * FROM UNIFIED_AUDIT_TRAIL where EVENT_TIMESTAMP >= TRUNC(SYSDATE-1) and UNIFIED_AUDIT_POLICIES = 'AUDIT_SELECT_ON_INTERNALDM_REP';
SELECT * FROM UNIFIED_AUDIT_TRAIL where EVENT_TIMESTAMP >= TRUNC(SYSDATE-1) and upper(SQL_TEXT) like '%SRC_CLIENT_CODE%';
SELECT * FROM UNIFIED_AUDIT_TRAIL where EVENT_TIMESTAMP >= TRUNC(SYSDATE-3) and upper(SQL_TEXT) like '%MDM_MAN.SRC__%' ORDER BY EVENT_TIMESTAMP;
SELECT * FROM UNIFIED_AUDIT_TRAIL where EVENT_TIMESTAMP >= TRUNC(SYSDATE-14) and upper(SQL_TEXT) like '%OPTDEAL_BASE%';
SELECT * FROM UNIFIED_AUDIT_TRAIL where EVENT_TIMESTAMP >= TRUNC(SYSDATE-14) and upper(SQL_TEXT) like '%ALTER%TABLE%';
SELECT COUNT(1),AUDIT_TYPE,UNIFIED_AUDIT_POLICIES FROM UNIFIED_AUDIT_TRAIL where EVENT_TIMESTAMP >= TRUNC(SYSDATE-7) GROUP BY AUDIT_TYPE,UNIFIED_AUDIT_POLICIES ORDER BY 1 DESC;
SELECT COUNT(1),AUDIT_TYPE,UNIFIED_AUDIT_POLICIES FROM UNIFIED_AUDIT_TRAIL where EVENT_TIMESTAMP >= TRUNC(SYSDATE-7) and DBUSERNAME = 'OUTST_LEONOVDV' GROUP BY AUDIT_TYPE,UNIFIED_AUDIT_POLICIES ORDER BY 1 DESC;
SELECT * FROM UNIFIED_AUDIT_TRAIL where EVENT_TIMESTAMP >= TRUNC(SYSDATE-7) AND UNIFIED_AUDIT_POLICIES = 'ORA_LOGON_FAILURES' order by EVENT_TIMESTAMP;
SELECT * FROM UNIFIED_AUDIT_TRAIL where EVENT_TIMESTAMP >= TRUNC(SYSDATE-7) AND UNIFIED_AUDIT_POLICIES is NULL and AUDIT_TYPE = 'Standard' order by EVENT_TIMESTAMP;
  SELECT COUNT (1),
         OS_USERNAME,
         DBUSERNAME,
         USERHOST
    FROM UNIFIED_AUDIT_TRAIL
   WHERE     EVENT_TIMESTAMP >= TRUNC (SYSDATE - 7)
         AND UNIFIED_AUDIT_POLICIES IS NULL
         AND AUDIT_TYPE = 'Standard'
GROUP BY DBUSERNAME, OS_USERNAME,USERHOST
ORDER BY 1 DESC;
SELECT * FROM UNIFIED_AUDIT_TRAIL where ACTION_NAME LIKE 'LOG%';
SELECT * FROM UNIFIED_AUDIT_TRAIL where DBUSERNAME = 'OUTST_LEONOVDV' and UNIFIED_AUDIT_POLICIES is NULL order by EVENT_TIMESTAMP;
SELECT * FROM UNIFIED_AUDIT_TRAIL where AUDIT_TYPE = 'Standard' and EVENT_TIMESTAMP >= TRUNC(SYSDATE-1);
SELECT AUDIT_TYPE,count(1) FROM UNIFIED_AUDIT_TRAIL where EVENT_TIMESTAMP >= TRUNC(SYSDATE-7) group by AUDIT_TYPE order by count(1) desc;
select * from UNIFIED_AUDIT_TRAIL where UPPER(SQL_TEXT) like '%MOEX_OTC_CUSTOMER_LM%';

-- Аудит селектов пользователей к представлениям витрин

CREATE OR REPLACE VIEW AUDIT_REPORT_DATA_MARTS_WEEKLY AS
  SELECT CASE WHEN A.EXTERNAL_USERID IS NULL THEN 'USER IN DB !' ELSE REGEXP_REPLACE(A.EXTERNAL_USERID,'[A-Z,a-z,0-9,,,=]','') END DOMAIN_USER,
         A.DBUSERNAME,
         A.USERHOST,
         COUNT(1) NUMBER_OF_SQL_STATEMENTS,
         A.CLIENT_PROGRAM_NAME,
         TRUNC(A.EVENT_TIMESTAMP,'DD') SELECT_DATE,
         A.OBJECT_SCHEMA,
         A.OBJECT_NAME,
         V.INFOSEC_GROUP_ID,
         M.DESCRIPTION MARKET
    FROM UNIFIED_AUDIT_REPORT A,INTERNALDM_ADMIN.INFOSEC_VIEWS V,INTERNALDM_ADMIN.INFOSEC_MARKETS M
   WHERE A.UNIFIED_AUDIT_POLICIES <> 'AUDIT_CHANGE_ETL_TABLES'
   AND A.OBJECT_SCHEMA = V.VIEW_OWNER(+)
   AND A.OBJECT_NAME = V.VIEW_NAME(+)
   AND V.INFOSEC_MARKET = M.MARKET(+)
   GROUP BY CASE WHEN A.EXTERNAL_USERID IS NULL THEN 'USER IN DB !' ELSE REGEXP_REPLACE(A.EXTERNAL_USERID,'[A-Z,a-z,0-9,,,=]','') END,
         A.CLIENT_PROGRAM_NAME,
         TRUNC(A.EVENT_TIMESTAMP,'DD'),
         A.DBUSERNAME,
         A.USERHOST,
         A.OBJECT_SCHEMA,
         A.OBJECT_NAME,
         V.INFOSEC_GROUP_ID,
         M.DESCRIPTION
         HAVING A.OBJECT_SCHEMA NOT LIKE 'SYS%' AND A.OBJECT_NAME NOT LIKE 'from$_subquery$_%' AND TRUNC(A.EVENT_TIMESTAMP,'DD') >= TRUNC(SYSDATE-7)
ORDER BY TRUNC(A.EVENT_TIMESTAMP,'DD'),COUNT(1) DESC;

COMMENT ON COLUMN ARDB_USER.AUDIT_REPORT_DATA_MARTS_WEEKLY.DOMAIN_USER IS 'Доменное имя пользователя (для пользователей, авторизующихся в БД - USER IN DB !, имя см. в столбце DBUSERNAME)';
COMMENT ON COLUMN ARDB_USER.AUDIT_REPORT_DATA_MARTS_WEEKLY.DBUSERNAME IS 'Имя пользователя в БД (для пользователей, авторизующихся в домене - глобальный пользователь в БД)';
COMMENT ON COLUMN ARDB_USER.AUDIT_REPORT_DATA_MARTS_WEEKLY.USERHOST IS 'Имя ПК пользователя';
COMMENT ON COLUMN ARDB_USER.AUDIT_REPORT_DATA_MARTS_WEEKLY.NUMBER_OF_SQL_STATEMENTS IS 'Кол-во запросов пользователя к объекту витрины';
COMMENT ON COLUMN ARDB_USER.AUDIT_REPORT_DATA_MARTS_WEEKLY.CLIENT_PROGRAM_NAME IS 'Используемая клиентом для работы с БД программа';
COMMENT ON COLUMN ARDB_USER.AUDIT_REPORT_DATA_MARTS_WEEKLY.SELECT_DATE IS 'Дата выполнения запросов';
COMMENT ON COLUMN ARDB_USER.AUDIT_REPORT_DATA_MARTS_WEEKLY.OBJECT_SCHEMA IS 'Владелец объекта витрины';
COMMENT ON COLUMN ARDB_USER.AUDIT_REPORT_DATA_MARTS_WEEKLY.OBJECT_NAME IS 'Имя объекта витрины';
COMMENT ON COLUMN ARDB_USER.AUDIT_REPORT_DATA_MARTS_WEEKLY.INFOSEC_GROUP_ID IS 'Категория ИБ, к которой относится объект витрины в соответствии с матрицей кагегоризации объектов по группам информационной безопасности';
COMMENT ON COLUMN ARDB_USER.AUDIT_REPORT_DATA_MARTS_WEEKLY.MARKET IS 'Название рынка, к которому принадлежит объект';

-- FGA_AUDIT
select * from DBA_FGA_AUDIT_TRAIL;
select count(1),STATEMENT_TYPE,OBJECT_SCHEMA,OBJECT_NAME from DBA_FGA_AUDIT_TRAIL where TIMESTAMP >= sysdate-1 group by STATEMENT_TYPE,OBJECT_SCHEMA,OBJECT_NAME order by 1 desc;
select * from DBA_FGA_AUDIT_TRAIL where TIMESTAMP >= sysdate-1; 

select min(TIMESTAMP),max(TIMESTAMP),SQL_TEXT from DBA_FGA_AUDIT_TRAIL where TIMESTAMP >= trunc(sysdate) and POLICY_NAME = 'SWAP_REP_UD' group by SQL_TEXT;
select * from DBA_FGA_AUDIT_TRAIL where TIMESTAMP >= trunc(sysdate) and POLICY_NAME = 'SWAP_REP_UD';
select * from DBA_FGA_AUDIT_TRAIL where POLICY_NAME = 'SWAP_REP_UD';
select * from DBA_FGA_AUDIT_TRAIL where TIMESTAMP >= trunc(sysdate) and POLICY_NAME = 'SWAP_REP_UD' and OBJECT_NAME = 'SWAP_REP' and SQL_TEXT like 'DELETE%' order by TIMESTAMP; 

-- ACL

-- просмотр существующих листов:
SELECT * FROM dba_network_acls order by 1,4;
SELECT * FROM dba_network_acls where ACL like '%acl_permissions.xml' order by 1,4;
SELECT * FROM dba_network_acls where ACL like '%ldap_access.xml' order by 1,4;
SELECT * FROM dba_network_acls where ACL like '%web_service.xml' order by 1,4;

--для конкретного пользователя:
SELECT * FROM dba_network_acl_privileges order by PRINCIPAL;
SELECT * FROM dba_network_acl_privileges WHERE principal = 'COMPARE_ARDB';
SELECT * FROM dba_network_acl_privileges WHERE principal in ('MONITOR_PROD','BPEL');
SELECT * FROM dba_network_acl_privileges WHERE principal = 'MDATA_MDDEV_HADOOP';
 
--2) создание листа

BEGIN
   DBMS_NETWORK_ACL_ADMIN.create_acl (acl           => 'web_service.xml', -- or any other file name
                                      description   => 'network access to web service at host 172.19.174.202 port 5000',
                                      principal     => 'MDATA_MDDEV_HADOOP', -- the user name trying to access the network resource
                                      is_grant      => TRUE,
                                      privilege     => 'connect',
                                      start_date    => NULL,
                                      end_date      => NULL);
END;
/
commit;

--3) Добавление/удаление разрешений для пользователя в/ лист/а

BEGIN
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl         => 'ldap_access.xml',
                                         principal   => 'PROT',
                                         is_grant    => TRUE,
                                         privilege   => 'connect');
END;
/

BEGIN
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl         => 'ldap_access.xml',
                                         principal   => 'PROT',
                                         is_grant    => TRUE,
                                         privilege   => 'resolve');
END;
/

COMMIT;

BEGIN
   DBMS_NETWORK_ACL_ADMIN.DELETE_PRIVILEGE (acl         => 'ldap_access.xml',
                                         principal   => 'IDM_AUTH',
                                         is_grant    => TRUE,
                                         privilege   => 'connect');
END;
/

BEGIN
   DBMS_NETWORK_ACL_ADMIN.DELETE_PRIVILEGE (acl         => 'ldap_access.xml',
                                         principal   => 'IDM_AUTH',
                                         is_grant    => TRUE,
                                         privilege   => 'resolve');
END;
/

COMMIT;


--4) Добавление сервера в лист (Only one ACL can be assigned to a specific host and port-range combination)

BEGIN
   DBMS_NETWORK_ACL_ADMIN.assign_acl (acl          => 'acl_permissions.xml',
                                      HOST         => '172.19.174.201',
                                      lower_port   => 5555,
                                      upper_port   => 5555);
END;
/

COMMIT;

--4) Удаление сервера из листа

BEGIN
   DBMS_NETWORK_ACL_ADMIN.unassign_acl (acl          => 'ldap_access.xml',
                                      HOST         => '172.22.10.28',
                                      lower_port   => 17002,
                                      upper_port   => 17002);
END;
/

COMMIT;

--5) Добавление разрешений пользователю (можно не запускать):

grant execute on UTL_SMTP  to BPEL;
grant execute on UTL_TCP   to BPEL;
grant execute on UTL_INADDR   to BPEL;
grant execute on UTL_HTTP   to BPEL;


-- Гладников (доступы пользователей в БД)


select
--distinct(owner_)
user_
,schema_
,table_
,grant_
,type_
,direct_or_role_
from
(
 -- 1-ая часть
 -- доступы на прямую
 (select --u.created, u.lock_date, 
 pr.grantee user_
 ,pr.owner schema_
 ,pr.table_name table_
 --,pr.grantor
 ,pr.privilege grant_
 ,pr.type type_
 ,'direct grant' direct_or_role_
 from dba_tab_privs pr
 )
 union all
 (
 -- 2-ая часть
 -- доступы через через роли
  select 
 r.grantee user_
 --,r.granted_role 
 ,rl.schema schema_
 ,rl.table_name table_
 ,rl.privilege grant_
 ,rl.type type_
 ,'role grant' direct_or_role_
from 
 dba_role_privs r
,(select
rt.role role 
,rt.table_name table_name
,rt.privilege privilege
,o.object_type type
,o.owner schema
from 
role_tab_privs rt
,dba_objects o
where
1=1
and rt.table_name = o.object_name
) rl
where
1=1
and r.granted_role = rl.role
 )
) a
where a.user_ in 
(select u.username from dba_users u 
where 1=1
and u.account_status in ('EXPIRED','OPEN')-- отсеиваем юзеров в статусе EXPIREDandLOCKED, у них  u.lock_date = u.created
)
and schema_ not in ('SYS','SYSTEM','DBSNMP','XDB','APPQOSSYS','PUBLIC') -- отсеиваем системные схемы
and user_ in ('G_ZAKROYSHCHIKOVVN')
--and schema_ in ('INTERNALDM','INTERNALPEP') -- закомментировать для вывода всех пользователей
and user_ in (select USERNAME from dba_users where PASSWORD = 'GLOBAL') --закомментировать для вывода всех пользователей в БД, иначе, только с глобальной аутентификацией
order by user_,schema_,grant_,table_

select * from dba_users;

-- ENABLE UNIFIED AUDIT

--enable (shutdown DB first)

cd $ORACLE_HOME/rdbms/lib
make -f ins_rdbms.mk uniaud_on ioracle ORACLE_HOME=$ORACLE_HOME

--disable (shutdown DB first)

cd $ORACLE_HOME/rdbms/lib
make -f ins_rdbms.mk uniaud_off ioracle ORACLE_HOME=$ORACLE_HOME

-- set last archive timestamp for other types of audit

SELECT * FROM DBA_AUDIT_MGMT_LAST_ARCH_TS ORDER BY 3;
SELECT AUDIT_TRAIL,LAST_ARCHIVE_TS FROM DBA_AUDIT_MGMT_LAST_ARCH_TS ORDER BY LAST_ARCHIVE_TS;

-- cleanup jobs for audit records

SELECT * FROM DBA_AUDIT_MGMT_CLEANUP_JOBS;
SELECT * FROM DBA_AUDIT_MGMT_CLEAN_EVENTS;
SELECT * FROM DBA_AUDIT_MGMT_CONFIG_PARAMS ORDER BY AUDIT_TRAIL;
SELECT DISTINCT POLICY_NAME FROM AUDIT_UNIFIED_POLICIES;
SELECT * FROM AUDIT_UNIFIED_ENABLED_POLICIES;
SELECT AUDIT_OPTION,AUDIT_OPTION_TYPE FROM AUDIT_UNIFIED_POLICIES where POLICY_NAME = 'ORA_ACCOUNT_MGMT' 
MINUS
SELECT AUDIT_OPTION,AUDIT_OPTION_TYPE  FROM AUDIT_UNIFIED_POLICIES where POLICY_NAME = 'ORA_CIS_RECOMMENDATIONS';

-- enables UNIFIED policies (manually by me)

--manually created
AUDIT POLICY AUDIT_CHANGE_DB_STRUCTURE;
AUDIT POLICY AUDIT_CHANGE_ETL_TABLES;
AUDIT POLICY AUDIT_SELECT_ON_INTERNALDM_REP;
--DEFAULT policies
AUDIT POLICY ORA_ACCOUNT_MGMT;
AUDIT POLICY ORA_CIS_RECOMMENDATIONS;
AUDIT POLICY ORA_DATABASE_PARAMETER;
AUDIT POLICY ORA_LOGON_FAILURES;
AUDIT POLICY ORA_RAS_POLICY_MGMT;
AUDIT POLICY ORA_RAS_SESSION_MGMT;
AUDIT POLICY ORA_SECURECONFIG;

-- exclude USER and HOST from UNIFIED audit policy example (write in condition)

lower(SYS_CONTEXT('USERENV','OS_USER')) not in ('gusevag') and SYS_CONTEXT('USERENV','HOST') not in ('asbpel','ksapp-appdl0-fmb','ksapp-appdlr-fhb','asbpeldev','NT_D\CHISTOV15','mr01vm01.moex.com','mr01vm02.moex.com','var01vm01.moex.com','var01vm02.moex.com') 

 
EXEC DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,SYSTIMESTAMP-180);
EXEC DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,ADD_MONTHS(SYSTIMESTAMP,-2),1);

--move audit in other TS (AUDIT_DATA)

BEGIN
DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION(
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_DB_STD,
audit_trail_location_value => 'AUDIT_DATA');
END;

BEGIN
DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION(
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
audit_trail_location_value => 'AUDIT_DATA');
END;

-- writes the unified audit trail records in the SGA queue to disk

exec DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL;

select DBMS_AUDIT_MGMT.GET_AUDIT_COMMIT_DELAY from dual;

--Step 3: Initialize the Cleanup process and set the Cleanup interval

begin
DBMS_AUDIT_MGMT.INIT_CLEANUP(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,
DEFAULT_CLEANUP_INTERVAL => 24 );
end;
/

begin
DBMS_AUDIT_MGMT.INIT_CLEANUP(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
DEFAULT_CLEANUP_INTERVAL => 24 );
end;
/

begin
DBMS_AUDIT_MGMT.INIT_CLEANUP(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD,
DEFAULT_CLEANUP_INTERVAL => 24 );
end;
/

--Deinitialize if needed
exec DBMS_AUDIT_MGMT.DEINIT_CLEANUP(AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL);
exec DBMS_AUDIT_MGMT.DEINIT_CLEANUP(AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD);

--Step 4: Set the archive timestamp to sysdate-365*2. This tells the clean-up job to delete everything older than 2 years.

begin
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_DB_STD,
LAST_ARCHIVE_TIME => add_months(sysdate,-12));
end;
/

begin
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
LAST_ARCHIVE_TIME => add_months(sysdate,-12));
end;
/

begin
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,
LAST_ARCHIVE_TIME => ADD_MONTHS(sysdate,-2));
end;
/

--Step 5: Create the Purge job
 
begin
DBMS_AUDIT_MGMT.CREATE_PURGE_JOB (
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,
AUDIT_TRAIL_PURGE_INTERVAL => 24,
AUDIT_TRAIL_PURGE_NAME => 'AUDIT_TRAIL_PURGE',
USE_LAST_ARCH_TIMESTAMP => TRUE );
end;
/

begin
DBMS_AUDIT_MGMT.CREATE_PURGE_JOB (
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
AUDIT_TRAIL_PURGE_INTERVAL => 24,
AUDIT_TRAIL_PURGE_NAME => 'AUDIT_TRAIL_UNIFIED_PURGE',
USE_LAST_ARCH_TIMESTAMP => TRUE );
end;
/

--Step 6: schedule a job to automatically advance the last_archive_timestamp

grant audit_admin to ardb_user;

CREATE OR REPLACE procedure ARDB_USER.set_archive_retention (retention in number default 180) as
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
LAST_ARCHIVE_TIME => SYSDATE - retention/4,
rac_instance_number => 1);
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
AUDIT_TRAIL_TYPE  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,
LAST_ARCHIVE_TIME => SYSDATE - retention/4,
rac_instance_number => 1);
--clean UNIFUED AUDIT TRAIL MANUALY IF PURGE JOB IS NOT WORKED
DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(51,TRUE);
end;
/

select * from unified_audit_trail where object_name='DBMS_AUDIT_MGMT' and object_schema='SYS' and sql_text like '%DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL%';


