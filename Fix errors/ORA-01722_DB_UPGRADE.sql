Disabling database VAULT (исправление ошибки ORA-01722 при UPGRADE БД)

http://docs.oracle.com/cd/B28359_01/server.111/b31222/dvdisabl.htm#DVADM70985

sqlplus / as sysdba
SHUTDOWN IMMEDIATE
EXIT

emctl stop dbconsole
lsnrctl stop

cd $ORACLE_HOME/rdbms/lib
make -f ins_rdbms.mk dv_off
cd $ORACLE_HOME/bin
relink all