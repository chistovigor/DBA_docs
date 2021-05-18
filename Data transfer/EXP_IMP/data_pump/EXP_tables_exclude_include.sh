expdp router/loopexamspit parallel=2 estimate=blocks EXCLUDE=TABLE:\"LIKE \'__201%\'\" directory=EXPORT dumpfile=router_const.dmp logfile=router_const.log

expdp ardb_user schemas=icdb dumpfile=exp_icdb.dmp logfile=exp_icdb.log compression=all parallel=4 EXCLUDE=TABLE:\"IN \(\'ALL_ORGS_EXT_HCNG\',\'REPORTING_PERSON_HCNG\',\'SECURITIES_HCNG\'\)\" FLASHBACK_TIME=sysdate

expdp router/loopexamspit parallel=2 estimate=blocks INCLUDE=TABLE:\"LIKE \'__201403%\'\" directory=EXPORT dumpfile=router_201403.dmp logfile=router_201403.log

--export from 12c to 11g

expdp ardb_user SCHEMAS=DWHLOAD dumpfile=DATA_PUMP_ASM:exp_DWHLOAD_OLTP logfile=exp_DWHLOAD_OLTP parallel=8 compression=all LOGTIME=ALL STATISTICS=NONE METRICS=YES REUSE_DUMPFILES=yes VERSION=11.2.0

impdp ROUTER_TEST/loopexamspit directory=EXPORT dumpfile=router_const.dmp logfile=imp_router_const.log remap_schema=ROUTER:ROUTER_TEST

impdp ROUTER_TEST/loopexamspit directory=EXPORT QUERY=CB201403:'"WHERE SZDTIME <  TO_DATE (SZDTIME, ''YYYY-MM-DD HH24:MI:SS'') < TO_DATE (''2014-03-02 00:00:00'', ''YYYY-MM-DD HH24:MI:SS'');"' dumpfile=router_201403.dmp logfile=imp_router_201403.log remap_schema=ROUTER:ROUTER_TEST

IMPORT with COMPRESSION (oracle 12c)

transform=table_compression_clause:COLUMN STORE COMPRESS FOR ARCHIVE LOW либо transform=table_compression_clause:COLUMN STORE COMPRESS FOR ARCHIVE


Connect to impdp/expdp job and continue to monitor its status

impdp arbd_user attach=SYS_IMPORT_FULL_02

--for show import status for each element run:
CONTINUE_CLIENT