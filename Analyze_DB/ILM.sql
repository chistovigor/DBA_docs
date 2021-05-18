select * from DBA_ILMOBJECTS where object_name = 'CU_ORDBOOK' order by 4;

select * from DBA_ILMDATAMOVEMENTPOLICIES;

select * from DBA_ILMEVALUATIONDETAILS where object_name = 'CU_ORDBOOK' and JOB_NAME is not NULL order by 5;

select * from DBA_ILMEVALUATIONDETAILS where object_name = 'CU_ORDBOOK' order by 5;

select * from all_tab_partitions where table_name = 'CU_ORDBOOK' order by 4;

select * from  V$HEAT_MAP_SEGMENT where OBJECT_NAME = 'CU_ORDBOOK';

select * from dba_HEAT_MAP_SEG_HISTOGRAM  where OBJECT_NAME = 'CU_ORDBOOK';