REM  Locate the top PGA user

set lines 75
set pages 999
set serveroutput on

spool topuser.out

declare a1 number;
            a2 number;
            a3 varchar2(30);
            a4 varchar2(30);
            a5 number;
            a6 number;
            a7 number;
            a8 number;
            blankline varchar2(70);

cursor code is select pid, spid, substr(username,1,20) "USER" , substr(program,1,30) "Program",
PGA_USED_MEM, PGA_ALLOC_MEM, PGA_FREEABLE_MEM, PGA_MAX_MEM
from v$process where pga_alloc_mem=
(select max(pga_alloc_mem) from v$process
where program not like '%LGWR%');

begin
  blankline:=chr(13);
  open code;
  fetch code into a1, a2, a3, a4, a5, a6, a7, a8;
    
  dbms_output.put_line(blankline);
  dbms_output.put_line('               Top PGA User');
  dbms_output.put_line(blankline);

  dbms_output.put_line('PID:   '||a1||'             '||'SPID:   '||a2);
  dbms_output.put_line('User Info:           '||a3);
  dbms_output.put_line('Program:            '||a4);
  dbms_output.put_line('PGA Used:            '||a5);
  dbms_output.put_line('PGA Allocated:        '||a6);
  dbms_output.put_line('PGA Freeable:             '||a7);
  dbms_output.put_line('Maximum PGA:            '||a8);

end;
/  

set lines 132
col value format 999,999,999,999,999

select * from v$pgastat;

spool off
