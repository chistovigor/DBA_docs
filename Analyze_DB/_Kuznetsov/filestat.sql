select b.name, a.PHYRDS, 'read  ' as "Action"
from v$filestat a join v$datafile b using (file#)
order by 2 desc
/
select b.name, a.PHYWRTS, 'write '  as "Action"
from v$filestat a join v$datafile b using (file#)
order by 2 desc
/
