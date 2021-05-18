CREATE OR REPLACE PROCEDURE DBMAN.ATM_ALPHA_TO_SITE
AS
   v_code    NUMBER;
   v_count   NUMBER;
   v_errm    VARCHAR2 (1000);
BEGIN
   -- insert data about active ATMs to the temporary table dbman.ATM_ALPHA_TEMP
   INSERT INTO dbman.ATM_ALPHA_TEMP
      SELECT N_MRC_ATM,
             C_NATM,
             C_ATM_SER_NUM,
             C_MRC_CITY_FULL,
             C_MRC_ADDR_FULL,
             C_MRC_CMP_NAME,
             C_ATM_TYPE,
             CF_MRC_ATM_CASH_IN,
             CF_MRC_ATM_EUR,
             CF_MRC_ATM_USD,
             D_ATM_REG,
             C_ATM_LOCATION_TYPE,
             C_ATM_LOCATION_TYPE_DESC,
             C_ATM_AVAILABILITY,
             CF_ATM_AVAILABILITY,
             C_ATM_ACCESSIBILITY,
             CF_ATM_ACCESSIBILITY,
             CF_ATM_HANDICAP
        FROM v_mrc_atm MA
       WHERE MA.Cf_Mrc_Atm_Stat IN ('A');

   -- insert data about active ATMs to the remote DB (public synonym ATM_ALPHA) from temporary table dbman.ATM_ALPHA_TEMP
   INSERT INTO ATM_ALPHA (N_MRC_ATM,
                          C_NATM,
                          C_ATM_SER_NUM,
                          C_MRC_CITY_FULL,
                          C_MRC_ADDR_FULL,
                          C_MRC_CMP_NAME,
                          C_ATM_TYPE,
                          CF_MRC_ATM_CASH_IN,
                          CF_MRC_ATM_EUR,
                          CF_MRC_ATM_USD,
                          D_ATM_REG,
                          C_ATM_LOCATION_TYPE,
                          C_ATM_LOCATION_TYPE_DESC,
                          C_ATM_AVAILABILITY,
                          CF_ATM_AVAILABILITY,
                          C_ATM_ACCESSIBILITY,
                          CF_ATM_ACCESSIBILITY,
                          CF_ATM_HANDICAP)
      SELECT N_MRC_ATM,
             C_NATM,
             C_ATM_SER_NUM,
             C_MRC_CITY_FULL,
             C_MRC_ADDR_FULL,
             C_MRC_CMP_NAME,
             C_ATM_TYPE,
             CF_MRC_ATM_CASH_IN,
             CF_MRC_ATM_EUR,
             CF_MRC_ATM_USD,
             D_ATM_REG,
             C_ATM_LOCATION_TYPE,
             C_ATM_LOCATION_TYPE_DESC,
             C_ATM_AVAILABILITY,
             CF_ATM_AVAILABILITY,
             C_ATM_ACCESSIBILITY,
             CF_ATM_ACCESSIBILITY,
             CF_ATM_HANDICAP
        FROM dbman.ATM_ALPHA_TEMP;

   -- insert information about data transfer into dbman.ATM_ALPHA_TO_SITE_INSERT_LOG table
   v_count := SQL%ROWCOUNT;

   INSERT INTO dbman.ATM_ALPHA_TO_SITE_INSERT_LOG (INSERT_DATE, INSERT_ROWS)
        VALUES (SYSDATE, v_count);

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      v_code := SQLCODE;
      v_errm := SQLERRM;

      INSERT
        INTO dbman.ATM_ALPHA_TO_SITE_INSERT_LOG (INSERT_DATE, INSERT_STATUS)
      VALUES (SYSDATE, v_code || ' ' || v_errm);

      COMMIT;
END;
/