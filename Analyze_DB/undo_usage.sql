-- статистика использования UNDO и анализ его размера за период

/* Formatted on 26.02.2015 13:04:53 (QP5 v5.227.12220.39754) */
SET LINESIZE 120
SET PAGESIZE 6000
ALTER SESSION SET nls_date_format = "dd-Mon-yyyy hh24:mi:ss";
COL TXNCOUNT FOR 99,999,999 HEAD "Txn. Cnt."
COL MAXQUERYLEN FOR 99,999,999 HEAD "Max|Query|Sec"
COL MAXCONCURRENCY FOR 9,999 HEAD "Max|Concr|Txn"
COL bks_per_sec FOR 99,999,999 HEAD "Blks per|Second"
COL kb_per_second FOR 99,999,999 HEAD "KB per|Second"
COL undo_mb_suggested FOR 999,999 HEAD "MB Suggested|Undo"
COL ssolderrcnt FOR 9,999 HEAD "ORA-01555|Count"
COL nospaceerrcnt FOR 9,999 HEAD "No Space|Count"
BREAK ON REPORT
COMPUTE MAX OF txncount maxquerylen maxconcurrency bks_per_sec kb_per_second undo_mb_suggested ON REPORT
COMPUTE SUM OF  ssolderrcnt nospaceerrcnt ON REPORT

  SELECT begin_time,
         txncount,
         maxquerylen,
         maxconcurrency,
         ROUND (undoblks / ( (end_time - begin_time) * 86400)) AS bks_per_sec,
         ROUND (
              (undoblks / ( (end_time - begin_time) * 86400))
            * t.block_size
            / 1024)
            AS kb_per_second,
         ROUND (
              (  (undoblks / ( (end_time - begin_time) * 86400))
               * t.block_size
               / 1024)
            * TO_NUMBER (p2.VALUE)
            / 1024)
            AS undo_MB_suggested,
         ssolderrcnt,
         nospaceerrcnt
    FROM v$undostat s,
         dba_tablespaces t,
         v$parameter p,
         v$parameter p2
   WHERE     t.tablespace_name = UPPER (p.VALUE)
         AND p.name = 'undo_tablespace'
         AND p2.name = 'undo_retention'
ORDER BY 7 DESC, 1;

/* Formatted on 19.02.2014 13:43:16 (QP5 v5.227.12220.39754) */
SELECT *
  FROM DBA_ROLLBACK_SEGS
 WHERE status <> 'ONLINE';

--segment_name in ('_SYSSMU46_196099517$');

ALTER ROLLBACK SEGMENT "_SYSSMU1_3054863786$" OFFLINE;

DROP ROLLBACK SEGMENT "_SYSSMU1_3054863786$";

  SELECT *
    FROM v$rollname
ORDER BY 2;


SELECT rn.Name "Rollback Segment",
       rs.RSSize / 1024 "Size (KB)",
       rs.Gets "Gets",
       rs.waits "Waits",
       (rs.Waits / rs.Gets) * 100 "% Waits",
       rs.Shrinks "# Shrinks",
       rs.Extends "# Extends"
  FROM sys.v_$rollName rn, sys.v_$rollStat rs
 WHERE rn.usn = rs.usn;