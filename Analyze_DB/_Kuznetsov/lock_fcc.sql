column osuser format a25
column schemaname format a17
column username format a18
column pprogram format a20
column sprogram format a25
column client_info format a50
column spid format a8
column sid format 999999
column serial# format 999999
column pga_used_mb justify center
column pga_alloc_mb justify center
column pga_max_mb justify center
column module format a25
column machine format a17
column ip_address format a15
column user_process format a25
column service_name format a20

select p.spid,
        s.sid,
        s.serial#,
        s.status,
        s.osuser,
        s.machine,
        s.program sprogram,
        p.program pprogram
   from v$process p, v$session s
  where S.PADDR = P.ADDR(+)
    and s.sid in (select distinct session_id from dba_dml_locks where owner='FCC')
/
