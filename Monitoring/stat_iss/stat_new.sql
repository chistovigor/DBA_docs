/* Formatted on 15/05/2014 10:42:40 (QP5 v5.227.12220.39754) */
SELECT 'Mast Auth  All'||'|'|| COUNT (serno)
  FROM authorizations
 WHERE     serno >= (SELECT MAX (serno) FROM authorizations) - 5000
       AND ltimestamp BETWEEN (SYSDATE - 65 / 86400)
                          AND (SYSDATE - 5 / 86400)
       AND i000_msg_type NOT IN
              ('0100', '0120', '0302', '0400', '0420', '0600', '0620', '0800')
       AND source IN ('MAST')
UNION ALL
SELECT 'Visa Auth All'||'|'|| COUNT (serno)
  FROM authorizations
 WHERE     serno >= (SELECT MAX (serno) FROM authorizations) - 5000
       AND ltimestamp BETWEEN (SYSDATE - 65 / 86400)
                          AND (SYSDATE - 5 / 86400)
       AND i000_msg_type NOT IN
              ('0100', '0120', '0302', '0400', '0420', '0600', '0620', '0800')
       AND source IN ('VISA')
UNION ALL
SELECT 'Visa Auth Unsuccsess'||'|'|| COUNT (serno)
  FROM authorizations
 WHERE     serno >= (SELECT MAX (serno) FROM authorizations) - 5000
       AND ltimestamp BETWEEN (SYSDATE - 65 / 86400)
                          AND (SYSDATE - 5 / 86400)
       AND i039_rsp_cd NOT IN ('00')
       AND i000_msg_type NOT IN
              ('0100', '0120', '0302', '0400', '0420', '0600', '0620', '0800')
       AND source IN ('VISA')
UNION ALL
SELECT 'Mast Auth Unsuccsess'||'|'|| COUNT (serno)
  FROM authorizations
 WHERE     serno >= (SELECT MAX (serno) FROM authorizations) - 5000
       AND ltimestamp BETWEEN (SYSDATE - 65 / 86400)
                          AND (SYSDATE - 5 / 86400)
       AND i000_msg_type NOT IN
              ('0100', '0120', '0302', '0400', '0420', '0600', '0620', '0800')
       AND i039_rsp_cd NOT IN ('00')
       AND source IN ('MAST')
UNION ALL
SELECT 'ARQC Problem' || '|' || COUNT (serno)
  FROM authorizations
 WHERE     serno >= (SELECT MAX (serno) FROM authorizations) - 5000
       AND ltimestamp BETWEEN (SYSDATE - 65 / 86400)
                          AND (SYSDATE - 5 / 86400)
       AND i000_msg_type NOT IN
              ('0100', '0120', '0302', '0400', '0420', '0600', '0620', '0800')
       AND TRIM (i039_rsp_cd) = '05'
       AND reasoncode = '251'
UNION ALL
SELECT 'MsgType 0130 All' || '|' || COUNT (serno)
  FROM authorizations
 WHERE     serno >= (SELECT MAX (serno) FROM authorizations) - 5000
       AND ltimestamp BETWEEN (SYSDATE - 65 / 86400)
                          AND (SYSDATE - 5 / 86400)
       AND TRIM (i000_msg_type) IN ('0130')
UNION ALL
SELECT 'MsgType 0410 All' || '|' || COUNT (serno)
  FROM authorizations
 WHERE     serno >= (SELECT MAX (serno) FROM authorizations) - 5000
       AND ltimestamp BETWEEN (SYSDATE - 65 / 86400)
                          AND (SYSDATE - 5 / 86400)
       AND TRIM (i000_msg_type) IN ('0410')
UNION ALL
SELECT 'Interim 0430 All' || '|' || COUNT (serno)
  FROM authorizations
 WHERE     serno >= (SELECT MAX (serno) FROM authorizations) - 5000
       AND ltimestamp BETWEEN (SYSDATE - 65 / 86400)
                          AND (SYSDATE - 5 / 86400)
       AND TRIM (i000_msg_type) IN ('0430')
       AND source IN ('DSAF')
UNION ALL
SELECT 'MsgType 0120 All' || '|' || COUNT (serno)
  FROM authorizations
 WHERE     serno >= (SELECT MAX (serno) FROM authorizations) - 5000
       AND ltimestamp BETWEEN (SYSDATE - 65 / 86400)
                          AND (SYSDATE - 5 / 86400)
       AND TRIM (i000_msg_type) IN ('0120')
UNION ALL
SELECT 'Node_1_V_Tech_Err' || '|' || COUNT(serno)
  FROM authorizations
 WHERE serno >= (SELECT MAX(serno) FROM authorizations) - 5000
   AND ltimestamp BETWEEN (SYSDATE - 65 / 86400) AND (SYSDATE - 5 / 86400)
   AND NODENUMBER = (1)
   AND FORMAT = ('V')
   AND i039_rsp_cd IN
       ('06', '68', '91', '94', '96', '86', '81', '30', '88')
UNION ALL
SELECT 'Node_2_V_Tech_Err' || '|' || COUNT(serno)
  FROM authorizations
 WHERE serno >= (SELECT MAX(serno) FROM authorizations) - 5000
   AND ltimestamp BETWEEN (SYSDATE - 65 / 86400) AND (SYSDATE - 5 / 86400)
   AND NODENUMBER = (2)
   AND FORMAT = ('V')
   AND i039_rsp_cd IN
       ('06', '68', '91', '94', '96', '86', '81', '30', '88')
UNION ALL
SELECT 'Node_1_M_Tech_Err' || '|' || COUNT(serno)
  FROM authorizations
 WHERE serno >= (SELECT MAX(serno) FROM authorizations) - 5000
   AND ltimestamp BETWEEN (SYSDATE - 65 / 86400) AND (SYSDATE - 5 / 86400)
   AND NODENUMBER = (1)
   AND FORMAT = ('M')
   AND i039_rsp_cd IN
       ('06', '68', '91', '94', '96', '86', '81', '30', '88')
UNION ALL
SELECT 'Node_2_M_Tech_Err' || '|' || COUNT(serno)
  FROM authorizations
 WHERE serno >= (SELECT MAX(serno) FROM authorizations) - 5000
   AND ltimestamp BETWEEN (SYSDATE - 65 / 86400) AND (SYSDATE - 5 / 86400)
   AND NODENUMBER = (2)
   AND FORMAT = ('M')
   AND i039_rsp_cd IN
       ('06', '68', '91', '94', '96', '86', '81', '30', '88')
UNION ALL
SELECT 'Node_1_O_Tech_Err' || '|' || COUNT(serno)
  FROM authorizations
 WHERE serno >= (SELECT MAX(serno) FROM authorizations) - 5000
   AND ltimestamp BETWEEN (SYSDATE - 65 / 86400) AND (SYSDATE - 5 / 86400)
   AND NODENUMBER = (1)
   AND FORMAT = ('O')
   AND i039_rsp_cd IN
       ('06', '68', '91', '94', '96', '86', '81', '30', '88')
UNION ALL
SELECT 'Node_2_O_Tech_Err' || '|' || COUNT(serno)
  FROM authorizations
 WHERE serno >= (SELECT MAX(serno) FROM authorizations) - 5000
   AND ltimestamp BETWEEN (SYSDATE - 65 / 86400) AND (SYSDATE - 5 / 86400)
   AND NODENUMBER = (2)
   AND FORMAT = ('O')
   AND i039_rsp_cd IN
       ('06', '68', '91', '94', '96', '86', '81', '30', '88')
UNION ALL
SELECT 'Mant Auth  All'||'|'|| COUNT (serno)
  FROM authorizations
 WHERE     serno >= (SELECT MAX (serno) FROM authorizations) - 5000
       AND ltimestamp BETWEEN (SYSDATE - 65 / 86400)
                          AND (SYSDATE - 5 / 86400)
       AND i000_msg_type NOT IN
              ('0100', '0120', '0302', '0400', '0420', '0600', '0620', '0800')
       AND source IN ('MANT')
UNION ALL
SELECT 'Vina Auth All'||'|'|| COUNT (serno)
  FROM authorizations
 WHERE     serno >= (SELECT MAX (serno) FROM authorizations) - 5000
       AND ltimestamp BETWEEN (SYSDATE - 65 / 86400)
                          AND (SYSDATE - 5 / 86400)
       AND i000_msg_type NOT IN
              ('0100', '0120', '0302', '0400', '0420', '0600', '0620', '0800')
       AND source IN ('VINA')
UNION ALL
SELECT 'Vina Auth Unsuccsess'||'|'|| COUNT (serno)
  FROM authorizations
 WHERE     serno >= (SELECT MAX (serno) FROM authorizations) - 5000
       AND ltimestamp BETWEEN (SYSDATE - 65 / 86400)
                          AND (SYSDATE - 5 / 86400)
       AND i039_rsp_cd NOT IN ('00')
       AND i000_msg_type NOT IN
              ('0100', '0120', '0302', '0400', '0420', '0600', '0620', '0800')
       AND source IN ('VINA')
UNION ALL
SELECT 'Mant Auth Unsuccsess'||'|'|| COUNT (serno)
  FROM authorizations
 WHERE     serno >= (SELECT MAX (serno) FROM authorizations) - 5000
       AND ltimestamp BETWEEN (SYSDATE - 65 / 86400)
                          AND (SYSDATE - 5 / 86400)
       AND i000_msg_type NOT IN
              ('0100', '0120', '0302', '0400', '0420', '0600', '0620', '0800')
       AND i039_rsp_cd NOT IN ('00')
       AND source IN ('MANT')
;