SET TERMOUT ON
SET ECHO OFF
SET LINESIZE 1000
SET PAGESIZE 1000

SPOOL who_lock.log
ACCEPT Server PROMPT 'Enter a server alias/connection string (DB_NAME): ' DEFAULT DB_NAME
ACCEPT SYSpw PROMPT 'Enter SYS USER PASSWORD: '
CONNECT SYS/&SYSpw@&Server as sysdba

PROMPT *** START AT ***

select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') as "ƒата" from dual;

Prompt *** v$instance ***

SELECT * FROM v$instance;

Prompt *** locked objects - ORA-00054 ERROR ***

SELECT object_name,
       s.sid,
       s.serial#,
       s.program,
       s.osuser,
       s.terminal,
       s.prev_sql_id,
       p.spid,
       q.SQL_TEXT
  FROM v$locked_object l,
       dba_objects o,
       v$session s,
       v$process p,
       V_$SQLTEXT q
 WHERE     l.object_id = o.object_id
       AND l.session_id = s.sid
       AND s.paddr = p.addr
       AND s.prev_sql_id = Q.SQL_ID;

PROMPT *** FINISH AT ***

select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') as "ƒата" from dual;

-- DBA_BLOCKERS Ц Shows non-waiting sessions holding locks being waited-on
-- DBA_DDL_LOCKS Ц Shows all DDL locks held or being requested
-- DBA_DML_LOCKS - Shows all DML locks held or being requested
-- DBA_LOCK_INTERNAL Ц Displays 1 row for every lock or latch held or being requested with the username of who is holding the lock
-- DBA_LOCKS - Shows all locks or latches held or being requested
-- DBA_WAITERS - Shows all sessions waiting on, but not holding waited for locks

-- These tables or views may not contain all the information about locked session, usename ,process name etc. 
-- So you may have to join with v$session , v$locked_object and v$process views to obtain detailed locks information


SET SERVEROUTPUT OFF
SPOOL OFF
SET TERMOUT ON
SET ECHO ON
SET SHOW ON
SET VER ON
EXIT