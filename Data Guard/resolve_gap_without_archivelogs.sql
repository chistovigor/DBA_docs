-- при появлении ошибки и остановки восстановления (MRP0 process в представлении V$MANAGED_STANDBY будет отсутствовать)

fetching gap sequence xxxxx-xxxxx и наличии архивлогов (НЕ БИТЫХ) с теми же sequence в каталоге логов на standby, выполняем на standby:

1) ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
2) ALTER DATABASE REGISTER LOGFILE '/archivelogs_folder/1_XXXX_archlog.dbf';
3) ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT;

В алертлоге снова будут периодические записи 'Media recovery log ...' и в представлении V$MANAGED_STANDBY в строке с процессом MRP0 будет увеличиваться SEQUENCE#

Oracle support ID 836986.1

-- выявленние битых логов на STANDBY (которые передались с PRIMARY), прерывающих восстановление

1) ОБЯЗАТЕЛЬНО скопировать куда-либо логи за весь период сбоя на PRIMARY (т.к. они будут удалены, т.к. СУБД думает, что они успешно переданы на STANDBY)
2) На стороне STANDBY выполнить в rman: 
spool log to validate_archivelog
backup validate archivelog low sequence = xxxxx high sequence = xxxxx 
spool log off
(мин номер - номер последнего восстановленного на standby лога, максимальный - номер последнего лога на PRIMARY, когда устранили причину сбоя передачи логов на STANDBY)
3) Вручную скопировать "FAILED" логи из сформированного в предыдущем шаге лога с PRIMARY на STANDBY (туда, где они указаны в логе)
scp archlog_xxxx.dbf oracle@10.123.11.11:/mnt/ora_data10/ARCHLOGS
4) Проверить скопированные на STANDBY логи еще раз: rman target /
spool log to validate_archivelog_copied
run
{
backup validate archivelog sequence = xxxxx;
...
backup validate archivelog sequence = xxxxx;
}
spool log off
5) После этого прерывания восстановлениея на указанных логах на стороне STANDBY прекратятся

http://www.oracle-ckpt.com/rman-incremental-backups-to-roll-forward-a-physical-standby-database-2/

-- оценка времени завершения восстановления standby (выполняем на standby)

select * from v$dataguard_stats; --v$recovery_progress

1) На standby сервере выбираем последний SCN (на primary он будет больше, т.к. часть логов не передалась)

column CURRENT_SCN format 999999999999999999

select DATABASE_ROLE,DB_UNIQUE_NAME,CURRENT_SCN from v$database;

DATABASE_ROLE    DB_UNIQUE_NAME                         CURRENT_SCN
---------------- ------------------------------ -------------------
PRIMARY          ULTRADB_S_MSK_P_ULTRADB01            9286460101991

2)  Делаем инкрементальный бекап на primary сервере c найденного SCN

rman target /

backup incremental from scn 9286460101991 database format '/u01/backup/remote/rman/for_standby_%U' tag='standby';

3) Делаем бекап контролфайла для восстановления инкрементального standby 

backup current controlfile for standby format '/u01/backup/remote/rman/ctl_file_for_standby_%U';

-- если на основной БД они будут не видны в репозитории RMAN после выполнения бекапа, то каталогизируем их:

catalog start with '/u01/backup/remote/rman' (на основной БД!)

4) Копируем созданные бекапы на standby сервер (в отдельный ПУСТОЙ каталог)

cd /u01/backup/remote/rman/
scp * oracle@s-msk-p-ultradb02:/u01/backup/remote/rman

5) На standby сервере останавливаем БД, удаляем контролфайлы (sho parameter control_files), запускаем в NOMOUNT режиме

sqlplus / as sysdba

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
shutdown immediate;
startup nomount;

6) Востанавливаем standby БД

rman target /

restore controlfile from '/u01/backup/remote/rman/ctl_file_for_standby_3pphdqpq_1_1';
sql 'alter database mount standby database';
catalog start with '/u01/backup/remote/rman';
recover database noredo;
exit

sqlplus / as sysdba
sql 'shutdown immediate';
exit

7) Добавляем standby логи (redo логи добавятся автоматически после восстановления БД в каталог db_create_online_log_dest_1)

sqlplus / as sysdba
startup nomount;
alter database mount standby database;
alter database open read only;
set linesize 200
column TYPE format a10
column MEMBER format a150
select GROUP#,TYPE,MEMBER from V_$LOGFILE;

    GROUP# TYPE       MEMBER
---------- ---------- ----------------------------------------------------------------------------------------------------
         4 ONLINE     /u01/oradata/redologs/ULTRADB_S_MSK_P_ULTRADB02/onlinelog/o1_mf_4_b08m215w_.log
         5 ONLINE     /u01/oradata/redologs/ULTRADB_S_MSK_P_ULTRADB02/onlinelog/o1_mf_5_b08m2k6k_.log
         6 ONLINE     /u01/oradata/redologs/ULTRADB_S_MSK_P_ULTRADB02/onlinelog/o1_mf_6_b08m2y0q_.log
         7 ONLINE     /u01/oradata/redologs/ULTRADB_S_MSK_P_ULTRADB02/onlinelog/o1_mf_7_b08m37hn_.log
         8 STANDBY    /u01/oradata/redologs/ULTRADB_S_MSK_P_ULTRADB02/onlinelog/o1_mf_8_b08n95hr_.log
         9 STANDBY    /u01/oradata/redologs/ULTRADB_S_MSK_P_ULTRADB02/onlinelog/o1_mf_9_b08nc34w_.log
        10 STANDBY    /u01/oradata/redologs/ULTRADB_S_MSK_P_ULTRADB02/onlinelog/o1_mf_10_b08ndl4r_.log
        11 STANDBY    /u01/oradata/redologs/ULTRADB_S_MSK_P_ULTRADB02/onlinelog/o1_mf_11_b08nf30j_.log
        12 STANDBY    /u01/oradata/redologs/ULTRADB_S_MSK_P_ULTRADB02/onlinelog/o1_mf_12_b08ngcxf_.log

удаляем STANDBY логи (8-12) и добавляем новые (добавятся по пути /u01/oradata/redologs/<unique_db_name>/onlinelog)

alter database drop logfile group 8;
alter database drop logfile group 9;
alter database drop logfile group 10;
alter database drop logfile group 11;
alter database drop logfile group 12;

alter database add standby logfile group 8 size 1G;
alter database add standby logfile group 9 size 1G;
alter database add standby logfile group 10 size 1G;
alter database add standby logfile group 11 size 1G;
alter database add standby logfile group 12 size 1G;

8) Запускаем standby БД в режиме восстановлени:

sqlplus / as sysdba
shutdown immediate;
STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT;

9) Проверяем - делаем alter system switch logfile на primary БД и выбираем на standby:

select * from v$archive_gap;

10) Удаляем созданную резервную копию на Primary и на Standby:

RMAN TARGET /

delete backupset tag=standby






