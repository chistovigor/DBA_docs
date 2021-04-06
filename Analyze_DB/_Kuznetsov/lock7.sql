col "WAITING USER" format a15
col "BLOCKER USER"  format a15
col "OS User" format a15
col "Sid" format 9999999999
col "PID" format a15
col OSUser format a15
col username format a15
col machine format a15
col mode_requested format a15
col mode_held format a15
col blocker format a15
col schemaname format a15
col program format a15
col module format a15
col event format a27
col WAIT_CLASS format a15

-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2004 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : locks_blocking.sql                                              |
-- | CLASS    : Locks                                                           |
-- | PURPOSE  : Query all Blocking Locks in the databases. This query will      |
-- |            display both the user(s) holding the lock and the user(s)       |
-- |            waiting for the lock.                                           |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SELECT /*+ RULE */   
    SUBSTR(s1.username,1,12)           "WAITING USER"
  , SUBSTR(s1.osuser,1,8)              "OS User"
  , SUBSTR(TO_CHAR(w.session_id),1,5)  "Sid"
  , p1.spid                            "PID"
  , SUBSTR(s2.username,1,12)           "BLOCKER USER"
  , SUBSTR(s2.osuser,1,8)              "OS User"
  , SUBSTR(TO_CHAR(h.session_id),1,5)  "Sid"
  , p2.spid                            "PID"
FROM
    sys.v_$process p1
  , sys.v_$process p2
  , sys.v_$session s1
  , sys.v_$session s2
  , dba_locks  w
  , dba_locks  h
WHERE
      h.mode_held      != 'None'
  AND h.mode_held      != 'Null'
  AND w.mode_requested != 'None'
  AND w.lock_type  (+)  = h.lock_type
  AND w.lock_id1   (+)  = h.lock_id1
  AND w.lock_id2   (+)  = h.lock_id2
  AND w.session_id      = s1.sid   (+)
  AND h.session_id      = s2.sid   (+)
  AND s1.paddr          = p1.addr  (+)
  AND s2.paddr          = p2.addr  (+);


Select /*+ RULE */   
         'Blocker is =>' blocker,
         s.sid, 
	   s.username, 
	   s.osuser, 
	   s.machine, 
	   s.status,  
	   DECODE(lk.TYPE, 'TX', 'Transaction', 'TM', 'DML', 'UL', 'PL/SQL User Lock', lk.TYPE  ) lock_type,  
	   DECODE(lk.lmode,      0, 'None',         1, 'Null',         2, 'Row-S (SS)',         3, 'Row-X (SX)',         4, 'Share',         5, 'S/Row-X (SSX)',         6, 'Exclusive',         TO_CHAR(lk.lmode)    ) mode_held,  
	   DECODE(lk.request,    0, 'None',         1, 'Null',         2, 'Row-S (SS)',         3, 'Row-X (SX)',         4, 'Share',         5, 'S/Row-X (SSX)',         6, 'Exclusive',         TO_CHAR(lk.request)  ) mode_requested 
FROM v$lock lk, 
     v$session s 
WHERE lk.block = 1  
  AND lk.SID = s.SID  ;


select /*+ ALL_ROWS */  
       (select distinct username from gv$session where inst_id=a.inst_id and sid=a.sid) "BLOCKER USER",
        a.inst_id, a.sid,
       ' is blocking ' "IS BLOCKING",
       (select distinct username from gv$session where inst_id=b.inst_id and sid=b.sid) "WAITING USER",
       b.inst_id, b.sid, a.LMODE "Blocker Lock mode", a.REQUEST "Blocker Request", b.LMODE "Waiter Lock mode", b.REQUEST "Waiter Request"
from gv$lock a, gv$lock b
where a.inst_id = b.inst_id 
	and a.block = 1
  and b.request > 0
  and a.id1 = b.id1
  and a.id2 = b.id2;


select /*+ ALL_ROWS */ 
'Blocker is =>' blocker, 
inst_id, 
sid, 
serial#, 
username, 
status, 
server, 
schemaname, 
osuser, 
machine, 
program, 
module, 
sql_id, 
prev_sql_id, 
row_wait_obj#, 
blocking_session, 
event, 
wait_class
from gv$session 
where sid in (select distinct blocking_session from gv$session where blocking_session is not null ) ;

