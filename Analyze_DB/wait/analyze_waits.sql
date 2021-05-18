-- анализ событий ожиданий, связанных с сетью

-- анализ истории сетевых ожиданий

SELECT TRUNC (end_interval_time) wait_date,
         wait_class,
         SUM (time_waited) sum_waited_sec
    FROM dba_hist_service_wait_class JOIN dba_hist_snapshot USING (snap_id)
   WHERE wait_class = 'Network'
GROUP BY TRUNC (end_interval_time), wait_class
ORDER BY sum_waited_sec DESC, TRUNC (end_interval_time);

-- анализ текущих событий класса сеть для всех пользователей, кроме системных

  SELECT *
    FROM V$SESSION_EVENT a,
         V$SESSION_WAIT b,
         V$EVENT_NAME c,
         v$session d
   WHERE     1 = 1
         AND A.EVENT <> 'SQL*Net message from client'
         AND a.WAIT_CLASS = 'Network'
         AND A.SID(+) = B.SID
         AND A.EVENT_ID = C.EVENT_ID(+)
         AND A.SID = D.SID(+)
         AND D.SCHEMANAME NOT IN ('SYS', 'SYSMAN', 'DBSNMP')
ORDER BY a.TIME_WAITED DESC;