ACCEPT owner CHAR default 'SYSADM' prompt 'Enter the database account name used by your application (default SYSADM): '

ACCEPT alg CHAR default 'AES128' prompt 'Choose encryption algorithm: 3DES168, AES128 (default), AES192, or AES256: '


PROMPT **********************************************************************
PROMPT Connect / as sysdba to grant necessary privilieges to &owner
PROMPT **********************************************************************

conn / as sysdba

grant execute on DBMS_REDEFINITION to &owner;
grant CREATE ANY TABLE, ALTER ANY TABLE, DROP ANY TABLE, LOCK ANY TABLE, SELECT ANY TABLE, CREATE ANY TRIGGER, CREATE ANY INDEX to &owner;

PROMPT **********************************************************************
PROMPT Connect as &owner
PROMPT **********************************************************************

conn &owner
PROMPT **********************************************************************
PROMPT Please provide password for &owner
PROMPT **********************************************************************

set timing on;

rem ALTER SESSION FORCE PARALLEL DML ...

PROMPT **********************************************************************
PROMPT Create table otr_log:
PROMPT **********************************************************************
create table		otr_log (
tbs_name		varchar2(32)
, tbs_ddl		clob
, enc_tbs_name		varchar2(32)
, enc_tbs_ddl		clob);

PROMPT **********************************************************************
PROMPT Populating tbs_name and enc_tbs_name in otr_log (22 seconds)
PROMPT **********************************************************************
insert into otr_log (tbs_name, enc_tbs_name) select distinct tablespace_name, tablespace_name||'_ENC' from user_tables;

insert into otr_log (tbs_name, enc_tbs_name) values ('PSINDEX','PSINDEX_ENC');

PROMPT **********************************************************************
PROMPT Populating tbs_ddl in otr_log (47 seconds)
PROMPT **********************************************************************
set long 100000;
set heading off;
set feedback off;
set echo off;
set pages 100;
set trimspool on;
set linesize 2500;
set timing off;

exec dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',true); 

column tbs_ddl format a2500 word_wrapped;

update otr_log set tbs_ddl = dbms_metadata.get_ddl('TABLESPACE',tbs_name);

set heading on;
set feedback on;
set echo on;
PROMPT **********************************************************************
PROMPT Populated tbs_ddl in otr_log
PROMPT **********************************************************************
PROMPT
PROMPT **********************************************************************
PROMPT Create enc_tbs_ddl in otr_log from tbs_ddl
PROMPT **********************************************************************
PROMPT
PROMPT **********************************************************************
PROMPT Change <tablespace_name> to <tablespace_name>_ENC:
PROMPT **********************************************************************
update otr_log set enc_tbs_ddl = replace(tbs_ddl,'" DATAFILE','_ENC" DATAFILE');

PROMPT **********************************************************************
PROMPT Change <OS-filename>.dbf to <OS-filename>_enc.dbf
PROMPT **********************************************************************
update otr_log set enc_tbs_ddl = replace(enc_tbs_ddl,'.dbf','_enc.dbf');

PROMPT **********************************************************************
PROMPT Insert ENCRYPTION parameters using &alg
PROMPT **********************************************************************
update otr_log set enc_tbs_ddl = replace(enc_tbs_ddl,'DEFAULT NOCOMPRESS ','ENCRYPTION using ''&alg'' DEFAULT'||CHR(10)||'  NOCOMPRESS STORAGE(ENCRYPT)');

commit;

PROMPT
PROMPT **********************************************************************
PROMPT Create table index_log (For later, needs to exist before 
PROMPT tables_in_tbs is populated)
PROMPT **********************************************************************

create table		index_log (
index_name			varchar2(32)
, int_index_name	varchar2(32)
, index_ddl			clob
, int_index_ddl	clob
, table_name		varchar2(32)
, int_table_name	varchar2(32)
, tbs_name			varchar2(32)
, enc_tbs_name		varchar2(32)
, owner				varchar2(16));

PROMPT **********************************************************************
PROMPT Create table tables_in_tbs:
PROMPT **********************************************************************
create table		tables_in_tbs (
table_name			varchar2(32)
, tbs_name			varchar2(32)
, enc_tbs_name		varchar2(32)
, can_redef			varchar2(3)
, table_ddl			clob
, int_table_ddl	clob
, has_lob			varchar2(3)
, owner				varchar2(32));

PROMPT **********************************************************************
PROMPT Populating tables_in_tbs: (90 minutes)
PROMPT **********************************************************************
set long 100000;
set heading off;
set feedback off;
set echo off;
set pages 100;
set trimspool on;
set linesize 2500;
set timing off;

exec dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',true); 

column x format a2500 word_wrapped;

insert into tables_in_tbs (table_name, table_ddl, tbs_name, enc_tbs_name) select table_name, dbms_metadata.get_ddl('TABLE',table_name) x, tablespace_name, tablespace_name||'_ENC' from user_tables;

update tables_in_tbs set owner ='&owner';

set timing on;
set heading on;
set feedback on;
set echo on;
PROMPT **********************************************************************
PROMPT Populated tables_in_tbs
PROMPT **********************************************************************
PROMPT
PROMPT **********************************************************************
PROMPT Check if all tables can be online redefined (8 minutes)
PROMPT **********************************************************************
@./01-check_redef_procedure.sql;

exec check_redef;

PROMPT **********************************************************************
PROMPT Tables that cannot be redefined:
PROMPT **********************************************************************
select tbs_name, table_name from tables_in_tbs where can_redef = 'NO' order by tbs_name;

PROMPT **********************************************************************
PROMPT Create int_table_ddl in tables_in_tbs from table_ddl
PROMPT **********************************************************************
PROMPT
PROMPT **********************************************************************
PROMPT Change <tablespace_name> to <tablespace_name>_ENC: (23 seconds)
PROMPT **********************************************************************
update tables_in_tbs set int_table_ddl = replace(table_ddl,'" ;','_ENC";');

PROMPT **********************************************************************
PROMPT Change <table_name> to INT_<table_name>: (24 seconds)
PROMPT **********************************************************************
update tables_in_tbs set int_table_ddl = replace(int_table_ddl,'"&owner"."','"&owner"."INT_');

PROMPT **********************************************************************
PROMPT Insert <new_line> to avoid line breaks: (17 sec.)
PROMPT **********************************************************************
update tables_in_tbs set int_table_ddl = replace(int_table_ddl,'DEFAULT FLASH','DEFAULT'||CHR(10)||'  FLASH');

PROMPT **********************************************************************
PROMPT Find tables that contain LOB or CLOB columns:
PROMPT **********************************************************************
update tables_in_tbs set has_lob = 'YES' where dbms_lob.instr(int_table_ddl,'TABLESPACE',1,2) > 0;

create bitmap index has_lob_bidx on tables_in_tbs(has_lob) tablespace "PSINDEX";
create unique index table_name_idx on tables_in_tbs(table_name) tablespace "PSINDEX";

PROMPT **********************************************************************
PROMPT Change <tablespace_name> to <tablespace_name>_ENC in tables with LOB:
PROMPT **********************************************************************
@./02-replace_ENC.sql;

exec replace_CT_with_ENC;

PROMPT **********************************************************************
PROMPT Preparing Indexes:
PROMPT **********************************************************************
PROMPT
PROMPT **********************************************************************
PROMPT Populating index_log (51 minutes)
PROMPT **********************************************************************

set long 100000;
set heading off;
set feedback off;
set echo off;
set pages 100;
set trimspool on;
set linesize 2500;

exec dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',true); 

column index_ddl format a2500 word_wrapped;

insert into index_log (index_name, int_index_name, index_ddl, table_name, int_table_name) select index_name, 'INT_'||index_name, dbms_metadata.get_ddl('INDEX',index_name,'&owner'), table_name, 'INT_'||table_name from user_indexes where tablespace_name = 'PSINDEX';

create unique index index_name_idx on index_log(index_name) tablespace "PSINDEX";

insert into index_log (index_name, int_index_name, index_ddl, table_name, int_table_name) values ('INDEX_NAME_IDX','INT_INDEX_NAME_IDX', dbms_metadata.get_ddl('INDEX','INDEX_NAME_IDX','&owner'), 'INDEX_LOG','INT_INDEX_LOG');

update index_log i set i.tbs_name = (select t.tbs_name from tables_in_tbs t where t.table_name = i.table_name);

update index_log set enc_tbs_name = tbs_name||'_ENC';

update index_log set owner = '&owner';

PROMPT **********************************************************************
PROMPT Populated index_log
PROMPT **********************************************************************

set heading on;
set feedback on;
set echo on;

PROMPT **********************************************************************
PROMPT Create int_index_ddl in index_log from index_ddl:
PROMPT **********************************************************************
PROMPT
PROMPT **********************************************************************
PROMPT Change <tablespace_name> to <tablespace_name>_ENC:
PROMPT **********************************************************************
update index_log set int_index_ddl = replace (index_ddl,'" ;','_ENC";');

PROMPT **********************************************************************
PROMPT Change <table_name> to INT_<table_name>:
PROMPT **********************************************************************
update index_log set int_index_ddl = replace (int_index_ddl,'"&owner"."','"&owner"."INT_');

PROMPT **********************************************************************
PROMPT Insert <new_line> to avoid line breaks:
PROMPT **********************************************************************
update index_log set int_index_ddl = replace (int_index_ddl,'ON "&owner"','ON'||CHR(10)||'  "&owner"');
update index_log set int_index_ddl = replace (int_index_ddl,'", "','",'||CHR(10)||'  "');
update index_log set int_index_ddl = replace (int_index_ddl,'DEFAULT FLASH','DEFAULT'||CHR(10)||'  FLASH');

PROMPT **********************************************************************
PROMPT Create OS directory "./work" to store migration scripts
PROMPT **********************************************************************
host mkdir ./work

PROMPT **********************************************************************
PROMPT Connect / as sysdba to create DIRECTORY
PROMPT **********************************************************************
conn / as sysdba

create or replace DIRECTORY work as '/home/oracle/work';

PROMPT **********************************************************************
PROMPT Grant write privilege on DIRECTORY to &owner
PROMPT **********************************************************************
grant write on DIRECTORY work to &owner;

conn &owner
PROMPT **********************************************************************
PROMPT Please provide password for '&owner'
PROMPT **********************************************************************
PROMPT
PROMPT **********************************************************************
PROMPT Compile procedure that will generate master script for encrypted tablespaces:
PROMPT **********************************************************************
@./03-create_enc_tbs_procedure.sql;

PROMPT **********************************************************************
PROMPT Execute procedure that will generate master script for encrypted tablespaces:
PROMPT **********************************************************************
exec create_tbs_scripts;

PROMPT **********************************************************************
PROMPT STOP and verify master script ('./work/create_enc_tbs_script.sql')
PROMPT in other terminal window; hit 'RETURN' to run master script.
PROMPT It will generate one script for each tablespace, containing the DDL to
PROMPT create an encrypted tablespace, and the DDL for all tables in that
PROMPT tablespace.
PROMPT **********************************************************************
ACCEPT return

@./work/create_enc_tbs_script.sql;

PROMPT **********************************************************************
PROMPT Compile procedure that will generate scripts to start 
PROMPT Online Table Redefinition
PROMPT **********************************************************************
@./04-create_start_redef_procedure.sql;

PROMPT **********************************************************************
PROMPT Execute procedure that will generate one script for each tablespace.
PROMPT **********************************************************************
exec create_start_redef_tbs_scripts;

PROMPT **********************************************************************
PROMPT Compile procedure that will generate master script to create indexes 
PROMPT for current tablespace in 'PSINDEX'
PROMPT **********************************************************************
@./05-create_indexes.sql;

exec create_index_scripts;

@./work/create_int_index_script.sql

@./06-reg_indexes_procedure.sql

exec register_indexes;


PROMPT **********************************************************************
PROMPT Issue OS command to remove all blank lines from SQL files in ./work; some of
PROMPT them will generate errors when the SQL commands are executed by the database.
PROMPT **********************************************************************

PROMPT **********************************************************************
PROMPT Change to the WORK directory and issue on the OS command line:
PROMPT find . –type f –exec sed –i '/^$/d' {} \;
PROMPT **********************************************************************
PROMPT If SED is not available, try 'perl':
PROMPT find . -type f -exec perl -pi -e 's/^\n$//' {} \;
PROMPT **********************************************************************

exit

cd /home/oracle

@./07-create_copy_deps_procedure.sql;

exec create_copy_deps_scripts;

@./08-create_sync_finish_procedure.sql;

exec create_sync_finish_scripts;
****************************************

****************************************
PROMPT EXTRA STEPS for PSINDEX:
****************************************

@./work/01-create_tbs_PSINDEX_ENC.sql

****************************************
PROMPT Unless ALL application tables are migrated,
PROMPT 'PSINDEX' cannot be deleted and 
PROMPT 'PSINDEX_ENC' cannot be renamed to 'PSINDEX' !!
****************************************

****************************************
PROMPT EXTRA STEPS for PSDEFAULT:
****************************************

@./work/01-create_tbs_PSDEFAULT_ENC.sql

@./work/02-start_redef_PSDEFAULT_ENC.sql

@./work/03-create_index_for_PSDEFAULT_ENC.sql

@./work/04-reg_indexes_in_PSDEFAULT_ENC.sql

@./work/05-copy_deps_from_PSDEFAULT.sql

@./work/06-sync_finish_tables_in_PSDEFAULT_ENC.sql

alter tablespace PSDEFAULT rename to PSDEFAULT_backup;

alter tablespace PSDEFAULT_ENC rename to PSDEFAULT;

conn / as sysdba

grant connect, resource, dba to PS identified by PS;

conn PS/PS;

drop index PS_PSDBOWNER;

drop public synonym PSDBOWNER;

alter table PSDBOWNER move tablespace PSDEFAULT;

create unique index PS_PSDBOWNER on PSDBOWNER (DBNAME) tablespace PSDEFAULT;

create public synonym PSDBOWNER for PSDBOWNER;

grant select on PSDBOWNER to PUBLIC;

conn / as sysdba;

alter user &owner default tablespace PSDEFAULT;

alter user PSFTDBA default tablespace PSDEFAULT;

alter user PEOPLE default tablespace PSDEFAULT;

revoke connect, resource, dba from PS;

conn &owner;

REM drop tablespace PSDEFAULT_backup including contents and datafiles;

exit;
