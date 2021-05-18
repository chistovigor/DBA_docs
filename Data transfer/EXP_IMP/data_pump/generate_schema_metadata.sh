expdp system schemas=spur_day content=metadata_only dumpfile=exp_spur_day.dmp logfile=exp_spur_day.log compression=all reuse_dumpfiles=y

impdp ardb_user dumpfile=exp_spur_day.dmp logfile=sql_spur_day_1.log SQLFILE=spur_day_1.sql EXCLUDE=INDEX_STATISTICS EXCLUDE=TABLE_STATISTICS