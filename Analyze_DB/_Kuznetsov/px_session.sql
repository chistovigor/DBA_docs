col osuser format a15
col event format a28
col spid format a10
col username format a12

select p.spid,
       --s.paddr,
       substr(s.osuser,1,15) osuser,
       s.username,
       px.QCSID,
       px.SID,
       px.SERIAL#,
       px.SERVER_SET,
       px.SERVER#,
       px.DEGREE,
       px.REQ_DEGREE,
       s.PQ_STATUS,
       s.STATUS,
       s.sql_id,
       substr(s.EVENT,1,28) EVENT
from v$px_session px,
     v$session s,
     v$process p
where px.sid = s.sid
  and px.serial# = s.serial#
  and p.addr = s.paddr
  and px.SERVER_SET is not null
order by s.username, px.QCSID, px.server_set, px.server#;
