#!/bin/bash

. $HOME/.bash_profile

# set variables

ultra_user=vsmc3ds
ultra_pwd=vsmc3ds
atm_user=atm
atm_pwd=atm
web_user=arcot_callout_a
web_user_pwd=arcot_callout_a_pwd
sqlplus_header='SET SHOW OFF FEEDBACK OFF timing off heading off pagesize 200 feedback off serveroutput off LINESIZE 200'
logdir='/opt/scripts/E-commerce'
send2zabbix='/usr/bin/zabbix_sender -T -z 10.243.12.20 -i '

# script body

clear
echo start `date`

sqlplus -S $ultra_user/$ultra_pwd@ULTRA_SERVICE<<!

$sqlplus_header

SPOOL $logdir/ultra_out.txt

SELECT hostname,
       LOWER ('ultradb.' || key) AS key,
       timestamp,
       VALUE
  FROM (SELECT 's-msk08-ultra-la' AS hostname FROM DUAL),
       (SELECT *
          FROM (SELECT *
                  FROM (SELECT COUNT (1) AS trn_overall,
                               COUNT (CASE WHEN alphaprocess = 'Y' THEN 1 ELSE NULL END) AS trn_y,
                               COUNT (CASE WHEN alphaprocess = 'U' THEN 1 ELSE NULL END) AS trn_u,
                               COUNT (CASE WHEN alphaprocess = 'N' THEN 1 ELSE NULL END) AS trn_n,
                               COUNT (CASE WHEN enrollprocess = 'N' THEN 1 ELSE NULL END) AS trn_enroll_n,
                               COUNT (CASE WHEN transrespcode IN ('89', '68', '96') THEN 1 ELSE NULL END) AS trn_tech_err
                          FROM (SELECT *
                                  FROM dddsproc_transact_info a LEFT OUTER JOIN tandem_transact_info b ON a.id = b.id
                                 WHERE a.transdate >= TRUNC (SYSDATE, 'MI') - 2 / 24 / 60
                                       AND a.transdate < TRUNC (SYSDATE, 'MI') - 1 / 24 / 60)) trns,
                       (SELECT COUNT (1) AS event_all, COUNT (CASE WHEN evt.resp_code <> '0' THEN 1 ELSE NULL END) AS event_fail
                          FROM http_event evt
                         WHERE evt.resp_process_time >= TRUNC (SYSDATE, 'MI') - 2 / 24 / 60
                               AND evt.resp_process_time < TRUNC (SYSDATE, 'MI') - 1 / 24 / 60) http_evt,
                       (SELECT COUNT (1) AS reversals
                          FROM tandem_transact_info revs
                         WHERE     revs.operationtype = '100'
                               AND revs.reversal = 'Y'
                               AND revs.reversalrespcode IS NOT NULL
                               AND revs.reversalnote IS NOT NULL
                               AND revs.reversalrespcode = '00'
                               AND revs.reversalnote <> 'Send in progress'
                               AND LENGTH (revs.reversalnote) = 6
                               AND revs.reversaldate >= TRUNC (SYSDATE, 'MI') - 2 / 24 / 60
                               AND revs.reversaldate < TRUNC (SYSDATE, 'MI') - 1 / 24 / 60) tnd_revrs,
                       (SELECT COUNT (1) AS revers_left
                          FROM tandem_transact_info a
                         WHERE a.operationtype = '100' AND a.reversal = 'Y' AND a.reversalrespcode IS NULL) tnd_revers_left,
                       (SELECT COUNT (1) AS xml_event
                          FROM xml_event x
                         WHERE x.transdate >= TRUNC (SYSDATE, 'MI') - 2 / 24 / 60
                               AND x.transdate < TRUNC (SYSDATE, 'MI') - 1 / 24 / 60) xmlevts,
                       (SELECT COUNT (CASE WHEN b.id IS NULL THEN 1 ELSE NULL END) AS tonight_clearing
                          FROM dddsproc_transact_info a
                               INNER JOIN tandem_transact_info c
                                   ON a.id = c.id AND c.reversal <> 'Y'
                               LEFT OUTER JOIN tandem_transact_info b
                                   ON a.id = b.refid AND b.operationtype = '220' AND b.transrespcode = '00'
                         WHERE TRUNC (a.clearingdate) = TRUNC (SYSDATE) AND a.alphaprocess = 'Y') tnghtclrng,
                       (SELECT COUNT (CASE WHEN tt.operationtype = '220' THEN 1 ELSE NULL END) AS trn_200,
                               COUNT (CASE WHEN tt.operationtype = '220' AND tt.transrespcode <> '00' THEN 1 ELSE NULL END)
                                   AS trn_200failed
                          FROM tandem_transact_info tt
                         WHERE tt.transdate >= TRUNC (SYSDATE, 'MI') - 2 / 24 / 60
                               AND tt.transdate < TRUNC (SYSDATE, 'MI') - 1 / 24 / 60) clrng,
                       (SELECT COUNT (1) AS clrnow_flg
                          FROM dddsproc_flags a, tandem_transact_info b
                         WHERE a.flag_type = 2 AND a.flag_state = 1 AND a.id = b.refid AND b.operationtype = '100') clrngnfl,
                       (SELECT COUNT (1) AS clrnow_clrd
                          FROM dddsproc_transact_info a
                               INNER JOIN tandem_transact_info c
                                   ON a.id = c.id AND c.reversal <> 'Y'
                               LEFT OUTER JOIN tandem_transact_info b
                                   ON a.id = b.refid AND b.operationtype = '220' AND b.transrespcode = '00'
                         WHERE a.clearingdate <= SYSDATE AND a.alphaprocess = 'Y' AND b.id IS NULL) clrnddclrdate,
                       (SELECT COUNT (1) AS clrn_errtotal
                          FROM tandem_transact_info a
                         WHERE a.operationtype = '220' AND a.transrespcode <> '00') clrnertot,
                       (SELECT COUNT (CASE WHEN a.processtype = 'VSMC3DS_CLEARING' THEN 1 ELSE NULL END) AS clr_pr_total,
                               COUNT (CASE WHEN a.processtype = 'VSMC3DS_REVERSAL' THEN 1 ELSE NULL END) AS rvr_pr_total,
                               COUNT (
                                   CASE
                                       WHEN a.processtype = 'VSMC3DS_CLEARING' AND a.calltime > SYSDATE - 2 / 24 / 60 THEN 1
                                       ELSE NULL
                                   END)
                                   AS clr_pr_now,
                               COUNT (
                                   CASE
                                       WHEN a.processtype = 'VSMC3DS_REVERSAL' AND a.calltime > SYSDATE - 2 / 24 / 60 THEN 1
                                       ELSE NULL
                                   END)
                                   AS rvr_pr_now
                          FROM process_life a) process_lifes,
                       (SELECT COUNT (1) acql_alive
                          FROM acquirerlog4 ac
                         WHERE ac.serno = (SELECT MAX (serno) FROM acquirerlog4) AND ac.ltimestamp >= SYSDATE - 25 / 24 / 60) acq_log,
                       (SELECT (CASE WHEN COUNT (1) > 0 THEN 1 ELSE 0 END) AS is_xml_alive
                          FROM icbsxpproxy_transact_info icb
                         WHERE icb.transdate >= TRUNC (SYSDATE, 'MI') - 1 / 24 / 60) xmlgate) UNPIVOT (VALUE
                                                                                              FOR key
                                                                                              IN  (trn_overall,
                                                                                                  trn_y,
                                                                                                  trn_u,
                                                                                                  trn_n,
                                                                                                  trn_enroll_n,
                                                                                                  trn_tech_err,
                                                                                                  event_all,
                                                                                                  event_fail,
                                                                                                  acql_alive,
                                                                                                  is_xml_alive,
                                                                                                  trn_200,
                                                                                                  trn_200failed,
                                                                                                  reversals,
                                                                                                  revers_left,
                                                                                                  xml_event,
                                                                                                  tonight_clearing,
                                                                                                  clrnow_flg,
                                                                                                  clrnow_clrd,
                                                                                                  clrn_errtotal,
                                                                                                  clr_pr_total,
                                                                                                  rvr_pr_total,
                                                                                                  clr_pr_now,
                                                                                                  rvr_pr_now)),
               (SELECT TO_NUMBER (
                           (  TRUNC (SYSDATE, 'MI')
                            - 1 / 6
                            - 1 / 24 / 60
                            - TO_DATE ('01/01/1970 00:00:00', 'MM-DD-YYYY HH24:MI:SS'))
                           * 24
                           * 60
                           * 60)
                           AS timestamp
                  FROM DUAL))

/

spool off
exit

!

sqlplus -S $atm_user/$atm_pwd@ULTRA_PREVIEW<<!

$sqlplus_header

SPOOL $logdir/atmrigel_out.txt

WITH op
         AS (SELECT SUBSTR (a.location, 1, INSTR (a.location, '(') - 1)
                        AS method,
                    SUBSTR (a.MESSAGE, INSTR (a.MESSAGE, '(') + 1, 2)
                        AS result
               FROM logs a
              WHERE     a.location LIKE 'com.rigel.webservice.WSInvocation%'
                    AND a.MESSAGE LIKE 'exit with(%)'
                    AND a.logdate >= TRUNC (SYSDATE))
SELECT hostname,
       LOWER ('atmrigel.' || key) AS key,
       timestamp,
       VALUE
  FROM (SELECT 's-msk08-ultra-la' AS hostname FROM DUAL),
       (SELECT *
          FROM (SELECT *
                  FROM (SELECT COUNT (
                                   CASE
                                       WHEN op.method =
                                                'com.rigel.webservice.WSInvocation.subscribeSMSInfo'
                                            AND op.result = '00'
                                       THEN
                                           1
                                       ELSE
                                           NULL
                                   END)
                                   AS subscribesmsinfo_ok,
                               COUNT (
                                   CASE
                                       WHEN op.method =
                                                'com.rigel.webservice.WSInvocation.subscribeSMSInfo'
                                            AND op.result <> '00'
                                       THEN
                                           1
                                       ELSE
                                           NULL
                                   END)
                                   AS subscribesmsinfo_er,
                               COUNT (
                                   CASE
                                       WHEN op.method =
                                                'com.rigel.webservice.WSInvocation.rconnectSubscribeToService'
                                            AND op.result = '00'
                                       THEN
                                           1
                                       ELSE
                                           NULL
                                   END)
                                   AS rconnectsubscribetoservice_ok,
                               COUNT (
                                   CASE
                                       WHEN op.method =
                                                'com.rigel.webservice.WSInvocation.rconnectSubscribeToService'
                                            AND op.result <> '00'
                                       THEN
                                           1
                                       ELSE
                                           NULL
                                   END)
                                   AS rconnectsubscribetoservice_er,
                               COUNT (
                                   CASE
                                       WHEN op.method =
                                                'com.rigel.webservice.WSInvocation.rconnectActivateOTP'
                                            AND op.result = '00'
                                       THEN
                                           1
                                       ELSE
                                           NULL
                                   END)
                                   AS rconnectactivateotp_ok,
                               COUNT (
                                   CASE
                                       WHEN op.method =
                                                'com.rigel.webservice.WSInvocation.rconnectActivateOTP'
                                            AND op.result <> '00'
                                       THEN
                                           1
                                       ELSE
                                           NULL
                                   END)
                                   AS rconnectactivateotp_er,
                               COUNT (
                                   CASE
                                       WHEN op.method =
                                                'com.rigel.webservice.WSInvocation.rconnectAccessRenewalWithoutOTP'
                                            AND op.result = '00'
                                       THEN
                                           1
                                       ELSE
                                           NULL
                                   END)
                                   AS rconaccessrenewalwithoutotp_ok,
                               COUNT (
                                   CASE
                                       WHEN op.method =
                                                'com.rigel.webservice.WSInvocation.rconnectAccessRenewalWithoutOTP'
                                            AND op.result <> '00'
                                       THEN
                                           1
                                       ELSE
                                           NULL
                                   END)
                                   AS rconaccessrenewalwithoutotp_er,
                               COUNT (
                                   CASE
                                       WHEN op.method =
                                                'com.rigel.webservice.WSInvocation.rconnectAccessRenewalWithOTP'
                                            AND op.result = '00'
                                       THEN
                                           1
                                       ELSE
                                           NULL
                                   END)
                                   AS rconaccessrenewalwithotp_ok,
                               COUNT (
                                   CASE
                                       WHEN op.method =
                                                'com.rigel.webservice.WSInvocation.rconnectAccessRenewalWithOTP'
                                            AND op.result <> '00'
                                       THEN
                                           1
                                       ELSE
                                           NULL
                                   END)
                                   AS rconaccessrenewalwithotp_er,
                               COUNT (
                                   CASE
                                       WHEN op.method =
                                                'com.rigel.webservice.WSInvocation.changeSMSInfoPhone'
                                            AND op.result = '00'
                                       THEN
                                           1
                                       ELSE
                                           NULL
                                   END)
                                   AS changesmsinfophone_ok,
                               COUNT (
                                   CASE
                                       WHEN op.method =
                                                'com.rigel.webservice.WSInvocation.changeSMSInfoPhone'
                                            AND op.result <> '00'
                                       THEN
                                           1
                                       ELSE
                                           NULL
                                   END)
                                   AS changesmsinfophone_er
                          FROM op) q1,
                       (SELECT COUNT (
                                   CASE
                                       WHEN (TO_CHAR (
                                                 TRUNC (SYSDATE, 'hh24'),
                                                 'hh24') NOT IN
                                                 ('00',
		 		 		 		 		 		 		 		 		 		 		 		   '01',
                                                  '02',
                                                  '03',
                                                  '04',
                                                  '05',
                                                  '06',
                                                  '07',
		 		 		 		 		 		 		 		 		 		 		 		   '08')
                                             AND a.logdate > SYSDATE - 1 / 24)
                                            OR (TO_CHAR (
                                                    TRUNC (SYSDATE, 'hh24'),
                                                    'hh24') IN
                                                    ('00',
		 		 		 		 		 		 		 		 		 		 		 		 		  '01',
                                                     '02',
                                                     '03',
                                                     '04',
                                                     '05',
                                                     '06',
                                                     '07',
		 		 		 		 		 		 		 		 		 		 		 		 		  '08')
                                                AND a.logdate >
                                                        SYSDATE - 8 / 24)
                                       THEN
                                           1
                                       ELSE
                                           NULL
                                   END)
                                   AS opcount
                          FROM logs a
                         WHERE a.MESSAGE = 'exit with(00)'
                               AND a.location LIKE
                                       'com.rigel.webservice.WSInvocation%'
                               AND a.logdate > SYSDATE - 1) q2) UNPIVOT (VALUE
                                                                FOR key
                                                                IN  (subscribesmsinfo_ok,
                                                                    subscribesmsinfo_er,
                                                                    rconnectsubscribetoservice_ok,
                                                                    rconnectsubscribetoservice_er,
                                                                    rconnectactivateotp_ok,
                                                                    rconnectactivateotp_er,
                                                                    rconaccessrenewalwithoutotp_ok,
                                                                    rconaccessrenewalwithoutotp_er,
                                                                    rconaccessrenewalwithotp_ok,
                                                                    rconaccessrenewalwithotp_er,
                                                                    changesmsinfophone_ok,
                                                                    changesmsinfophone_er,
                                                                    opcount)),
               (SELECT TO_NUMBER (
                           (TRUNC (SYSDATE, 'MI') - 1 / 6
                            - TO_DATE ('01/01/1970 00:00:00',
                                       'MM-DD-YYYY HH24:MI:SS'))
                           * 24
                           * 60
                           * 60)
                           AS timestamp
                  FROM DUAL))

/

spool off

exit

!

sqlplus -S $web_user/$web_user_pwd@WEBDB_L<<!

$sqlplus_header

SPOOL $logdir/web_out.txt

SELECT hostname,
       LOWER ('callout.' || key) AS key,
       timestamp,
       VALUE
  FROM (SELECT 's-msk34-web-a' AS hostname FROM DUAL),
       (SELECT *
          FROM (SELECT COUNT (CASE WHEN a.TYPE = 'validate' THEN 1 ELSE NULL END) AS validate_all,
                       COUNT (CASE WHEN a.TYPE = 'validate' AND a.result <> 22 THEN 1 ELSE NULL END) AS validate_fail,
                       COUNT (CASE WHEN a.TYPE = 'sms' THEN 1 ELSE NULL END) AS sms_all,
                       COUNT (CASE WHEN a.TYPE = 'sms' AND a.result <> 2 THEN 1 ELSE NULL END) AS sms_fail
                  FROM dynamic_log a
                 WHERE a.time >= TRUNC (SYSDATE, 'MI') - 1 / 24 / 60 AND a.time < TRUNC (SYSDATE, 'MI')) UNPIVOT (VALUE
                                                                                                         FOR key
                                                                                                         IN  (validate_all,
                                                                                                             validate_fail,
                                                                                                             sms_all,
                                                                                                             sms_fail)),
               (SELECT TO_NUMBER (
                           (TRUNC (SYSDATE, 'MI') -  1/6 - TO_DATE ('01/01/1970 00:00:00', 'MM-DD-YYYY HH24:MI:SS')) * 24 * 60 * 60)
                           AS timestamp
                  FROM DUAL))

/

spool off

exit

!

$send2zabbix $logdir/ultra_out.txt > /dev/null
$send2zabbix $logdir/atmrigel_out.txt > /dev/null
$send2zabbix $logdir/web_out.txt > /dev/null

echo
echo end `date`

exit