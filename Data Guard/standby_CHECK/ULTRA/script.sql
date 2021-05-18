SET TERMOUT ON
SET ECHO OFF
SET LINESIZE 300
SET PAGESIZE 3000

SPOOL script.log
ACCEPT Server PROMPT 'Enter a server alias/connection string (DB_NAME): ' DEFAULT DB_NAME
ACCEPT SYSpw PROMPT 'Enter SYS USER PASSWORD: '
CONNECT SYS/&SYSpw@&Server as sysdba

Prompt
-- Prompt Соединение SYS/&SYSpw@&Server 

PROMPT *** START AT ***

select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') as "Дата" from dual;

Prompt *** v$instance ***

COLUMN INSTANCE_NAME      format A13
COLUMN HOST_NAME          format A18
COLUMN VERSION            format A12
COLUMN STATUS             format A10

SELECT * FROM v$instance;

SELECT MAX(SEQUENCE#) FROM V$LOG_HISTORY;

Prompt *** applied archive logs ***

COLUMN NAME               format A10
COLUMN ARCHIVED           format A10
COLUMN DELETED            format A10
COLUMN STANDBY_DB_FOR_LOG format A20
COLUMN COMPLETION_TIME    format A25

SELECT SEQUENCE#,NAME as STANDBY_DB_FOR_LOG,round(((BLOCKS*BLOCK_SIZE)/1024/1024),2) "size, Mb",ARCHIVED,DELETED,to_char(COMPLETION_TIME,'dd/mm/yyyy hh24:mi:ss') as COMPLETION_TIME FROM V$ARCHIVED_LOG where APPLIED = 'YES' and COMPLETION_TIME > (sysdate - 1) ORDER BY SEQUENCE#;

Prompt *** current database status ***

select switchover_status,database_role from v$database;


PROMPT *** FINISH AT ***

select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') as "Дата" from dual;


SET SERVEROUTPUT OFF
SPOOL OFF
SET TERMOUT ON
SET ECHO ON
SET SHOW ON
SET VER ON
EXIT