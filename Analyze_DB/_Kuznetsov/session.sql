SELECT P.SPID,
       S.SID,
       S.SERIAL#,
       S.STATUS,
       S.PROCESS UPROCESS,
       S.TERMINAL,
       S.MACHINE,
       S.USERNAME,
       S.OSUSER,
       S.SCHEMANAME, 
       TO_CHAR(S.LOGON_TIME,'DD.MM.YYYY HH24:MI:SS') as LOGON_TIME,
       ROUND((T.VALUE/60/100),3) as CPU_USAGE_MIN,
       S.MODULE,
       S.ACTION,
       P.PROGRAM "PROGRAM PROCESS",
       S.PROGRAM "PROGRAM SESSION"
FROM   V$PROCESS P,
       V$SESSION S,
       V$SESSTAT T
WHERE  S.PADDR = P.ADDR(+) and T.STATISTIC# = 12 and T.SID = S.SID
ORDER BY  2,3,4
/

select s.sid, s.serial#, s.osuser, s.username, d.name dispatcher, ss.name shared_server
from v$session s,
     v$circuit c,
     v$dispatcher d,
     v$shared_server ss
where s.saddr = c.saddr and
      c.dispatcher = d.paddr and
      c.server = ss.paddr
/


select s.sid, s.serial#, s.osuser, s.machine, s.username, s.program sprogram, c.circuit, c.saddr circuit_addr, d.name disp, d.paddr disp_addr, p.program proc, p.addr proc_addr
from  v$circuit c,
      v$dispatcher d, 
      v$process p,
      v$session s
where c.dispatcher=d.paddr and
      p.addr=d.paddr and
      s.saddr=c.saddr
/

select s.sid, s.serial#, s.osuser, s.machine, s.username, s.program sprogram, d.name disp, ss.name shared_server
from  v$circuit c,
      v$dispatcher d, 
      v$process p,
      v$session s,
      v$shared_server ss
where c.dispatcher=d.paddr and
      p.addr=d.paddr and
      s.saddr=c.saddr and
      c.circuit = ss.circuit
/



select vb.name NOME, vp.program, vp.spid , vs.sid
from v$session vs, v$process vp, v$bgprocess vb
where vb.paddr <> '00' and
      vb.paddr = vp.addr and
      vp.addr = vs.paddr
/
