#!/bin/bash

#variables
dblist=(`ps -ef | grep pmon | grep -v grep  | cut -d '_' -f 3 | egrep '^w4|^dm'`)
sga_size=5G
pga_size=3G

unset ORACLE_SID
export ORACLE_HOME=/ora12c/app/product/12.1.0/dbhome_1

#execution steps

echo SHOW ONLY MEMORY PARAMETERS FOR PGA AND SGA WHICH IS NOT EQUAL TO GIVEN IN SCRIPT VARIABLES

for i in "${dblist[@]}"
do
#echo connect for the database $i
export ORACLE_SID=$i
#set | grep ORACLE_SID | grep -v "_="
echo echo database $i
sqlplus -S / as sysdba <<!
set heading off linesize 300 pagesize 0 serveroutput on feedback off
col command for a300

select 'cp '||value||' '||value||'.'||to_char(sysdate,'yyyymmdd') command
from v\$parameter where name = 'spfile' and value is not null;
select name,DISPLAY_VALUE from v\$parameter where name = 'sga_target' and DISPLAY_VALUE <> '$sga_size';
select name,DISPLAY_VALUE from v\$parameter where name = 'sga_max_size' and DISPLAY_VALUE <> '$sga_size';
select name,DISPLAY_VALUE from v\$parameter where name = 'pga_aggregate_target' and DISPLAY_VALUE <> '$pga_size';
select name,DISPLAY_VALUE from v\$parameter where name = 'pga_aggregate_limit' and DISPLAY_VALUE <> '$pga_size';
declare
v_spfile VARCHAR2(4000);
v_db_name VARCHAR2(20);
v_resize VARCHAR2(1):='$1';
begin
dbms_output.enable;
select lower(value) into v_db_name from v\$parameter where name = 'db_unique_name';
select value into v_spfile from v\$parameter where name = 'spfile';
if v_spfile like '%/%' then
dbms_output.put_line('prompt spfile used for db '||v_db_name);
IF v_resize = 'Y' THEN
dbms_output.put_line('memory resize');
execute immediate 'alter system set sga_target = $sga_size scope = spfile sid = ''*''';
execute immediate 'alter system set sga_max_size = $sga_size scope = spfile sid = ''*''';
execute immediate 'alter system set pga_aggregate_target = $pga_size scope = spfile sid = ''*''';
execute immediate 'alter system set pga_aggregate_limit = $pga_size scope = spfile sid = ''*''';
ELSE
dbms_output.put_line('alter system set sga_target = $sga_size scope = spfile sid = ''*'';');
dbms_output.put_line('alter system set sga_max_size = $sga_size scope = spfile sid = ''*'';');
dbms_output.put_line('alter system set pga_aggregate_target = $pga_size scope = spfile sid = ''*'';');
dbms_output.put_line('alter system set pga_aggregate_limit = $pga_size scope = spfile sid = ''*'';');
END IF;
else
dbms_output.put_line('pfile used for db '||v_db_name||', set parameter MANUALLY ');
end if;
end;
/
exit
!
done

exit