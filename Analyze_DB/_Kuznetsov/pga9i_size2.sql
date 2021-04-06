column username format a18
column osuser format a15
column sprogram format a28
column machine format a20
column pga_size format a18
column pga_max_size format a18

select p.spid, 
       s.sid, 
       vb.name BG_PR,
--       substr(vb.description,1,20) bg_pr_desc,
       substr(s.osuser,1,15) osuser, 
       s.status,
       s.machine,
       s.username,
       substr(s.program,1,28) sprogram,
       s.logon_time, 
       to_char(round(t.value/(1024*1024),2),'999G999D99') || ' MB' PGA_SIZE,
       to_char(round(p.PGA_MAX_MEM/(1024*1024),2),'999G999D99') || ' MB' PGA_MAX_SIZE
from v$session s,
     v$statname n,
     v$sesstat t,
     v$process p,
     v$bgprocess vb
where s.sid=t.sid and
      t.statistic#=n.statistic# and
      p.addr = s.paddr and
     -- vb.paddr <> '00' and
      vb.paddr(+) = p.addr and
      n.name = 'session pga memory'
order by vb.name, s.logon_time      
/
