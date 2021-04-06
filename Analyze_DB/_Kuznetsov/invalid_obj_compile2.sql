prompt 
prompt Compile all invalid objects in current schema ... 
prompt 


set serveroutput on size 1000000
set verify off 
set feedback off 


begin
  UTL_RECOMP.recomp_serial('&USER_NAME');
end;
/
