--Decoding P1/P2/P3 in for event 'enq: TX - row lock contention'

COL wait_class FOR a20
COL display_name FOR a35

SELECT event#, wait_class, display_name
  FROM v$event_name
 WHERE name = 'enq: TX - row lock contention';

SELECT COUNT (event#), MAX (event#) FROM v$event_name;

SELECT parameter1, parameter2, parameter3
  FROM v$event_name
 WHERE name = 'enq: TX - row lock contention';

SELECT *
  FROM v$lock
 WHERE sid = &sessin_sid;

  SELECT blocking_session,
         sid,
         serial#,
         wait_class,
         seconds_in_wait
    FROM v$session
   WHERE blocking_session IS NOT NULL
ORDER BY blocking_session;

COL os_user FOR a10
COL os_pid FOR a6
COL oracle_user FOR a12
COL lock_type FOR a15
COL lock_held FOR a10
COL lock_requested FOR a15
COL status FOR a15
COL owner FOR a10
COL object_name FOR a11
SET LINE 140

  SELECT OS_USER_NAME os_user,
         PROCESS os_pid,
         ORACLE_USERNAME oracle_user,
         l.SID oracle_id,
         DECODE (TYPE,
                 'MR', 'Media Recovery',
                 'RT', 'Redo Thread',
                 'UN', 'User Name',
                 'TX', 'Transaction',
                 'TM', 'DML',
                 'UL', 'PL/SQL User Lock',
                 'DX', 'Distributed Xaction',
                 'CF', 'Control File',
                 'IS', 'Instance State',
                 'FS', 'File Set',
                 'IR', 'Instance Recovery',
                 'ST', 'Disk Space Transaction',
                 'TS', 'Temp Segment',
                 'IV', 'Library Cache Invalidation',
                 'LS', 'Log Start or Switch',
                 'RW', 'Row Wait',
                 'SQ', 'Sequence Number',
                 'TE', 'Extend Table',
                 'TT', 'Temp Table',
                 TYPE)
            lock_type,
         DECODE (LMODE,
                 0, 'None',
                 1, 'Null',
                 2, 'Row-S (SS)',
                 3, 'Row-X (SX)',
                 4, 'Share',
                 5, 'S/Row-X (SSX)',
                 6, 'Exclusive',
                 lmode)
            lock_held,
         DECODE (REQUEST,
                 0, 'None',
                 1, 'Null',
                 2, 'Row-S (SS)',
                 3, 'Row-X (SX)',
                 4, 'Share',
                 5, 'S/Row-X (SSX)',
                 6, 'Exclusive',
                 request)
            lock_requested,
         DECODE (BLOCK,
                 0, 'Not Blocking',
                 1, 'Blocking',
                 2, 'Global',
                 block)
            status,
         OWNER,
         OBJECT_NAME
    FROM v$locked_object lo, dba_objects do, v$lock l
   WHERE lo.OBJECT_ID = do.OBJECT_ID AND l.SID = lo.SESSION_ID
ORDER BY DECODE (BLOCK,
                 0, 'Not Blocking',
                 1, 'Blocking',
                 2, 'Global',
                 block);

COL username FOR a10
COL sql_text FOR a20

  SELECT sn.USERNAME,
         m.SID,
         sn.SERIAL#,
         m.TYPE,
         DECODE (LMODE,
                 0, 'None',
                 1, 'Null',
                 2, 'Row-S (SS)',
                 3, 'Row-X (SX)',
                 4, 'Share',
                 5, 'S/Row-X (SSX)',
                 6, 'Exclusive')
            lock_type,
         DECODE (REQUEST,
                 0, 'None',
                 1, 'Null',
                 2, 'Row-S (SS)',
                 3, 'Row-X (SX)',
                 4, 'Share',
                 5, 'S/Row-X (SSX)',
                 6, 'Exclusive')
            lock_requested,
         m.ID1,
         m.ID2,
         t.SQL_TEXT
    FROM v$session sn, v$lock m, v$sqltext t
   WHERE     t.ADDRESS = sn.SQL_ADDRESS
         AND t.HASH_VALUE = sn.SQL_HASH_VALUE
         AND (   (sn.SID = m.SID AND m.REQUEST != 0)
              OR (    sn.SID = m.SID
                  AND m.REQUEST = 0
                  AND LMODE != 4
                  AND (ID1, ID2) IN
                         (SELECT s.ID1, s.ID2
                            FROM v$lock S
                           WHERE     REQUEST != 0
                                 AND s.ID1 = m.ID1
                                 AND s.ID2 = m.ID2)))
ORDER BY sn.USERNAME, sn.SID, t.PIECE;

-- info about SID,lock type,object locked,SQL_id for last 30 minutes

SELECT TO_CHAR (sample_time, 'HH:MI') st,
         SUBSTR (event, 0, 20) event,
         ash.session_id sid,
         MOD (ash.p1, 16) lm,
         ash.p2,
         ash.p3,
         NVL (o.object_name, ash.current_obj#) objn,
         SUBSTR (o.object_type, 0, 10) otype,
         CURRENT_FILE# fn,
         CURRENT_BLOCK# blockn,
         ash.SQL_ID,
         BLOCKING_SESSION bsid
    FROM v$active_session_history ash, all_objects o
   WHERE     event LIKE 'enq: T%'
         AND o.object_id(+) = ash.CURRENT_OBJ#
         AND sample_time > SYSDATE - 30 / (60 * 24)
ORDER BY sample_time;



  SELECT s.SCHEMANAME,
         s.OSUSER,
         s.PROCESS,
         s.MACHINE,
         s.PROGRAM,
         s.MODULE,
         s.PREV_EXEC_START,
         s.CLIENT_INFO,
         s.TYPE,
         s.LOGON_TIME,
         sid,
         s.SERIAL#,
         s.PREV_SQL_ID,
         s.SQL_ID,
         sql_text
    FROM v$session s, v$sql q
   WHERE sid IN (SELECT sid
                   FROM v$session
                  WHERE state IN ('WAITING') AND wait_class != 'Idle' 
				  --     AND event = 'enq: TX %contention'  -- wait event type
                        AND (q.sql_id = s.sql_id OR q.sql_id = s.prev_sql_id))
ORDER BY 1, 2;

SELECT VIEW_DEFINITION
  FROM V$FIXED_VIEW_DEFINITION
 WHERE VIEW_NAME = 'V$LOCK';

SELECT VIEW_DEFINITION
  FROM V$FIXED_VIEW_DEFINITION
 WHERE VIEW_NAME = 'GV$LOCK';