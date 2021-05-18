/* Formatted on 16.07.2014 14:33:30 (QP5 v5.227.12220.39754) */
--USERS WITH UNLIMITED PASSWORD lifetime

SELECT a.username, a.resource_name "Resource name", LIMIT "Setting"
  FROM (SELECT username,
               p.resource_name,
               DECODE (
                  p.LIMIT,
                  'DEFAULT', (SELECT LIMIT
                                FROM SYS.DBA_PROFILES
                               WHERE     PROFILE = 'DEFAULT'
                                     AND RESOURCE_NAME =
                                            'PASSWORD_REUSE_TIME'
                                     AND RESOURCE_TYPE = 'PASSWORD'),
                  P.LIMIT)
                  LIMIT
          FROM dba_users u, dba_profiles P
         WHERE     u.PROFILE = p.PROFILE
               AND resource_name = 'PASSWORD_REUSE_TIME'
               AND p.LIMIT IN ('UNLIMITED', 'DEFAULT')) A;

--USERS WITH UNLIMITED PASSWORD UNLIMITED REUSE

SELECT a.username, a.resource_name "Resource Name", LIMIT "Setting"
  FROM (SELECT username,
               p.resource_name,
               DECODE (
                  p.LIMIT,
                  'DEFAULT', (SELECT LIMIT
                                FROM SYS.DBA_PROFILES
                               WHERE     PROFILE = 'DEFAULT'
                                     AND RESOURCE_NAME = 'PASSWORD_REUSE_MAX'
                                     AND RESOURCE_TYPE = 'PASSWORD'),
                  P.LIMIT)
                  LIMIT
          FROM dba_users u, dba_profiles p
         WHERE     u.profile = p.profile
               AND resource_name = 'PASSWORD_REUSE_MAX'
               AND p.LIMIT IN ('UNLIMITED', 'DEFAULT')) a;

--Users with unlimited failed logins

SELECT a.username, a.resource_name "Resource Name", LIMIT "Setting"
  FROM (SELECT username,
               p.resource_name,
               DECODE (
                  p.LIMIT,
                  'DEFAULT', (SELECT LIMIT
                                FROM SYS.DBA_PROFILES
                               WHERE     PROFILE = 'DEFAULT'
                                     AND RESOURCE_NAME =
                                            'FAILED_LOGIN_ATTEMPTS'
                                     AND RESOURCE_TYPE = 'PASSWORD'),
                  P.LIMIT)
                  LIMIT
          FROM dba_users u, dba_profiles p
         WHERE     u.profile = p.profile
               AND resource_name = 'FAILED_LOGIN_ATTEMPTS'
               AND p.LIMIT IN ('UNLIMITED', 'DEFAULT')) a;

--Users with unlimited lock time

SELECT a.username, a.resource_name "Resource Name", LIMIT "Setting"
  FROM (SELECT username,
               p.resource_name,
               DECODE (
                  p.LIMIT,
                  'DEFAULT', (SELECT LIMIT
                                FROM SYS.DBA_PROFILES
                               WHERE     PROFILE = 'DEFAULT'
                                     AND RESOURCE_NAME = 'PASSWORD_LOCK_TIME'
                                     AND RESOURCE_TYPE = 'PASSWORD'),
                  P.LIMIT)
                  LIMIT
          FROM dba_users u, dba_profiles p
         WHERE     u.profile = p.profile
               AND resource_name = 'PASSWORD_LOCK_TIME'
               AND p.LIMIT IN ('UNLIMITED', 'DEFAULT')) a;

--Users with unlimited grace time

SELECT a.username, a.resource_name "Resource Name", LIMIT "Setting"
  FROM (SELECT username,
               p.resource_name,
               DECODE (
                  p.LIMIT,
                  'DEFAULT', (SELECT LIMIT
                                FROM SYS.DBA_PROFILES
                               WHERE     PROFILE = 'DEFAULT'
                                     AND RESOURCE_NAME =
                                            'PASSWORD_GRACE_TIME'
                                     AND RESOURCE_TYPE = 'PASSWORD'),
                  P.LIMIT)
                  LIMIT
          FROM dba_users u, dba_profiles p
         WHERE     u.profile = p.profile
               AND resource_name = 'PASSWORD_GRACE_TIME'
               AND p.LIMIT IN ('UNLIMITED', 'DEFAULT')) a;

 --list of users with PASSWORD_VERIFY_FUNCTION set to NULL

SELECT u.username,
       u.ACCOUNT_STATUS,
       p.profile,
       p.resource_name,
       p.LIMIT
  FROM sys.dba_users u, sys.dba_profiles p
 WHERE     u.profile = p.profile
       AND p.resource_name = 'PASSWORD_VERIFY_FUNCTION'
       AND p.resource_type = 'PASSWORD'
       AND LIMIT = 'NULL';

-- full list of users with unlimited failed logons:

SELECT a.username, a.resource_name "Resource Name", LIMIT "setting"
  FROM (SELECT username,
               p.resource_name,
               DECODE (
                  p.LIMIT,
                  'DEFAULT', (SELECT LIMIT
                                FROM SYS.DBA_PROFILES
                               WHERE     PROFILE = 'DEFAULT'
                                     AND RESOURCE_NAME =
                                            'FAILED_LOGIN_ATTEMPTS'
                                     AND RESOURCE_TYPE = 'PASSWORD'),
                  P.LIMIT)
                  LIMIT
          FROM dba_users u, dba_profiles p
         WHERE     u.profile = p.profile
               AND resource_name = 'FAILED_LOGIN_ATTEMPTS'
               AND p.LIMIT IN ('UNLIMITED', 'DEFAULT')) a
               
               
SELECT a.username "Username",
       a.resource_name "Resource Name",
       LIMIT "Setting"
  FROM (SELECT username,
               p.resource_name,
               DECODE (
                  p.LIMIT,
                  'DEFAULT', (SELECT LIMIT
                                FROM SYS.DBA_PROFILES
                               WHERE     PROFILE = 'DEFAULT'
                                     AND RESOURCE_NAME = 'PASSWORD_LIFE_TIME'
                                     AND RESOURCE_TYPE = 'PASSWORD'),
                  P.LIMIT)
                  LIMIT
          FROM dba_users u, dba_profiles p
         WHERE     u.profile = p.profile
               AND resource_name = 'PASSWORD_LIFE_TIME'
               AND p.LIMIT IN ('UNLIMITED')) a