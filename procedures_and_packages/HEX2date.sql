/* Formatted on 15/01/2015 11:19:12 (QP5 v5.227.12220.39754) */
CREATE OR REPLACE FUNCTION hex_to_date (p_str IN VARCHAR2)
   RETURN TIMESTAMP
AS
BEGIN
   RETURN TO_TIMESTAMP (
                TO_CHAR (TO_NUMBER (SUBSTR (p_str, 1, 2), 'xx') - 100,
                         'fm00')
             || TO_CHAR (TO_NUMBER (SUBSTR (p_str, 3, 2), 'xx') - 100,
                         'fm00')
             || TO_CHAR (TO_NUMBER (SUBSTR (p_str, 5, 2), 'xx'), 'fm00')
             || TO_CHAR (TO_NUMBER (SUBSTR (p_str, 7, 2), 'xx'), 'fm00')
             || TO_CHAR (TO_NUMBER (SUBSTR (p_str, 10, 2), 'xx') - 1, 'fm00')
             || TO_CHAR (TO_NUMBER (SUBSTR (p_str, 12, 2), 'xx') - 1, 'fm00')
             || TO_CHAR (TO_NUMBER (SUBSTR (p_str, 14, 2), 'xx') - 1, 'fm00'),
             'yyyymmddhh24miss');
END;

SELECT hex_to_date ('786F0901 010101') FROM DUAL;