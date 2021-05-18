1) копируем бекап на новый хост

scp -r /mnt/data_p400/remote_backup/20140311 oracle@10.242.182.17:/mnt/data2/backup/work_db

2) удаляем старую БД (если она есть)

sqlplus / as sysdba
shutdown immediate;
startup mount exclusive restrict;
drop database;

Из старого ORACLE_HOME делаем:

3) rman nocatalog

2) connect target /

3) берем DBID из лога бекапа восстанавливаемой базы

set DBID=3705530278;

4) startup nomount;

5) Восстанавливаем pfile (из копии, указанной в логе бекапа)

restore spfile to pfile '/mnt/data/oracle/db_1/dbs/initLANIT.ora' from '/mnt/data2/backup/work_db/20140311/CTL_AUTO_c-3705530278-20140311-00.BCK';

6) Меняем в восстановленном файле параметры каталогов, удаляем STANDBY_ARCHIVE_DEST,USER_DUMP_DEST,BACKGROUND_DUMP_DEST
ставим 
*.log_archive_dest_state_2='DEFER'
проверяем параметры памяти

unique name оставляем как есть, не забываем - control_files - директории должны быть

7) STARTUP FORCE NOMOUNT PFILE='/mnt/data/oracle/db_1/dbs/initLANIT.ora';

или (если pfile лежит в $ORACLE_HOME/dbs)
STARTUP FORCE NOMOUNT;

8) Восстанавливаем CONTROLFILE (из копии, указанной в логе бекапа)

RESTORE CONTROLFILE FROM '/mnt/data2/backup/work_db/20140311/CTL_AUTO_c-3705530278-20140311-00.BCK';
ALTER DATABASE MOUNT;

9) Регистрируем скопированный бекап

catalog start with '/mnt/data2/backup/work_db/20140311';

10) Удаляем информацию о нескопированных бекапах из CONTROLFILE

crosscheck backup;
delete expired backup;

11) Определяем точку восстановления

list backup of archivelog all;

находим наибольшее значение в столбце Seq

лучше

находим наибольшее значение в столбце Next SCN

12) Запускаем проверку восстановления до определенного sequence

spool log to '/mnt/data2/backup/work_db/restore_162288_pw.log';

RUN
{
  # Do a SET UNTIL to prevent recovery of the online logs
  SET until sequence=162288;
  # restore the database and switch the datafile names
  RESTORE DATABASE PREVIEW SUMMARY;
}

или (в случае с SCN)

RUN
{
  # Do a SET UNTIL to prevent recovery of the online logs
  SET until scn=9240291807455;
  # restore the database and switch the datafile names
  RESTORE DATABASE PREVIEW SUMMARY;
}

Если при задании until sequence в RUN блоке выводится сообщение о том, что часть файлов не может быть восстановлена, запускаем

RUN
{
  # restore the database and switch the datafile names
  RESTORE DATABASE PREVIEW SUMMARY;
}

spool log off;

13) Запускаем восстановление

Если при задании until sequence в RUN блоке предыдущего шага выводится сообщение о том, что часть файлов не может быть восстановлена, запускаем

spool log to '/mnt/data2/backup/work_db/restore_1.log';

RUN
{
  # restore the database and switch the datafile names
  RESTORE DATABASE;
  RECOVER DATABASE NOREDO;
}

spool log to '/mnt/data2/backup/work_db/recover_1.log';

RUN
{
  # Do a SET UNTIL to prevent recovery of the online logs
  # recover the database
  SET until scn=9240291807455;
  RECOVER DATABASE;
}

spool log off;

если при задании until sequence в RUN блоке предыдущего шага НЕ выводится сообщение о том, что часть файлов не может быть восстановлена, запускаем

spool log to '/mnt/data2/backup/work_db/restore_seq.log';

RUN
{
  # Do a SET UNTIL to prevent recovery of the online logs
  SET until scn=9240291807455;
  # restore the database and switch the datafile names
  RESTORE DATABASE;
  # recover the database
  RECOVER DATABASE;
}

spool log off;

или (в случае с SCN)

spool log to '/mnt/data2/backup/work_db/restore_scn.log';

RUN
{
  # Do a SET UNTIL to prevent recovery of the online logs
  SET until scn=9240291807455;
  # restore the database and switch the datafile names
  RESTORE DATABASE;
  RECOVER DATABASE;
}

spool log off;

14) Открываем БД

alter database open resetlogs;

15) sqlplus / as sysdba

create spfile from pfile;
shutdown immediate;

Удаляем созданный на этапе 5 pfile

startup;

15) Восстанавливаем настройки каналов тестовой БД

/usr/local/bin/scripts/restore_backup/set_channels_test.sh

16) Пересоздание EMCA

emca -config dbcontrol db -repos recreate