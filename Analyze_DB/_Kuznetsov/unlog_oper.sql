

set doc on

DOC
######################################################################
######################################################################
##
## Unlogged or unrecoverable operations
##
## Recover after unlogging operations
## http://download-uk.oracle.com/docs/cd/B19306_01/server.102/b14239/scenarios.htm#i1015738
##
######################################################################
######################################################################
#

set doc off


column f_name  format a50
column ts_name format a35
column force_logging format a15
column force_logging format a15

select name, force_logging from v$database
/

select f.file#, 
       f.name as f_name, 
       t.name as ts_name, 
       (select force_logging from dba_tablespaces where dba_tablespaces.tablespace_name=t.name) force_logging,
       f.unrecoverable_time, 
       f.unrecoverable_change#
from  v$datafile f, 
      v$tablespace t
where f.ts#=t.ts#
order by t.name
/
