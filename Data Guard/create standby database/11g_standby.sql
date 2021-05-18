На primary сервере

exec DBMS_SERVICE.CREATE_SERVICE(service_name =>'CTRLDB_SERVICE',network_name =>'CTRLDB_SERVICE',aq_ha_notifications=>true,failover_method =>'BASIC',failover_type =>'SELECT',failover_retries =>180,failover_delay => 5);

BEGIN DBMS_SERVICE.START_SERVICE('CTRLDB_SERVICE'); END;
/

CREATE OR REPLACE TRIGGER MANAGED_SERVICE
   AFTER DB_ROLE_CHANGE
   ON DATABASE
DECLARE
   ROLE   VARCHAR (30);
BEGIN
   SELECT DATABASE_ROLE INTO ROLE FROM V$DATABASE;

   IF ROLE = 'PRIMARY'
   THEN
      DBMS_SERVICE.START_SERVICE ('CTRLDB_SERVICE');
   ELSE
      DBMS_SERVICE.STOP_SERVICE ('CTRLDB_SERVICE');
   END IF;
END;
/

CREATE OR REPLACE TRIGGER MANAGED_SERVICE_START
   AFTER STARTUP
   ON DATABASE
DECLARE
   ROLE   VARCHAR (30);
BEGIN
   SELECT DATABASE_ROLE INTO ROLE FROM V$DATABASE;

   IF ROLE = 'PRIMARY'
   THEN
      DBMS_SERVICE.START_SERVICE ('CTRLDB_SERVICE');
   ELSE
      DBMS_SERVICE.STOP_SERVICE ('CTRLDB_SERVICE');
   END IF;
END;
/

На standby сервере:

sqlplus / as sysdba

alter system register;

SID_LIST_LISTENER =
  (SID_LIST =
   (SID_DESC =
      (SID_NAME = CTRLDB)
      (ORACLE_HOME = /opt/oracle/app/oracle/product/11.2.0/dbhome_1)
    )
   )
   
lsnrctl reload   
   
vim tnsnames.ora

добавляем запись о сервисе auxiliary БД (пример для сервера s-msk-p-ctrldb01)

CTRLDB_REMOTE =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = s-msk-p-ctrldb02)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = CTRLDB)
    )
  )

CTRLDB_SERVICE =
 (DESCRIPTION =
  (TRANSPORT_CONNECT_TIMEOUT=3)
  (failover=on)
  (ADDRESS = (PROTOCOL = TCP)(HOST = s-msk-p-ctrldb01.raiffeisen.ru)(PORT = 1521))
  (ADDRESS = (PROTOCOL = TCP)(HOST = s-msk-p-ctrldb02.raiffeisen.ru)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = CTRLDB_SERVICE.raiffeisen.ru)
    (failover_mode=
   (type=session))
  )
 )

добавляем запись о сервисе auxiliary БД (пример для сервера s-msk-p-ctrldb02)

CTRLDB_REMOTE =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = s-msk-p-ctrldb01)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = CTRLDB)
    )
  )
  
CTRLDB_SERVICE =
 (DESCRIPTION =
  (TRANSPORT_CONNECT_TIMEOUT=3)
  (failover=on)
  (ADDRESS = (PROTOCOL = TCP)(HOST = s-msk-p-ctrldb01.raiffeisen.ru)(PORT = 1521))
  (ADDRESS = (PROTOCOL = TCP)(HOST = s-msk-p-ctrldb02.raiffeisen.ru)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = CTRLDB_SERVICE.raiffeisen.ru)
    (failover_mode=
   (type=session))
  )
 )

На основном (s-msk-p-ctrldb01) сервере

alter system set log_archive_config='DG_CONFIG=(CTRLDB_S_MSK_P_CTRLDB01,CTRLDB_S_MSK_P_CTRLDB02)' SCOPE=BOTH;
alter system set log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=CTRLDB_S_MSK_P_CTRLDB01' SCOPE=BOTH;

для асинхронного режима (MAX_PERFORMANCE)

alter system set log_archive_dest_2 = 'SERVICE=CTRLDB_REMOTE ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=CTRLDB_S_MSK_P_CTRLDB02' scope=both;

для синхронного режима (MAX_PROTECTION,MAX_AVAILABILITY)

alter system set log_archive_dest_2='SERVICE=CTRLDB_REMOTE SYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=CTRLDB_S_MSK_P_CTRLDB02' SCOPE=BOTH;

alter system set fal_client='CTRLDB' SCOPE=BOTH;
alter system set fal_server='CTRLDB_REMOTE' SCOPE=BOTH;
alter system set standby_file_management='AUTO' SCOPE=BOTH;
ALTER SYSTEM SET local_listener = "(ADDRESS=(PROTOCOL=TCP)(HOST=s-msk-p-ctrldb01)(PORT=1521))" SCOPE=BOTH;
ALTER SYSTEM SET service_names='' SCOPE=BOTH;

На основном (s-msk-p-ctrldb01) сервере (c запущенной PRIMARY БД)

connect target sys/spotlight
connect auxiliary sys/spotlight@CTRLDB_REMOTE
run
{
DUPLICATE TARGET DATABASE FOR STANDBY FROM ACTIVE DATABASE DORECOVER
  SPFILE
    SET db_unique_name='CTRLDB_S_MSK_P_CTRLDB02'
	SET LOG_ARCHIVE_DEST_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=CTRLDB_S_MSK_P_CTRLDB02'
    SET LOG_ARCHIVE_DEST_2='SERVICE=CTRLDB_REMOTE SYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=CTRLDB_S_MSK_P_CTRLDB01'
	SET local_listener='(ADDRESS=(PROTOCOL=TCP)(HOST=s-msk-p-ctrldb02)(PORT=1521))'
	SET service_names='CTRLDB_S_MSK_P_CTRLDB02','CTRLDB_SERVICE'
  NOFILENAMECHECK;
}

не забываем, если используем асинхронный режим, то для другой БД:

SET LOG_ARCHIVE_DEST_2='SERVICE=CTRLDB_REMOTE ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=CTRLDB_S_MSK_P_CTRLDB01'
  
Изменение protection mode c maximum PERFORMANCE на maximum AVAILABILITY

(даже при ASYNC передаче для того, чтобы логи на primary и standby писались параллельно!)

На основном сервере:

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE SET STANDBY DATABASE TO MAXIMIZE AVAILABILITY;
ALTER DATABASE OPEN;
select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;

На резервном сервере
select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;

STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT;

Номера последних журналов должны совпадать.
Далее убедитесь, что на резервной БД принялись все переданные архивные журналы:

ALTER SYSTEM SWITCH LOGFILE;
SELECT MAX(SEQUENCE#),thread# FROM V$LOG_HISTORY group by thread#;

SELECT * from V$ARCHIVE_GAP;
--если работает медленно (на 11.2.0.4), то

SELECT USERENV ('Instance'),
       high.thread#,
       low.lsq,
       high.hsq
  FROM (  SELECT a.thread#, rcvsq, MIN (a.sequence#) - 1 hsq
            FROM v$archived_log a,
                 (  SELECT lh.thread#,
                           lh.resetlogs_change#,
                           MAX (lh.sequence#) rcvsq
                      FROM v$log_history lh, v$database_incarnation di
                     WHERE     lh.resetlogs_time = di.resetlogs_time
                           AND lh.resetlogs_change# = di.resetlogs_change#
                           AND di.status = 'CURRENT'
                           AND lh.thread# IS NOT NULL
                           AND lh.resetlogs_change# IS NOT NULL
                           AND lh.resetlogs_time IS NOT NULL
                  GROUP BY lh.thread#, lh.resetlogs_change#) b
           WHERE     a.thread# = b.thread#
                 AND a.resetlogs_change# = b.resetlogs_change#
                 AND a.sequence# > rcvsq
        GROUP BY a.thread#, rcvsq) high,
       (SELECT srl_lsq.thread#, NVL (lh_lsq.lsq, srl_lsq.lsq) lsq
          FROM (  SELECT thread#, MIN (sequence#) + 1 lsq
                    FROM v$log_history lh,
                         x$kccfe fe,
                         v$database_incarnation di
                   WHERE     TO_NUMBER (fe.fecps) <= lh.next_change#
                         AND TO_NUMBER (fe.fecps) >= lh.first_change#
                         AND fe.fedup != 0
                         AND BITAND (fe.festa, 12) = 12
                         AND di.resetlogs_time = lh.resetlogs_time
                         AND lh.resetlogs_change# = di.resetlogs_change#
                         AND di.status = 'CURRENT'
                GROUP BY thread#) lh_lsq,
               (  SELECT thread#, MAX (sequence#) + 1 lsq
                    FROM v$log_history
                   WHERE (SELECT MIN (TO_NUMBER (fe.fecps))
                            FROM x$kccfe fe
                           WHERE fe.fedup != 0 AND BITAND (fe.festa, 12) = 12) >=
                            next_change#
                GROUP BY thread#) srl_lsq
         WHERE srl_lsq.thread# = lh_lsq.thread#(+)) low
 WHERE low.thread# = high.thread# AND lsq <= hsq AND hsq > rcvsq;

Просмотр процессов, отвечающих за восстановление STANDBY

SELECT PROCESS, STATUS, THREAD#, SEQUENCE#, BLOCK#, BLOCKS FROM V$MANAGED_STANDBY;
select * from v$archive_dest_status;

Просмотр текущего статуса БД:

select name,switchover_status,CONTROLFILE_TYPE,OPEN_MODE,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;
column DESTINATION format a20
SELECT DESTINATION, STATUS, ARCHIVED_THREAD#, ARCHIVED_SEQ# FROM V$ARCHIVE_DEST_STATUS
 WHERE STATUS <> 'DEFERRED' AND STATUS <> 'INACTIVE';
 
 
Параметр SERVICE_NAMES отвечает за регистрацию сервисов, у primary должен быть один сервис CTRLDB_SERVICE,
у standby - он должен быть пуст
  