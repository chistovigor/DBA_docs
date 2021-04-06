--
-- Optimize Your UNDO Parameters
--

-- Optimal Undo Retention

select d.undo_size/(1024*1024) "ACTUAL UNDO SIZE (MEGS)",
       substr(e.value,1,25) "UNDO RETENTION (Secs)",
       round((d.undo_size / (to_number(f.value) * g.undo_block_per_sec))) "OPTIMAL UNDO RETENTION (Secs)"
from (select sum(a.bytes) undo_size
      from v$datafile a,
           v$tablespace b, 
           dba_tablespaces c
      where c.contents = 'UNDO' and 
            c.status = 'ONLINE' and 
            b.name = c.tablespace_name and 
            a.ts# = b.ts#) d,
      v$parameter e,
      v$parameter f,
     (select max(undoblks/((end_time-begin_time)*3600*24)) undo_block_per_sec
      from v$undostat) g
where e.name = 'undo_retention'
and f.name = 'db_block_size'
/

-- Optimal Undo Size

select d.undo_size/(1024*1024) "ACTUAL UNDO SIZE (MEGS)",
       substr(e.value,1,25) "UNDO RETENTION (Secs)",
       (to_number(e.value) * to_number(f.value) * g.undo_block_per_sec) / (1024*1024) "NEEDED UNDO SIZE (MEGS)"
from (select sum(a.bytes) undo_size
      from v$datafile a,
           v$tablespace b,
           dba_tablespaces c
      where c.contents = 'UNDO' and 
            c.status = 'ONLINE' and 
            b.name = c.tablespace_name and a.ts# = b.ts#) d,
     v$parameter e,
     v$parameter f,
     (select max(undoblks/((end_time-begin_time)*3600*24)) undo_block_per_sec
       from v$undostat) g
where e.name = 'undo_retention'
and f.name = 'db_block_size'
/


