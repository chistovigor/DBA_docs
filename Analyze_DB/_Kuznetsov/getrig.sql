REM getrig.sql
set echo off
set verify off
set feedback off
set termout off
set heading off
set pagesize 0
set long 99999999
spool &1..sql

select
'create or replace trigger "' ||
         trigger_name || '"' || chr(10)||
 decode( substr( trigger_type, 1, 1 ),
         'A', 'AFTER', 'B', 'BEFORE', 'I', 'INSTEAD OF' ) ||
              chr(10) ||
 triggering_event || chr(10) ||
 'ON "' || table_owner || '"."' ||
       table_name || '"' || chr(10) ||
 decode( instr( trigger_type, 'EACH ROW' ), 0, null,
            'FOR EACH ROW' ) || chr(10) ,
 trigger_body
from user_triggers
where trigger_name = upper('&1')
/
prompt /

spool off
set verify on
set feedback on
set termout on
set heading on
