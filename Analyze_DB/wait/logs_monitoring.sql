column Start_Date format a15
column Start_Time format a10
column Mbytes     format 999,999 

SELECT Start_Date,
         Start_Time,
         Num_Logs Num_Logs_per_hour,
         ROUND (Num_Logs * (Vl.Bytes / (1024 * 1024)), 2) AS Mbytes,
         Vdb.NAME AS Dbname
    FROM (  SELECT TO_CHAR (Vlh.First_Time, 'YYYY-MM-DD') AS Start_Date,
                   TO_CHAR (Vlh.First_Time, 'HH24') || ':00' AS Start_Time,
                   COUNT (Vlh.Thread#) Num_Logs
              FROM V$log_History Vlh
          GROUP BY TO_CHAR (Vlh.First_Time, 'YYYY-MM-DD'),
                   TO_CHAR (Vlh.First_Time, 'HH24') || ':00') Log_Hist,
         V$log Vl,
         V$database Vdb
   WHERE Vl.Group# = 1
ORDER BY Log_Hist.Start_Date, Log_Hist.Start_Time;