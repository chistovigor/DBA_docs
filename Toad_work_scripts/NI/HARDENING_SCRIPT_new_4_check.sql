-- CORRECTED VERSION OF THE DB HARDENING SCRIPT
-- SEE MOS Doc ID 247093.1 FOR REFERENCE

SET ECHO off FEEDBACK off TIMING ON SERVEROUTPUT ON TERMOUT On pagesize 0 linesize 200 heading on
SPOOL hardening_script_new_check.log

prompt invalid objects before hardening
prompt

col OWNER for a30
col object_name for a30

SELECT
    owner,
    object_name,
    object_type,
    status,
    TO_CHAR(last_ddl_time,'dd-mm-yyyy hh24:mi:ss') last_ddl_time,
    TO_CHAR(TO_DATE(replace(timestamp,':',' '),'yyyy-mm-dd hh24 mi ss'),'dd-mm-yyyy hh24:mi:ss') timestamp
FROM
    dba_objects
WHERE
    status <> 'VALID'
ORDER BY
    1,
    2;

prompt

DECLARE
V_GRANT_STATEMENT VARCHAR2(4000);
V_REVOKE_STATEMENT VARCHAR2(4000);
BEGIN

DBMS_OUTPUT.ENABLE;
DBMS_OUTPUT.PUT_LINE('replacement grant statements based on the current dependencies '|| chr(13)||chr(10));
DBMS_OUTPUT.PUT_LINE('(this does not cover the use from dynamic sql, since that is not recorded in DBA_DEPENDENCIES)'|| chr(13)||chr(10));

  FOR REC IN
 (select distinct 'grant execute on '||
       referenced_name||' to '||owner grant_statement
    from dba_dependencies
               where
    referenced_owner in ('SYS','PUBLIC')     and
                     referenced_type in ('PACKAGE','SYNONYM')  and
                     referenced_name in
    ('DBMS_AQADM_SYSCALLS','DBMS_AQADM_SYS','DBMS_FILE_TRANSFER','DBMS_FILE_TRANSFER','UTL_FILE','UTL_HTTP','UTL_SMTP',
'UTL_TCP','DBMS_ADVISOR','DBMS_JAVA','DBMS_JOB','DBMS_LDAP','DBMS_LOB','DBMS_BACKUP_RESTORE','DBMS_SCHEDULER','DBMS_SQL','DBMS_XMLGEN','DBMS_XMLQUERY',
'UTL_FILE','UTL_INADDR','UTL_TCP','UTL_MAIL','UTL_SMTP','UTL_DBWS','UTL_ORAMTS','HTTPURITYPE','DBMS_SYS_SQL',
'DBMS_BACKUP_RESTORE','DBMS_REPACT_SQL_UTL','INITJVMAUX','DBMS_STREAMS_ADM_UTL','DBMS_AQADM_SYS',
'DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM','WWV_DBMS_SQL','WWV_EXECUTE_IMMEDIATE','DBMS_IJOB','DBMS_JAVA_TEST',
'DBMS_OBFUSCATION_TOOLKIT','DBMS_RANDOM') and
                     owner <> 'SYS' and
                     owner <> 'PUBLIC' order by 1)
 LOOP
  V_GRANT_STATEMENT:=REC.grant_statement;
  DBMS_OUTPUT.PUT_LINE('executing: '||REC.grant_statement);
  --execute immediate V_GRANT_STATEMENT;
 END LOOP;

DBMS_OUTPUT.PUT_LINE(chr(13)||chr(10));
DBMS_OUTPUT.PUT_LINE('REVOKE GRANTS'|| chr(13)||chr(10));

   FOR REC IN
 (select 'revoke execute on '||TABLE_NAME||' from public' revoke_statement from dba_tab_privs a where grantee='PUBLIC' and table_name in ('DBMS_AQADM_SYSCALLS','DBMS_AQADM_SYS','DBMS_FILE_TRANSFER','DBMS_FILE_TRANSFER','UTL_FILE','UTL_HTTP',
'UTL_SMTP','UTL_TCP','DBMS_ADVISOR','DBMS_JAVA','DBMS_JOB','DBMS_LDAP','DBMS_LOB',
'DBMS_BACKUP_RESTORE','DBMS_SCHEDULER','DBMS_SQL','DBMS_XMLGEN','DBMS_XMLQUERY','UTL_FILE','UTL_INADDR','UTL_TCP','UTL_MAIL','UTL_SMTP','UTL_DBWS','UTL_ORAMTS',
'HTTPURITYPE','DBMS_SYS_SQL','DBMS_BACKUP_RESTORE','DBMS_REPACT_SQL_UTL',
'INITJVMAUX','DBMS_STREAMS_ADM_UTL','DBMS_AQADM_SYS','DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM','WWV_DBMS_SQL',
'WWV_EXECUTE_IMMEDIATE','DBMS_IJOB','DBMS_JAVA_TEST','DBMS_OBFUSCATION_TOOLKIT','DBMS_RANDOM'))
  LOOP
  V_REVOKE_STATEMENT:=REC.revoke_statement;
  DBMS_OUTPUT.PUT_LINE('executing: '||REC.revoke_statement);
  --execute immediate V_REVOKE_STATEMENT;
 END LOOP;

END;
/

prompt
prompt invalid objects after hardening
prompt

col OWNER for a30
col object_name for a30

SELECT
    owner,
    object_name,
    object_type,
    status,
    TO_CHAR(last_ddl_time,'dd-mm-yyyy hh24:mi:ss') last_ddl_time,
    TO_CHAR(TO_DATE(replace(timestamp,':',' '),'yyyy-mm-dd hh24 mi ss'),'dd-mm-yyyy hh24:mi:ss') timestamp
FROM
    dba_objects
WHERE
    status <> 'VALID'
ORDER BY
    1,
    2;

SPOOL OFF

exit