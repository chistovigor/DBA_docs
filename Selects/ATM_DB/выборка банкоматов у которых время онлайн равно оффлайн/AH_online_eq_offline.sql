SELECT *
  FROM router.AH201309 a
 WHERE     a.robj = 4101
       AND a.szdtime > '2013-09-12 06:06:00'
       AND a.szdtime < '2013-09-12 06:10:00'
       AND (szdtime, ratm) IN (  SELECT szdtime, ratm
                                   FROM (SELECT *
                                           FROM router.AH201309 a
                                          WHERE a.robj = 4101
                                                AND a.szdtime >
                                                       '2013-09-12 06:06:00'
                                                AND a.szdtime <
                                                       '2013-09-12 06:10:00')
                               GROUP BY szdtime, ratm
                                 HAVING COUNT (DISTINCT rvalue) > 1)  ORDER BY ratm, szdtime, lseq;