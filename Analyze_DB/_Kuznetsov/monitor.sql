COL SID FORMAT 999999999
COL STATUS FORMAT A8
COL PROCESS FORMAT A10
COL SCHEMANAME FORMAT A16
COL OSUSER  FORMAT A16
COL SQL_ID  FORMAT A16
--COL SQL_TEXT FORMAT A300 HEADING 'SQL QUERY'
--column pprogram format a18
--column sprogram format a18

/*
SELECT s.sid,
       s.status,
       s.process,
       s.schemaname,
       s.osuser,
       a.sql_text,
       p.program pprogram,
       s.program sprogram
FROM   v$session s,
       v$sqlarea a,
       v$process p
WHERE  s.SQL_HASH_VALUE = a.HASH_VALUE
AND    s.SQL_ADDRESS = a.ADDRESS
AND    s.PADDR = p.ADDR
/
*/

col sql_text format a70
col pprogram format a30
col sprogram format a30
col event format a30


SELECT p.spid,
       s.sid,
       s.serial#,
       s.status,
       trim(substr(s.process,1,10)) as process,
       s.schemaname,
       s.osuser,
       a.CHILD_NUMBER,
       a.sql_id,
       trim(substr(a.sql_text,1,70)) as sql_text,
       trim(substr(s.event,1,30)) as event,
       a.DISK_READS, a.DIRECT_WRITES, a.BUFFER_GETS, a.ROWS_PROCESSED,
       trim(substr(p.program,1,30)) as pprogram,
       trim(substr(s.program,1,30)) as sprogram
FROM   v$session s,
       v$process p,
       v$sql a
WHERE  s.paddr = p.addr(+)
AND    s.sql_id = a.sql_id
AND    a.last_active_time = (select max(last_active_time) 
                             from v$sql 
                             where sql_id = a.sql_id)
ORDER BY 1;




