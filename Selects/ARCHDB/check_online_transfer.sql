/* Formatted on 27.05.2014 6:06:53 (QP5 v5.227.12220.39754) */
SELECT DISTINCT (eodserno) FROM raiff.acquirerlog@ONLINE_PROD;

  SELECT DISTINCT (serno)
    FROM raiff.eods@ONLINE_PROD
ORDER BY 1;

SELECT *
  FROM raiff.acquirerlog@ONLINE_PROD
 WHERE serno BETWEEN 2492310 AND 2492359;--and eodserno = 12100

  SELECT eodserno,
         MIN (ltimestamp),
         MIN (serno),
         MAX (ltimestamp),
         MAX (serno)
    FROM raiff.acquirerlog@ONLINE_PROD
   WHERE eodserno > (SELECT SERNO_LIST_ACQLOG FROM DUAL)
GROUP BY eodserno
ORDER BY eodserno;


  SELECT eodserno,
         MIN (ltimestamp),
         MIN (serno),
         MAX (ltimestamp),
         MAX (serno)
    FROM raiff.authorizations@ONLINE_PROD
   WHERE eodserno > (SELECT SERNO_LIST_AUTH FROM DUAL)
GROUP BY eodserno
ORDER BY eodserno;


  SELECT eodserno,
         MIN (ltimestamp),
         MIN (serno),
         MAX (ltimestamp),
         MAX (serno)
    FROM acquirerlog
   WHERE eodserno = (SELECT SERNO_LIST_AUTH FROM DUAL)
GROUP BY eodserno
UNION ALL
  SELECT eodserno,
         MIN (ltimestamp),
         MIN (serno),
         MAX (ltimestamp),
         MAX (serno)
    FROM authorizations
   WHERE eodserno = (SELECT SERNO_LIST_ACQLOG FROM DUAL)
GROUP BY eodserno
ORDER BY eodserno;


  SELECT eodserno,
         MIN (ltimestamp),
         MIN (serno),
         MAX (ltimestamp),
         MAX (serno)
    FROM acquirerlog
   WHERE eodserno >= (SELECT SERNO_LIST_ACQLOG FROM DUAL)
GROUP BY eodserno
ORDER BY eodserno;