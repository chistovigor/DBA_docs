0) Запускаем на старом хосте (с версией 10g) скрипт utlu112i_8.sql - для upgade на версию 11.2.0.4
spool utlu112i_8.log;
@utlu112i_8;
spool off;

следуем рекомендациям из лога этого скрипта 

Запускаем на старом хосте (с версией 10g) скрипт Audit_Pre_Process.sql - для предварительного обновления sys.AUD$
spool Audit_Pre_Process.log;
@Audit_Pre_Process;
spool off;

Собираем системную статистику:

EXECUTE dbms_stats.gather_dictionary_stats; 

1) копируем бекап на новый хост

удаляем старую БД (если она есть)
sqlplus / as sysdba
shutdown immediate;
startup mount exclusive restrict;
drop database;

Из Oracle database 11.2.0.4 home запускаем:

2) rman nocatalog

3) connect target /

4) берем DBID из лога бекапа восстанавливаемой базы

set DBID=3705530278;

5) startup nomount;

6) Восстанавливаем pfile

RUN
{
  SET CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/mnt/data/oracle/backup/prod_db/%Y%M%D/CTL_AUTO_%F.BCK';
  RESTORE SPFILE 
    TO PFILE '/mnt/data/oracle/backup/prod_db/initlanit.ora' 
    FROM AUTOBACKUP;
  SHUTDOWN ABORT;
}

7) Меняем в восстановленном файле параметры каталогов, удаляем STANDBY_ARCHIVE_DEST,USER_DUMP_DEST,BACKGROUND_DUMP_DEST

unique name оставляем как есть, не забываем - control_files - директории должны быть

8) STARTUP FORCE NOMOUNT PFILE='/mnt/data/oracle/backup/prod_db/initlanit.ora';

9) Восстанавливаем контролфайлы

RUN 
{
  SET CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/mnt/data/oracle/backup/prod_db/%Y%M%D/CTL_AUTO_%F.BCK';
  RESTORE CONTROLFILE FROM AUTOBACKUP;
  ALTER DATABASE MOUNT;
}

Добавляем в controlfile информацию о скопированным бекапе

CATALOG START WITH '/mnt/data/oracle/backup/prod_db/20131209';

YES

crosscheck backup;

delete expired backup;

YES

Запускаем восстановление

???

Смотрим максимальный Seq в выводе команды

list backup of archivelog all

Запускаем для этого Seq:

spool log to /mnt/data/oracle/backup/prod_db/recover.log

RUN
{
  # Do a SET UNTIL to prevent recovery of the online logs
  SET until sequence=6603;
  # restore the database and switch the datafile names
  RESTORE DATABASE;
  # recover the database
  RECOVER DATABASE;
}

spool log off

???

Если при задании until sequence в RUN блоке выводится сообщение о том, что часть файлов не может быть восстановлена, запускаем

RESTORE DATABASE;

list backup of archivelog all

и определяем последнюю SCN или sequence и запускаем восстановление до нее (т.к. онлайн логов нет)

spool log to /mnt/data/oracle/backup/prod_db/recover.log

RUN
{
  # Do a SET UNTIL to prevent recovery of the online logs
  # recover the database
  SET until sequence=159752;
  RECOVER DATABASE;
}

spool log off

Если выполняется с ошибками, то после RESTORE DATABASE; выполняем

RECOVER DATABASE NOREDO;

Отключаем Database Vault

SELECT * FROM V$OPTION WHERE PARAMETER = 'Oracle Database Vault';

SHUTDOWN IMMEDIATE
emctl stop dbconsole
lsnrctl stop listener

cd $ORACLE_HOME/rdbms/lib
make -f ins_rdbms.mk dv_off ioracle

копируем pfile в каталог @$ORACLE_HOME/dbs

alter database open resetlogs upgrade;

SPOOL /mnt/data/oracle/backup/prod_db/upgrade.log
@$ORACLE_HOME/rdbms/admin/catupgrd.sql

Выполнится обновление БД и БД будет остановлена.

STARTUP;

@$ORACLE_HOME/rdbms/admin/utlu112s.sql

@$ORACLE_HOME/rdbms/admin/utlrp.sql

Пересоздаем TEMP

alter tablespace temp1 drop tempfile '/mnt/data/oracle/dbfiles/temp11.dbf';
alter tablespace temp1 drop tempfile '/mnt/data/oracle/dbfiles/temp12.dbf';
alter tablespace temp1 add tempfile '/mnt/data/oracle/dbfiles/temp11.dbf' size 100M autoextend on next 100M maxsize 30G;
alter tablespace temp1 drop tempfile '/mnt/data/oracle/dbfiles/temp13.dbf';

alter tablespace temp1 add tempfile '/mnt/data/oracle/dbfiles/temp12.dbf' size 100M autoextend on next 100M maxsize 30G;
alter tablespace temp1 add tempfile '/mnt/data/oracle/dbfiles/temp13.dbf' size 100M autoextend on next 100M maxsize 30G;

Меняем в pfile параметр 

.compatible='11.2.0'

create spfile from pfile;

удяляем pfile

SHUTDOWN IMMEDIATE;
STARTUP;

Копируем файл паролей ($ORACLE_HOME/dbs/instnamepw) со старого сервера на новый

Пересоздаем EMCA

emca -config dbcontrol db -repos recreate

Проверяем работу БД

???

RUN
{
  # Do a SET UNTIL to prevent recovery of the online logs
  set until time "to_date('2013-12-06 02:14:00', 'yyyy-mm-dd hh24:mi:ss')";
  # restore the database and switch the datafile names
  RESTORE DATABASE;
  # recover the database
  RECOVER DATABASE;
}

???

В случае неуспешного восстановления и/или необходимости полного удаления БД:

RMAN target /

SHUTDOWN IMMEDIATE;
STARTUP FORCE MOUNT;
SQL 'ALTER SYSTEM ENABLE RESTRICTED SESSION';
DROP DATABASE INCLUDING BACKUPS NOPROMPT;

