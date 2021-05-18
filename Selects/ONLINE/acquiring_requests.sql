SELECT *
  FROM tctdbs.acquirerlog
 WHERE     serno >= (SELECT MAX (serno) FROM tctdbs.acquirerlog) - 50000
       AND ltimestamp BETWEEN (SYSDATE - 600 / 86400) AND (SYSDATE - 5 / 86400)
       AND i039_resp_cd IS NULL
UNION ALL
SELECT *
  FROM tctdbs.acquirerlog
 WHERE     serno >= (SELECT MAX (serno) FROM tctdbs.acquirerlog) - 50000
       AND ltimestamp BETWEEN (SYSDATE - 600 / 86400) AND (SYSDATE - 5 / 86400)
       AND regexp_like ( i000_msg_type, '0.[02].')
       AND i000_msg_type not  in (0320)
       AND reasoncode is null
UNION ALL
SELECT *
  FROM tctdbs.acquirerlog
 WHERE     serno >= (SELECT MAX (serno) FROM tctdbs.acquirerlog) - 50000
       AND ltimestamp BETWEEN (SYSDATE - 600 / 86400) AND (SYSDATE - 5 / 86400)
       AND regexp_like ( i000_msg_type, '0.[02].')
       AND i000_msg_type not  in (0320)
       AND reasoncode is not  null;