--I have run the report covering the past 4 days and it reports
--ORA-20025: SQL ID 84kfv4p500pgh does not exist for this database/instance

--Solution
AWR only captures statements considered to be Top N (DBA_HIST_WR_CONTROL.TOPNSQL)
You can use DBMS_WORKLOAD_REPOSITORY.ADD_COLORED_SQL so that AWR will include it

exec dbms_workload_repository.add_colored_sql('<sql_id>');

exec dbms_workload_repository.create_snapshot;

select sql_id,snap_id, instance_number ,dbid from dba_hist_sqlstat where sql_id in ('<sql_id>');

После этого можно запускать отчет