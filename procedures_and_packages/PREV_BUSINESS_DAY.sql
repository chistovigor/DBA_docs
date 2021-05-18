CREATE OR REPLACE FUNCTION ROUTER.PREV_BUSINESS_DAY (
   input_date DATE DEFAULT SYSDATE)
   RETURN DATE
IS
   prev_business_day    VARCHAR2 (15);
   prev_business_date   DATE;
BEGIN
   prev_business_day := TO_CHAR ( (input_date), 'D');
   IF prev_business_day IN ('1', '2')
   THEN
      IF prev_business_day = '1'
      THEN
         SELECT TRUNC (input_date - 2) INTO prev_business_date FROM DUAL;
      ELSE
         SELECT TRUNC (input_date - 3) INTO prev_business_date FROM DUAL;
      END IF;
   ELSE
      SELECT TRUNC (input_date - 1) INTO prev_business_date FROM DUAL;
   END IF;
RETURN prev_business_date;
END;
/
