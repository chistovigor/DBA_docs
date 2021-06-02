SET TERMOUT ON
SET LINESIZE 140
SET ECHO OFF
SET SHOW OFF
SET VER OFF
SET SERVEROUTPUT ON FORMAT WRAPPED

SPOOL gather_stat.log
ACCEPT Server PROMPT 'Enter a server alias/connection string (DUO): ' DEFAULT DUO
ACCEPT MGUSER PROMPT 'Enter application USER (DBMAN): ' DEFAULT DBMAN
ACCEPT MGPsw PROMPT 'Enter application USER PASSWORD: ' DEFAULT DUO HIDE
CONNECT &MGUSER/&MGPsw@&Server;

select to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') TIME from dual;

set serveroutput on

execute dbms_output.enable(20000000);

begin

DBMS_STATS.GATHER_INDEX_STATS ('&MGUSER','TRX_TRX_TYPE_I');

end;
/

execute dbms_output.disable;

select to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') TIME from dual;

SET SERVEROUTPUT OFF
SPOOL OFF
SET TERMOUT ON
SET ECHO ON
SET SHOW ON
SET VER ON
EXIT