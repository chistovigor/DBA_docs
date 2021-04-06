select t.name as tablespace_name, d.file# as "df#", d.name as file_name, b.status
from v$datafile d, v$tablespace t, v$backup b
where d.ts#=t.ts#
and b.file#=d.file#
and b.status='ACTIVE'
/
