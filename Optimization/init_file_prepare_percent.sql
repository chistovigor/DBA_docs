SELECT '*.' || NAME || '=' || VALUE AS PFILE
  FROM (SELECT *
          FROM (SELECT SID,
                       NAME,
                       DISPLAY_VALUE,
                       CASE
                           WHEN TYPE = 'string' THEN '''' || VALUE || ''''
                           ELSE VALUE
                       END
                           VALUE
                  FROM V$SPPARAMETER
                 WHERE     ISSPECIFIED = 'TRUE'
                       AND SID = '*'
                       AND NAME NOT IN
                               (SELECT NAME
                                  FROM V$SPPARAMETER
                                 WHERE     ISSPECIFIED = 'TRUE'
                                       AND SID =
                                           (SELECT INSTANCE_NAME
                                              FROM V$INSTANCE))
                UNION ALL
                SELECT SID,
                       NAME,
                       DISPLAY_VALUE,
                       CASE
                           WHEN TYPE = 'string' THEN '''' || VALUE || ''''
                           ELSE VALUE
                       END
                           VALUE
                  FROM V$SPPARAMETER
                 WHERE     ISSPECIFIED = 'TRUE'
                       AND SID = (SELECT INSTANCE_NAME FROM V$INSTANCE))
         WHERE NAME NOT IN (SELECT NAME
                              FROM V$PARAMETER
                             WHERE TYPE = 6 AND LENGTH (VALUE) >= 10)
        UNION ALL
        SELECT SID,
               NAME,
               DISPLAY_VALUE,
               CASE
                   WHEN ROUND (
                              (CAST (VALUE AS NUMBER) / 1024 / 1024 / 1024)
                            * &PERC
                            / 100) >=
                        1
                   THEN
                          TO_CHAR (
                              ROUND (
                                    (  CAST (VALUE AS NUMBER)
                                     / 1024
                                     / 1024
                                     / 1024)
                                  * &&PERC
                                  / 100))
                       || 'G'
                   ELSE
                       DISPLAY_VALUE
               END
                   AS VALUE
          FROM (SELECT SID,
                       NAME,
                       DISPLAY_VALUE,
                       VALUE
                  FROM V$SPPARAMETER
                 WHERE     ISSPECIFIED = 'TRUE'
                       AND SID = '*'
                       AND NAME NOT IN
                               (SELECT NAME
                                  FROM V$SPPARAMETER
                                 WHERE     ISSPECIFIED = 'TRUE'
                                       AND SID =
                                           (SELECT INSTANCE_NAME
                                              FROM V$INSTANCE))
                UNION ALL
                SELECT SID,
                       NAME,
                       DISPLAY_VALUE,
                       VALUE
                  FROM V$SPPARAMETER
                 WHERE     ISSPECIFIED = 'TRUE'
                       AND SID = (SELECT INSTANCE_NAME FROM V$INSTANCE))
         WHERE NAME IN (SELECT NAME
                          FROM V$PARAMETER
                         WHERE TYPE = 6 AND LENGTH (VALUE) >= 10)
        ORDER BY 2);