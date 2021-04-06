--ASM configuration ooo

set linesize 1000
set pagesize 1000
col cmd format a30
col GROUP_NAME format a20

SELECT inst_id, NAME GROUP_NAME,
       STATE STATE,
       TYPE TYPE,
       TOTAL_MB TOTAL_MB,
       (TOTAL_MB-FREE_MB) USED_MB,
       FREE_MB,
       ROUND((1-(FREE_MB/decode(TOTAL_MB,0,-1,TOTAL_MB)))*100, 2) PCT_USED,
       decode(state,'DISMOUNTED','alter diskgroup '||name||' mount;','') cmd
FROM gV$ASM_DISKGROUP
ORDER BY NAME
/
col instance_name format a20
col SOFTWARE_VERSION format a12
col COMPATIBLE_VERSION format a12
select * from gv$asm_client
order by 1,2
/
prompt  gv$asm_disk:
col path format a40
col HEADER_STATUS format a15
col STATE format a15
col NAME format a20
select inst_id, header_status,state,group_number,disk_number,mode_status,total_mb,path, name
  from gv$asm_disk d
  order by path
/
prompt v$asm_operations:
set linesize 200
select * from v$asm_operation
/


col host_name format a25
col name format a12
col path format a20
col type format a8
col COMPATIBILITY format a12
col DATABASE_COMPATIBILITY format a12
break on report
compute sum of total_gb on report
compute sum of free_gb on report
select (select host_name from v$instance) host_name,
       group_number, 
       name, 
       type,
       round(total_mb/1024,0) total_gb, 
       round(free_mb/1024,0) free_gb, 
       round(100-(free_mb*100)/total_mb,2) used_pct, 
       round((free_mb*100)/total_mb,2) free_pct
--     cold_used_mb,
--       REQUIRED_MIRROR_FREE_MB,
--       USABLE_FILE_MB,
--     COMPATIBILITY,
--     DATABASE_COMPATIBILITY,
--     VOTING_FILES
from v$asm_diskgroup
order by 1,2,3;


col host_name format a20
col name format a16
col path format a30
col HEADER_STATUS format a9
col REDUNDANCY format a12
col FAILGROUP format a12
col STATE format a10
break on report
compute sum of total_gb on report
compute sum of free_gb on report
select (select host_name from v$instance) host_name,
       group_number,
       disk_number,
       name,
       path,
       HEADER_STATUS,
       round(total_mb/1024,0) total_gb, 
       round(free_mb/1024,0) free_gb,
       round(os_mb/1024,0) os_gb,
--       COLD_USED_MB,
--       REDUNDANCY,
--       FAILGROUP,
       decode(VOTING_FILE,'Y','Y',NULL) VOTING_FILE,
       STATE
--       REPAIR_TIMER,
--       PREFERRED_READ
from v$asm_disk
order by 1,2,3;


