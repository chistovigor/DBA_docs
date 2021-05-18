Active Standby
Now you can bring up the standby database in read-only mode and continue to have the standby database updated from the primary. Here are the steps to achieve that:

1. Stop the managed recovery process:

alter database recover managed standby database cancel;

2. Open the standby database as read-only (if error appeared, shutdown and mount standby database first):

alter database open read only;

3. Restart the managed recovery process:

alter database recover managed standby database using current logfile disconnect;

Now the standby database is being updated, but it is simultaneously open for read-only access—this is the essence of Oracle Active Data Guard.

4. To test the “active” part of Oracle Active Data Guard, create a table in the primary database:

create table test (col1 number);

5. After a few seconds, check the existence of the table in the standby database:

select table_name from user_tables where table_name = 'TEST';

The table will be present. The standby database is open in read-only mode, but it is still applying the logs from the primary database. This feature enables you to run reports against it without sacrificing the ability to put the standby database into the primary role quickly.

6. To confirm the application of redo logs on the primary database, first switch the log file:

alter system switch logfile;

7. Now observe the alert log of the standby database. Use the automatic diagnostic repository command interpreter (ADRCI) tool, new in Oracle Database 11g:

$ adrci 
adrci> show alert -tail -f

The output is shown in Listing 2. The log message confirms that standby log group 5 was opened. The log was switched on the standby database when the log switch occurred on the primary database.

Code Listing 2: Partial output of the standby database’s alert log
2008-05-30 17:46:22.593000 -04:00
Media Recovery Waiting for thread 1 sequence 628
2008-05-30 17:46:23.928000 -04:00
Primary database is in MAXIMUM PERFORMANCE mode
kcrrvslf: active RFS archival for log 4 thread 1 sequence 627
RFS[1]: Successfully opened standby log 5: '+DATA1/sby_log02.rdo'
2008-05-30 17:46:28.717000 -04:00
Recovery of Online Redo Log: Thread 1 Group 5 Seq 628 Reading mem 0
Mem# 0: +DATA1/sby_log02.rdo


Next Steps


LEARN more about Oracle Active Data Guard 
 oracle.com/database/active-data-guard.html 
 oracle.com/technetwork/deploy/availability/htdocs/activedataguard.html
 Oracle Data Guard Concepts and Administration 
 Oracle high-availability solutions

You can take an Oracle RMAN backup from the standby database instead of the primary to reduce the load on the latter. And, better yet, you can take the backup even when the standby database is open in read-only and managed recovery mode.