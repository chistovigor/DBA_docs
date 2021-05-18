CREATE TABLE TTT_PHONE_EXT
(
  NUMBERX  CHAR(25 BYTE),
  PHONE    CHAR(16 BYTE),
  ACTION   CHAR(1 BYTE),
  A        CHAR(2 BYTE)
)
ORGANIZATION EXTERNAL
  (  TYPE ORACLE_LOADER
     DEFAULT DIRECTORY SMS_CORPORATE
     ACCESS PARAMETERS 
       ( RECORDS DELIMITED BY NEWLINE
       NOBADFILE
       NODISCARDFILE
       NOLOGFILE
       SKIP 0
       FIELDS TERMINATED BY '|'
       MISSING FIELD VALUES ARE NULL
       REJECT ROWS WITH ALL NULL FIELDS
       (
         NUMBERX Char,
         PHONE Char,
         ACTION Char,
         A Char
       ) )
     LOCATION (SMS_CORPORATE:'SMS_PHONE.TXT')
  )
REJECT LIMIT UNLIMITED
PARALLEL ( DEGREE DEFAULT INSTANCES DEFAULT )
NOMONITORING;




  CREATE OR REPLACE PROCEDURE "TCTDBS"."sms_customers" (v_cursor OUT SYS_REFCURSOR)
IS
   p_file                  UTL_FILE.FILE_TYPE;
   l_table                 VARCHAR2 (1024);
   v_filename              VARCHAR2 (50);
   v_cards_in_online       NUMBER;
   v_cards_not_in_online   NUMBER;
BEGIN
   EXECUTE IMMEDIATE 'truncate table TTT_SMS1';

   SELECT MAX (phone) INTO l_table FROM TTT_PHONE_EXT;

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

   SELECT COUNT (NUMBERX)
     INTO v_cards_not_in_online
     FROM TTT_PHONE_EXT
    WHERE CAST (NUMBERX AS CHAR (25)) NOT IN
             (SELECT cardnumber FROM raiff.cards@ONLINE_PROD);

   SELECT COUNT (NUMBERX)
     INTO v_cards_in_online
     FROM TTT_PHONE_EXT
    WHERE CAST (NUMBERX AS CHAR (25)) IN
             (SELECT cardnumber FROM raiff.cards@ONLINE_PROD);

   IF (100 - ROUND ( (v_cards_not_in_online / v_cards_in_online) * 100, 2)) >=
         90
   THEN
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
            SET s.primcardserno =
                   (SELECT SERNO
                      FROM TTT_SMS1
                     WHERE     NUMBERX IS NOT NULL
                           AND GROUPSERNO = rec.groupserno)
          WHERE s.groupserno = rec.groupserno;
      END LOOP;

      UPDATE TTT_SMS1
         SET primcardserno = NULL
       WHERE primcardserno = serno;

      COMMIT;

      SELECT 'SMS_PHONE_' || TO_CHAR (SYSDATE, 'YYMMDDHH24MI') || '.TXT'
        INTO v_filename
        FROM DUAL;

      p_file := UTL_FILE.fopen ('SMS_CORPORATE', v_filename, 'W');

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

      SELECT COUNT (NUMBERX)
        INTO v_cards_not_in_online
        FROM TTT_PHONE_EXT
       WHERE CAST (NUMBERX AS CHAR (25)) NOT IN
                (SELECT cardnumber FROM raiff.cards@ONLINE_PROD);

      OPEN v_cursor FOR
         SELECT    'resulting file for sms notifications is '
                || v_filename
                || ' in the same folder as SMS_PHONE.txt file'
                   AS sms_customers
           FROM DUAL;

      UTL_FILE.fclose_all ();

      IF v_cards_not_in_online > 0
      THEN
         SELECT    'SMS_PHONE_ERROR_CARDS_'
                || TO_CHAR (SYSDATE, 'YYMMDDHH24MI')
                || '.TXT'
           INTO v_filename
           FROM DUAL;

         p_file := UTL_FILE.fopen ('SMS_CORPORATE', v_filename, 'W');

         FOR l_table
            IN (SELECT NUMBERX
                  FROM TTT_PHONE_EXT
                 WHERE CAST (NUMBERX AS CHAR (25)) NOT IN
                          (SELECT cardnumber FROM raiff.cards@ONLINE_PROD))
         LOOP
            UTL_FILE.PUT_LINE (p_file, l_table.NUMBERX);
         END LOOP;

         UTL_FILE.fclose_all ();
      END IF;
   ELSE
      OPEN v_cursor FOR
         SELECT 'Error: Less than 90% of cards from \\raiffeisen\DFS\RBA\MSK\Smolenskoe\Workgroups\Bank Cards\Reports\SMS_Corporate\SMS_PHONE.txt in ONLINE'
                   AS sms_customers
           FROM DUAL;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      OPEN v_cursor FOR
         SELECT 'Error: check if the file SMS_PHONE.txt exists in \\raiffeisen\DFS\RBA\MSK\Smolenskoe\Workgroups\Bank Cards\Reports\SMS_Corporate folder'
                   AS sms_customers
           FROM DUAL;
END;