SET TERMOUT ON
SET ECHO OFF
SET LINESIZE 1000
SET PAGESIZE 1000

SPOOL create_admin_user.log
ACCEPT Server PROMPT 'Enter a server alias/connection string (ULTRA): ' DEFAULT ULTRA
ACCEPT SYSpw PROMPT 'Enter SYS USER PASSWORD: ' DEFAULT duo HIDE
ACCEPT adminuser PROMPT 'Enter new admin USER name: '
ACCEPT adminpassword PROMPT 'Enter new admin USER PASSWORD: ' DEFAULT admin HIDE
CONNECT SYS/&SYSpw@&Server as sysdba


PROMPT *** START AT ***

select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') as "Дата" from dual;

CREATE USER &adminuser IDENTIFIED BY "&adminpassword"
DEFAULT TABLESPACE "USERS"
TEMPORARY TABLESPACE "TEMP";

GRANT OEM_MONITOR TO &adminuser;

PROMPT *** FINISH AT ***

select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') as "Дата" from dual;


SET SERVEROUTPUT OFF
SPOOL OFF
SET TERMOUT ON
SET ECHO ON
SET SHOW ON
SET VER ON
EXIT