alter session set optimizer_mode=rule; 


COLUMN "Latch Hit Ratio %" FORMAT 990.00
 
SELECT a.name "Latch Name",
       a.gets "Gets (Wait)",
       a.misses "Misses (Wait)",
       (1 - (misses / gets)) * 100 "Latch Hit Ratio %"
FROM   v$latch a
WHERE  a.gets   != 0
UNION
SELECT a.name "Latch Name",
       a.gets "Gets (Wait)",
       a.misses "Misses (Wait)",
       100 "Latch Hit Ratio"
FROM   v$latch a
WHERE  a.gets   = 0
ORDER BY 1
/

