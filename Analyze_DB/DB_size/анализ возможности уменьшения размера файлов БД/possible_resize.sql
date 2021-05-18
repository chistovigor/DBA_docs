SET TERMOUT ON
SET ECHO OFF
SET LINESIZE 1000
SET PAGESIZE 1000

SPOOL possible_resize.log
ACCEPT Server PROMPT 'Enter a server alias/connection string (UNOC): ' DEFAULT UNOC
ACCEPT SYSpw PROMPT 'Enter SYS USER PASSWORD: ' DEFAULT duo HIDE
CONNECT SYS/&SYSpw@&Server as sysdba

Prompt
Prompt Соединение SYS/&SYSpw@&Server 

PROMPT *** START AT ***

select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') as "Дата" from dual;

PROMPT *** possible resize for files ***

select
    f.file#,
    round(f.bytes/1024/1024,2)||' Mb' MEGABYTES,
    decode(trunc(e.maxextend*blocksize/1000/10),
       0,round(e.maxextend*blocksize,2)||' Mb',
       null,null,
       'Unlimited') MAXEXTEND,
    decode(e.inc,null,null,round(e.inc*blocksize,2)||' Mb') inc,
    ceil(nvl(r.min_resize,0)*blocksize)||' Mb' MIN_RESIZE,
    f.name
  from sys.filext$ e, v$datafile f,
    ( select
          e.file_id file#,
          max(e.block_id + e.blocks) as MIN_RESIZE
        from dba_extents e
        group by e.file_id
    ) r,
    (select to_number(value)/1024/1024 blocksize
       from v$parameter where name='db_block_size')
  where e.file#(+) = f.file#
    and r.file#(+) = f.file#
  order by 1;
  
PROMPT *** objects sizes in system TS ***

select segment_name, sum(bytes)/1024/1024 as MEGABYTES
   from dba_segments where tablespace_name = 'SYSTEM'
   group by segment_name
   order by 2 desc;


PROMPT *** FINISH AT ***

select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') as "Дата" from dual;


SET SERVEROUTPUT OFF
SPOOL OFF
SET TERMOUT ON
SET ECHO ON
SET SHOW ON
SET VER ON
EXIT