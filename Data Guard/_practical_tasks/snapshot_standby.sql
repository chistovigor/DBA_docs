--Проверка работы базы Standby Spurstb в режиме SNAPSHOT Standby 
--oracle@var01vm01


1) Перевод БД в режим Snapshot:
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


2) Перезапускаем БД (вроде, работает и так, но лишний раз не помешает).


SQL> shutdown immediate;

SQL> startup;

SQL> Select NAME, OPEN_MODE, GUARD_STATUS, DATABASE_ROLE from v$database;


--Возвращение базы в режим ADG Physical standby:
---------------------------------------------------
1) 

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

2) 

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