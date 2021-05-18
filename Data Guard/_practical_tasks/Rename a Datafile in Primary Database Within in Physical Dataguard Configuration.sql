How to Rename a Datafile in Primary Database Within in Physical Dataguard Configuration (Doc ID 733796.1)

The following steps describe how to rename a datafile in the primary database and manually propagate the changes to the standby database. 

1. Set STANDBY_FILE_MANAGEMENT=MANUAL on both Primary and Standby Database.

SQL>ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=MANUAL;

2. Take the Tablespace offline on the Primary Database:

SQL> ALTER TABLESPACE tbs_4 OFFLINE;

3. Rename Datafile on Primary Site:

% mv /Disk1/oracle/oradata/mum/payroll_1.dbf /Disk1/oracle/oradata/mum/payroll_01.dbf

4. Rename the Datafile in the Primary Database and bring the Tablespace back online:

SQL> ALTER TABLESPACE tbs_4 RENAME DATAFILE '/Disk1/oracle/oradata/mum/payroll_1.dbf' TO '/Disk1/oracle/oradata/mum/payroll_01.dbf'; 
SQL> ALTER TABLESPACE tbs_4 ONLINE;

5. Stop Redo Apply on Standby Database:

SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

6. Shutdown the Standby Database:

SQL> SHUTDOWN;

7. Rename the Datafile at the Standby site :

% mv /Disk1/oracle/oradata/mum/payroll_1.dbf /Disk1/oracle/oradata/mum/payroll_01.dbf

8. Start and mount the Standby Database:

SQL> STARTUP MOUNT;

9. Rename the Datafile in the Standby Database control file.

SQL> ALTER DATABASE RENAME FILE '/Disk1/oracle/oradata/mum/payroll_1.dbf' TO '/Disk1/oracle/oradata/mum/payroll_01.dbf';

Note : STANDBY_FILE_MANAGEMENT initialization parameter must be set to MANUAL. 

10. On the Standby Database, restart Redo Apply:

SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

11. Set STANDBY_FILE_MANAGEMENT=AUTO on both Primary and Standby Database.

SQL>ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO;