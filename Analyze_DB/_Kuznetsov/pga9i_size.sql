column osuser format a20
column schemaname format a17
column username format a18
column pprogram format a30
column sprogram format a30
column client_info format a50
column spid format a8
column sid format 999999
column serial# format 999999
--column pga_used_mb justify center format 999999999999
--column pga_alloc_mb justify center format a15
--column pga_max_mb justify center format a15
column module format a26
column machine format a21
column ip_address format a15
column user_process format a25
column service_name format a20
column state format a20
column event format a17
column action format a17
column sql_text format a35
column sql_prev_text format a35
column RESOURCE_CONSUMER_GROUP format a24
column MACHINE format a27


select p.spid,
       s.process uspid,
       s.sid, 
       s.serial#, 
       s.osuser,
       s.machine,
       --utl_inaddr.get_host_address(substr(s.machine,instr(s.machine,'\')+1)) ip_address,
       s.username, 
       s.program sprogram, 
       p.program pprogram, 
       round(p.pga_used_mem/(1024*1024),2) pga_used_mb, 
       --to_char(p.pga_alloc_mem/(1024*1024),'999G990D000') pga_alloc_mb, 
       round(p.pga_max_mem/(1024*1024),2) pga_max_mb, 
       s.module,
       s.action,
       s.client_info
from v$process p, v$session s
where S.PADDR = P.ADDR(+)
order by s.serial#
/
