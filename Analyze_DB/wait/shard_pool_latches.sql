-- processes holding latches

select * from v$latchholder;

-- row cashe latches

  SELECT *
    FROM v$rowcache
ORDER BY gets DESC;

-- determine type of latch calls

SELECT *
  FROM v$latch_misses
 WHERE parent_name = 'shared pool' AND sleep_count > 0 order by SLEEP_COUNT desc;
 
-- latch childrens

  SELECT latch#, child#, sleeps
    FROM v$latch_children
   WHERE name = 'shared pool' AND sleeps > 0
ORDER BY sleeps DESC;
 
-- latch event waits in PCT_OF_DB_TIME

  SELECT EVENT,
         TIME_WAITED_MICRO,
         ROUND (TIME_WAITED_MICRO * 100 / S.DBTIME, 1) PCT_DB_TIME
    FROM V$SYSTEM_EVENT,
         (SELECT VALUE DBTIME
            FROM V$SYS_TIME_MODEL
           WHERE STAT_NAME = 'DB time') S
   WHERE EVENT LIKE 'latch%'
ORDER BY PCT_DB_TIME desc;

-- sql which contributes of shared pool latch

  SELECT sql_text, invalidations
    FROM v$sqlarea
   WHERE invalidations > 10
ORDER BY invalidations DESC;

  SELECT sql_text, COUNT (*), SUM (executions) "TotExecs"
    FROM v$sqlarea
   WHERE executions < 5
GROUP BY sql_text
  HAVING COUNT (*) > 30
ORDER BY 2 desc;

  SELECT sql_text,
         sql_id,
         COUNT (*),
         ROUND (SUM (sharable_mem) / 1024 / 1024) "Mb",
         SUM (users_opening) "Open",
         SUM (executions) "Exec"
    FROM v$sql
GROUP BY sql_text, sql_id
  HAVING     SUM (sharable_mem) > 10000
         AND (COUNT (*) > 1 AND SUM (executions) > COUNT (*))
ORDER BY 6 DESC;

