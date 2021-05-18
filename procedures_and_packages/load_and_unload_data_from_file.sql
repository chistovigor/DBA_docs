/* Formatted on 19.03.2015 16:51:51 (QP5 v5.227.12220.39754) */
CREATE OR REPLACE PROCEDURE TCTDBS.sms_customers (v_cursor OUT SYS_REFCURSOR)
IS
   p_file    UTL_FILE.FILE_TYPE;
   l_table   VARCHAR2 (1024);
BEGIN
   EXECUTE IMMEDIATE 'truncate table TTT_SMS1';

   INSERT INTO TTT_SMS1 (SERNO,
                         CARDNUMBER,
                         EXPIRY,
                         CURRENCY,
                         LASTNAME,
                         GROUPSERNO,
                         PRIMCARDSERNO,
                         PHONE)
      SELECT serno,
             cardnumber,
             expirydate,
             authcurrency,
             lastname,
             groupserno1,
             NULL,
             p.phone
        FROM raiff.cards@ONLINE_PROD, TTT_PHONE_EXT p
       WHERE cardnumber = p.numberx;


   DELETE FROM TTT_SMS1
         WHERE    ROWID IN (  SELECT MAX (ROWID)
                                FROM TTT_SMS1
                               WHERE CARDNUMBER IN (  SELECT CARDNUMBER
                                                        FROM TTT_SMS1
                                                    GROUP BY CARDNUMBER
                                                      HAVING COUNT (*) > 1)
                            GROUP BY CARDNUMBER)
               OR phone IS NULL;

   FOR rec
      IN (SELECT groupserno, t.serno, c.numberx
            FROM TTT_SMS1 t, raiff.cardx@PRIME_PROD c
           WHERE     t.cardnumber = c.numberx
                 AND c.primarycard = 1
                 AND stgeneral IN ('NORM', 'NEW'))
   LOOP
      UPDATE TTT_SMS1 s
         SET s.NUMBERX = rec.numberx
       WHERE s.cardnumber = rec.numberx;
   END LOOP;

   FOR rec IN (SELECT serno, groupserno
                 FROM TTT_SMS1
                WHERE NUMBERX <> cardnumber OR NUMBERX IS NULL)
   LOOP
      UPDATE TTT_SMS1 s
         SET s.primcardserno = rec.serno
       WHERE s.groupserno = rec.groupserno;
   END LOOP;

   UPDATE TTT_SMS1
      SET primcardserno = NULL
    WHERE primcardserno = serno;

   COMMIT;

   p_file := UTL_FILE.fopen ('REPORTS', 'sms_rconnect.txt', 'W');

   FOR l_table
      IN (  SELECT    TS.serno
                   || '|'
                   || TS.primcardserno
                   || '|'
                   || TRIM (TS.cardnumber)
                   || '|'
                   || TO_CHAR (
                         ADD_MONTHS (TO_DATE (TS.expiry, 'DD.MM.YYYY'),
                                     12 * 2000),
                         'DD/MM/YYYY')
                   || '|'
                   || TRIM (TS.lastname)
                   || '|'
                   || TRIM (TS.phone)
                   || '|'
                   || TS.currency
                   || '|'
                   || crd.externalreference
                   || '|'
                      AS sms_customers
              FROM TTT_SMS1 TS,
                   raiff.Cardx@PRIME_PROD Crd LEFT OUTER JOIN raiff.cextension@PRIME_PROD CE ON CE.rowserno = Crd.serno AND CE.tabindicator = 'C' AND CE.fieldno = 10002
             WHERE LENGTH (TS.phone) > 5 AND Crd.numberx = TS.cardnumber
          ORDER BY TRIM (TS.cardnumber))
   LOOP
      UTL_FILE.PUT_LINE (p_file, l_table.sms_customers);
   END LOOP;

   UTL_FILE.fclose_all ();
END;
/