Из старого ORACLE_HOME делаем:

1) rman nocatalog

2) connect target /

3) берем DBID из лога бекапа восстанавливаемой базы

set DBID=4101235284;

4) startup nomount;

5) Восстанавливаем pfile (из копии, указанной в логе бекапа)

restore spfile to pfile 'D:\oracle\product\11.2.0\database\dbs\initUNOC.ora' from 'G:\BACKUP\20140211\SPFILE_20140211_UNOC_SQP0ALDJ_1_1.RM';

6) Меняем в восстановленном файле параметры каталогов, удаляем STANDBY_ARCHIVE_DEST,USER_DUMP_DEST,BACKGROUND_DUMP_DEST
ставим 
*.log_archive_dest_state_2='DEFER'
проверяем параметры памяти

unique name оставляем как есть, не забываем - control_files - директории должны быть

7) STARTUP FORCE NOMOUNT PFILE='D:\oracle\product\11.2.0\database\dbs\initUNOC.ora';

8) Восстанавливаем CONTROLFILE (из копии, указанной в логе бекапа)

RESTORE CONTROLFILE FROM 'G:\BACKUP\20140211\CONTROLFILE_20140211_UNOC_SRP0ALDM_1_1.RM';
ALTER DATABASE MOUNT;

9) Определяем точку восстановления
spool log to 'G:\BACKUP\prod_db\list_backup.log';
crosscheck backup;
delete expired backup;
list backup;
list backup of archivelog all;
spool log off;

8) Запускаем восстановление до определенного sequence

spool log to 'G:\BACKUP\prod_db\restore_backup.log';

RUN
{
  # Do a SET UNTIL to prevent recovery of the online logs
  SET until sequence=493455;
  # restore the database and switch the datafile names
  RESTORE DATABASE;
  # recover the database
  RECOVER DATABASE;
}

spool log off;

9) Открываем БД

alter database open resetlogs;

10) Запускаем DBUA, выбираем БД для upgrade

11) Задаем TNS_ADMIN, запускаем NETCA, создаем LISTENER, копируем tnsnames.ora в новый TNS_ADMIN


ORACLE_HOME был D:\oracle\OraHome
TNS_ADMIN был   D:\oracle\OraHome\NETWORK\ADMIN

поставить 
ORACLE_HOME=D:\oracle\product\11.2.0\database
TNS_ADMIN=D:\oracle\product\11.2.0\database\NETWORK\ADMIN

В PATH первым должен идти путь
D:\oracle\product\11.2.0\database\bin