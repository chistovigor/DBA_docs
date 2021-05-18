SET TERMOUT ON
SET ECHO OFF
SET LINESIZE 1000
SET PAGESIZE 1000

SPOOL idle_connections.log
ACCEPT Server PROMPT 'Enter a server alias/connection string (DB_NAME): ' DEFAULT DB_NAME
ACCEPT SYSpw PROMPT 'Enter SYS USER PASSWORD: '
CONNECT SYS/&SYSpw@&Server as sysdba

PROMPT *** START AT ***

select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') as "Дата" from dual;

Prompt *** v$instance ***

SELECT * FROM v$instance;

Prompt *** idle connections ***

   SELECT p.sid,
         ROUND (p.seconds_in_wait / 60, 0) AS Mins_waiting,
         p.wait_class,
         p.state,
         s.osuser,
         s.machine,
         s.program,
         s.schemaname
    FROM v$session_wait p, v$session s
   WHERE     p.sid = s.sid
         AND p.state = 'WAITING'
         AND p.event = 'SQL*Net message from client'
ORDER BY p.seconds_in_wait DESC;


SET SERVEROUTPUT OFF
SPOOL OFF
SET TERMOUT ON
SET ECHO ON
SET SHOW ON
SET VER ON
EXIT