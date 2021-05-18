1) Oracle Recommended Patches -- "Oracle JavaVM Component Database PSU" (OJVM PSU) Patches (Doc ID 1929745.1)

For versions 11.1.0.7, 11.2.0.3, 11.2.0.4, 12.1.0.1 and 12.1.0.2 .

Requires a complete outage.

Database/s are protected on completion of patching.

1) Shutdown all databases in the ORACLE_HOME

emctl stop dbconsole
lsnrctl stop
sqlplus / as sysdba
shutdown immediate;
exit

2) Apply DB PSU (or equivalent) but do NOT run post-install steps (if standby is used first run steps 2,3 on standby!)

cd /u01/backup/distrib/PSU_11.2.0.4.6/20299013
opatch prereq CheckConflictAgainstOHWithDetail -ph ./
opatch apply

3) Apply OJVM PSU patch [see note-1 below]

cd ../20406239/
opatch prereq CheckConflictAgainstOHWithDetail -ph ./
opatch apply

Note-1: IMPORTANT: Do not access the database after applying the OJVM PSU patch other than to execute the post install steps - this includes starting the database in any mode other than "upgrade" mode. Once the post install steps have completed successfully then you can allow access to the database again.

4) Run post install steps on all DBs in the patched home: (if standby is used steps 4,5 for primary DB only!)
For 12.1.0.1 or later run "datapatch" post install steps

For 11.2.0.3 and 11.2.0.4 run the OJVM PSU post install steps

sqlplus / AS SYSDBA
startup;
spool PSU_apply.log
@postinstall;

Либо (если нет файла postinstall.sql в каталоге OJVM PSU патча):

4.1. Install the SQL portion of the patch by running the following command. For an Oracle RAC environment, reload the packages on one of the nodes.
cd $ORACLE_HOME/sqlpatch/<номер OJVM PSU патча - 20406239>
sqlplus /nolog
CONNECT / AS SYSDBA
startup upgrade
@postinstall.sql
shutdown
startup

4.2 After installing the SQL portion of the patch, some packages could become INVALID. This will get recompiled upon access or you can run utlrp.sql to get them back into a VALID state.
@?/rdbms/admin/utlrp;

5) followed by the DB PSU (or equivalent) post install steps.

@?/rdbms/admin/catbundle.sql psu apply
@?/rdbms/admin/utlrp;
PROMPT check db components current status
set linesize 150
set wrap off
column COMP_NAME format a30
column VERSION   format a15
column status    format a8
column modified  format a20
column SCHEMA    format a10
column procedure format a25

select COMP_NAME,version,status,modified,schema,procedure from DBA_REGISTRY;
spool off
QUIT

6) Start all services (if standby is used first run primary DB, then standby!)

lsnrctl start
emctl start dbconsole
