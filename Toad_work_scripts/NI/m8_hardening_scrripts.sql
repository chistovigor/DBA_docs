spool /export/home/oracle/grants1.sql
select 'grant execute on '||TABLE_NAME||' to '||b.username||';' from dba_tab_privs a,dba_users b where grantee='PUBLIC' and
table_name in ('DBMS_AQADM_SYSCALLS','DBMS_AQADM_SYS','DBMS_FILE_TRANSFER','DBMS_FILE_TRANSFER','UTL_FILE','UTL_HTTP','UTL_SMTP',
'UTL_TCP','DBMS_ADVISOR','DBMS_JAVA','DBMS_JOB','DBMS_LDAP','DBMS_LOB','DBMS_BACKUP_RESTORE','DBMS_SCHEDULER','DBMS_SQL','DBMS_XMLGEN','DBMS_XMLQUERY',
'UTL_FILE','UTL_INADDR','UTL_TCP','UTL_MAIL','UTL_SMTP','UTL_DBWS','UTL_ORAMTS','HTTPURITYPE','DBMS_SYS_SQL',
'DBMS_BACKUP_RESTORE','DBMS_REPACT_SQL_UTL','INITJVMAUX','DBMS_STREAMS_ADM_UTL','DBMS_AQADM_SYS',
'DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM','WWV_DBMS_SQL','WWV_EXECUTE_IMMEDIATE','DBMS_IJOB','DBMS_JAVA_TEST',
'DBMS_OBFUSCATION_TOOLKIT','DBMS_RANDOM');
spool off;


spool /export/home/oracle/grants2.sql
select 'grant select on '||TABLE_NAME||' to '||b.username||';' from dba_tab_privs a,dba_users b where grantee='PUBLIC' and table_name in
('USER_ROLE_PRIVS','USER_TAB_PRIVS','ALL_SOURCE','ROLE_ROLE_PRIVS');
spool off


spool /export/home/oracle/revoke1.sql
select 'revoke execute on '||TABLE_NAME||' from public;' from dba_tab_privs a,dba_users b where grantee='PUBLIC' and table_name in ('DBMS_AQADM_SYSCALLS','DBMS_AQADM_SYS','DBMS_FILE_TRANSFER','DBMS_FILE_TRANSFER','UTL_FILE','UTL_HTTP',
'UTL_SMTP','UTL_TCP','DBMS_ADVISOR','DBMS_JAVA','DBMS_JOB','DBMS_LDAP','DBMS_LOB',
'DBMS_BACKUP_RESTORE','DBMS_SCHEDULER','DBMS_SQL','DBMS_XMLGEN','DBMS_XMLQUERY','UTL_FILE','UTL_INADDR','UTL_TCP','UTL_MAIL','UTL_SMTP','UTL_DBWS','UTL_ORAMTS',
'HTTPURITYPE','DBMS_SYS_SQL','DBMS_BACKUP_RESTORE','DBMS_REPACT_SQL_UTL',
'INITJVMAUX','DBMS_STREAMS_ADM_UTL','DBMS_AQADM_SYS','DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM','WWV_DBMS_SQL',
'WWV_EXECUTE_IMMEDIATE','DBMS_IJOB','DBMS_JAVA_TEST','DBMS_OBFUSCATION_TOOLKIT','DBMS_RANDOM');
spool off


spool /export/home/oracle/revoke2.sql
select 'revoke select on '||TABLE_NAME||' from public;' from dba_tab_privs a,dba_users b where grantee='PUBLIC' and
table_name in ('USER_ROLE_PRIVS','USER_TAB_PRIVS','ALL_SOURCE','ROLE_ROLE_PRIVS');
spool off



