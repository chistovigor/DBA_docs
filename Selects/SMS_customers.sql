/* Formatted on 05.03.2015 18:51:24 (QP5 v5.227.12220.39754) */
--DELETE FROM TTT_SMS;

--SELECT * FROM TTT_SMS;

DECLARE
   v_cursor   SYS_REFCURSOR;
BEGIN
   INSERT INTO TTT_SMS (SERNO,
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
             0,
             p.phone
        FROM raiff.cards@ONLINE_PROD, TTT_PHONE_EXT p
       WHERE cardnumber = p.numberx;


   DELETE FROM TTT_SMS
         WHERE    ROWID IN (  SELECT MAX (ROWID)
                                FROM TTT_SMS
                               WHERE CARDNUMBER IN (  SELECT CARDNUMBER
                                                        FROM TTT_SMS
                                                    GROUP BY CARDNUMBER
                                                      HAVING COUNT (*) > 1)
                            GROUP BY CARDNUMBER)
               OR phone IS NULL;

   FOR rec
      IN (SELECT groupserno, t.serno, c.numberx
            FROM TTT_SMS t, raiff.cardx@PRIME_PROD c
           WHERE     t.cardnumber = c.numberx
                 AND c.primarycard = 1
                 AND stgeneral IN ('NORM', 'NEW'))
   LOOP
      UPDATE TTT_SMS s
         SET s.NUMBERX = rec.numberx
       WHERE s.cardnumber = rec.numberx;
   END LOOP;

   COMMIT;

   FOR rec IN (SELECT serno, groupserno
                 FROM TTT_SMS
                WHERE NUMBERX <> cardnumber)
   LOOP
      UPDATE TTT_SMS s
         SET s.primcardserno = rec.serno
       WHERE s.groupserno = rec.groupserno;
   END LOOP;

   COMMIT;



   OPEN v_cursor FOR
        SELECT    TS.serno
               || '|'
               || TS.primcardserno
               || '|'
               || TRIM (TS.cardnumber)
               || '|'
               || TO_CHAR (
                     ADD_MONTHS (TO_DATE (TS.expiry, 'DD.MM.YYYY'), 12 * 2000),
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
          FROM TTT_SMS TS,
               raiff.Cardx@PRIME_PROD Crd LEFT OUTER JOIN raiff.cextension@PRIME_PROD CE ON CE.rowserno = Crd.serno AND CE.tabindicator = 'C' AND CE.fieldno = 10002
         WHERE LENGTH (TS.phone) > 5 AND Crd.numberx = TS.cardnumber
      ORDER BY TRIM (TS.cardnumber);
END;