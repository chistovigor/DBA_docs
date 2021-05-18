/* Formatted on 06.04.2015 13:50:16 (QP5 v5.227.12220.39754) */
CREATE OR REPLACE PROCEDURE TCTDBS.p_metlife (v_cursor OUT SYS_REFCURSOR)
IS
   p_file                 UTL_FILE.FILE_TYPE;
   l_table                VARCHAR2 (1024);
   v_filename             VARCHAR2 (50);
   v_cards_not_in_prime   NUMBER;
BEGIN
   SELECT 'METLIFE_' || TO_CHAR (SYSDATE, 'YYMMDDHH24MI') || '.csv'
     INTO v_filename
     FROM DUAL;

   p_file := UTL_FILE.fopen ('METLIFE', v_filename, 'W');

   EXECUTE IMMEDIATE 'alter session set NLS_DATE_FORMAT=''DD.MM.YYYY''';

   FOR l_table
      IN (SELECT    cnum
                 || ';'
                 || cost
                 || ';'
                 || '="'
                 || TRIM (numberx)
                 || '"'
                 || ';'
                 || EXPIRYDATE
                    AS metlf
            FROM v_metlife)
   LOOP
      UTL_FILE.PUT_LINE (p_file, l_table.metlf);
   END LOOP;

   OPEN v_cursor FOR
      SELECT    'resulting file for sms notifications is '
             || v_filename
             || ' in the same folder as metlife.csv file'
                AS metlf
        FROM DUAL;

   UTL_FILE.fclose_all ();

   SELECT COUNT (1) INTO v_cards_not_in_prime FROM v_metlife_bad;

   IF v_cards_not_in_prime > 0
   THEN
      SELECT    'METLIFE_ERROR_CARDS_'
             || TO_CHAR (SYSDATE, 'YYMMDDHH24MI')
             || '.csv'
        INTO v_filename
        FROM DUAL;

      p_file := UTL_FILE.fopen ('METLIFE', v_filename, 'W');

      FOR l_table
         IN (SELECT CNUM || ';' || COST || ';' || CMASK AS metlf
               FROM v_metlife_bad)
      LOOP
         UTL_FILE.PUT_LINE (p_file, l_table.metlf);
      END LOOP;

      UTL_FILE.fclose_all ();
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      OPEN v_cursor FOR
         SELECT 'Error: check if the file metlife.csv exists in V:\CSS folder'
                   AS metlf
           FROM DUAL;
END;
/