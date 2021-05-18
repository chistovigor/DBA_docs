1) Check tablespaces for remap (from DDL in file)

impdp ardb_user dumpfile=bpel_sov_loaderb sqlfile=bpel_sov_loaderb.sql
  
2) CREATE USER

CREATE USER bpel_sov
  IDENTIFIED BY vvm562
  DEFAULT TABLESPACE BPEL
  TEMPORARY TABLESPACE TEMP
  PROFILE DEFAULT
  ACCOUNT UNLOCK;
  -- Roles for bpel_sov 
  GRANT CONNECT TO bpel_sov;
  GRANT RESOURCE TO bpel_sov;
  GRANT CREATE VIEW TO bpel_sov;
  GRANT UNLIMITED TABLESPACE TO bpel_sov;
  GRANT CREATE DATABASE LINK TO bpel_sov;
  alter user bpel_sov default role all;
  
3) Import data with remapping

impdp ardb_user/vvm562 dumpfile=pie_gcb logfile=imp_pie_gcb remap_tablespace=PIE_DATA:small_tables_data,USERS:small_tables_data

4) If some rows were not imported because of ORA-12899 error, then change size of columns in tables with errors

5) List of constraints for disabling after all imported

select distinct 'alter table '||owner||'.'||table_name||' disable constraint '||constraint_name||' ; ' from dba_constraints
where r_constraint_name in ( select constraint_name from dba_constraints )
and r_owner = 'BPEL_SOV' and status = 'DISABLED'
order by 1 ;

6) Disable constraint before import all table rows

select distinct 'alter table '||owner||'.'||table_name||' disable constraint '||constraint_name||' ; ' from dba_constraints
where r_constraint_name in ( select constraint_name from dba_constraints )
and r_owner = 'BPEL_SOV' and status = 'ENABLED'
order by 1 ;

7) Import all table rows

impdp ardb_user/vvm562 dumpfile=bpel_sov_loadera logfile=imp_bpel_sov_rows table_exists_action=truncate content=data_only

8) Enable constrains after import

select distinct 'alter table '||owner||'.'||table_name||' enable constraint '||constraint_name||' ; ' from dba_constraints
where r_constraint_name in ( select constraint_name from dba_constraints )
and r_owner = 'BPEL_SOV' and status = 'DISABLED'
order by 1 ;

9) Disable constraints were disabled (list from step 5 !!!)

10) Grant select on V$SESSION to imported users

sqlplus / as sysdba
grant select on V_$SESSION to PIE_GCB,PIE_SWT,FB_ONLINE,bpel_sov;
  
