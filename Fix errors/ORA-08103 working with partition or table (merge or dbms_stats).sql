Ошибка:

SQL*Plus: Release 12.1.0.2.0 Production on Tue Aug 9 18:08:29 2016

Copyright (c) 1982, 2014, Oracle.  All rights reserved.

Last Successful login time: Tue Aug 09 2016 15:30:12 +03:00

Connected to:
Oracle Database 12c Enterprise Edition Release 12.1.0.2.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management,
OLAP,
Advanced Analytics and Real Application Testing options

BEGIN DBMS_STATS.GATHER_TABLE_STATS ('EQ','TRADES_BASE', 'EQ_TRADES_BASE_P_20110720', GRANULARITY => 'PARTITION'); END;

*
ERROR at line 1:
ORA-08103: object no longer exists
ORA-06512: at "SYS.DBMS_STATS", line 34757
ORA-06512: at line 1


SQL>

Для затронутой партиции выполняем:

SQL> analyze table EQ.TRADES_BASE partition(EQ_TRADES_BASE_P_20110720) validate structure;
если не помогло, то
SQL> alter table EQ.TRADES_BASE move partition EQ_TRADES_BASE_P_20110720 update indexes;
если не помогло, то установить для сессии
SQL> alter session set db_file_multiblock_read_count=1;



Информация из SR в MOS:

This issue happened on Partition Table and call stack for this issue matches with Bug 21896069 

Action Plan 
======== 

1] Workaround 
Setting db_file_multiblock_read_count=1 may help in some cases. 

If there is no issue with this workaround, please continue with the same workaround. 

Or 

2] Issue is first included in 12.1.0.2.160419 (Apr 2016) Database Proactive Bundle Patch 
If you have plan to upgrade DB to 12.1.0.2.160419, then this issue will be resolved. 

Or 

3] You can apply the following patch on top of 12.1.0.2.160119 
Patch for Bug 21896069 
Patch for Bug 20708701 
Both patches available. 

Refer: 
Bug 21896069 - ORA-8103 in EXADATA on Compressed HCC Tables stored in Bigfile Tablespaces ( Doc ID 21896069.8 ) 


Let me know, if there is any query. 

