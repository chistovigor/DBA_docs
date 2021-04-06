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

select
   name profile, 
   cnt, 
   decode(total, 0, 0, round(cnt*100/total)) percentage
from 
   (
      select 
         name, 
         value cnt, 
         (sum(value) over ()) total
      from
         v$sysstat 
      where
         name like 'workarea exec%'
   )
/


select le.leseq current_log_sequence#,
100*cp.cpodr_bno/le.lesiz percentage_full
from    x$kcccp cp,x$kccle le
where   le.leseq =cp.cpodr_seq  and le.lesiz>0
/

select
   round(a.total_waits/(a.total_waits + b.total_waits)*100,2)  "PCT_FULL_SCAN",
   round(b.total_waits/(a.total_waits + b.total_waits)*100,2)  "PCT_INDEX_SCAN"
from
   v$system_event  a,
   v$system_event  b
where a.event = 'db file scattered read'
  and b.event = 'db file sequential read'
/

select p.spid,
       s.process uspid,
       s.sid, 
       s.serial#,
       s.status, 
       s.osuser,
       s.machine,
       --utl_inaddr.get_host_address(substr(s.machine,instr(s.machine,'\')+1)) ip_address,
       s.username, 
       s.logon_time,
       s.program sprogram, 
       p.program pprogram, 
       s.type,
       round(p.pga_used_mem/(1024*1024),2) pga_used_mb, 
       --to_char(p.pga_alloc_mem/(1024*1024),'999G990D000') pga_alloc_mb, 
       round(p.pga_max_mem/(1024*1024),2) pga_max_mb, 
       s.service_name,
       s.module,
       s.action,
       s.sql_id,
	     (select substr(sql_text,1,35) from v$sqltext where sql_id=s.sql_id and piece=0 and rownum=1) sql_text,
       s.prev_sql_id,
       (select substr(sql_text,1,35) from v$sqltext where sql_id=s.prev_sql_id and piece=0 and rownum=1) sql_prev_text,
       s.client_info,
       s.resource_consumer_group,
       s.blocking_session,
       s.state,
       s.event,
       s.p1, 
       s.p2, 
       s.p3
from v$process p, v$session s
where S.PADDR = P.ADDR(+)
order by s.type, s.serial#
/
