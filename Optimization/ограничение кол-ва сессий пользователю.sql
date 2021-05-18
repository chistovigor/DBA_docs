-- текущие пераметры экземпляра

SELECT name, VALUE
  FROM v$parameter
 WHERE name IN ('processes', 'sessions');

-- просмотр текущего и максимально использованного кол-ва процессов/сессий
 
SELECT COUNT (1) FROM v$process;

SELECT *
  FROM v$resource_limit
 WHERE resource_name IN ('processes', 'sessions');

-- определяем, какой пользователь выбирает лимиты
 
  SELECT COUNT (*), SCHEMANAME
    FROM v$session
GROUP BY SCHEMANAME
ORDER BY 1 DESC;

-- создаем PROFILE, ограничивающий кол-во сессий этого пользователя

CREATE PROFILE MAX_100_SESSIONS LIMIT
  SESSIONS_PER_USER 100
  CPU_PER_SESSION DEFAULT
  CPU_PER_CALL DEFAULT
  CONNECT_TIME DEFAULT
  IDLE_TIME DEFAULT
  LOGICAL_READS_PER_SESSION DEFAULT
  LOGICAL_READS_PER_CALL DEFAULT
  COMPOSITE_LIMIT DEFAULT
  PRIVATE_SGA DEFAULT
  FAILED_LOGIN_ATTEMPTS DEFAULT
  PASSWORD_LIFE_TIME DEFAULT
  PASSWORD_REUSE_TIME DEFAULT
  PASSWORD_REUSE_MAX DEFAULT
  PASSWORD_LOCK_TIME DEFAULT
  PASSWORD_GRACE_TIME DEFAULT
  PASSWORD_VERIFY_FUNCTION DEFAULT;
  
-- назначаем пользователю PROFILE
  
ALTER USER UNLOADUSER PROFILE MAX_100_SESSIONS;

-- ВКЛЮЧАЕМ resource_limit для того, чтобы ограничения в PROFILE использовались

SHO PARAMETER LIMIT

ALTER SYSTEM SET resource_limit = TRUE SCOPE = BOTH;