1) Updated DST Transitions and New Time Zones in Oracle Time Zone File Patches (Doc ID 412160.1)

сurrent Server timezone version

1.1 

sqlplus / as sysdba
@utltzver.sql

или

SELECT version FROM v$timezone_file;

column PROPERTY_NAME format A40
column value format A20

SELECT PROPERTY_NAME, SUBSTR(property_value, 1, 30) value
FROM DATABASE_PROPERTIES
WHERE PROPERTY_NAME LIKE 'DST_%'
ORDER BY PROPERTY_NAME;

2) Applying the DSTv23 update (Doc ID 1907093.1)

Applying the RDBMS DSTv23 patch 19396455 on the server side in Oracle RDBMS 11gR2 
(POSSIBLE without stopping RDBMS software)

2.1
download 11gR2 RDBMS DSTv23 Patch 19396455 for your platform (p19396455_112040_Linux-x86-64.zip)

2.2
Apply the RDBMS DSTv23 Patch 19396455  using Opatch.

cd <PATCH_TOP_DIR>/19396455
opatch prereq CheckConflictAgainstOHWithDetail -ph ./
opatch apply

Note: in 11.2 and up there is no need to shut down or stop processes seen you are simply adding new files, not replacing used ones.

Applying the RDBMS DSTv23 patch 19396455 on the client side in Oracle RDBMS 11gR2.

2.1
download 11gR2 RDBMS DSTv23 Patch 19396455 for your platform (p19396455_112040_WINNT.zip)

2.2
Apply the RDBMS DSTv23 Patch 19396455  using Opatch.

cd <PATCH_TOP_DIR>/19396455
opatch prereq CheckConflictAgainstOHWithDetail -ph ./
opatch apply

2.3 
restart the application(s) using this client.

Note: in 11.2 and up there is no need to shut down or stop processes seen you are simply adding new files, not replacing used ones.

3) Update all databases using this home by Scripts (DBMS_DST_scriptsV1.9.zip) to automatically update the RDBMS DST (timezone) version in an 11gR2 or 12cR1 database. (Doc ID 1585343.1)

3.1
(optional) run countTSTZdata.sql and removed uneeded TSTZ data to reduce the time needed to run upg_tzv_check.sql and upg_tzv_apply.sql

cd /u01/backup/distrib/dst_patch/DBMS_DST_scriptsV1.9                CTRLDB  
cd /mnt/data_fc/disk50G/distrib/dst_patch/rhel/DBMS_DST_scriptsV1.9  ultra-lb
cd /mnt/data_fc/disk50G/Distrib/dst_patch/rhel/DBMS_DST_scriptsV1.9  ultra-la

sqlplus / as sysdba
@countTSTZdata.sql

For most databases the biggest amount of data that is affected by DST updates will be in DBMS_SCHEDULER tables. 
If DBMS_SCHEDULER is not used for own jobs or is used but there is no need to keep the history then it might be an idea to purge the DBMS_SCHEDULER logging information using

exec dbms_scheduler.purge_log;

3.2
run upg_tzv_check.sql using SQL*PLUS from the database home

@upg_tzv_check.sql
A succesfull run will show at the end:

 INFO: A newer RDBMS DST version than the one currently used is found. 
 INFO: Note that NO DST update was yet done. 
 INFO: Now run upg_tzv_apply.sql to do the actual RDBMS DST update. 
 INFO: Note that the upg_tzv_apply.sql script will  
 INFO: restart the database 2 times WITHOUT any confirmation or prompt.
 
If above is seen upg_tzv_apply.sql can be run.

3.3
if upg_tzv_check.sql has run sucessfully , run upg_tzv_apply.sql using SQL*PLUS from the database home

 For RAC databases make sure the database is started as single instance
 Make sure any application accessing or storing TSTZ data is stopped
 upg_tzv_apply.sql will restart the database 2 times without asking any confirmation
 Typically upg_tzv_apply.sql will take less time than upg_tzv_check.sql
 When runned against the CDB of a Multitenant db all PDB will be closed
 
sqlplus / as sysdba
@upg_tzv_apply.sql

A succesfull run will show at the end:

 INFO: The RDBMS DST update is successfully finished.
 INFO: Make sure to exit this sqlplus session.
 INFO: Do not use it for timezone related selects.








