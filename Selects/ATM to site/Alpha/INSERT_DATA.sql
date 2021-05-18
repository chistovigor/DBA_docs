--test

create public DATABASE LINK DBOTST1 CONNECT TO "ATM" IDENTIFIED BY "ATM_to_testCMS120056" USING 'DBOTST1';

select * from ATM_ALPHA@DBOTST1;

--prod

CREATE PUBLIC DATABASE LINK DBO
 CONNECT TO ATM
 IDENTIFIED BY ATM_to_CMS120056
 USING 'DBO';

Выбираем между test и prod, пересоздавая synonym

create or replace public synonym ATM_ALPHA for ATM_ALPHA@DBOTST1; --test 
create or replace public synonym ATM_ALPHA for ATM_ALPHA@DBO;     --prod
 
select * from ATM_ALPHA;

/* Formatted on 30.01.2014 15:54:20 (QP5 v5.163.1008.3004) */

create global temporary table dbman.ATM_ALPHA_TEMP as select N_MRC_ATM,
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
    
/* Formatted on 03.02.2014 18:43:10 (QP5 v5.163.1008.3004) */
CREATE TABLE DBMAN.ATM_ALPHA_TO_SITE_INSERT_LOG
(
   INSERT_DATE     DATE NOT NULL,
   INSERT_STATUS   VARCHAR2 (1000) DEFAULT 'SUCCESS'
)
TABLESPACE AF_DATA
LOGGING
NOCOMPRESS
NOCACHE
NOPARALLEL
NOMONITORING;
    
 /* Formatted on 03.02.2014 17:53:00 (QP5 v5.163.1008.3004) */
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
    
select * FROM dbman.ATM_ALPHA_TEMP;

/* Formatted on 30.01.2014 17:28:06 (QP5 v5.163.1008.3004) */
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
     
commit;

rollback;

select * from ATM_ALPHA;

delete from ATM_ALPHA;

/* Formatted on 03.02.2014 17:53:27 (QP5 v5.163.1008.3004) */
  SELECT TO_NUMBER (SUBSTR (C_NATM,
                            1,
                            INSTR (C_NATM,
                                   '(',
                                   1,
                                   1)
                            - 1))
            AS C_NATM
    FROM ATM_ALPHA
--where C_NATM like '%(%'
ORDER BY 1;
  
/* Formatted on 30.01.2014 17:57:18 (QP5 v5.163.1008.3004) */
  SELECT TO_NUMBER (NVL ( (SUBSTR (C_NATM,
                                   1,
                                   INSTR (C_NATM,
                                          '(',
                                          1,
                                          1)
                                   - 1)),
                         TO_CHAR (C_NATM)))
            AS C_NATM
    FROM ATM_ALPHA
ORDER BY 1;
  
  select C_NATM from ATM_ALPHA;
     
commit;

Табличка изменений в записях о банкоматах

select * from dbman.MRC_ATM_CHANGE_LOG where D_INS > sysdate - 1;


/* Formatted on 03.02.2014 19:06:31 (QP5 v5.163.1008.3004) */
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


exec DBMAN.ATM_ALPHA_TO_SITE;

select * from DBMAN.ATM_ALPHA_TO_SITE_INSERT_LOG order by 1 desc;

select * from ATM_ALPHA;

select * FROM dbman.ATM_ALPHA_TEMP;


BEGIN
sys.dbms_scheduler.create_job( 
job_name => '"DBMAN"."ATM_ALPHA_TO_SITE_job"',
job_type => 'PLSQL_BLOCK',
job_action => 'begin
 ATM_ALPHA_TO_SITE;
end;',
repeat_interval => 'FREQ=DAILY;BYHOUR=1;BYMINUTE=0;BYSECOND=0',
start_date => systimestamp at time zone 'Europe/Moscow',
job_class => 'DEFAULT_JOB_CLASS',
comments => 'daily insert data about active ATMs to the remote DB using db link DBO',
auto_drop => FALSE,
enabled => FALSE);
sys.dbms_scheduler.set_attribute( name => '"DBMAN"."ATM_ALPHA_TO_SITE"', attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_FULL); 
sys.dbms_scheduler.enable( '"DBMAN"."ATM_ALPHA_TO_SITE"' ); 
END;
    