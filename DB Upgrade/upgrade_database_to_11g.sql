SET OLD $ORACLE_HOME

sqlplus / as sysdba
shutdown immediate;
exit

lsnrctl stop
emctl stop dbconsole

SET NEW $ORACLE_HOME

sqlplus / as sysdba
spool upgrade_to_11g.log

startup UPGRADE;

@$ORACLE_HOME/rdbms/admin/catupgrd.sql;

startup;

@$ORACLE_HOME/rdbms/admin/utlu112s.sql;

@$ORACLE_HOME/rdbms/admin/catuppst.sql;

@$ORACLE_HOME/rdbms/admin/utlrp.sql;

/*
If the dbupgdiag.sql script reports any invalid objects, run $ORACLE_HOME/rdbms/admin/utlrp.sql (multiple times) to validate the invalid objects in the database, until there is no change in the number of invalid objects.

After validating the invalid objects, re-run dbupgdiag.sql in the upgraded database once again and make sure that everything is fine.
*/

@$ORACLE_HOME/rdbms/admin/dbupgdiag.sql;