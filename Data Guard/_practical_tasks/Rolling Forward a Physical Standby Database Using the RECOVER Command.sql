http://allthingsoracle.com/rolling-forward-a-physical-standby-database-using-the-recover-command/
(it does not work if the databases are clustered. I had to set CLUSTER_DATABASE=FALSE on both primary and standby for te duration of the operation. I have not checked whether this is documented)

1) Execute on both primary and standby (on standby it will be less)

select max(sequence#) from v$archived_log;
 
2) Execute on primary

select sequence#, name from v$archived_log where sequence# > max sequence# from standby ;

3) Execute on both primary and standby (on standby it will be less)

select current_scn from v$database;

-- check datafiles were not recovered

select file#, checkpoint_change# from v$datafile;

4) In order to synchronize the standby we will stop the managed recovery processes on the physical standby database and place the physical standby database in MOUNT mode.

recover managed standby database cancel;
shutdown immediate;
startup mount;

5) ON STANDBY database

rman target /

recover database from service boston noredo using compressed backupset section size 100m; --HERE boston is the service name of primary DB

6) ON STANDBY database

SHUTDOWN IMMEDIATE;
STARTUP NOMOUNT;


rman target /

RESTORE STANDBY CONTROLFILE FROM SERVICE boston; --HERE boston is the service name of primary DB

ALTER DATABASE MOUNT;

