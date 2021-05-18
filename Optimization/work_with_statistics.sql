export_dictionary_stats

Export stats into temporary table 

begin
    dbms_stats.create_stat_table(ownname => 'OWS', stattab => 'TMP_STATTAB');
    dbms_stats.export_schema_stats(ownname => 'OWS', stattab => 'TMP_STATTAB', statown => 'OWS');
end;
/


expdp igor_oem schemas=OWS include=TABLE:\"=\'TMP_STATTAB\'\" directory=stat dumpfile=exp_tmp_stattab logfile=exp_tmp_stattab compression=all flashback_time=sysdate

Export current stats backup into temporary table on prod system

begin
    dbms_stats.create_stat_table(ownname => 'OWS', stattab => 'TMP_STATTAB_BAK');
    dbms_stats.export_schema_stats(ownname => 'OWS', stattab => 'TMP_STATTAB_BAK', statown => 'OWS');
end;
/

export/import the statistics table with datapump


Import stats from temporary table on prod system

begin
    dbms_stats.import_schema_stats(ownname => 'OWS', stattab => 'TMP_STATTAB', statown => 'OWS');
end;
/

In case of error:

ERROR at line 1:
ORA-20002: Version of statistics table "OWS"."TMP_STATTAB_BAK" is too old.
Please try upgrading it with dbms_stats.upgrade_stat_table
ORA-06512: at "SYS.DBMS_STATS", line 18254
ORA-06512: at line 1

during creating backup of current statistics use the following solution (see DocID 21065289.8):

1) Drop newly created statistics table

exec dbms_stats.drop_stat_table('OWS','TMP_STATTAB_BAK');

2) Set nls_length_semantics at session level:

 alter session set nls_length_semantics=byte;

3) Recreate statistics table for backup

exec dbms_stats.create_stat_table('OWS','TMP_STATTAB_BAK');

4) Proceed with step 5
