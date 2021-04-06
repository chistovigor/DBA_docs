column sid_serial format a15
column rbs format a25
column oracle_user format a15
column client_user format a15
column unix_user format a15
column unix_pid format a15
column login_time format a18
column last_txn format a18

SELECT  r.name                   rbs,
        t.used_ublk * TO_NUMBER(x.value)/1024  as undo_kb,
        nvl(s.username, 'None')  oracle_user,
        s.osuser                 client_user,
        p.username               unix_user,
        to_char(s.sid)||','||to_char(s.serial#) as sid_serial,
        p.spid                   unix_pid,
        TO_CHAR(s.logon_time, 'mm/dd/yy hh24:mi:ss') as login_time,
        TO_CHAR(sysdate - (s.last_call_et) / 86400,'mm/dd/yy hh24:mi:ss') as last_txn
   FROM v$process     p,
        v$rollname    r,
        v$session     s,
        v$transaction t,
        v$parameter   x
  WHERE s.taddr = t.addr
    AND s.paddr = p.addr(+)
    AND r.usn   = t.xidusn(+)
    AND x.name  = 'db_block_size'
  ORDER
     BY r.name
;
