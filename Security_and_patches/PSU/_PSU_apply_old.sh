1) Распаковка патча

unzip p17478514_11204_<platform>.zip

2) Выявление конфликтов

добавить путь к утилите opatch в PATH (в .bash_profile) или
export PATH=PATH:$ORACLE_HOME/OPatch

cd 17478514
opatch prereq CheckConflictAgainstOHWithDetail -ph ./

3) Применение патча к ORACLE_HOME

отключаем передачу логов на Standby

alter system set log_archive_dest_state_2 = 'DEFER' scope = both sid='*'

Сначала делаем на Standby, затем на Primary

lsnrctl stop
sqlplus / AS SYSDBA
shutdown immediate;

cd 17478514 
opatch apply

4) Применение патча к БД (ТОЛЬКО на Primary)

cd $ORACLE_HOME/rdbms/admin

sqlplus / AS SYSDBA
STARTUP
@catbundle.sql psu apply
COMMIT;
QUIT

если spu (security)

cd $ORACLE_HOME/rdbms/admin

sqlplus / AS SYSDBA
STARTUP
@catbundle.sql spu apply
COMMIT;
QUIT

alter system register;

5) Запускаем восстановление на стороне Standby 

STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT;

6) Включаем передачу логов на Standby на Primary БД

alter system set log_archive_dest_state_2 = 'ENABLE' scope = both sid='*'

7) Информация о последних патчах Oracle

Oracle support note 
821263.1

$ORACLE_HOME/Opatch/opatch lsinventory -detail
$ORACLE_HOME/OPatch/opatch lsinventory -bugs_fixed | grep MOLECULE

Смотреть в БД

select * from DBA_REGISTRY_HISTORY;
select * from REGISTRY$HISTORY;

Если ошибка:
Exception in thread "main" java.lang.NoClassDefFoundError
см. Doc ID 1335889.1
или проверить правильность добавления opatch в PATH !!!
