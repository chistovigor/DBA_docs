cd $ORACLE_HOME/rdbms/admin

set heading off feedback off termout off trimspool on

SELECT OBJECT_NAME, LAST_DDL_TIME, OWNER
  FROM all_objects
 WHERE OWNER = 'AQJAVA' AND STATUS <> 'VALID';

SPOOL sys_grants.sql

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
   FROM dba_tab_privs@ULTRA_SERVICE
  WHERE     owner = 'SYS'
        AND privilege NOT IN ('ENQUEUE', 'DEQUEUE')
        AND privilege NOT IN ('READ', 'WRITE')
UNION
SELECT    'grant '
        || privilege
        || ' on DIRECTORY "'
        || owner
        || '"."'
        || table_name
        || '" to "'
        || grantee
        || '" '
        || DECODE (grantable, 'YES', 'WITH Grant option')
        || ';'
   FROM dba_tab_privs@ULTRA_SERVICE
  WHERE     owner = 'SYS'
        AND privilege NOT IN ('ENQUEUE', 'DEQUEUE')
        AND privilege IN ('READ', 'WRITE');

SPOOL OFF

@sys_grants;

SPOOL usr_grants.sql

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
   FROM dba_tab_privs@ULTRA_SERVICE
  WHERE     owner IN ('AQJAVA', 'ARCOT_CALLOUT_A', 'RC_VSMC', 'VSMC3DS','ECOM')
        AND grantee IN ('AQJAVA', 'ARCOT_CALLOUT_A', 'RC_VSMC', 'VSMC3DS','ECOM');

SPOOL OFF

@usr_grants;

@utlrp;

SELECT OBJECT_NAME, LAST_DDL_TIME, OWNER
  FROM all_objects
 WHERE OWNER = 'AQJAVA' AND STATUS <> 'VALID';

exit