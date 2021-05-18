DECLARE 

taskname varchar2(30) := 'SQLACCESS2400659';
task_desc varchar2(256) := 'SQL Access Advisor';
task_or_template varchar2(30) := 'SQLACCESS_OLTP';
task_id number := 0;
wkld_name varchar2(30) := 'SQLACCESS2400659_wkld';
saved_rows number := 0;
failed_rows number := 0;
num_found number;

BEGIN
dbms_advisor.reset_task(taskname);
select count(*) into num_found from user_advisor_sqla_wk_map where task_name = taskname and workload_name = wkld_name;
IF num_found > 0 THEN
dbms_advisor.delete_sqlwkld_ref(taskname,wkld_name);
END IF;
select count(*) into num_found from user_advisor_sqlw_sum where workload_name = wkld_name;
IF num_found > 0 THEN
dbms_advisor.delete_sqlwkld(wkld_name);
END IF;
dbms_advisor.create_sqlwkld(wkld_name,null);
dbms_advisor.add_sqlwkld_ref(taskname,wkld_name);
dbms_advisor.set_sqlwkld_parameter(wkld_name,'VALID_ACTION_LIST',DBMS_ADVISOR.ADVISOR_UNUSED);
dbms_advisor.set_sqlwkld_parameter(wkld_name,'VALID_MODULE_LIST',DBMS_ADVISOR.ADVISOR_UNUSED);
dbms_advisor.set_sqlwkld_parameter(wkld_name,'SQL_LIMIT',DBMS_ADVISOR.ADVISOR_UNLIMITED);
dbms_advisor.set_sqlwkld_parameter(wkld_name,'VALID_USERNAME_LIST',DBMS_ADVISOR.ADVISOR_UNUSED);
dbms_advisor.set_sqlwkld_parameter(wkld_name,'VALID_TABLE_LIST',DBMS_ADVISOR.ADVISOR_UNUSED);
dbms_advisor.set_sqlwkld_parameter(wkld_name,'INVALID_TABLE_LIST',DBMS_ADVISOR.ADVISOR_UNUSED);
dbms_advisor.set_sqlwkld_parameter(wkld_name,'ORDER_LIST','PRIORITY,OPTIMIZER_COST');
dbms_advisor.set_sqlwkld_parameter(wkld_name,'INVALID_ACTION_LIST',DBMS_ADVISOR.ADVISOR_UNUSED);
dbms_advisor.set_sqlwkld_parameter(wkld_name,'INVALID_USERNAME_LIST',DBMS_ADVISOR.ADVISOR_UNUSED);
dbms_advisor.set_sqlwkld_parameter(wkld_name,'INVALID_MODULE_LIST',DBMS_ADVISOR.ADVISOR_UNUSED);
dbms_advisor.set_sqlwkld_parameter(wkld_name,'VALID_SQLSTRING_LIST',DBMS_ADVISOR.ADVISOR_UNUSED);
dbms_advisor.set_sqlwkld_parameter(wkld_name,'INVALID_SQLSTRING_LIST',DBMS_ADVISOR.ADVISOR_UNUSED);
dbms_advisor.set_sqlwkld_parameter(wkld_name,'JOURNALING','6');
dbms_advisor.set_sqlwkld_parameter(wkld_name,'DAYS_TO_EXPIRE','30');
dbms_advisor.import_sqlwkld_sqlcache(wkld_name,'REPLACE',2,saved_rows,failed_rows);
dbms_advisor.set_task_parameter(taskname,'ANALYSIS_SCOPE','ALL');
dbms_advisor.set_task_parameter(taskname,'RANKING_MEASURE','PRIORITY,OPTIMIZER_COST');
dbms_advisor.set_task_parameter(taskname,'DEF_PARTITION_TABLESPACE','ANNUAL_DATAENC');
dbms_advisor.set_task_parameter(taskname,'TIME_LIMIT',10000);
dbms_advisor.set_task_parameter(taskname,'MODE','COMPREHENSIVE');
dbms_advisor.set_task_parameter(taskname,'STORAGE_CHANGE',DBMS_ADVISOR.ADVISOR_UNLIMITED);
dbms_advisor.set_task_parameter(taskname,'DML_VOLATILITY','TRUE');
dbms_advisor.set_task_parameter(taskname,'WORKLOAD_SCOPE','PARTIAL');
dbms_advisor.set_task_parameter(taskname,'DEF_INDEX_TABLESPACE','CORE_INDEX');
dbms_advisor.set_task_parameter(taskname,'DEF_INDEX_OWNER','ROUTER');
dbms_advisor.set_task_parameter(taskname,'DEF_MVIEW_TABLESPACE','CORE_INDEX');
dbms_advisor.set_task_parameter(taskname,'DEF_MVIEW_OWNER','ROUTER');
dbms_advisor.set_task_parameter(taskname,'DEF_MVLOG_TABLESPACE','CORE');
dbms_advisor.set_task_parameter(taskname,'CREATION_COST','TRUE');
dbms_advisor.set_task_parameter(taskname,'JOURNALING','6');
dbms_advisor.set_task_parameter(taskname,'DAYS_TO_EXPIRE','30');
dbms_advisor.execute_task(taskname);
END;
 