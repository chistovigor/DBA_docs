-- CREATE USER FOR MONITOR software

CREATE USER G_TALEYKISAS
  IDENTIFIED GLOBALLY AS ''
  DEFAULT TABLESPACE SMALL_TABLES_DATA
  TEMPORARY TABLESPACE TEMP
  PROFILE DEFAULT
  ACCOUNT UNLOCK;

GRANT R_MONITOR_SOFT TO G_TALEYKISAS;
ALTER USER G_TALEYKISAS DEFAULT ROLE ALL;

-- create DB user for end users

CREATE USER DB_KRILOVDA
  IDENTIFIED BY " "
  DEFAULT TABLESPACE SMALL_TABLES_DATA
  TEMPORARY TABLESPACE TEMP
  PROFILE DB_USERS_SECURE_PROFILE
  ACCOUNT UNLOCK;
  
ALTER USER DB_KRILOVDA DEFAULT ROLE ALL;

-- create app user

CREATE USER IDM_AUTH
  IDENTIFIED BY " "
  DEFAULT TABLESPACE SMALL_TABLES_DATA
  TEMPORARY TABLESPACE TEMP
  ACCOUNT UNLOCK;
  
CREATE ROLE R_IDM_AUTH;
GRANT APPLICATION_ROLE TO IDM_AUTH;
GRANT R_IDM_AUTH TO IDM_AUTH;

ALTER USER IDM_AUTH DEFAULT ROLE ALL;
ALTER USER IDM_AUTH QUOTA UNLIMITED ON SMALL_TABLES_DATA;

-- create app user for BASE tables

CREATE USER IFX
  IDENTIFIED BY " "
  DEFAULT TABLESPACE SMALL_TABLES_DATA
  TEMPORARY TABLESPACE TEMP
  ACCOUNT UNLOCK;
  
CREATE ROLE R_IFX;
GRANT CONNECT,RESOURCE,CREATE VIEW TO R_IFX;
GRANT R_IFX TO IFX;

ALTER USER IFX DEFAULT ROLE ALL;
ALTER USER IFX QUOTA UNLIMITED ON SMALL_TABLES_DATA;

-- create app user for LM tables

CREATE USER IFX_LM
  IDENTIFIED BY " "
  DEFAULT TABLESPACE LM_DATA
  TEMPORARY TABLESPACE TEMP
  ACCOUNT UNLOCK;
  
CREATE ROLE R_IFX_LM;
GRANT CONNECT,RESOURCE,CREATE VIEW TO R_IFX_LM;
GRANT R_IFX_LM TO IFX_LM;

ALTER USER IFX_LM DEFAULT ROLE ALL;
ALTER USER IFX_LM QUOTA UNLIMITED ON LM_DATA;

-- create role with grants on user's objects

CREATE ROLE R_SELECT_ON_TLDWH;

  SELECT    'grant select on '
         || OWNER
         || '.'
         || OBJECT_NAME
         || ' to R_STRATEG_DEVEL;'
    FROM ALL_OBJECTS D
   WHERE     D.OBJECT_TYPE IN ('TABLE', 'VIEW', 'MATERIALIZED VIEW')
         AND D.OWNER = 'INTERNALREP' 
         AND D.OBJECT_NAME LIKE 'V_FRPA%'
ORDER BY OBJECT_TYPE, OBJECT_NAME;

CREATE ROLE R_ERMAKOVAV;

GRANT CONNECT TO R_ERMAKOVAV;
GRANT CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO R_ERMAKOVAV;

CREATE USER G_ERMAKOVAV
  IDENTIFIED GLOBALLY AS ''
  DEFAULT TABLESPACE SMALL_TABLES_DATA
  TEMPORARY TABLESPACE TEMP
  PROFILE DEFAULT
  ACCOUNT UNLOCK;

ALTER USER G_ERMAKOVAV QUOTA 500M ON SMALL_TABLES_DATA;

GRANT R_ERMAKOVAV TO G_ERMAKOVAV;
ALTER USER G_ERMAKOVAV DEFAULT ROLE ALL;

-- grant needed for create TEMPORARY TABLES (need to be granted directly to user, NOT via ROLE)

GRANT CREATE TABLE TO G_STRATEG_DEVEL;

--REVOKE "R_SELECT_ON_TLDWH" FROM G_KOROTYCHVI;
--GRANT SELECT ON INTERNALDM.V_EQ_SECHIST TO G_ERMAKOVAV;
-- revoke create database link from DQ_EXT_DB;

ALTER USER G_BORISOVAGV TEMPORARY TABLESPACE G_TEMP_GROUP;

-- crate role with read only accsess to ALL objects in schema

CREATE ROLE R_ACCESS_TO_SCHEMA;

   SELECT    CASE
                WHEN OBJECT_TYPE IN ('TABLE', 'VIEW','MATERIALIZED VIEW') THEN 'GRANT SELECT ON '
                ELSE 'GRANT EXECUTE ON '
            END
         || OWNER
         || '.'
         || OBJECT_NAME
         || ' to R_ANALYTIC;' AS SQL
    FROM DBA_OBJECTS
   WHERE     OBJECT_TYPE IN ('TABLE',
                             'VIEW',
                             'MATERIALIZED VIEW',
                             'FUNCTION',
                             'PROCEDURE',
                             'PACKAGE')
         AND OWNER = 'ANALYTIC_DATA'
ORDER BY OBJECT_TYPE, OBJECT_NAME;

-- add modify access to ALL objects in schemas 

  SELECT    CASE
                WHEN OBJECT_TYPE IN ('TABLE', 'VIEW')
                THEN
                    CASE
                        WHEN OBJECT_TYPE IN ('TABLE')
                        THEN
                            'GRANT SELECT,INSERT,UPDATE,DELETE ON '
                        ELSE
                            'GRANT SELECT ON '
                    END
                ELSE
                    'GRANT EXECUTE ON '
            END
         || OWNER
         || '.'
         || OBJECT_NAME
         || ' to R_PETROVAN;' AS GRANT_SQL
    FROM ALL_OBJECTS
   WHERE     OBJECT_TYPE IN ('TABLE',
                             'VIEW',
                             'FUNCTION',
                             'PROCEDURE')
         AND OWNER IN ('MDMWORK_TST',
                       'MDMWORK_PMI',
                       'MOSCOW_EXCHANGE_PMI',
                       'MOSCOW_EXCHANGE_TST')
ORDER BY OBJECT_TYPE, OWNER, OBJECT_NAME;

  SELECT 'GRANT SELECT ON ' || OWNER || '.' || OBJECT_NAME || ' to R_PETROVAN;'
             AS GRANT_SQL
    FROM DBA_OBJECTS
   WHERE     OWNER IN ('MDMWORK', 'MOSCOW_EXCHANGE')
         AND OBJECT_TYPE IN ('TABLE', 'VIEW')
         AND STATUS = 'VALID'
ORDER BY OWNER, OBJECT_TYPE, OBJECT_NAME;

-- ALL PRIVILEGES FROM ALL USERS EXCEPS ORACLE MAINTAINED USERS FROM DB

-- SYSTEM PRIVILEGES

SELECT    'grant '
       || PRIVILEGE
       || ' on "'
       || OWNER
       || '"."'
       || TABLE_NAME
       || '" to "'
       || GRANTEE
       || '" '
       || DECODE (GRANTABLE, 'YES', 'WITH Grant option')
       || ';'
  FROM DBA_TAB_PRIVS
 WHERE     OWNER = 'SYS'
       AND PRIVILEGE NOT IN ('ENQUEUE', 'DEQUEUE')
       AND PRIVILEGE NOT IN ('READ', 'WRITE')
       AND GRANTEE NOT IN (SELECT ROLE
                             FROM DBA_ROLES
                            WHERE ORACLE_MAINTAINED = 'Y')
       AND GRANTEE NOT IN (SELECT USERNAME
                             FROM DBA_USERS
                            WHERE     DEFAULT_TABLESPACE = 'USERS'
                                  AND USERNAME NOT IN ('DB_GLADNIKOVAV',
                                                       'BPELWATCHDOG',
                                                       'SPUR_BLM_RISK',
                                                       'CFTUSER_CALCS',
                                                       'EQ_TEST'))
UNION
SELECT    'grant '
       || PRIVILEGE
       || ' on DIRECTORY "'
       || OWNER
       || '"."'
       || TABLE_NAME
       || '" to "'
       || GRANTEE
       || '" '
       || DECODE (GRANTABLE, 'YES', 'WITH Grant option')
       || ';'
  FROM DBA_TAB_PRIVS
 WHERE     OWNER = 'SYS'
       AND PRIVILEGE NOT IN ('ENQUEUE', 'DEQUEUE')
       AND PRIVILEGE IN ('READ', 'WRITE')
       AND GRANTEE NOT IN (SELECT ROLE
                             FROM DBA_ROLES
                            WHERE ORACLE_MAINTAINED = 'Y')
       AND GRANTEE NOT IN (SELECT USERNAME
                             FROM DBA_USERS
                            WHERE     DEFAULT_TABLESPACE = 'USERS'
                                  AND USERNAME NOT IN ('DB_GLADNIKOVAV',
                                                       'BPELWATCHDOG',
                                                       'SPUR_BLM_RISK',
                                                       'CFTUSER_CALCS',
                                                       'EQ_TEST'));
                                                       
-- OBJECT PRIVILEGES

SELECT    'grant '
       || PRIVILEGE
       || ' on "'
       || OWNER
       || '"."'
       || TABLE_NAME
       || '" to "'
       || GRANTEE
       || '" '
       || DECODE (GRANTABLE, 'YES', 'WITH Grant option')
       || ';'
  FROM DBA_TAB_PRIVS
 WHERE     GRANTEE NOT IN (SELECT ROLE
                             FROM DBA_ROLES
                            WHERE ORACLE_MAINTAINED = 'Y')
       AND GRANTEE NOT IN (SELECT USERNAME
                             FROM DBA_USERS
                            WHERE     DEFAULT_TABLESPACE = 'USERS'
                                  AND USERNAME NOT IN ('DB_GLADNIKOVAV',
                                                       'BPELWATCHDOG',
                                                       'SPUR_BLM_RISK',
                                                       'CFTUSER_CALCS',
                                                       'EQ_TEST'))
       AND (OWNER <> 'SYS' AND GRANTEE NOT IN ('PUBLIC', 'SYS'));
       
DECLARE
    V_GRANTEE           VARCHAR2 (20) := 'REDJEPOVTY';
    V_OBJ_NAME_PREFIX   VARCHAR2 (60) := 'V_FORTS';
    V_GRANTOR           VARCHAR2 (60) := 'INTERNALREP';
    V_STATEMENT         VARCHAR2 (100):= 'REVOKE';
BEGIN
    FOR REC
        IN (  SELECT    CASE V_STATEMENT
                            WHEN 'REVOKE' THEN 'REVOKE SELECT ON '
                            ELSE 'GRANT SELECT ON '
                        END
                     || OWNER
                     || '.'
                     || TABLE_NAME
                     || CASE V_STATEMENT
                            WHEN 'REVOKE' THEN ' FROM '
                            ELSE ' TO '
                        END
                     || GRANTEE
                     || CASE GRANTABLE
                            WHEN 'NO' THEN ''
                            ELSE ' WITH GRANT OPTION '
                        END
                         AS STMT
                FROM DBA_TAB_PRIVS
               WHERE     GRANTEE LIKE '%' || V_GRANTEE
                     AND TABLE_NAME LIKE V_OBJ_NAME_PREFIX || '%'
                     AND GRANTOR = V_GRANTOR
            ORDER BY TABLE_NAME, GRANTEE)
    LOOP
      DBMS_OUTPUT.PUT_LINE (REC.STMT);
      --EXECUTE IMMEDIATE REC.STMT;
    END LOOP;
END;

-- определение зависимостей для объектов схемы:

SELECT DISTINCT REFERENCED_OWNER,REFERENCED_NAME FROM DBA_DEPENDENCIES WHERE OWNER = 'DM' AND NAME LIKE 'V_ST_%' ORDER BY 1,2;
SELECT * FROM DBA_DEPENDENCIES WHERE OWNER = 'DM' AND NAME LIKE 'V_ST_%' ORDER BY REFERENCED_OWNER,REFERENCED_TYPE DESC,REFERENCED_NAME;
 
