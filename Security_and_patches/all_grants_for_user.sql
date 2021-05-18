SPOOL ALL_privs.sql
SELECT 'PROMPT *** ROLE PRIVILIGIES ***' FROM DUAL
UNION ALL
SELECT    'grant '
       || GRANTED_ROLE
       || ' to '
       || GRANTEE
       || DECODE (ADMIN_OPTION, 'YES', ' WITH Admin option')
       || ';'
  FROM DBA_ROLE_PRIVS
 WHERE UPPER (GRANTEE) IN ('DBMAN', 'ALTAIR')
UNION ALL
SELECT 'ALTER USER DBMAN DEFAULT ROLE ALL;' FROM DUAL
UNION ALL
SELECT 'ALTER USER ALTAIR DEFAULT ROLE ALL;' FROM DUAL
UNION ALL
SELECT 'PROMPT *** SYSTEM PRIVILIGIES ***' FROM DUAL
UNION ALL
SELECT    'grant '
       || privilege
       || ' to '
       || grantee
       || DECODE (ADMIN_OPTION, 'YES', ' WITH Admin option')
       || ';'
  FROM DBA_SYS_PRIVS
 WHERE UPPER (GRANTEE) IN ('DBMAN', 'ALTAIR')
UNION ALL
SELECT 'PROMPT *** TABLES PRIVILIGIES ***' FROM DUAL
UNION ALL
SELECT    'grant '
       || privilege
       || ' on "'
       || owner
       || '"."'
       || table_name
       || '" to "'
       || grantee
       || '" '
       || DECODE (grantable, 'YES', 'WITH Grant option')
       || ';'
  FROM dba_tab_privs
 WHERE    UPPER (owner) IN ('DBMAN', 'ALTAIR')
       OR UPPER (grantee) IN ('DBMAN', 'ALTAIR');
SPOOL OFF