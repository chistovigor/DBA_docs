/* Formatted on 13/11/2014 12:42:13 (QP5 v5.227.12220.39754) */
CREATE OR REPLACE PACKAGE PACKAGE1
AS
   /******************************************************************************
        NAME:
        PURPOSE:

        REVISIONS:
        Ver        Date        Author           Description
        ---------  ----------  ---------------  ------------------------------------
        1.0                        ruacii2           1.
     ******************************************************************************/

   FUNCTION FUNC1
      RETURN VARCHAR2;

   PROCEDURE PROC1 (V_MIN_SERNO   IN NUMBER DEFAULT 0,
                    V_MAX_SERNO   IN NUMBER DEFAULT 0);
END;


/* Formatted on 13/11/2014 12:42:16 (QP5 v5.227.12220.39754) */
CREATE OR REPLACE PACKAGE BODY PACKAGE1
AS
   FUNCTION FUNC1
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN FN_WHO_AM_I (0);
   END;

   PROCEDURE PROC1 (V_MIN_SERNO   IN NUMBER DEFAULT 0,
                    V_MAX_SERNO   IN NUMBER DEFAULT 0)
   IS
      v_owner      VARCHAR2 (100);
      v_name       VARCHAR2 (100);
      v_lineno     NUMBER;
      v_caller_t   VARCHAR2 (100);
      v1           VARCHAR2 (100);
   BEGIN
      OWA_UTIL.who_called_me (v_owner,
                              v_name,
                              v_lineno,
                              v_caller_t);

      SELECT FN_WHO_AM_I (1) INTO v1 FROM DUAL;

      -- DBMS_OUTPUT.PUT_LINE (v_owner);
      --  DBMS_OUTPUT.PUT_LINE (v_name);
      DBMS_OUTPUT.PUT_LINE (v1);
   END;
END;