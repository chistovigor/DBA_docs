--define _editor=uedit32.exe

set serveroutput on size 1000000
--exec dbms_java.set_output(1000000);


set trimspool on
set doc off
SET LONG 100000
SET LONGCHUNKSIZE 100000
set linesize 1000
set pagesize 1000
--set numwidth 20
set colsep '|'
--set recsep each
--set recsepchar '-'
set arraysize 256
set editfile tempquery.sql



column global_name format a25
column plan_plus_exp format a100
column file_name format a45
column table_name format a32
column index_name format a32
column object_name format a40
column cluster_name format a20
column column_name format a20
column dimension_name format a20
column grantee format a15
column group_owner format a15
column method_name format a20
column mview_name format a15
column oname format a15
column owner format a15
column partition_name format a15
column sname format a20
column sql_text format a40
column subpartition_name format a15
column tablespace_name format a15
column table_owner format a15
column username format a11
column user_name format a15
column comments format a60
column data_type format a10
column name format a50
col property_name format a35
col property_value format a35
col description format a40
col schemaname format a40
col username format a40
col dest_name format a45
col destination format a45
col sql_redo format a50
col sql_undo format a50
col seg_name format a35
column namehitratio format a25 justify left
column hitratio format a15 justify left
column goalhitratio format a15 justify left
col directory_path format a60
col column_value format a100 wrapped
col member format a50
col EXTERNAL_NAME format a10
col spid format a15
col uspid format a15
col upid format a15
col OPERATION format a10
col STATUS format a10
column type format a15
column value format a25
column version format a15
column schema format a15

-- 12c
col password format a30
col profile format a35
col INITIAL_RSRC_CONSUMER_GROUP format a35
col LAST_LOGIN format a40
col LIMIT format a32
col PROXY_NAME format a30
col PRIVILEGE format a40
col HOST_NAME format a26
column SUBOBJECT_NAME format a40

column global_name new_value gname
set termout off
--select lower(user) || '@' || decode(global_name, 'ORACLE8.WORLD', '8.0', 'ORA8I.WORLD','8i', global_name ) global_name from global_name;
select lower(user) || '@' || decode(global_name, 'ORACLE8.WORLD', '8.0', 'ORA8I.WORLD','8i', global_name )||'@'||(select instance_name from v$instance)  global_name from global_name;
set sqlprompt '&gname> '
set termout on

alter session set NLS_DATE_FORMAT="YYYY-MM-DD:HH24:MI:SS";
alter session set nls_language="AMERICAN";
alter session set nls_date_language="AMERICAN";


