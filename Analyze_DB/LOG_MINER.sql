Переводим БД в режим добавления доп. информации в логи для LOG MINER, если она еще не в нем:

SELECT SUPPLEMENTAL_LOG_DATA_MIN FROM V$DATABASE; -- if yes, than the following command is not needed

ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;

1) Определяем последний заархивированный REDO log для анализа
SELECT NAME
  FROM V$ARCHIVED_LOG
 WHERE FIRST_TIME = (SELECT MAX (FIRST_TIME) FROM V$ARCHIVED_LOG);

2) Добавляем этот файл для анализа (параметр LOGFILENAME)
 
EXECUTE DBMS_LOGMNR.ADD_LOGFILE(LOGFILENAME => '/u01/oradata/fast_recovery_area/ULTRADB_S_MSK_P_ULTRADB01/archivelog/2014_12_10/o1_mf_1_3217_b8j3ks0g_.arc',OPTIONS => DBMS_LOGMNR.NEW);

3) Запускаем LOG MINER

EXECUTE DBMS_LOGMNR.START_LOGMNR(OPTIONS => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG);

4) Смотрим результат

select count(*) FROM V$LOGMNR_CONTENTS;

select count(*) FROM V$LOGMNR_CONTENTS where username <> 'UNKNOWN' and trim(SQL_REDO) <> 'set transaction read write;';

select * FROM V$LOGMNR_CONTENTS;

  SELECT COUNT (1),
         OPERATION,
         username,SEG_NAME
    FROM V$LOGMNR_CONTENTS
GROUP BY OPERATION,username,SEG_NAME
ORDER BY COUNT (1) DESC;

SELECT username,
       (XIDUSN || '.' || XIDSLT || '.' || XIDSQN) AS XID,
       AUDIT_SESSIONID,
       SESSION#,
       OPERATION,
       SCN,
       START_SCN,
       COMMIT_SCN,
       TIMESTAMP,       
       COMMIT_TIMESTAMP,
       DATA_BLK#,
       SQL_REDO,
       ROLLBACK,
       SEG_OWNER,
       SEG_NAME,
       TABLE_NAME,
       SQL_UNDO
  FROM V$LOGMNR_CONTENTS where username = 'VSMC3DS' order by SCN--,TIMESTAMP,XID;
 
 5) Если нужно, проверяем опции утилиты
 
 select * from V$LOGMNR_PARAMETERS;
 select * FROM V$LOGMNR_CONTENTS;
 SELECT NAME FROM V$ARCHIVED_LOG WHERE DICTIONARY_BEGIN='YES';
 
 6) Останавливаем утилиту
 
 EXECUTE DBMS_LOGMNR.END_LOGMNR;