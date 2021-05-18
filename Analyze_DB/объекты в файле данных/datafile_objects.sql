SET TERMOUT ON
SET ECHO OFF
SET LINESIZE 1000
SET PAGESIZE 1000

SPOOL datafile_objects.log
ACCEPT Server PROMPT 'Enter a server alias/connection string (Database): ' DEFAULT Database
ACCEPT SYSpw PROMPT 'Enter SYS USER PASSWORD: ' DEFAULT duo HIDE
CONNECT SYS/&SYSpw@&Server as sysdba

Prompt
Prompt Соединение SYS/&SYSpw@&Server 

PROMPT *** START AT ***

select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') as "Дата" from dual;

 SELECT a.segment_name, a.file_id, b.file_name Datafile_name
    FROM dba_extents a, dba_data_files b
   WHERE a.file_id = b.file_id
         AND b.file_name LIKE 'F:\UNOC\CURRENT\ALPHA_LARGE_INDEX_02.DBF'
ORDER BY 1;


PROMPT *** FINISH AT ***

select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') as "Дата" from dual;


SET SERVEROUTPUT OFF
SPOOL OFF
SET TERMOUT ON
SET ECHO ON
SET SHOW ON
SET VER ON
EXIT