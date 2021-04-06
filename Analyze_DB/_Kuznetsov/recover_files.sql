column df_name format a40
column error format a30

select r.file# as df#, d.name as df_name, t.name as tbsp_name, d.status, r.error, r.change#, r.time
from v$recover_file r, v$datafile d, v$tablespace t
where t.ts# = d.ts# and d.file# = r.file#
/
