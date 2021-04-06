REm This is created by Prashu on 3/30/01
REm Modified : 04/05/01

set pagesize 600
set linesize 120
set head on
set echo off
SET VERIFY OFF

spool Database_report.txt

BREAK ON Created_on
COLUMN Created_on NEW_VALUE _DATE
SELECT TO_CHAR(SYSDATE, 'fmMonth DD, YYYY : hh:mi') created_on
FROM DUAL;
CLEAR BREAKS

prompt ***** Database information *****
col instance_name form a8 Heading "Instance"
col name form a8 Heading "DB Name"
col host_name form a12 Heading "Hostname"
select dbid,name,instance_name,host_name,created,log_mode from v$database, v$instance;

prompt ***** Database version information *****
select * from V$version;

prompt ***** Database options available *****
column parameter format a40
column value format a7
select * from v$option order by value,parameter;
cl column

prompt ***** Active Background processes *****
column description format a30
select name,status,description from v$session, v$bgprocess where v$session.paddr=v$bgprocess.paddr;

prompt ***** Database SGA allowcation *****
select * from v$sga;

prompt ***** Control file locations *****
column name format a80
select name from v$controlfile;


Prompt ***** Info about the REDO log files *****
column member format a80
select v$logfile.group#,member,bytes/1048576 MB from v$logfile, v$log where v$log.group#=v$logfile.group#;

prompt ***** Information about the Rollback segments *****
column segment_name format a10
column TABLESPACE_NAME format a15
select segment_name "SEG Names", tablespace_name from dba_rollback_segs;

prompt ***** Tablespace and data file locations *****
column max format a10
column pct format 999
column min format 999
select tablespace_name,initial_extent/1024 "Ini KB",next_extent/1024 "Next KB",min_extents Min,
replace (max_extents,2147483645,'Unlimited')Max, pct_increase PCT, status,extent_management Management from dba_tablespaces

column file_name format a50
break on tablespace_name skip 1
compute sum label 'Total' of MB on report
break on report
select tablespace_name, file_name, bytes/1048576 MB, autoextensible,status from dba_data_files order by tablespace_name; 

prompt ***** User information *****
column default_tablespace format a15
column temporary_tablespace format a15
column profile format a15
select username, DEFAULT_TABLESPACE ,TEMPORARY_TABLESPACE ,CREATED,profile from dba_users;

Prompt ***** User Roles *****
select GRANTEE,GRANTED_ROLE,ADMIN_OPTION from dba_role_privs where grantee not in ('SYS','SYSTEM','DBA','ORDSYS');

REM Select the parameters in two different way

prompt ***** init.ora parameters *****
column name format a35
column value format a15
select name, value from v$parameter where length(value)<10 order by name;

cl column
column name format a33
prompt ***** settings for the init.ora about the locations of the paths *****
select name, value from v$parameter where length(value)>=10 order by name;

cl column
cl break
spool off
Prompt ***** Database report creation completed *****



