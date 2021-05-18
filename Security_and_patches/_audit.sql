Для того, чтобы избавиться от излишних записей о LOGON/LOGOFF в таблице аудита нужно:

проверить текущие опции аудита (для AUDIT_OPTION=CREATE SESSION)

SELECT * FROM DBA_PRIV_AUDIT_OPTS;
SELECT * FROM ALL_DEF_AUDIT_OPTS;
SELECT * FROM DBA_STMT_AUDIT_OPTS;

выбрать пользователей, для которых больше всего попыток logon/logoff в БД:

select count(1),trunc(TIMESTAMP),USERNAME,ACTION_NAME from dba_audit_trail group by trunc(TIMESTAMP),USERNAME,ACTION_NAME order by 1 desc;

установить аудит только неуспешных попыток

NOAUDIT CREATE SESSION;
AUDIT CREATE SESSION WHENEVER NOT SUCCESSFUL;

установить аудит сессий пользователей, для которых это необходимо (UNLOADUSER - исключить)
(это будет видно в представлении DBA_STMT_AUDIT_OPTS)

select 'AUDIT CREATE SESSION by '||s.name||';' from sys.user$ s where S.NAME <> 'UNLOADUSER';

убрать аудит тех сессий, которые не нужны
NOAUDIT CREATE SESSION by user1 WHENEVER SUCCESSFUL; (или NOAUDIT CREATE SESSION by user1;)

Настройка аудита на уровне ОС

Для аудита действий пользователя SYS, а также пользователей с привилегиями SYSDBA или SYSOPER, необходимо применить следующие параметры инициализации:

sqlplus / as sysdba

create pfile ='/usr/oracle/app/product/11.2.0/dbhome_1/dbs/backup/initWEBDB.ora' from spfile;

alter system set AUDIT_SYS_OPERATIONS=TRUE scope=spfile; 
alter system set AUDIT_SYSLOG_LEVEL=LOCAL1.WARNING scope=spfile;

Для передачи событий аудита на сервер ArcSight на хосте с БД необходимо изменить конфигурацию службы syslog:

1. ОС AIX
a. Добавить ключ "-n" в параметры запуска syslog, который

b. Добавить в /etc/syslog.conf строку:
local1.warning;auth.info	@10.243.128.239
Перезапустить syslog:
refresh -s syslogd

2. ОС Linux
Добавить в /etc/syslog.conf строку:

vim /etc/rsyslog.conf

local1.warn		@10.243.128.239
Перезапустить syslog:

/etc/init.d/syslog restart

service rsyslog restart



Настройка аудита на уровне БД

/* Formatted on 20.02.2014 11:12:19 (QP5 v5.227.12220.39754) */
SELECT COUNT (1) FROM aud$;


CREATE SMALLFILE TABLESPACE "AUD1" DATAFILE '/mnt/oracle/tables/ARCHDB/aud01.dbf'
SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE 10G LOGGING EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;


BEGIN
   DBMS_AUDIT_MGMT.INIT_CLEANUP (
      AUDIT_TRAIL_TYPE           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
      DEFAULT_CLEANUP_INTERVAL   => 12);
END;
/


BEGIN
   DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION (
      audit_trail_type             => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
      audit_trail_location_value   => 'AUD1');
END;
/


CREATE INDEX aud$_s_e_a
   ON aud$ (sessionid, entryid, action#)
   INITRANS 10
   TABLESPACE AUD1;


CREATE INDEX aud$_ntimestamp#
   ON aud$ (ntimestamp#)
   INITRANS 10
   TABLESPACE AUD1;

SELECT owner, segment_name, tablespace_name
  FROM dba_segments
 WHERE tablespace_name = 'AUD1';

--1) Setup minimum audit settings

--ALTER SYSTEM SET audit_trail=DB SCOPE=SPFILE;

AUDIT UPDATE, DELETE ON sys.aud$ BY ACCESS;
AUDIT SELECT, UPDATE, DELETE ON sys.dba_common_audit_trail BY ACCESS;
AUDIT SESSION BY ACCESS;
AUDIT ALTER SESSION BY ACCESS;
AUDIT NETWORK BY ACCESS;
AUDIT SYSTEM GRANT BY ACCESS;
AUDIT SYSTEM AUDIT BY ACCESS;
AUDIT USER BY ACCESS;
AUDIT SESSION WHENEVER NOT SUCCESSFUL;

--2) Turn off unwanted redundancy options

NOAUDIT SELECT ANY DICTIONARY;
NOAUDIT SELECT ANY TABLE;
NOAUDIT SELECT TABLE;
NOAUDIT DELETE ANY TABLE;
NOAUDIT DELETE TABLE;
NOAUDIT INSERT ANY TABLE;
NOAUDIT INSERT TABLE;
NOAUDIT UPDATE ANY TABLE;
NOAUDIT UPDATE TABLE;
NOAUDIT EXECUTE ANY PROCEDURE;
NOAUDIT EXECUTE PROCEDURE;
NOAUDIT SELECT ANY SEQUENCE;
NOAUDIT SELECT SEQUENCE;
NOAUDIT LOCK ANY TABLE;
NOAUDIT LOCK TABLE;

--3) Check audit settings

SELECT * FROM DBA_OBJ_AUDIT_OPTS;

SELECT * FROM DBA_STMT_AUDIT_OPTS;

SELECT * FROM DBA_PRIV_AUDIT_OPTS;

SELECT * FROM ALL_DEF_AUDIT_OPTS;

--4) How to analyze audit logs

COL db_user FORMAT a18
COL os_user FORMAT a20
COL userhost FORMAT a30
COL OBJECT_NAME FORMAT a20
COL OBJECT_SCHEMA FORMAT a20

  SELECT TO_CHAR (extended_timestamp,
                  'YYYY-MON-DD HH24:MI:SS',
                  'NLS_DATE_LANGUAGE=AMERICAN')
            extended_timestamp,
         db_user,
         os_user,
         userhost,
         statement_type,
         object_name,
         object_schema,
         CASE returncode
            WHEN 0 THEN 'Successful'
            WHEN 1017 THEN 'Invalid username/password'
            ELSE TO_CHAR (returncode)
         END
            AS returncode
    FROM dba_common_audit_trail
   WHERE audit_type = 'Standard Audit'
ORDER BY extended_timestamp;

--Action names count

  SELECT t.action_name, returncode, COUNT (*)
    FROM dba_audit_trail t
GROUP BY t.action_name, returncode
ORDER BY 3;

--Удаление старых данных из журнала аудита

--1) Процедура удаления исторических данных в журнале аудита


CREATE OR REPLACE PROCEDURE delete_audit_rows (days INTEGER)
IS
BEGIN
   DELETE /*+ INDEX(a AUD$_NTIMESTAMP#) */
         FROM  sys.aud$ a
         WHERE a.ntimestamp# < (SYSDATE - days);

   DBMS_OUTPUT.put_line ('deleted ' || SQL%ROWCOUNT || ' rows...');
   COMMIT;
END;
/

--2) Проверка

EXEC delete_audit_rows(80);

--deleted 0 rows...


--3) Создание дЖоба для авто-удаления

--P.S. По умолчанию храним 7 суток или если надо другое время то уточняем у заказчика



EXEC dbms_scheduler.drop_job('"SYS"."DELETE_AUDIT_ROWS_JOB"',TRUE);

BEGIN
   sys.DBMS_SCHEDULER.create_job (
      job_name          => '"SYS"."DELETE_AUDIT_ROWS_JOB"',
      job_type          => 'PLSQL_BLOCK',
      job_class         => 'DEFAULT_JOB_CLASS',
      comments          => 'To delete rows from audit log',
      job_action        => 'begin delete_audit_rows(60); end;',
      repeat_interval   => 'FREQ=DAILY;INTERVAL=1;BYHOUR=6;BYMINUTE=0;BYSECOND=0',
      start_date        => SYSTIMESTAMP AT TIME ZONE '+4:00',
      auto_drop         => FALSE,
      enabled           => FALSE);
END;
/

EXEC sys.dbms_scheduler.enable('DELETE_AUDIT_ROWS_JOB' );

CREATE USER "ARCSIGHT" IDENTIFIED BY "Password0"
  DEFAULT TABLESPACE "AUD1"
  QUOTA UNLIMITED ON "AUD1"
  TEMPORARY TABLESPACE "TEMP"
  PROFILE "UNEXPIRED_USERS_PROFILE";

GRANT "CONNECT" TO "ARCSIGHT";
GRANT CREATE VIEW TO "ARCSIGHT";
GRANT CREATE TABLE TO "ARCSIGHT";
GRANT SELECT ON "SYS"."USER$" TO "ARCSIGHT";
GRANT SELECT ON "SYS"."V_$SESSION" TO "ARCSIGHT";
GRANT SELECT ON "SYS"."V_$INSTANCE" TO "ARCSIGHT";
GRANT SELECT ON "SYS"."DBA_USERS" TO "ARCSIGHT";
GRANT SELECT ON "SYS"."DBA_AUDIT_TRAIL" TO "ARCSIGHT";
GRANT SELECT ON "SYS"."DBA_COMMON_AUDIT_TRAIL" TO "ARCSIGHT";
GRANT EXECUTE ON "SYS"."DELETE_AUDIT_ROWS" TO "ARCSIGHT";
ALTER USER "ARCSIGHT" DEFAULT ROLE ALL;

NOAUDIT ALL BY arcsight;
NOAUDIT SELECT TABLE BY arcsight;
NOAUDIT SELECT ANY TABLE BY arcsight;

DROP TABLE arcsight.adm_connections;

CREATE TABLE arcsight.adm_connections
(
   s_id         NUMBER,
   user_name    VARCHAR2 (30),
   host_ip      VARCHAR2 (200),
   progr        VARCHAR2 (200),
   begin_date   DATE DEFAULT SYSDATE,
   end_date     DATE
);

CREATE OR REPLACE TRIGGER arcsight.OnLogonAC
   AFTER LOGON
   ON DATABASE
DECLARE
   pr   VARCHAR2 (64);
BEGIN
   BEGIN
      SELECT program
        INTO pr
        FROM sys.v_$session t
       WHERE audsid = SYS_CONTEXT ('USERENV', 'SESSIONID');

      INSERT INTO arcsight.adm_connections (s_id,
                                            user_name,
                                            host_ip,
                                            progr)
           VALUES (SYS_CONTEXT ('USERENV', 'SESSIONID'),
                   ora_login_user,
                   ora_client_ip_address,
                   pr);
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.PUT_LINE (SQLCODE);
         DBMS_OUTPUT.PUT_LINE (SQLERRM);
   END;
END;
/

SELECT owner, trigger_name, status
  FROM dba_triggers
 WHERE trigger_name = 'ONLOGONAC';

SELECT * FROM arcsight.adm_connections;

CREATE INDEX arcsight.ADM_CONNECTIONS_S_ID_IDX
   ON arcsight.ADM_CONNECTIONS (S_ID)
   INITRANS 32
   PCTFREE 20
   PARALLEL 4;

CREATE INDEX arcsight.ADM_CONNECTIONS_B_DT_IDX
   ON arcsight.ADM_CONNECTIONS (BEGIN_DATE)
   INITRANS 32
   PCTFREE 20
   PARALLEL 4;

SELECT owner,
       segment_name,
       segment_type,
       tablespace_name
  FROM dba_segments
 WHERE owner = 'ARCSIGHT';

CREATE OR REPLACE FORCE VIEW ARCSIGHT.AUDIT_ALL_STD
(
   AUDIT_TYPE,
   ACTION_NAME,
   SID,
   PROXY_SESSIONID,
   STATEMENTID,
   ENTRYID,
   EXTENDED_TIMESTAMP,
   GLOBAL_UID,
   USERNAME,
   CLIENT_ID,
   EXT_NAME,
   OS_USERNAME,
   USERHOST,
   OS_PROCESS,
   TERMINAL,
   INSTANCE_NUMBER,
   OBJECT_SCHEMA,
   OBJECT_NAME,
   ACTION,
   RETURNCODE,
   SCN,
   COMMENT_TEXT,
   SQL_TEXT,
   OBJ_PRIVILEGE,
   ADMIN_OPTION,
   OS_PRIVILEGE,
   GRANTEE,
   PRIV_USED,
   SES_ACTIONS,
   PROGRAM,
   HOST_NAME,
   VERSION,
   INSTANCE_NAME
)
AS
   SELECT /*+ FIRST_ROWS(100) */
         dba_common_audit_trail.AUDIT_TYPE,
          dba_common_audit_trail.STATEMENT_TYPE AS ACTION_NAME,
          dba_common_audit_trail.SESSION_ID AS SID,
          dba_common_audit_trail.PROXY_SESSIONID,
          dba_common_audit_trail.STATEMENTID,
          dba_common_audit_trail.ENTRYID,
          CAST (dba_common_audit_trail.EXTENDED_TIMESTAMP AS DATE)
             AS EXTENDED_TIMESTAMP,
          dba_common_audit_trail.GLOBAL_UID,
          dba_common_audit_trail.DB_USER AS USERNAME,
          dba_common_audit_trail.CLIENT_ID,
          dba_common_audit_trail.EXT_NAME,
          dba_common_audit_trail.OS_USER AS OS_USERNAME,
          dba_common_audit_trail.USERHOST,
          dba_common_audit_trail.OS_PROCESS,
          dba_common_audit_trail.TERMINAL,
          dba_common_audit_trail.INSTANCE_NUMBER,
          dba_common_audit_trail.OBJECT_SCHEMA,
          dba_common_audit_trail.OBJECT_NAME,
          dba_common_audit_trail.ACTION,
          dba_common_audit_trail.RETURNCODE,
          dba_common_audit_trail.SCN,
          dba_common_audit_trail.COMMENT_TEXT,
          dba_common_audit_trail.SQL_TEXT,
          dba_common_audit_trail.OBJ_PRIVILEGE,
          dba_common_audit_trail.ADMIN_OPTION,
          dba_common_audit_trail.OS_PRIVILEGE,
          dba_common_audit_trail.GRANTEE,
          dba_common_audit_trail.PRIV_USED,
          dba_common_audit_trail.SES_ACTIONS,
          adm_connections.progr AS PROGRAM,
          V$Instance.HOST_NAME,
          V$Instance.VERSION,
          V$Instance.INSTANCE_NAME
     FROM dba_common_audit_trail,
          V$Instance,
          arcsight.adm_connections adm_connections
    WHERE     adm_connections.s_id(+) = dba_common_audit_trail.SESSION_ID
          AND dba_common_audit_trail.AUDIT_TYPE IN ('Standard Audit')
   WITH READ ONLY;

CREATE OR REPLACE FORCE VIEW ARCSIGHT.AUDIT_ALL_SYS
(
   AUDIT_TYPE,
   ACTION_NAME,
   SID,
   PROXY_SESSIONID,
   STATEMENTID,
   ENTRYID,
   EXTENDED_TIMESTAMP,
   GLOBAL_UID,
   USERNAME,
   CLIENT_ID,
   EXT_NAME,
   OS_USERNAME,
   USERHOST,
   OS_PROCESS,
   TERMINAL,
   INSTANCE_NUMBER,
   OBJECT_SCHEMA,
   OBJECT_NAME,
   ACTION,
   RETURNCODE,
   SCN,
   COMMENT_TEXT,
   SQL_TEXT,
   OBJ_PRIVILEGE,
   ADMIN_OPTION,
   OS_PRIVILEGE,
   GRANTEE,
   PRIV_USED,
   SES_ACTIONS,
   PROGRAM,
   HOST_NAME,
   VERSION,
   INSTANCE_NAME
)
AS
   SELECT dba_common_audit_trail.AUDIT_TYPE,
          dba_common_audit_trail.STATEMENT_TYPE AS ACTION_NAME,
          dba_common_audit_trail.SESSION_ID AS SID,
          dba_common_audit_trail.PROXY_SESSIONID,
          dba_common_audit_trail.STATEMENTID,
          dba_common_audit_trail.ENTRYID,
          CAST (dba_common_audit_trail.EXTENDED_TIMESTAMP AS DATE)
             AS EXTENDED_TIMESTAMP,
          dba_common_audit_trail.GLOBAL_UID,
          dba_common_audit_trail.DB_USER AS USERNAME,
          dba_common_audit_trail.CLIENT_ID,
          dba_common_audit_trail.EXT_NAME,
          dba_common_audit_trail.OS_USER AS OS_USERNAME,
          dba_common_audit_trail.USERHOST,
          dba_common_audit_trail.OS_PROCESS,
          dba_common_audit_trail.TERMINAL,
          dba_common_audit_trail.INSTANCE_NUMBER,
          dba_common_audit_trail.OBJECT_SCHEMA,
          dba_common_audit_trail.OBJECT_NAME,
          dba_common_audit_trail.ACTION,
          dba_common_audit_trail.RETURNCODE,
          dba_common_audit_trail.SCN,
          dba_common_audit_trail.COMMENT_TEXT,
          dba_common_audit_trail.SQL_TEXT,
          dba_common_audit_trail.OBJ_PRIVILEGE,
          dba_common_audit_trail.ADMIN_OPTION,
          dba_common_audit_trail.OS_PRIVILEGE,
          dba_common_audit_trail.GRANTEE,
          dba_common_audit_trail.PRIV_USED,
          dba_common_audit_trail.SES_ACTIONS,
          'SYS Action' AS PROGRAM,
          V$Instance.HOST_NAME,
          V$Instance.VERSION,
          V$Instance.INSTANCE_NAME
     FROM dba_common_audit_trail, V$Instance
    WHERE dba_common_audit_trail.AUDIT_TYPE <> 'Standard XML Audit'
   WITH READ ONLY;

CREATE OR REPLACE FORCE VIEW ARCSIGHT.AUDIT_ALL
(
   AUDIT_TYPE,
   ACTION_NAME,
   SID,
   PROXY_SESSIONID,
   STATEMENTID,
   ENTRYID,
   EXTENDED_TIMESTAMP,
   GLOBAL_UID,
   USERNAME,
   CLIENT_ID,
   EXT_NAME,
   OS_USERNAME,
   USERHOST,
   OS_PROCESS,
   TERMINAL,
   INSTANCE_NUMBER,
   OBJECT_SCHEMA,
   OBJECT_NAME,
   ACTION,
   RETURNCODE,
   SCN,
   COMMENT_TEXT,
   SQL_TEXT,
   OBJ_PRIVILEGE,
   ADMIN_OPTION,
   OS_PRIVILEGE,
   GRANTEE,
   PRIV_USED,
   SES_ACTIONS,
   PROGRAM,
   HOST_NAME,
   VERSION,
   INSTANCE_NAME
)
AS
     SELECT 'Standard Audit' AS AUDIT_TYPE,
            dba_audit_trail.ACTION_NAME,
            dba_audit_trail.SESSIONID AS SID,
            dba_audit_trail.PROXY_SESSIONID,
            dba_audit_trail.STATEMENTID,
            dba_audit_trail.ENTRYID,
            CAST (dba_audit_trail.EXTENDED_TIMESTAMP AS DATE)
               AS EXTENDED_TIMESTAMP,
            dba_audit_trail.GLOBAL_UID,
            dba_audit_trail.USERNAME,
            dba_audit_trail.CLIENT_ID,
            'null' AS EXT_NAME,
            dba_audit_trail.OS_USERNAME,
            dba_audit_trail.USERHOST,
            dba_audit_trail.OS_PROCESS,
            dba_audit_trail.TERMINAL,
            dba_audit_trail.INSTANCE_NUMBER,
            dba_audit_trail.OWNER AS OBJECT_SCHEMA,
            dba_audit_trail.OBJ_NAME AS OBJECT_NAME,
            dba_audit_trail.ACTION,
            dba_audit_trail.RETURNCODE,
            dba_audit_trail.SCN,
            dba_audit_trail.COMMENT_TEXT,
            dba_audit_trail.SQL_TEXT,
            dba_audit_trail.OBJ_PRIVILEGE,
            dba_audit_trail.ADMIN_OPTION,
            'null' AS OS_PRIVILEGE,
            dba_audit_trail.GRANTEE,
            dba_audit_trail.PRIV_USED,
            dba_audit_trail.SES_ACTIONS,
            adm_connections.progr AS PROGRAM,
            V$Instance.HOST_NAME,
            V$Instance.VERSION,
            V$Instance.INSTANCE_NAME
       FROM dba_audit_trail, V$Instance, adm_connections
      WHERE adm_connections.s_id(+) = dba_audit_trail.SESSIONID
   ORDER BY extended_timestamp DESC;

CREATE OR REPLACE FORCE VIEW ARCSIGHT.AUDIT_USER
(
   USERNAME,
   USER_ID,
   STATUS,
   ACTION_DATE,
   HOST_NAME,
   VERSION,
   INSTANCE_NAME,
   NAME
)
AS
   SELECT d.username AS USERNAME,
          d.user_id AS USER_ID,
          d.account_status AS STATUS,
          d.lock_date AS ACTION_DATE,
          v.HOST_NAME,
          v.VERSION,
          v.INSTANCE_NAME,
          'UserAudit - User Locked' AS NAME
     FROM sys.dba_users d, V$Instance v
    WHERE d.account_status <> 'OPEN'
   UNION
   SELECT d.username AS USERNAME,
          d.user_id AS USER_ID,
          d.account_status AS STATUS,
          d.created AS ACTION_DATE,
          v.HOST_NAME,
          v.VERSION,
          v.INSTANCE_NAME,
          'UserAudit - User Created' AS NAME
     FROM sys.dba_users d, V$Instance v
   UNION
   SELECT d.username AS USERNAME,
          d.user_id AS USER_ID,
          d.account_status AS STATUS,
          u.ptime AS ACTION_DATE,
          v.HOST_NAME,
          v.VERSION,
          v.INSTANCE_NAME,
          'UserAudit - Password Changed' AS NAME
     FROM sys.dba_users d, V$Instance v, sys.user$ u
    WHERE d.user_id = u.user#
   ORDER BY ACTION_DATE DESC;

GRANT SELECT ON sys.v_$session TO arcsight;
GRANT SELECT ON sys.v_$instance TO arcsight;
GRANT SELECT ON sys.dba_users TO arcsight;
GRANT SELECT ON sys.user$ TO arcsight;
GRANT SELECT ON sys.dba_common_audit_trail TO arcsight;
GRANT SELECT ON sys.dba_audit_trail TO arcsight;

SELECT object_name, object_type, status
  FROM dba_objects
 WHERE owner = 'ARCSIGHT';

--create index aud$_ntimestamp# on aud$(ntimestamp#)  initrans 10 tablespace aud;

GRANT EXECUTE ON sys.delete_audit_rows TO arcsight;

CREATE OR REPLACE SYNONYM arcsight.delete_audit_rows FOR sys.delete_audit_rows;

CREATE OR REPLACE PROCEDURE delete_adm_connections_rows (days INTEGER)
IS
BEGIN
   DELETE /*+ INDEX(a ADM_CONNECTIONS_B_DT_IDX) */
         FROM  arcsight.ADM_CONNECTIONS a
         WHERE a.BEGIN_DATE < (SYSDATE - days);

   DBMS_OUTPUT.put_line ('deleted ' || SQL%ROWCOUNT || ' rows...');
   COMMIT;
END;
/

GRANT EXECUTE ON sys.delete_adm_connections_rows TO arcsight;

CREATE OR REPLACE SYNONYM arcsight.delete_adm_connections_rows
    FOR sys.delete_adm_connections_rows;

--    exec dbms_scheduler.drop_job('"SYS"."DELETE_ADMCON_ROWS_JOB"',TRUE);

BEGIN
   sys.DBMS_SCHEDULER.create_job (
      job_name          => '"SYS"."DELETE_ADMCON_ROWS_JOB"',
      job_type          => 'PLSQL_BLOCK',
      job_class         => 'DEFAULT_JOB_CLASS',
      comments          => 'To delete rows from audit log',
      job_action        => 'begin delete_adm_connections_rows(7); end;',
      repeat_interval   => 'FREQ=DAILY;INTERVAL=1;BYHOUR=6;BYMINUTE=0;BYSECOND=0',
      start_date        => SYSTIMESTAMP AT TIME ZONE '+4:00',
      auto_drop         => FALSE,
      enabled           => FALSE);
END;
/


EXEC sys.dbms_scheduler.enable('DELETE_ADMCON_ROWS_JOB' );


Отключение аудита входа в БД для отдельных пользователей:

-- to sswitch off audit session for all users
--

noaudit session;


--
-- Exclude all users ONL_%
--

SQL> select username from dba_users where username like 'ONL_%';


--
-- to switch on audit session for each user exclude SYS and ONL_%
--
begin
for l_q in ( select 'audit session by '||username||' by access' as l_cmd
             from dba_users
             where username not in ('SYS')
               and username not in (select username from dba_users where username like 'ONL_%'))
loop
 dbms_output.put_line(l_q.l_cmd);
 execute immediate l_q.l_cmd;
 dbms_output.put_line('done...');
end loop;
end;

select * from DBA_OBJ_AUDIT_OPTS;
select * from DBA_STMT_AUDIT_OPTS;
select * from DBA_PRIV_AUDIT_OPTS;
select * from ALL_DEF_AUDIT_OPTS;


-- Просмотр событий по типу и отключение аудита сессий системных пользователей

NOAUDIT network BY VSMC3DS; 
NOAUDIT SESSION by VSMC3DS;
NOAUDIT CREATE SESSION by VSMC3DS WHENEVER NOT SUCCESSFUL; --ICBSXPPROXY PROXY3DS
NOAUDIT CREATE SESSION by VSMC3DS WHENEVER SUCCESSFUL;

  SELECT COUNT (1),
         USERID,
         ACTION#,
         TO_CHAR (NTIMESTAMP#, 'DD-MM-YYYY HH24') as HOUR
    FROM aud$ a
   WHERE A.NTIMESTAMP# >= SYSDATE - 1
GROUP BY USERID, ACTION#,to_char(NTIMESTAMP#,'DD-MM-YYYY HH24')
having COUNT (1) > 1000
ORDER BY 4, 1 desc;

