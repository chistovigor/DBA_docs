col undo_retention_sec format a20
col db_block_size format a15
--col needed_undo_size_megs format a15


set doc on

/*

 Show statistics for UNDO tablespace

*/

set doc off

select max(undoblks/((end_time-begin_time)*3600*24)) undo_block_per_sec from v$undostat
/

select e.value undo_retention_sec,
       f.value db_block_size,
       round((to_number(e.value) * to_number(f.value) * g.undo_block_per_sec) / (1024*1024),0) NEEDED_UNDO_SIZE_MEGS,
       round(d.undo_size/(1024*1024),3) ACTUAL_UNDO_SIZE_MEGS
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
     (select max(undoblks/((end_time-begin_time)*3600*24)) undo_block_per_sec from v$undostat) g
where e.name = 'undo_retention'
  and f.name = 'db_block_size'
/

--
-- Среднее количество UNDO блоков за час
--
select undotsn,
       end_time,
       undoblks_sum,
       round(undoblks_avg,1) undoblks_avg
from (
select undotsn,
       end_time,
       undoblks_sum,
       avg(undoblks_sum) over (partition by to_char(to_date(end_time,'yyyy-mm-dd hh24'),'yyyy-mm-dd')) undoblks_avg,
       row_number() over (order by end_time desc) rn
from (
       select distinct
              undotsn, 
              to_char(end_time,'yyyy-mm-dd hh24') end_time,
              sum(undoblks) over (partition by to_char(end_time,'yyyy-mm-dd hh24')) undoblks_sum
       from v$undostat
       order by end_time desc
)
)
where rn<=12
/

--
-- Среднее количество UNDO блоков за день
--
select distinct
       undotsn, 
       to_char(end_time,'dd-mm-yyyy','nls_date_language=russian') end_time,
       sum(undoblks) over (partition by to_char(end_time,'dd-mon-yyyy','nls_date_language=russian')) undoblks_sum
from v$undostat
order by end_time desc
/

