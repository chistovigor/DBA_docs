--FRA usage ooo
set linesize 1000 pagesize 10000


col file_type format a24
rem col percent_space_used format a40
rem col percent_space_reclaimable format a40

select a.*,round(a.percent_space_used*b.value/1024/1024/100,2) used_Mb,round(a.percent_space_reclaimable*b.value/1024/1024/100,2) can_be_deleted_Mb,
(
select round(sum(l.blocks * l.block_size)/1024/1024)
  from v$archived_log l
  where l.applied='NO' and l.deleted= 'NO' and l.dest_id=2
) non_applied_redo_mb
from
  v$flash_recovery_area_usage a,
  (select value from v$parameter where name='db_recovery_file_dest_size') b
  order by 1;


col space_name format a12
select name space_name, 
       round(space_limit/1024/1024/1024) space_limit_gb,  
       round(space_used/1024/1024/1024) space_used_gb,
       round(space_reclaimable/1024/1024/1024) space_reclaimable_gb,
       number_of_files,
       round((space_used-space_reclaimable)/space_limit*100) space_used_percent
from v$recovery_file_dest;


col param format a55
col value format a65
select param, value
from (
  select ksppinm param, ksppstvl  value, ksppdesc description, decode(instr('_',ksppinm),0,'Normal','Undescore') status
  from  x$ksppi x, x$ksppcv y
  where x.indx = y.indx
  union all
  select t.kspponm param, null value, null description, 'Eliminated' status
    from x$ksppo t
    where t.ksppoflg = 1
)
where
param in
('db_recovery_file_dest', 'db_recovery_file_dest_size','_log_deletion_policy','standby_archive_dest')
union all
select name, value from v$parameter where
(name like 'log_archive_dest%' and value is not null and name not like 'log_archive_dest_state_%')
or (name like 'log_archive_dest_state%' and value<>'enable' )
union all
select 'rman:   '||a.name, a.value from v$rman_configuration a
order by 1;


select inst_id, oldest_flashback_time, retention_target as retention_mins, round(flashback_size/1024/1024/1024) flash_size_gb, round(estimated_flashback_size/1024/1024/1024) estimated_size_gb   from GV$FLASHBACK_DATABASE_LOG;

select inst_id, t.flashback_on from gv$database t;

