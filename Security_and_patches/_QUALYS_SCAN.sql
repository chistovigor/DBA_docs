1) ОС разрешения для пользователя infosec

ULTRA

sudo -u oracle /usr/oracle/app/product/11.2.0/dbhome_1/OPatch/opatch lsinventory

ARCHDB

sudo -u oracle /mnt/oracle/product/11.2.0/dbhome_2/OPatch/opatch lsinventory


2) Добавление разрешений в БД

CREATE ROLE "QUALYS_ROLE" NOT IDENTIFIED;
GRANT CREATE SESSION TO "QUALYS_ROLE";
GRANT SELECT ON "SYS"."DBA_PROCEDURES" TO "QUALYS_ROLE";
GRANT SELECT ON "SYS"."DBA_PROFILES" TO "QUALYS_ROLE";
GRANT SELECT ON "SYS"."DBA_TS_QUOTAS" TO "QUALYS_ROLE";
GRANT SELECT ON "SYS"."DBA_USERS" TO "QUALYS_ROLE";
GRANT SELECT ON "SYS"."GV_$DATABASE" TO "QUALYS_ROLE";
GRANT SELECT ON "SYS"."GV_$INSTANCE" TO "QUALYS_ROLE";
GRANT SELECT ON "SYS"."GV_$PARAMETER" TO "QUALYS_ROLE";
GRANT SELECT ON "SYS"."GV_$VERSION" TO "QUALYS_ROLE";
GRANT SELECT ON "SYS"."REGISTRY$HISTORY" TO "QUALYS_ROLE";
GRANT SELECT ON "SYS"."USER_TAB_COLUMNS" TO "QUALYS_ROLE";

CREATE USER "QUALYS_SCAN" PROFILE "UNEXPIRED_USERS_PROFILE" IDENTIFIED BY "!,.Zxc34ed" PASSWORD EXPIRE DEFAULT TABLESPACE "AUD1" QUOTA 100 M ON "AUD1" ACCOUNT UNLOCK;
GRANT CREATE SESSION TO "QUALYS_SCAN";
GRANT "CONNECT" TO "QUALYS_SCAN";
GRANT "QUALYS_ROLE" TO "QUALYS_SCAN";

Проверка наобходимых разрешений (выполняется из под sysdba)

/* Formatted on 31/03/2014 15:52:29 (QP5 v5.227.12220.39754) */
SELECT USER "Prerequisites", '<---Current logged on user' "Status" FROM DUAL
UNION
SELECT 'UNEXPIRED_USERS_PROFILE' "Prerequisites",
       DECODE (inv1.check1,
               0, 'FAILED - profile does not exist',
               'PASSED - profile exists')
          "Status"
  FROM (SELECT COUNT (profile) check1
          FROM dba_profiles
         WHERE profile = UPPER ('UNEXPIRED_USERS_PROFILE')) inv1
UNION
SELECT 'QUALYS_SCAN' "Prerequisites",
       DECODE (inv2.check2,
               0, 'FAILED - account does not exist',
               'PASSED - account exists')
          "Status"
  FROM (SELECT COUNT (username) check2
          FROM dba_users
         WHERE username = UPPER ('QUALYS_SCAN')) inv2
UNION
SELECT 'QUALYS_ROLE' "Prerequisites",
       DECODE (inv3.check3,
               0, 'FAILED - role does not exists',
               'PASSED - role exists')
          "Status"
  FROM (SELECT COUNT (role) check3
          FROM dba_roles
         WHERE role = 'QUALYS_ROLE') inv3
UNION
SELECT 'QUALYS_ROLE' "Prerequisites",
       DECODE (inv4.check4,
               0, 'FAILED - role not granted to user',
               'PASSED - role granted to user')
          "Status"
  FROM (SELECT COUNT (granted_role) check4
          FROM dba_role_privs
         WHERE grantee = 'QUALYS_SCAN' AND granted_role = 'QUALYS_ROLE') inv4
UNION
SELECT 'CREATE SESSION ROLE' "Prerequisites",
       DECODE (inv5.check5,
               0, 'FAILED - CREATE SESSION does not exist',
               'PASSED - CREATE SESSION exists')
          "Status"
  FROM (SELECT COUNT (grantee) check5
          FROM dba_sys_privs
         WHERE grantee = 'QUALYS_ROLE') inv5
UNION
SELECT 'GV_$PARAMETER' "Prerequisites",
       DECODE (inv6.check6,
               0, 'FAILED - SELECT privilege not granted to user',
               'PASSED - SELECT privilege exists')
          "Status"
  FROM (SELECT COUNT (privilege) check6
          FROM dba_tab_privs
         WHERE grantee = 'QUALYS_ROLE' AND table_name = 'GV_$PARAMETER') inv6
UNION
SELECT 'DBA_PROFILES' "Prerequisites",
       DECODE (inv7.check7,
               0, 'FAILED - SELECT privilege not granted to user',
               'PASSED - SELECT privilege exists')
          "Status"
  FROM (SELECT COUNT (privilege) check7
          FROM dba_tab_privs
         WHERE grantee = 'QUALYS_ROLE' AND table_name = 'DBA_PROFILES') inv7
UNION
SELECT 'DBA_USERS' "Prerequisites",
       DECODE (inv8.check8,
               0, 'FAILED - SELECT privilege not granted to user',
               'PASSED - SELECT privilege exists')
          "Status"
  FROM (SELECT COUNT (privilege) check8
          FROM dba_tab_privs
         WHERE grantee = 'QUALYS_ROLE' AND table_name = 'DBA_USERS') inv8
UNION
SELECT 'USER_TAB_COLUMNS' "Prerequisites",
       DECODE (inv9.check9,
               0, 'FAILED - SELECT privilege not granted to user',
               'PASSED - SELECT privilege exists')
          "Status"
  FROM (SELECT COUNT (privilege) check9
          FROM dba_tab_privs
         WHERE grantee = 'QUALYS_ROLE' AND table_name = 'USER_TAB_COLUMNS') inv9
UNION
SELECT 'GV_$DATABASE' "Prerequisites",
       DECODE (inv10.check10,
               0, 'FAILED - SELECT privilege not granted to user',
               'PASSED - SELECT privilege exists')
          "Status"
  FROM (SELECT COUNT (privilege) check10
          FROM dba_tab_privs
         WHERE grantee = 'QUALYS_ROLE' AND table_name = 'GV_$DATABASE') inv10
UNION
SELECT 'DBA_TS_QUOTAS' "Prerequisites",
       DECODE (inv11.check11,
               0, 'FAILED - SELECT privilege not granted to user',
               'PASSED - SELECT privilege exists')
          "Status"
  FROM (SELECT COUNT (privilege) check11
          FROM dba_tab_privs
         WHERE grantee = 'QUALYS_ROLE' AND table_name = 'DBA_TS_QUOTAS') inv11
UNION
SELECT 'SYS.REGISTRY$HISTORY' "Prerequisites",
       DECODE (inv12.check12,
               0, 'FAILED - SELECT privilege not granted to user',
               'PASSED - SELECT privilege exists')
          "Status"
  FROM (SELECT COUNT (privilege) check12
          FROM dba_tab_privs
         WHERE grantee = 'QUALYS_ROLE' AND table_name = 'REGISTRY$HISTORY') inv12
UNION
SELECT 'GV_$VERSION' "Prerequisites",
       DECODE (inv13.check13,
               0, 'FAILED - SELECT privilege not granted to user',
               'PASSED - SELECT privilege exists')
          "Status"
  FROM (SELECT COUNT (privilege) check13
          FROM dba_tab_privs
         WHERE grantee = 'QUALYS_ROLE' AND table_name = 'GV_$VERSION') inv13
UNION
SELECT 'DBA_PROCEDURES' "Prerequisites",
       DECODE (inv14.check14,
               0, 'FAILED - SELECT privilege not granted to user',
               'PASSED - SELECT privilege exists')
          "Status"
  FROM (SELECT COUNT (privilege) check14
          FROM dba_tab_privs
         WHERE grantee = 'QUALYS_ROLE' AND table_name = 'DBA_PROCEDURES') inv14
ORDER BY 2;

результат:

SYS	<---Current logged on user
CREATE SESSION ROLE	PASSED - CREATE SESSION exists
DBA_PROCEDURES	PASSED - SELECT privilege exists
DBA_PROFILES	PASSED - SELECT privilege exists
DBA_TS_QUOTAS	PASSED - SELECT privilege exists
DBA_USERS	PASSED - SELECT privilege exists
GV_$DATABASE	PASSED - SELECT privilege exists
GV_$PARAMETER	PASSED - SELECT privilege exists
GV_$VERSION	PASSED - SELECT privilege exists
SYS.REGISTRY$HISTORY	PASSED - SELECT privilege exists
USER_TAB_COLUMNS	PASSED - SELECT privilege exists
QUALYS_SCAN	PASSED - account exists
UNEXPIRED_USERS_PROFILE	PASSED - profile exists
QUALYS_ROLE	PASSED - role exists
QUALYS_ROLE	PASSED - role granted to user