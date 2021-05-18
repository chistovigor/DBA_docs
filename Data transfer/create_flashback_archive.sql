!!! При заведении новых Flashback архивов необходимо:

1)	Либо для табличных пространств этих архивов давать квоты для пользователей, которые будут использовать эти flashback архивы для хранения данных и у которых нет привилегии unlimited tablespace
2)	Либо явно назначать пользователям новых flashback архивов привилегию unlimited tablespace
 
В противном случае может произойти сбой в процессе FBDA, который вызовет нештатное завершение этого процесса и не позволит БД после этого функционировать в штатном режиме (SR 3-1487873279)

sqlplus / as sysdba

CREATE FLASHBACK ARCHIVE DEFAULT FLA1 TABLESPACE FLASHBACK_DATA RETENTION 100 YEAR OPTIMIZE DATA;

-- CREATE NON DEFAULT ARCHIVE WITH LIMITED RETENTION POLICY

CREATE FLASHBACK ARCHIVE FLA_6_MONTHS TABLESPACE FLASHBACK_LIMITED_TIME_DATA RETENTION 6 MONTH OPTIMIZE DATA;

-- ENABLE for table

ALTER TABLE EQ.RPT99HOLD_BASE FLASHBACK ARCHIVE;

-- DISABLE for table

ALTER TABLE EQ.RPT99HOLD_BASE NO FLASHBACK ARCHIVE;

-- Package used: dbms_flashback_archive

-- views for query info about atchive

SELECT * FROM DBA_FLASHBACK_ARCHIVE_TABLES;

--Выбор данных по истории

--ЗНАЧЕНИЕ В ТАБЛИЦЕ НА 0:00:00 11 ДНЕЙ НАЗАД:

select * from EQ.TRADES_BASE AS OF TIMESTAMP TRUNC(SYSDATE)-11 WHERE TRADEDATE = TO_DATE('19-10-2016','dd-mm-yyyy') and TRADENO = 2636356383;

 select distinct OPERATION from eq.SYS_FBA_HIST_79400;
 
 select * from eq.SYS_FBA_HIST_79400 where OPERATION = 'U';
 
 set timing on 
  SELECT VERSIONS_XID,
       VERSIONS_STARTTIME,
       VERSIONS_ENDTIME,
       VERSIONS_OPERATION,
       VERSIONS_STARTSCN,
       VERSIONS_ENDSCN,
       CLEARINGBANKACCID,
       TRADEDATE,
       ORDERNO
       from EQ.TRADES_BASE VERSIONS BETWEEN TIMESTAMP TRUNC (SYSDATE) - 10 AND SYSDATE WHERE  TRADEDATE = TO_DATE('20-10-2016','dd-mm-yyyy') and TRADENO between 2636839000 and 2636839100;
	   
-- Изменение структуры для таблицы с включенным FLASHBACK:

1) Выяснить, включен ли FLASHBACK для таблицы и имя архивной таблицы для нее в этом случае

select * from DBA_FLASHBACK_ARCHIVE_TABLES;	   

2) Если FLASHBACK не включен, вносить изменения в структуру таблицы можно без ограничений.
3) Если FLASHBACK не включен, то перед изменением структуры таблицы (например,EQ.CASH_BASE) необходимо выполнить:

exec DBMS_FLASHBACK_ARCHIVE.disassociate_fba(owner_name=>'EQ',table_name=>'CASH_BASE');
commit;

4) Внести измененения в таблицу, например, добавить столбцы.
5) Внести аналогичные измененения в таблицу истории (ARCHIVE_TABLE_NAME из DBA_FLASHBACK_ARCHIVE_TABLES)
6) Выполнить включение FLASHBACK архива для таблицы:

exec DBMS_FLASHBACK_ARCHIVE.reassociate_fba(owner_name=>'EQ',table_name=>'CASH_BASE');
commit;

При выполнении указанных операций менять данные в таблице НЕЛЬЗЯ.



