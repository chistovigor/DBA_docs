set linesize 300
column name format a55
column start_time format a25
column completion_time format a25
column end_time format a25
column mb format 999,999

select round(SUM(MB)/1024) GB,COMPLETION_TIME from 
(select name,
       to_char(COMPLETION_TIME,'ddmmyyyy') COMPLETION_TIME,
       sum(ROUND (blocks * block_size / 1024 / 1024)) MB
  from V$ARCHIVED_LOG
 where COMPLETION_TIME between (sysdate - 30) and (sysdate)
       and name is not null 
       group by name,
       completion_time) group by COMPLETION_TIME
       order by 1 desc;

SELECT name,
       TO_CHAR (first_time, 'DD-MM-YYYY HH24:MI:SS') start_time,
       TO_CHAR (next_time, 'DD-MM-YYYY HH24:MI:SS') end_time,
       completion_time,
       ROUND (blocks * block_size / 1024 / 1024) MB
  FROM V$ARCHIVED_LOG
 WHERE completion_time BETWEEN (SYSDATE - 1) AND (SYSDATE - 13 / 24)
       AND name IS NOT NULL;

	   
SELECT name,
       TO_CHAR (first_time, 'DD-MM-YYYY HH24:MI:SS') start_time,
       TO_CHAR (next_time, 'DD-MM-YYYY HH24:MI:SS') end_time,
       completion_time,
       ROUND (blocks * block_size / 1024 / 1024) MB
  FROM V$ARCHIVED_LOG
 WHERE completion_time BETWEEN (SYSDATE - 20/24) AND SYSDATE
       AND name IS NOT NULL;