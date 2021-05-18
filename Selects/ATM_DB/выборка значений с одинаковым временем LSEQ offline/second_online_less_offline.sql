SELECT a.SZDTIME,a.ratm,A.LSEQ second_online,B.LSEQ second_offline
  FROM router.AH201309 a, router.AH201309 b 
 WHERE     a.robj = 4101 
       AND a.szdtime > '2013-09-12 06:06:00' 
       AND a.szdtime < '2013-09-12 06:10:00' 
       AND A.RATM = b.RATM 
       AND A.SZDTIME = b.SZDTIME 
       AND A.RVALUE > b.RVALUE 
       AND A.LSEQ < b.LSEQ 
       AND (a.szdtime, a.ratm) IN (  SELECT szdtime, ratm 
                                       FROM (SELECT * 
                                               FROM router.AH201309 a 
                                              WHERE a.robj = 4101 
                                                    AND a.szdtime > 
                                                           '2013-09-12 06:06:00' 
                                                    AND a.szdtime < 
                                                           '2013-09-12 06:10:00') 
                                   GROUP BY szdtime, ratm 
                                     HAVING COUNT (DISTINCT rvalue) > 1) 
ORDER BY a.ratm, a.szdtime, a.lseq; 