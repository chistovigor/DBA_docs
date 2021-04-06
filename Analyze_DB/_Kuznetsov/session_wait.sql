/*

SELECT sid,
       CHR (BITAND (p1,-16777216) / 16777215) ||
       CHR (BITAND (p1, 16711680) / 65535) enq,
       DECODE (CHR (BITAND (p1,-16777216) / 16777215) ||
               CHR (BITAND (p1, 16711680) / 65535),
                 'TX', 'Transaction (RBS)',
                 'TM', 'DML Transaction',
                 'TS', 'Tablespace and Temp Seg',
                 'TT', 'Temporary Table',
                 'ST', 'Space Mgt (e.g., uet$, fet$)',
                 'UL', 'User Defined',
                 CHR (BITAND (p1,-16777216) / 16777215) ||
                 CHR (BITAND (p1, 16711680) / 65535)) enqueue_name,
       DECODE (BITAND (p1, 65535), 1, 'Null', 2, 'Sub-Share',
                 3, 'Sub-Exclusive', 4, 'Share', 5, 'Share/Sub-Exclusive',
                 6, 'Exclusive', 'Other') lock_mode
FROM   v$session_wait
/

*/



column osuser format a25
column schemaname format a17
column username format a17
column spid format a8
column sid format 999999
column serial# format 999999
column module format a17
column action format a17
column machine format a17
column event format a30
column sql_text format a40

SELECT p.spid,
       s.sid, 
       s.serial#,
       substr(s.username,1,17) username,
       substr(s.module,1,17) module, 
       substr(s.action,1,17) action, 
       sw.seq#, 
       sw.event, 
       sw.state, 
       s.blocking_session block_session,
       s.blocking_session_status block_status,
       s.sql_id,
       s.row_wait_obj#, 
       s.row_wait_file#, 
       s.row_wait_block#,
       (select substr(sql_text,1,40) from   v$sqlarea where  sql_id=s.sql_id) sql_text,
       round(sw.seconds_in_wait/1,2) wait_sec,
       round(sw.seconds_in_wait/60,2) wait_min,
       round(sw.seconds_in_wait/(60*60),2) wait_hours,
       round(sw.seconds_in_wait/(24*60*60),2) wait_days
FROM   v$session_wait sw,
       v$process p, 
       v$session s
WHERE  s.paddr = p.addr(+)
  AND  s.sid = sw.sid
  AND  s.type='USER'
  AND  sw.event not in ('rdbms ipc message',
                        'pmon timer',
                        'smon timer',
                        'wakeup time manager')
order by s.sid, sw.seq#
/



