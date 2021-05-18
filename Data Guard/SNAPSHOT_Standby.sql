тестирование работы standby баз данных Spur и dbmstb02 в режиме Snapshot Standby.
Базы были переведены в режим Snapshot Standby (в котором БД доступна для изменений), в каждой из них была удалена большая таблица,
после чего базы были возвращены в стандартный режим ADG read-only с применением редо логов с основной БД, 
после чего была проведена проверка того, что удаленная таблица была автоматически восстановлена.

Данные шаги не повлияли на работу основной базы.


Тест 1 - Проверка работы базы Standby dbmstb02 в режиме SNAPSHOT Standby 
=====================================================================================================
oracle@var01vm02

Перевод БД в режим Snapshot:
---------------------------------------------------
sqlplus "/as sysdba"

SQL> shutdown immediate;

SQL> startup mount;

SQL> alter database flashback on;

SQL> alter database open;

SQL> alter database recover managed standby database cancel;



SQL> ALTER DATABASE CONVERT TO SNAPSHOT STANDBY;

Database altered.

SQL> select NAME, OPEN_MODE, GUARD_STATUS, DATABASE_ROLE from v$database;


5.Перезапускаем БД (вроде, работает и так, но лишний раз не помешает).


SQL> shutdown immediate;

6.
startup;

SQL> Select NAME, OPEN_MODE, GUARD_STATUS, DATABASE_ROLE from v$database;

NAME OPEN_MODE GUARD_S DATABASE_ROLE
--------- -------------------- ------- ----------------
PROD READ WRITE NONE SNAPSHOT STANDBY




Проверка удаления пользовательской таблицы:
---------------------------------------------------


SQL> select  table_name , (BLOCKS*8192)/1024/1024/1024 as GB from dba_tables where owner='CBMIRROR' and table_name ='TRADES_BASE';

TABLE_NAME
--------------------------------------------------------------------------------
        GB
----------
TRADES_BASE
241.589348


SQL> show parameter db_re

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_recovery_file_dest                string      +RECOC2
db_recovery_file_dest_size           big integer 1100000M
db_recycle_cache_size                big integer 0
SQL> select count(*) from CBMIRROR.REP40_BASE;

  COUNT(*)
----------
  35301181

SQL> select  table_name , (BLOCKS*8192)/1024/1024/1024 as GB from dba_tables where owner='CBMIRROR' and table_name ='REP40_BASE';

TABLE_NAME
--------------------------------------------------------------------------------
        GB
----------
REP40_BASE
12.9163284


SQL> drop table CBMIRROR.REP40_BASE;

Table dropped.

SQL> select count(*) from CBMIRROR.REP40_BASE;
select count(*) from CBMIRROR.REP40_BASE
                              *
ERROR at line 1:
ORA-00942: table or view does not exist


SQL> select  table_name , (BLOCKS*8192)/1024/1024/1024 as GB from dba_tables where owner='CBMIRROR' and table_name ='REP40_BASE';

no rows selected

SQL> Select NAME, OPEN_MODE, GUARD_STATUS, DATABASE_ROLE from v$database;

NAME      OPEN_MODE            GUARD_S DATABASE_ROLE
--------- -------------------- ------- ----------------
DBM02     READ WRITE           NONE    SNAPSHOT STANDBY




Возвращение базы в режим ADG Physical standby:
---------------------------------------------------


SQL> shutdown immediate;
Database closed.
Database dismounted.
ORACLE instance shut down.
SQL> startup mount;
ORACLE instance started.

Total System Global Area 3.7581E+10 bytes
Fixed Size                  3720216 bytes
Variable Size            2415922152 bytes
Database Buffers         1.3422E+10 bytes
Redo Buffers              264712192 bytes
In-Memory Area           2.1475E+10 bytes
Database mounted.
SQL> ALTER DATABASE CONVERT TO PHYSICAL STANDBY;

Database altered.

SQL> shutdown immediate;
ORA-01109: database not open


Database dismounted.
ORACLE instance shut down.
SQL> startup nomount;
ORACLE instance started.

Total System Global Area 3.7581E+10 bytes
Fixed Size                  3720216 bytes
Variable Size            2415922152 bytes
Database Buffers         1.3422E+10 bytes
Redo Buffers              264712192 bytes
In-Memory Area           2.1475E+10 bytes
SQL> alter database mount standby database;

Database altered.

SQL> alter database recover managed standby database using current logfile disconnect from session;

Database altered.

SQL> shutdown immediate;
ORA-01109: database not open


Database dismounted.
ORACLE instance shut down.
SQL> startup nomount;
ORACLE instance started.

Total System Global Area 3.7581E+10 bytes
Fixed Size                  3720216 bytes
Variable Size            2415922152 bytes
Database Buffers         1.3422E+10 bytes
Redo Buffers              264712192 bytes
In-Memory Area           2.1475E+10 bytes
SQL> alter database mount standby database;

Database altered.

SQL> alter database flashback off;

Database altered.

SQL> alter database open read only;

Database altered.

SQL> alter database recover managed standby database using current logfile disconnect from session;
select flashback_on from v$database;
Database altered.

SQL> select flashback_on from v$database;
select flashback_on from v$database;select flashback_on from v$database
                                   *
ERROR at line 1:
ORA-00933: SQL command not properly ended


SQL> select flashback_on from v$database;

FLASHBACK_ON
------------------
NO

SQL> select NAME, OPEN_MODE, GUARD_STATUS, DATABASE_ROLE from v$database;

NAME      OPEN_MODE            GUARD_S DATABASE_ROLE
--------- -------------------- ------- ----------------
DBM02     READ ONLY WITH APPLY NONE    PHYSICAL STANDBY



Проверка того, что удаленная таблица восстановлена:
---------------------------------------------------


SQL> select count(*) from CBMIRROR.REP40_BASE;

  COUNT(*)
----------
  35301181

SQL> select  table_name , (BLOCKS*8192)/1024/1024/1024 as GB from dba_tables where owner='CBMIRROR' and table_name ='REP40_BASE';

TABLE_NAME
--------------------------------------------------------------------------------
        GB
----------
REP40_BASE
12.9163284








!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!







Тест2 - Проверка работы базы Standby Spurstb в режиме SNAPSHOT Standby 
=====================================================================================================
oracle@var01vm01


Перевод БД в режим Snapshot:
---------------------------------------------------
sqlplus "/as sysdba"

SQL> shutdown immediate;

SQL> startup mount;

SQL> alter database flashback on;

SQL> alter database open;

SQL> alter database recover managed standby database cancel;



SQL> ALTER DATABASE CONVERT TO SNAPSHOT STANDBY;

Database altered.

SQL> select NAME, OPEN_MODE, GUARD_STATUS, DATABASE_ROLE from v$database;


5.Перезапускаем БД (вроде, работает и так, но лишний раз не помешает).


SQL> shutdown immediate;

6.
startup;

SQL> Select NAME, OPEN_MODE, GUARD_STATUS, DATABASE_ROLE from v$database;



Проверка удаления пользовательской таблицы:
---------------------------------------------------




SQL> select  table_name , (BLOCKS*8192)/1024/1024/1024 as GB from dba_tables where owner='EQ' and table_name ='TRADES_BASE';

TABLE_NAME
--------------------------------------------------------------------------------
        GB
----------
TRADES_BASE
28.3594208


SQL> select  table_name , (BLOCKS*8192)/1024/1024/1024 as GB from dba_tables where owner='CURR' and table_name ='TRADES_BASE';

TABLE_NAME
--------------------------------------------------------------------------------
        GB
----------
TRADES_BASE
3.07533264


SQL> drop table EQ.TRADES_BASE;

Table dropped.

SQL> drop table CURR.TRADES_BASE;

Table dropped.

SQL> select  table_name , (BLOCKS*8192)/1024/1024/1024 as GB from dba_tables where owner='EQ' and table_name ='TRADES_BASE';

no rows selected

SQL> select  table_name , (BLOCKS*8192)/1024/1024/1024 as GB from dba_tables where owner='CURR' and table_name ='TRADES_BASE';

no rows selected

SQL>




Возвращение базы в режим ADG Physical standby:
---------------------------------------------------

SQL> shutdown immediate;
ORA-01109: database not open


Database dismounted.
ORACLE instance shut down.
SQL> startup nomount;
ORACLE instance started.

Total System Global Area 1.2885E+11 bytes
Fixed Size                  6875568 bytes
Variable Size            1.1543E+10 bytes
Database Buffers         7.4088E+10 bytes
Redo Buffers              261558272 bytes
In-Memory Area           4.2950E+10 bytes
SQL> alter database mount standby database;

Database altered.

SQL> alter database flashback off;

Database altered.

SQL> alter database open read only;

Database altered.

SQL> alter database recover managed standby database using current logfile disconnect from session;

Database altered.

SQL> select NAME, OPEN_MODE, GUARD_STATUS, DATABASE_ROLE from v$database;

NAME      OPEN_MODE            GUARD_S DATABASE_ROLE
--------- -------------------- ------- ----------------
SPUR      READ ONLY WITH APPLY NONE    PHYSICAL STANDBY





Проверка того, что удаленная таблица восстановлена:
---------------------------------------------------


SQL> select  table_name , (BLOCKS*8192)/1024/1024/1024 as GB from dba_tables where owner='EQ' and table_name ='TRADES_BASE';

TABLE_NAME
--------------------------------------------------------------------------------
        GB
----------
TRADES_BASE
28.3594208


SQL> select  table_name , (BLOCKS*8192)/1024/1024/1024 as GB from dba_tables where owner='CURR' and table_name ='TRADES_BASE';

TABLE_NAME
--------------------------------------------------------------------------------
        GB
----------
TRADES_BASE
3.07533264


SQL>
