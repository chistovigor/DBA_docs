Отключаем Database Vault

SELECT * FROM V$OPTION WHERE PARAMETER = 'Oracle Database Vault';

SHUTDOWN IMMEDIATE
emctl stop dbconsole
lsnrctl stop listener

cd $ORACLE_HOME/rdbms/lib
make -f ins_rdbms.mk dv_off ioracle