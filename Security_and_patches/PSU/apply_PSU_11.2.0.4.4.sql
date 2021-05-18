cd /mnt/oracle/temp/distrib/patchsets/PSU_11.2.0.4.4/19791364/19121551
opatch apply
cd ../19282021
opatch apply

cd $ORACLE_HOME/sqlpatch/19282021
sqlplus /nolog
CONNECT / AS SYSDBA
STARTUP
@postinstall.sql
QUIT

cd $ORACLE_HOME/rdbms/admin
sqlplus /nolog
CONNECT / AS SYSDBA
@catbundle.sql psu apply
QUIT
