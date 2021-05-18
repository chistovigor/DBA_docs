/* Formatted on 04.02.2014 12:34:20 (QP5 v5.163.1008.3004) */
SELECT    tsh.tablespace_name
       || ' '
       || TO_CHAR (SYSDATE, 'DD-MON-YY HH24:MI:SS')
          tablespace_name,
       dtf.omvang size_temp_files,
       tsh.free_space_space_header free_space_in_temp_files,
       NVL (ss.free_space_sort_segment, tsh.used_space_space_header)
          free_space_in_sort_segment                         -- could be empty
                                    ,
       NVL (ss.used_space_sort_segment, 0) used_space_in_sort_segment,
       tsh.free_space_space_header
       + NVL (ss.free_space_sort_segment, tsh.used_space_space_header)
          TOTAL_FREE
  FROM (  SELECT tablespace_name, SUM (bytes) / 1024 / 1024 omvang
            FROM dba_temp_files
        GROUP BY tablespace_name) dtf,
       (  SELECT tablespace_name,
                 SUM (BYTES_USED) / 1024 / 1024 USED_SPACE_SPACE_HEADER,
                 SUM (BYTES_FREE) / 1024 / 1024 FREE_SPACE_SPACE_HEADER
            FROM v$temp_space_header
        GROUP BY tablespace_name) tsh,
       (  SELECT tablespace_name,
                 SUM (USED_BLOCKS) * par.VALUE / 1024 / 1024
                    USED_SPACE_SORT_SEGMENT,
                 SUM (FREE_BLOCKS) * par.VALUE / 1024 / 1024
                    FREE_SPACE_SORT_SEGMENT
            FROM v$sort_segment ss, v$parameter par
           WHERE par.name = 'db_block_size'
        GROUP BY tablespace_name, VALUE) ss
 WHERE dtf.tablespace_name = tsh.tablespace_name
       AND ss.tablespace_name(+) = dtf.tablespace_name;
	   
-- Определение, какие сессии используют TEMP

SHOW PARAMETER db_files

SELECT file#, name FROM v$tempfile;

SELECT
    a.username,
    a.sid,
    a.serial#,
    a.osuser,
    a.program,
    a.module,
    a.action,
    a.status,
    a.machine,
    a.logon_time,
    b.tablespace,
    b.segtype,
    round(b.blocks * dt.block_size / 1024 / 1024) mb_used,
    a.event,
    b.sql_id,
    c.sql_text
FROM
    gv$session a,
    v$tempseg_usage b,
    v$sqlarea c,
    dba_tablespaces dt
WHERE
    a.saddr = b.session_addr
    AND c.address = a.sql_address
    AND c.hash_value = a.sql_hash_value
    AND dt.tablespace_name = b.tablespace
ORDER BY
    b.blocks desc,
    b.tablespace;


-- How Can Temporary Segment Usage Be Monitored Over Time? (Doc ID 364417.1)

CREATE OR REPLACE PROCEDURE TEMP_TEMP_SEG_USAGE_INSERT IS
BEGIN
insert into TEMP_TEMP_SEG_USAGE
SELECT
    a.username,
    a.sid,
    a.serial#,
    a.osuser,
    a.program,
    a.module,
    a.action,
    a.status,
    a.machine,
    a.logon_time,
    b.tablespace,
    b.segtype,
    round(b.blocks * dt.block_size / 1024 / 1024) mb_used,
    a.event,
    b.sql_id,
    c.sql_text
FROM
    gv$session a,
    v$tempseg_usage b,
    v$sqlarea c,
    dba_tablespaces dt
WHERE
    a.saddr = b.session_addr
    AND c.address = a.sql_address
    AND c.hash_value = a.sql_hash_value
    AND dt.tablespace_name = b.tablespace
	AND round(b.blocks * dt.block_size / 1024 / 1024) > 1024;
COMMIT;
END;
/
	
	
column OSUSER format a12
column program format a20
column port       format 9999
column process format a5
column machine format a16
column event  format a30

SELECT sid,
       username,
       osuser,
       program,
       port,
       process,
       machine,
       event
  FROM v$session
 WHERE sid IN (223, 193, 312);
--(<sid returned from above query>) 

select  *from v$session

-- The segfile# from v$sort_usage corresponds to the sum of the value for parameter db_files and the value for file# from v$tempfile. 
-- Close / Kill the sessions referenced in the query.