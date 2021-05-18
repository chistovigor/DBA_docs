-- Анализ текущей конфигурации

Primary Database (from all Instances if RAC is used) Output from Note: 1577401.1 - Script to Collect Data Guard Primary Site Diagnostic Information for Version 10g and above (Including RAC).
Standby Database (from all Instances if RAC is used) Output from Note: 1577406.1 - Script to Collect Data Guard Physical and Active Standby Diagnostic Information for Version 10g and above (Including RAC)

-- При пропадании связи между Standby и Primary может возникнуть ошибка 
DGMGRL> show configuration verbose;

Configuration - dbm02_pr

  Protection Mode: MaxPerformance
  Members:
  dbm02    - Primary database
    Error: ORA-16778: redo transport error for one or more databases

    dbmstb02 - Physical standby database

-- при просмотре ее статуса видно, что она была из-за отсутствия всязи со standby хостом
DGMGRL> SHOW DATABASE dbm02 LogXptStatus;
LOG TRANSPORT STATUS
PRIMARY_INSTANCE_NAME STANDBY_DATABASE_NAME               STATUS
              dbm021             dbmstb02 ORA-12545: Connect failed because target host or object does not exist
			  
--исправление ошибки - отключаем передачу логов на Primary, включаем обратно (после этого ошибка должна пропасть):
DGMGRL> edit database dbm02 set State = TRANSPORT-OFF;
Succeeded.
DGMGRL> edit database dbm02 set State = TRANSPORT-ON;
Succeeded.	  

-- Анализ возможности переключение на standby (swithover) Doc ID 1578787.1, 1582837.1

На стороне Primary:
sql: alter database switchover to spur verify;
dgmgrl: validate database verbose spurstb

-- выполнение операций на STANDBY БД c возможностью полного их отката:

в dgmgrl (на стороне PRIMARY или STANDBY)

disable database spurstb;

в sqlplus (на стороне STANDBY)

shutdown immediate;
startup mount;
create restore point backme;
-- выполняем любые операции
startup force mount;
flashback database to restore point backme;
alter database convert to physical standby;
drop restore point backme;
recover managed standby database disconnect;
-- подождать 5-10 минут
recover managed standby database cancel;
alter database open read only;

в dgmgrl (на стороне PRIMARY!!!)
enable database spurstb;

-- если валидация виснет, то выполнить (удалить большие файлы проверок из metadata, которые читает rms0 процесс):

cd /u01/app/oracle/diag/rdbms/spur/spur1
tar cfz /u01/app/oracle/diag/spur_hm.tar.gz hm/* metadata/HM*
rm hm/* metadata/HM*
*/

-- отключение пременения логов на STANDBY (например, для добавления лог-файлов на нее)

EDIT DATABASE spurstb SET STATE = APPLY-OFF;
EDIT DATABASE spurstb SET STATE = APPLY-ON;
show database verbose spurstb;

-- отключение передачи на PRIMARY

EDIT DATABASE spur SET STATE = TRANSPORT-OFF;
EDIT DATABASE spur SET STATE = TRANSPORT-ON;
show database verbose spur;

-- отключение конфигурации

DISABLE CONFIGURATION;
ENABLE CONFIGURATION;

-- Обязательно включить для SNAPSHOT_STANDBY режим запуска open для успешной конвертации ее из PHYSICAL_STANDBY

srvctl modify database -d spur -o /u01/app/oracle/product/12.1.0.2/dbhome_1 -r SNAPSHOT_STANDBY -s open

-- Упрощенный способ возврата из shanshot standby:

-- на Snapshot standby:
sqlplus "/as sysdba"
---
shutdown abort;
startup mount;
alter database convert to physical standby;
shutdown immediate;
startup nomount;
database mount standby database;
---
exit;

dgmgrl
connect sys

convert database spurstb to physical standby;
show configuration verbose;
show database verbose spurstb;
exit

-- трейс dgmgrl - файл drc<instance_name>.log лежит там же, где alertlog БД (+ трейсы фонового процесса RSM0 - *_rsm0_*.trc)

включение трассировки dgmgrl
dgmgrl
connect sys
edit configuration set property TraceLevel='SUPPORT';

Отключить детальную трассировку
dgmgrl
connect sys
edit configuration set property TraceLevel='USER';

-- анализ файлов STANDBY на предмет FUZZYNESS и CHECKPOINT_CHANGE# в заголовках (важно для консистентного ткрытия БД)

SELECT *
  FROM V$DATAFILE_HEADER
 WHERE FUZZY <> 'NO';

  SELECT DISTINCT CHECKPOINT_CHANGE#, TABLESPACE_NAME
    FROM V$DATAFILE_HEADER
ORDER BY 1 DESC;

-- гистограмма задержек применения измененией на STANDBY

  SELECT NAME,TIME,UNIT,COUNT,TO_DATE (LAST_TIME_UPDATED, 'MM/DD/YYYY HH24:MI:SS') FROM V$STANDBY_EVENT_HISTOGRAM
ORDER BY UNIT DESC, TIME;

--check data guard apply/transport gap
--https://franckpachot.medium.com/where-to-check-data-guard-gap-e1ccadc8f41
--You must always check when the value was calculated (TIME_COMPUTED) and may add this to gap to estimate the gap from the current time

select name||' '||value ||' '|| unit ||' computed at '||time_computed from v$dataguard_stats;

--Скрипт для создания Standby БД (TARGET - это Primary БД, AUXILARY - будущая Standby)

-- для создания standby после выполнения FAILOVER или нештатного перехода на резервный сервер

1) Остановить БД (локальную, на том сервере, где нужно пересоздать standby), запустить в nomount через pfile
sqlplus / as sysdba
create pfile='/home/oracle/scripts/initspur.ora.20170228' from spfile;
shutdown immediate;
startup nomount pfile='/home/oracle/scripts/initspur.ora.20170228';
2) Удалить вручную файлы БД (DATAFILES,TEMPFILES,REDO,STANDBY LOGS) через asmcmd, проверить размер файлов в ASM через du
3) Удалить конфигурацию dgmgrl, как описано в http://wiki.moex.com:8090/pages/viewpage.action?pageId=46830133
4) Запустить скрипт /home/oracle/scripts/create_standby_at_*01vm01.sh для создания standby следующим образом (см. 2 скрипта ниже):
5) После выполнения скрипта на новой standby выполнить:
sqlplus / as sysdba
alter system reset log_archive_dest_2;
alter system set log_archive_dest_2 = '';
. ~/.setASM
-- если standby на mr01vm01
srvctl modify database -db spur -role PHYSICAL_STANDBY -startoption "READ ONLY"
srvctl config database -db spur
-- если standby на var01vm01
srvctl modify database -db spurstb -role PHYSICAL_STANDBY -startoption "READ ONLY"
srvctl config database -db spurstb
6) Пересоздать конфигурацию dgmgrl, как описано в http://wiki.moex.com:8090/pages/viewpage.action?pageId=46830133 

-- для создания standby на mr01vm01

nohup /home/oracle/scripts/create_standby_at_mr01vm01.sh 2>&1 &

-- скрипт /home/oracle/scripts/create_standby_at_mr01vm01.sh

#/bin/sh
#
rman target sys/welcome1@SPURSTB auxiliary sys/welcome1@SPURPRM <<EOF >create_standby_at_mr01vm01.txt
run{
duplicate target database for standby from active database DORECOVER spfile parameter_value_convert 'spurstb', 'spur'
set db_unique_name='spur'
set cluster_database='FALSE'
set log_archive_max_processes='5'
set fal_client='SPURPRM'
set fal_server='SPURSTB'
set standby_file_management='AUTO'
set db_recovery_file_dest='+RECOC1'
set LOG_ARCHIVE_DEST_2='SERVICE=SPURPRM LGWR ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=spur'
set LOG_ARCHIVE_DEST_1='location=USE_DB_RECOVERY_FILE_DEST'
set LOG_FILE_NAME_CONVERT='+RECOC1/SPURSTB','+RECOC1/SPUR','+DATAC1/SPURSTB','+DATAC1/SPUR'
nofilenamecheck
;
}
exit
EOF

-- для создания standby на var01vm01

nohup /home/oracle/scripts/create_standby_at_var01vm01.sh 2>&1 &

-- скрипт /home/oracle/scripts/create_standby_at_var01vm01.sh

#/bin/sh
#
rman target sys/welcome1@SPURPRM auxiliary sys/welcome1@SPURSTB <<EOF >create_standby_at_var01vm01.txt
run{
duplicate target database for standby from active database DORECOVER spfile parameter_value_convert 'spur', 'spurstb'
set db_unique_name='spurstb'
set cluster_database='FALSE'
set log_archive_max_processes='5'
set fal_client='SPURSTB'
set fal_server='SPURPRM'
set standby_file_management='AUTO'
set db_recovery_file_dest='+RECOC1'
set LOG_ARCHIVE_DEST_2='SERVICE=SPURSTB LGWR ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=spurstb'
set LOG_ARCHIVE_DEST_1='location=USE_DB_RECOVERY_FILE_DEST'
set LOG_FILE_NAME_CONVERT='+RECOC1/SPUR','+RECOC1/SPURSTB','+DATAC1/SPUR','+DATAC1/SPURSTB'
nofilenamecheck
;
}
exit
EOF

Для избежания дополнительного кеширования при записи в онлайн-логи устанавливаем параметр (и перезапускаем БД)

filesystemio_options=SETALL

Primary server

В SQLplus

Просмотр состояния логирования операций в основной БД 

select force_logging from v$database;

Если запрос выдаст NO, то выполнить команду

ALTER DATABASE FORCE LOGGING;

Создаем файлы инициализации для обеих БД

CREATE PFILE='/usr/oracle/app/product/11.2.0/dbhome_1/dbs/data_guard/initULTRALB.ora' FROM SPFILE;

CREATE PFILE='/usr/oracle/app/product/11.2.0/dbhome_1/dbs/data_guard/initULTRASTN.ora' FROM SPFILE;

Добавляем на основной БД триггеры и службу для реализации прозрачного подключения к текущей primary БД

exec DBMS_SERVICE.CREATE_SERVICE(service_name =>'ULTRA_SERVICE',network_name =>'ULTRA_SERVICE',aq_ha_notifications=>true,failover_method =>'BASIC',failover_type =>'SELECT',failover_retries =>180,failover_delay => 5);
exec DBMS_SERVICE.CREATE_SERVICE(service_name =>'ULTRA_SERVICE_STANDBY',network_name =>'ULTRA_SERVICE_STANDBY',aq_ha_notifications=>true,failover_method =>'BASIC',failover_type =>'SELECT',failover_retries =>180,failover_delay => 5);


изменить службу:

exec DBMS_SERVICE.MODIFY_SERVICE(service_name =>'SWICHOVER_SERVICE',aq_ha_notifications=>true,failover_method =>'BASIC',failover_type =>'SELECT',failover_retries =>10,failover_delay => 1);

посмотреть текущие параметры служб:

column SERVICE_ID       format 999999999
column NAME             format A20
column NETWORK_NAME     format A20
column CREATION_DATE    format A15
column FAILOVER_METHOD  format A10
column FAILOVER_TYPE    format A10
column FAILOVER_RETRIES format 999
column FAILOVER_DELAY   format 999
column ENABLED          format A5

select NAME,NETWORK_NAME,CREATION_DATE,FAILOVER_METHOD,FAILOVER_TYPE,FAILOVER_RETRIES,FAILOVER_DELAY,ENABLED from DBA_SERVICES;

select NAME,NAME_HASH,CREATION_DATE_HASH,GOAL,DTP,AQ_HA_NOTIFICATIONS,CLB_GOAL from DBA_SERVICES;

BEGIN DBMS_SERVICE.START_SERVICE('ULTRA_SERVICE'); END;
/

CREATE OR REPLACE TRIGGER MANAGED_SERVICE
AFTER DB_ROLE_CHANGE ON DATABASE
DECLARE
ROLE VARCHAR(30);
BEGIN
SELECT DATABASE_ROLE INTO ROLE FROM V$DATABASE;
IF ROLE = 'PRIMARY' THEN
DBMS_SERVICE.START_SERVICE('ULTRA_SERVICE');
ELSE
DBMS_SERVICE.STOP_SERVICE('ULTRA_SERVICE');
DBMS_SERVICE.START_SERVICE('ULTRA_SERVICE_STANDBY');
END IF;
END;
/

CREATE OR REPLACE TRIGGER MANAGED_SERVICE_START
AFTER STARTUP ON DATABASE
DECLARE
ROLE VARCHAR(30);
BEGIN
SELECT DATABASE_ROLE INTO ROLE FROM V$DATABASE;
IF ROLE = 'PRIMARY' THEN
DBMS_SERVICE.START_SERVICE('ULTRA_SERVICE');
ELSE
DBMS_SERVICE.STOP_SERVICE('ULTRA_SERVICE');
DBMS_SERVICE.START_SERVICE('ULTRA_SERVICE_STANDBY');
END IF;
END;
/

Прописываем имена используемых БД и службы на оба сервера

первый хост - основной, второй - стендбай

vim /usr/oracle/app/product/11.2.0/dbhome_1/network/admin/tnsnames.ora

ULTRA_SERVICE =
 (DESCRIPTION =
  (TRANSPORT_CONNECT_TIMEOUT=3)
  (failover=on)
  (ADDRESS = (PROTOCOL = TCP)(HOST = 10.243.112.31)(PORT = 1521))
  (ADDRESS = (PROTOCOL = TCP)(HOST = 10.243.12.31)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = ULTRA_SERVICE)
    (failover_mode=
   (type=session))
  )
 )
 
ULTRASTN =
   (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 10.243.12.31)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ULTRASTN)
    )
  )
  
Проверяем, успешно ли добавлена служба

lsnrctl stop
lsnrctl start
lsnrctl services
  

Скопируем файл паролей БД с основного сервера на резервный 
(по умолчанию расположен в ORACLE_HOME/dbs в UNIX или ORACLE_HOME/database в Windows)
file=/usr/oracle/app/product/11.2.0/dbhome_1/dbs/orapwULTRALB

Делаем настройку параметров инициализации для DataGuard на основной БД, не останавливая ее:

alter system set log_archive_config='DG_CONFIG=(ULTRALB,ULTRASTN)' SCOPE=BOTH;
alter system set log_archive_dest_1='LOCATION=/mnt/data2/backup VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=ULTRALB' SCOPE=BOTH;
alter system set log_archive_dest_2='SERVICE=ULTRASTN ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=ULTRASTN' SCOPE=BOTH;
alter system set fal_client='ULTRALB' SCOPE=BOTH;
alter system set fal_server='ULTRASTN' SCOPE=BOTH;
alter system set standby_file_management='AUTO' SCOPE=BOTH;
alter system set LOCAL_LISTENER='(ADDRESS=(PROTOCOL=TCP)(HOST=10.243.112.31)(PORT=1521))' SCOPE=BOTH;

???

Если нужно временно предварительно отключить передачу логов с основной БД 
!! до настройки резервной !!

alter system set log_archive_dest_state_2 = 'defer';

SHUTDOWN IMMEDIATE;

STARTUP;

включение:

alter system set log_archive_dest_state_2 = 'enable';

SHUTDOWN IMMEDIATE;

STARTUP;

примеры файлов инициализации из документации Oracle

primary

DB_NAME=ULTRALB
DB_UNIQUE_NAME=ULTRALB
LOG_ARCHIVE_CONFIG='DG_CONFIG=(ULTRALB,ULTRASTN)'
LOG_ARCHIVE_DEST_1=
'LOCATION=/mnt/data2/backup
VALID_FOR=(ALL_LOGFILES,ALL_ROLES)
DB_UNIQUE_NAME=ULTRALB'
LOG_ARCHIVE_DEST_2=
'SERVICE=ULTRASTN ASYNC
VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE)
DB_UNIQUE_NAME=ULTRASTN'
LOG_ARCHIVE_DEST_STATE_1=ENABLE
LOG_ARCHIVE_DEST_STATE_2=ENABLE
REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE
LOG_ARCHIVE_FORMAT=%t_%s_%r.arc
LOG_ARCHIVE_MAX_PROCESSES=30
FAL_SERVER=ULTRASTN
FAL_CLIENT=ULTRALB
STANDBY_FILE_MANAGEMENT=AUTO

standby

DB_NAME=ULTRALB
DB_UNIQUE_NAME=ULTRASTN
LOG_ARCHIVE_CONFIG='DG_CONFIG=(ULTRALB,ULTRASTN)'
LOG_ARCHIVE_DEST_1=
'LOCATION=/mnt/data2/backup
VALID_FOR=(ALL_LOGFILES,ALL_ROLES)
DB_UNIQUE_NAME=ULTRASTN'
LOG_ARCHIVE_DEST_2=
'SERVICE=ULTRALB ASYNC
VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE)
DB_UNIQUE_NAME=ULTRALB'
LOG_ARCHIVE_DEST_STATE_1=ENABLE
LOG_ARCHIVE_DEST_STATE_2=ENABLE
REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE
STANDBY_FILE_MANAGEMENT=AUTO
FAL_SERVER=ULTRALB
FAL_CLIENT=ULTRASTN

параметры, на standby, отличные от primary

DB_UNIQUE_NAME=ULTRASTN
LOG_ARCHIVE_DEST_1=
'LOCATION=/mnt/data2/backup
VALID_FOR=(ALL_LOGFILES,ALL_ROLES)
DB_UNIQUE_NAME=ULTRASTN'
LOG_ARCHIVE_DEST_2=
'SERVICE=ULTRALB ASYNC
VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE)
DB_UNIQUE_NAME=ULTRALB'
FAL_SERVER=ULTRALB
FAL_CLIENT=ULTRASTN

???


На резервном сервере создаем файл initULTRASTN.ora в параметром DB_NAME=ULTRALB в каталоге
ORACLE_HOME/dbs в UNIX или ORACLE_HOME/database в Windows

Выполняем запуск инстанса резервной БД

sqlplus / as sysdba;

startup nomount;

Создаем копию БД для physical standby с рабочей БД

подключаемся RMAN к обеим БД

connect target sys/trjvthc@ULTRALB
connect auxiliary sys/trjvthc@ULTRASTN

DUPLICATE TARGET DATABASE
  FOR STANDBY
  FROM ACTIVE DATABASE
  DORECOVER
  SPFILE
    SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(ULTRALB,ULTRASTN)'
    SET db_unique_name='ULTRASTN' COMMENT 'It is standby'
	SET LOG_ARCHIVE_DEST_1='LOCATION=/mnt/data2/backup VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=ULTRASTN'
    SET LOG_ARCHIVE_DEST_2='SERVICE=ULTRALB ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=ULTRALB'
    SET FAL_SERVER='ULTRALB' COMMENT 'It is primary'
	SET FAL_CLIENT='ULTRASTN' COMMENT 'It is standby'
  NOFILENAMECHECK;
  
На серверах смотрим номера и названия онлайн логов для добавления стендбай логов (см. ниже)

show parameter db_create_online_log_dest
show parameter standby_

select BYTES,STATUS,GROUP# from V$LOG;

номера и названия онлайн логов для добавления стендбай логов:

set linesize 200
set pagesize 1000
column MEMBER                format a70
column GROUP                 format 999
column IS_RECOVERY_DEST_FILE format a21
select * from v$logfile order by 1,3;

добавление логов при OMF (будут созданы в заданных db_create_online_log_dest):

alter system set db_create_online_log_dest_1 = '/mnt/oracle/temp' (логи создадутся в /mnt/oracle/temp/<DB_NAME>/onlinelog):

ALTER DATABASE ADD LOGFILE GROUP 4 SIZE 1G;

ALTER DATABASE ADD STANDBY LOGFILE GROUP 5 SIZE 1G;
ALTER DATABASE ADD STANDBY LOGFILE GROUP 6 SIZE 1G;
ALTER DATABASE ADD STANDBY LOGFILE GROUP 7 SIZE 1G;
ALTER DATABASE ADD STANDBY LOGFILE GROUP 8 SIZE 1G;

Удалить старые логи:

alter system switch logfile;
alter system checkpoint;

ALTER DATABASE DROP LOGFILE GROUP 1;
ALTER DATABASE DROP LOGFILE GROUP 2;
ALTER DATABASE DROP LOGFILE GROUP 3;
ALTER DATABASE DROP STANDBY LOGFILE GROUP 9;
ALTER DATABASE DROP STANDBY LOGFILE GROUP 10;
ALTER DATABASE DROP STANDBY LOGFILE GROUP 11;


На резервном сервере В SQLplus

SHUTDOWN IMMEDIATE;

ALTER DATABASE MOUNT STANDBY DATABASE;

Добавляем реду логи и стендбай логи в резервную БД:
Обратите внимание, что номер группы REDO-логов на резервной БД не должен
совпадать с номерами на основной БД, то есть если на основной БД три группы (1, 2, 3),
то на резервной БД необходимо добавить группы 4, 5, 6, 7. В противном случае
возникнет ошибка добавления логов. Также обращаем ваше внимание на то, что
STANDBY-логов должно быть больше, чем обычных хотя бы на 1.

alter database add standby logfile group 4 '/mnt/data1/oradata/ULTRALB/standbyredo04.log' size 52428800;
alter database add standby logfile group 5 '/mnt/data1/oradata/ULTRALB/standbyredo05.log' size 52428800;
alter database add standby logfile group 6 '/mnt/data1/oradata/ULTRALB/standbyredo06.log' size 52428800;
alter database add standby logfile group 7 '/mnt/data1/oradata/ULTRALB/standbyredo07.log' size 52428800;

Добавляем реду логи и стендбай логи в основную БД (для того, чтобы она могла работать в качестве standby):

alter database add standby logfile group 8 '/mnt/data1/oradata/ULTRALB/standbyredo08.log' size 52428800;
alter database add standby logfile group 9 '/mnt/data1/oradata/ULTRALB/standbyredo09.log' size 52428800;
alter database add standby logfile group 10 '/mnt/data1/oradata/ULTRALB/standbyredo10.log' size 52428800;
alter database add standby logfile group 11 '/mnt/data1/oradata/ULTRALB/standbyredo11.log' size 52428800;

Запуск резервной БД (на резервном сервере) в режиме приема логов с основной

STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT;

Добавление файлов TEMP на резервном сервере (сначала проверить, какие файлы и ТП есть на основном и резервном серверах)

column name format a40
column BYTES format 999,999,999,999,999

select NAME,BYTES from v$tempfile;

для того файла, который будет в результате выборки для standby БД, но физически отсутствует на диске:

выполнить на standby БД:

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
ALTER DATABASE OPEN READ ONLY;
alter database tempfile '/mnt/data1/oradata/ULTRALB/temp01.dbf' drop;
alter tablespace temp add tempfile '/mnt/data1/oradata/ULTRALB/temp01.dbf' size 1000M reuse;

для файла, которого нет в результате (и на диске) выборки для standby БД:

alter tablespace temp add tempfile '/mnt/data1/oradata/ULTRALB/temp02.dbf' size 100M autoextend on next 100M maxsize unlimited;
alter tablespace temp add tempfile '/mnt/data1/oradata/ULTRALB/temp04.dbf' size 100M autoextend on next 100M maxsize 30000M;

изменение максимального размера временного файла:

alter database tempfile '/mnt/data1/oradata/ULTRALB/temp03.dbf' autoextend on maxsize 15000M;

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

после добавлениея файлов TEMP снова запускаем standby БД

STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

Просмотр информации о логах:

show parameter db_create_online_log_dest
show parameter standby_

select BYTES,STATUS,GROUP# from V$LOG;

номера и названия онлайн логов для добавления стендбай логов:

column MEMBER format a80;
select type,group#,member,STATUS from v$logfile order by 1,2;

добавление логов при OMF (будут созданы в заданных db_create_online_log_dest):

alter system set db_create_online_log_dest_1 = '/mnt/oracle/temp' (логи создадутся в /mnt/oracle/temp/<DB_NAME>/onlinelog):

ALTER DATABASE ADD LOGFILE GROUP 4 SIZE 1G;

ALTER DATABASE ADD STANDBY LOGFILE GROUP 5 SIZE 1G;
ALTER DATABASE ADD STANDBY LOGFILE GROUP 6 SIZE 1G;
ALTER DATABASE ADD STANDBY LOGFILE GROUP 7 SIZE 1G;
ALTER DATABASE ADD STANDBY LOGFILE GROUP 8 SIZE 1G;

Удалить старые логи:

alter system switch logfile;
alter system checkpoint;

ALTER DATABASE DROP LOGFILE GROUP 1;
ALTER DATABASE DROP LOGFILE GROUP 2;
ALTER DATABASE DROP LOGFILE GROUP 3;
ALTER DATABASE DROP STANDBY LOGFILE GROUP 9;
ALTER DATABASE DROP STANDBY LOGFILE GROUP 10;
ALTER DATABASE DROP STANDBY LOGFILE GROUP 11;

???

Создание файла паролей для БД (при необходимости подключаться к БД, указывая пароль sys)
 
$ORACLE_HOME/bin/orapwd file=/usr/oracle/app/product/11.2.0/dbhome_1/dbs/orapwULTRALB password=trjvthc entries=6

$ORACLE_HOME/bin/orapwd file=/usr/oracle/app/product/11.2.0/dbhome_1/dbs/orapwULTRASTN password=trjvthc entries=6

???

Изменение protection mode c maximum PERFORMANCE на maximum AVAILABILITY

На основном сервере:

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE SET STANDBY DATABASE TO MAXIMIZE AVAILABILITY;
ALTER DATABASE OPEN;
alter system set log_archive_dest_2='SERVICE=ULTRASTN SYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=ULTRASTN' SCOPE=BOTH;
select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;

На резервном сервере
alter system set log_archive_dest_2='SERVICE=ULTRALB SYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=ULTRALB' SCOPE=BOTH;
select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;

запрос 

SELECT PROTECTION_MODE, PROTECTION_LEVEL FROM V$DATABASE;

должены выдать

PROTECTION_MODE                   PROTECTION_LEVEL
---------------------             ---------------------
MAXIMUM AVAILABILITY              MAXIMUM AVAILABILITY

Для ручного запуска STANDBY необходимо выполнить следующие команды на резервном сервере:

sqlplus / as sysdba;
STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

Для ручной остановки STANDBY необходимо выполнить следующие команды на резервном сервере:

sqlplus / as sysdba;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
SHUTDOWN IMMEDIATE;

ПРОВЕРКА ДОСТАВКИ ЛОГОВ

На основной БД введите:

sqlplus / as sysdba;

alter system archive log current;
ALTER SYSTEM SWITCH LOGFILE;
SELECT MAX(SEQUENCE#),thread# FROM V$LOG_HISTORY group by thread#;

На резервной БД введите:

sqlplus / as sysdba;
SELECT MAX(SEQUENCE#),thread# FROM V$LOG_HISTORY group by thread#;

--Номера последних журналов должны совпадать.
--Далее убедитесь, что на резервной БД принялись все переданные архивные журналы:

ALTER SYSTEM SWITCH LOGFILE;
SELECT MAX(SEQUENCE#),thread# FROM V$LOG_HISTORY group by thread#;

--Просмотр текущего статуса БД:

select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;
column DESTINATION format a20
SELECT DESTINATION, STATUS, ARCHIVED_THREAD#, ARCHIVED_SEQ# FROM V$ARCHIVE_DEST_STATUS
 WHERE STATUS <> 'DEFERRED' AND STATUS <> 'INACTIVE';
 
--Просмотр текущего режима восстановления:

SELECT RECOVERY_MODE FROM V$ARCHIVE_DEST_STATUS WHERE DEST_ID=2 ;

--Просмотр статуса восстановления логов:

SELECT PROCESS, STATUS, THREAD#, SEQUENCE#, BLOCK#, BLOCKS FROM V$MANAGED_STANDBY;

--Просмотр оценочного времени для восстановления standby:

set linesize 200 pagesize 10000
col name for a30
col value for a25
col datum_time for a30
col time_computed for a30
col start_time for a15
col type for a20
col item for a30
col units for a15
col timestamp for a15
col comments for a30

select * from v$dataguard_stats; -- выполняется около минуты при большом отставании standby от Primary

select * from v$recovery_progress; -- выполняется быстро

--detect gap in apply (run on both primary and stby):

select 'Instance'||thread#||': Last Applied='||max(sequence#)||'
(resetlogs_change#='||resetlogs_change#||')'
from v$archived_log
where applied = (select decode(database_role, 'PRIMARY', 'NO',
'YES') from v$database)
and thread# in (select thread# from gv$instance)
and resetlogs_change# = (select resetlogs_change# from v$database)
group by thread#, resetlogs_change#
order by thread#;

--determine how far behind the query results on the standby database are lagging the primary database (DB link to active stby is required), run from a primary DB:

select scn_to_timestamp((select current_scn from v$database))-scn_to_timestamp((select current_scn from v$database@rtq_stby)) from dual;  
 
Для ручного запуска STANDBY необходимо выполнить следующие команды на резервном сервере:

sqlplus / as sysdba;
STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

или (для Real-Time Apply)

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE;

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;

установка нулевой задержки при восстановлении:

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE NODELAY;

Для ручной остановки STANDBY необходимо выполнить следующие команды:

sqlplus / as sysdba;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
SHUTDOWN IMMEDIATE;
 

Переключение SWITCHOVER
Чтобы переключаться между PRIMARY и STANDBY (менять их ролями сколько угодно раз),
необходимо использовать операцию SWITCHOWER. Как следует из её названия, она предоставляет
возможность основной и резервной БД поменяться ролями. Данная операция обратима. Для выполнения
SWITCHOVER необходимо:
1. Выполнить переключение — SWITCHOVER на основной БД (ULTRALB):
sqlplus / as sysdba;
ALTER SYSTEM ARCHIVE LOG CURRENT;
ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;
SHUTDOWN IMMEDIATE;
connect sys/trjvthc@ULTRALB as sysdba;
STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

2. Переключить STANDBY в режим основной:
sqlplus / as sysdba;
ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE OPEN;

3. Проверить доставку логов на новую STANDBY БД (в данном случае — ULTRALB), для чего
выполнить следующее:
ALTER SYSTEM SWITCH LOGFILE;

Обратно - 

на STANDBY сервере

ALTER SYSTEM ARCHIVE LOG CURRENT;
ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;
SHUTDOWN IMMEDIATE;
connect sys/trjvthc@ULTRASTN as sysdba;
STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

на основном

sqlplus / as sysdba;
ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE OPEN;

3. Проверить доставку логов на новую STANDBY БД (в данном случае — ULTRASTN), для чего
выполнить следующее:
ALTER SYSTEM SWITCH LOGFILE;

!!! Переключение FAILOVER

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE FINISH;
ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE OPEN;

Пересоздание/добавление реду логов 

На резервной БД

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

alter database add standby logfile group 15 '/mnt/data1/oradata/ULTRALB/standbyredo15.log' size 500M;
alter database add standby logfile group 16 '/mnt/data1/oradata/ULTRALB/standbyredo16.log' size 500M;
alter database add standby logfile group 17 '/mnt/data1/oradata/ULTRALB/standbyredo17.log' size 500M;
alter database add standby logfile group 18 '/mnt/data1/oradata/ULTRALB/standbyredo18.log' size 500M;

на основной БД:

alter database add logfile group 12 '/mnt/data1/oradata/ULTRALB/redo12.log' size 500M;
alter database add logfile group 13 '/mnt/data1/oradata/ULTRALB/redo13.log' size 500M;
alter database add logfile group 14 '/mnt/data1/oradata/ULTRALB/redo14.log' size 500M;

alter database drop logfile group 1;
alter database drop logfile group 2;
alter database drop logfile group 3;

На резервной БД

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

alter database drop logfile group 8;
alter database drop logfile group 9;
alter database drop logfile group 10;
alter database drop logfile group 11;
alter database add logfile group 8 '/mnt/data1/oradata/ULTRALB/redo08.log' size 500M;
alter database add logfile group 9 '/mnt/data1/oradata/ULTRALB/redo09.log' size 500M;
alter database add logfile group 10 '/mnt/data1/oradata/ULTRALB/redo10.log' size 500M;

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

Увеличение вкорости передачи логов на standby БД при разрешении GAP

на БД ULTRALB выполняем
alter system set log_archive_dest_2='SERVICE=ULTRASTN SYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=ULTRASTN MAX_CONNECTIONS=3' SCOPE=MEMORY;

на БД ULTRASTN выполняем
alter system set log_archive_dest_2='SERVICE=ULTRALB SYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=ULTRALB MAX_CONNECTIONS=3' SCOPE=MEMORY;

alter system set log_archive_max_processes=8 scope=memory;

изменение обратно

на БД ULTRALB выполняем
alter system set log_archive_dest_2='SERVICE=ULTRASTN SYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=ULTRASTN' SCOPE=MEMORY;

на БД ULTRASTN выполняем
alter system set log_archive_dest_2='SERVICE=ULTRALB SYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=ULTRALB' SCOPE=MEMORY;

alter system set log_archive_max_processes=4 scope=memory;

Для асинхронной передачи логов:

alter system set LOG_ARCHIVE_DEST_2='SERVICE=dbmprm ARCH ASYNC NOAFFIRM  VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=dbm02';

Настройка dgmgrl

create configuration SRUR_PR as primary database is spurstb connect identifier is SPURSTB;
add database spur as connect identifier is SPURPRM maintained as physical;
enable configuration ;
SHOW DATABASE VERBOSE spur;
SHOW DATABASE VERBOSE spurstb;

EDIT DATABASE spur SET PROPERTY TransportDisconnectedThreshold='300';

--для установки наката логов с задержкой (процессом ARCH) выполнить (для всех БД, и Primary и Standby):

EDIT DATABASE spur SET PROPERTY LogXptMode = 'ARCH';

--monitoring the lag in redo transport/apply:

SELECT * FROM V$DATAGUARD_STATS WHERE lower(NAME) like '% lag';


Переключение ролей БД (switchover)

vim /usr/local/bin/scripts/switchover.sh

#!/bin/bash

. $HOME/.bash_profile

sqlplus_header='set heading off feedback off termout off trimspool on'

db_status=`sqlplus -S / as sysdba <<EOF
$sqlplus_header
select DATABASE_ROLE from v\\$database;
EOF`

switchover_status=`sqlplus -S / as sysdba <<EOF
$sqlplus_header
select switchover_status from v\\$database;918751
EOF`

#remote_instance=`sqlplus -S / as sysdba <<EOF
#$sqlplus_header
#select value from v\\$parameter where name = 'fal_server';
#EOF`

remote_instance=`echo "select value from v\\$parameter where name = 'fal_server';" | sqlplus -S / as sysdba | head -n+4 | tail -n-1`

remote_host=`tnsping $remote_instance # | grep HOST -A0 | cut -c73-85`

echo -e current host is \\n `uname -n`
echo -e current time is \\n `date`
echo -e current host db status is \\n $db_status
echo -e current host switchover status is \\n $switchover_status
echo -e remote instance name is \\n $remote_instance
echo -e remote host is \\n $remote_host

if [ ${db_status} == PRIMARY ];then
  if [[ $switchover_status == "SESSIONS ACTIVE"||"TO STANDBY" ]];then
  echo perform switchover primary to standby
  sqlplus -S / as sysdba <<EOF
  $sqlplus_header
  ALTER SYSTEM ARCHIVE LOG CURRENT;
  ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;
  SHUTDOWN IMMEDIATE;615
  connect / as sysdba;
  STARTUP NOMOUNT;
  ALTER DATABASE MOUNT STANDBY DATABASE;
  ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
EOF
  echo perform switchover standby to primary
  sqlplus -S sys/trjvthc@$remote_instance as sysdba <<EOF
  $sqlplus_header
  ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;
  SHUTDOWN IMMEDIATE;
  STARTUP MOUNT;
  ALTER DATABASE OPEN;
EOF
  else
   echo data transfer beetween databases is not complete: switchower is not possible now!
  fi
else
echo current DB status is $db_status run switchower on the host `tnsping $remote_instance`
fi