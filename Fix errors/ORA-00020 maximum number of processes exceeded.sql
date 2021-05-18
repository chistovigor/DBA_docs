1) Подсчет процессов в linux

ps alx | grep $ORACLE_SID | wc -l

2) Завершить пользовательские процессы, подключенные к БД

kill -9 `ps aux | grep 'oracleULTRADB (LOCAL=NO)' | grep -v grep | awk '{print $2}'`

3) Увеличить количество процессов на уровне экземпляра

alter system set processes=500 scope=spfile sid='*';
alter system reset sessions sid='*';
alter system reset transactions sid='*';


4) Анализ процессов в ОС

sqlplus -prelim / as sysdba

SQL> oradebug setmypid
Statement processed.
SQL> oradebug hanganalyze 3
Statement processed.
SQL> oradebug TRACEFILE_NAME
/opt/oracle/app/oracle/diag/rdbms/ultradb_s_msk_p_ultradb01/ULTRADB/trace/ULTRADB_ora_14040.trc
SQL> exit

SQL> oradebug setmypid
Statement processed.
SQL> oradebug unlimit
Statement processed.
SQL> oradebug dump systemstate 13903
Statement processed.
SQL> oradebug TRACEFILE_NAME
/opt/oracle/app/oracle/diag/rdbms/ultradb_s_msk_p_ultradb01/ULTRADB/trace/ULTRADB_ora_14391.trc
SQL> exit

тут 13903 - идентификатор процесса из вывода ps -aux | grep oracle