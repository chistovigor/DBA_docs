Использование Snapshot standby + Flashback database для тестирования, требующего отката БД во времени

Выполняем для standby БД

1) Отключаем накат логов

dgmgrl
edit database spurstb set State = APPLY-OFF;

2) Создаем точку восстанвления для последующего отката изменений

sqlplus / as sysdba
CREATE RESTORE POINT STANDBY_FLASHBACK_TESTING GUARANTEE FLASHBACK DATABASE;
SELECT NAME, SCN, TIME, DATABASE_INCARNATION#,GUARANTEE_FLASHBACK_DATABASE,STORAGE_SIZE FROM V$RESTORE_POINT;

3) Останавливаем БД для выполнения flashback

srvctl stop database -d spurstb &
srvctl start database -d spurstb -startoption MOUNT &

4) Выполняем откат БД до необходимого времени в прошлом (!!! обязательно восстанавливаем предварительно для этой БД все архивлоги из этого прошлого)

rman target /
restore archivelog from sequence 74214; --sequence before time of flashback
FLASHBACK DATABASE TO TIME "TO_DATE('19.12.2017 06:53:00','dd.mm.yyyy hh24:mi:ss')";

Прогресс отката можно наблюдать запросом

sqlplus / as sysdba
select opname,round(sofar/totalwork*100)||'%' complete,start_time,(sysdate+time_remaining/86400) predicted_finish from v$session_longops where time_remaining > 0;

5) Останавливаем БД, меняем в CW способ ее запуска (он изменился ранее в результате запуска с -startoption MOUNT)

srvctl stop database -d spurstb &
srvctl start database -d spurstb -startoption "READ ONLY" &

6) Конвертируем БД в Snapshot standby

dgmgrl
CONVERT DATABASE spurstb to SNAPSHOT STANDBY;

7) 

Выполняем необходимое тестирование

8) Конвертируем БД в Physical standby

dgmgrl
CONVERT DATABASE spurstb to PHYSICAL STANDBY;
edit database spurstb set State = APPLY-OFF;

9) Останавливаем БД, меняем в CW способ ее запуска (если он отличается от READ ONLY)

srvctl modify database -d spurstb -startoption "READ ONLY"
srvctl stop database -d spurstb

10) Запускаем БД, выполняем откат до созданной на шаге 2 изначальной точки восстановления

sqlplus / as sysdba
startup mount

rman target /
FLASHBACK DATABASE TO RESTORE POINT STANDBY_FLASHBACK_TESTING;

11) Перезапускаем БД через CW, проверяем запуск необходимых сервисов БД

srvctl stop database -d spurstb
srvctl start database -d spurstb
. .setASM
crsctl stat res -t

12) Включаем накат логов для Physical standby

. .bash_profile
dgmgrl
edit database spurstb set State = APPLY-ON;

13) Дожидаемся наката всех логов за период тестирования, проверяем возможность выполнения switchover для каждой БД

dgmgrl
validate switchover to spurstb;
validate switchover to spur;

14) Удаляем созданную на шаге 2 точку восстановления

sqlplus / as sysdba
DROP RESTORE POINT STANDBY_FLASHBACK_TESTING;
SELECT NAME, SCN, TIME, DATABASE_INCARNATION#,GUARANTEE_FLASHBACK_DATABASE,STORAGE_SIZE FROM V$RESTORE_POINT;