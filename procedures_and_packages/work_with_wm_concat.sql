
  CREATE OR REPLACE PROCEDURE "TCTDBS"."C2C_ANALYZE" (
   v_card_number       VARCHAR2,
   v_cursor        OUT SYS_REFCURSOR,
   v_interval          NUMBER DEFAULT 60)
/******************************************************************************
     NAME: c2c_analyze report
     PURPOSE: Run report for all card to card transactions for the given card

     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        26.03.2015     ruacii2        1. Procedure runs from Jasperserver, folder Processing
  ******************************************************************************/

IS
BEGIN
   DBMS_OUTPUT.ENABLE (100000);

   OPEN v_cursor FOR
        SELECT CAST (
                  wmsys.wm_concat (
                        CHR (10)
                     || CHR (13)
                     || '********ПЕРЕВОД ОТ '
                     || TO_CHAR (t.LTIMESTAMP, 'DD-MM-YYYY HH24:MI:SS')
                     || ' *********'
                     || CHR (13)
                     || 'ДАТА СОЗДАНИЯ ПЕРЕВОДА: '
                     || TO_CHAR (t.LTIMESTAMP, 'DD-MM-YYYY HH24:MI:SS')
                     || CHR (13)
                     || 'ДАТА ОСУЩЕСТВЛЕНИЯ ПЕРЕВОДА: '
                     || TO_CHAR (T1.LTIMESTAMP, 'DD-MM-YYYY HH24:MI:SS')
                     || CHR (13)
                     || 'НОМЕР КАРТЫ ОТПРАВИТЕЛЯ: '
                     || SUBSTR (t.i002_number, 1, 6)
                     || '******'
                     || SUBSTR (t.i002_number, 13, 4)
                     || CHR (13)
                     || 'СУММА ПЕРЕВОДА: '
                     || t.i004_amt_trxn
                     || CHR (13)
                     || 'СТАТУС ПЕРЕВОДА ОТ НАС: '
                     || CASE (t.i039_resp_cd)
                           WHEN '00' THEN 'УСПЕШНЫЙ '
                           ELSE 'НЕ УСПЕШНЫЙ, '
                        END
                     || t.i039_resp_cd
                     || '- '
                     || TRIM (r.description)
                     || CHR (13)
                     || 'TERMINAL_ID: '
                     || t.i041_pos_id
                     || CHR (13)
                     || 'MERCHANT_ID: '
                     || TRIM (t.i042_merch_id)
                     || CHR (13)
                     || 'MERCHANT_NAME: '
                     || TRIM (t.i043a_merch_name)
                     || CHR (13)
                     || 'RRN_ОПЕРАЦИИ: '
                     || t.i037_ret_ref_num
                     || CHR (13)
                     || 'КОД АВТОРИЗАЦИИ: '
                     || t.i038_auth_id
                     || CHR (13)
                     || 'КАРТА ПОЛУЧАТЕЛЯ: '
                     || SUBSTR (
                           REPLACE (SUBSTR (t.i104_tran_desc, 26, 35), 'F', ''),
                           1,
                           6)
                     || '******'
                     || SUBSTR (
                           REPLACE (SUBSTR (t.i104_tran_desc, 26, 35), 'F', ''),
                           13,
                           4)
                     || CHR (13)
                     || 'СТАТУС ПЕРЕВОДА НА СТОРОНЕ ПОЛУЧАТЕЛЯ: '
                     || CASE (t1.i039_resp_cd)
                           WHEN '00' THEN 'УСПЕШНЫЙ - '
                           ELSE 'НЕ УСПЕШНЫЙ - '
                        END
                     || r3.description
                     || CHR (13)
                     || 'КАТЕГОРИЯ ПОЛУЧАТЕЛЯ: '
                     || CASE TRIM (c.CARDHOLDERDATA)
                           WHEN 'R'
                           THEN
                              'Resident'
                           WHEN 'N'
                           THEN
                              'No Resident'
                           WHEN NULL
                           THEN
                              'Клиент банка, нет данных'
                           ELSE
                              'НЕТ ДАННЫХ: "получатель не клиент Raiffeisenbank"'
                        END
                     || CHR (13)
                     || 'EXPIRYDATE КАРТЫ ПОЛУЧАТЕЛЯ: '
                     || NVL (
                           TO_CHAR (c.EXPIRYDATE),
                           'НЕТ ДАННЫХ: "получатель не клиент Raiffeisenbank" ')
                     || CHR (13)
                     || 'СТАТУС КАРТЫ ПОЛУЧАТЕЛЯ: '
                     || NVL (
                           TO_CHAR (c.ACTION_RESCODE),
                           'НЕТ ДАННЫХ: "получатель не клиент Raiffeisenbank" ')
                     || CHR (13)
                     || 'ВАЛЮТА КАРТЫ ПОЛУЧАТЕЛЯ: '
                     || NVL (
                           TO_CHAR (c.AUTHCURRENCY),
                           'НЕТ ДАННЫХ: "получатель не клиент Raiffeisenbank" ')
                     || CHR (13)
                     || '===========================================') AS VARCHAR2 (4000))
                  AS c2c_analyze
          FROM raiff.acquirerlog@ONLINE_PROD t,
               raiff.acquirerlog@ONLINE_PROD t1,
               raiff.respcodes@ONLINE_PROD r,
               raiff.authorizations@ONLINE_PROD a,
               raiff.respcodes@ONLINE_PROD r1,
               tctdbs.cards@ONLINE_PROD c,
               raiff.respcodes@ONLINE_PROD r3
         WHERE     1 = 1
               AND C.CARDNUMBER(+) =
                      CAST (
                         REPLACE (SUBSTR (t.i104_tran_desc, 26), 'F', '') AS CHAR (25))
               AND r.code = t.i039_resp_cd
               AND r1.code(+) = a.I039_RSP_CD
               AND r3.code(+) = t1.i039_resp_cd
               AND A.I037_RET_REF_NUM(+) = T.I037_RET_REF_NUM
               AND A.I002_NUMBER(+) =
                      CAST (
                         REPLACE (SUBSTR (t.i104_tran_desc, 26), 'F', '') AS CHAR (25))
               AND t1.i002_number(+) =
                      CAST (
                         REPLACE (SUBSTR (t.i104_tran_desc, 26), 'F', '') AS CHAR (25))
               AND t.interfacemsgid = t1.interfacemsgid(+)
               AND t.ltimestamp >=
                      TO_DATE (TO_CHAR (SYSDATE - v_interval, 'ddmmyyyy'),
                               'ddmmyyyy')
               AND T.I000_MSG_TYPE = '0110'
               AND t.i002_number = v_card_number
               AND t.i003_proc_code <> '300000'
               AND t.i018_merch_type NOT IN ('6011', '6010', '9999')
               AND r.format(+) = 'V'
               AND r1.format(+) = 'V'
               AND r3.format(+) = 'V'
      ORDER BY t.ltimestamp;
END;