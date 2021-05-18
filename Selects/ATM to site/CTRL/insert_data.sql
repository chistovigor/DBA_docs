--test

create public DATABASE LINK DBOTST1 CONNECT TO "ATM" IDENTIFIED BY "ATM_to_testCMS120056" USING 'DBOTST1';

select * from ATM_CTRL@DBOTST1;

--prod

CREATE PUBLIC DATABASE LINK DBO
 CONNECT TO ATM
 IDENTIFIED BY ATM_to_CMS120056
 USING 'DBO';

Выбираем между test и prod, пересоздавая synonym

create or replace public synonym ATM_CTRL for ATM_CTRL@DBOTST1; --test 
create or replace public synonym ATM_CTRL for ATM_CTRL@DBO;     --prod

select * from ATM_CTRL;

CREATE TABLE ATM_CTRL_TO_SITE_INSERT_LOG
(
   INSERT_DATE     DATE NOT NULL,
   INSERT_ROWS     NUMBER,
   INSERT_STATUS   VARCHAR2 (1000) DEFAULT 'SUCCESS'
)
TABLESPACE ANNUAL_TABLE
LOGGING
NOCOMPRESS;

-- процедура для вставки значений

/* Formatted on 05/03/2014 13:12:16 (QP5 v5.227.12220.39754) */
CREATE OR REPLACE PROCEDURE ATM_CTRL_TO_SITE
AS
   v_code    NUMBER;
   v_count   NUMBER;
   v_errm    VARCHAR2 (1000);
BEGIN
   -- insert data about active ATMs to the remote DB (public synonym ATM_CTRL)
   -- from router tables (amattr,objlist,obj2ip)

   INSERT INTO ATM_CTRL (C_NATM_CTRL)
      SELECT DISTINCT TO_NUMBER (SUBSTR (szname,
                                         1,
                                           INSTR (szname,
                                                  ' ',
                                                  1,
                                                  1)
                                         - 1))
                         AS C_NATM_CTRL
        FROM (SELECT DISTINCT robj, szname
                FROM objlist
               WHERE ltag = 100
              MINUS
              SELECT DISTINCT robj, szname
                FROM objlist
               WHERE robj IN
                        (SELECT ratm
                           FROM amattr
                          WHERE    (    robj = 4113
                                    AND lindex = 26
                                    AND rvalue = 0)
                                OR (robj = 4102 AND rvalue = 1))
              INTERSECT
              SELECT DISTINCT b.ROBJ, b.szname
                FROM obj2ip a, objlist b
               WHERE     a.lstatus = 1
                     AND a.ROBJ = b.ROBJ
                     AND LOWER (b.szname) NOT LIKE '%блокирован%'
                     AND b.szname NOT IN ('NDC', 'DDC'));

   -- insert information about data transfer into router.ATM_CTRL_TO_SITE_INSERT_LOG table
   v_count := SQL%ROWCOUNT;

   INSERT INTO ATM_CTRL_TO_SITE_INSERT_LOG (INSERT_DATE, INSERT_ROWS)
        VALUES (SYSDATE, v_count);

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      v_code := SQLCODE;
      v_errm := SQLERRM;

      INSERT INTO ATM_CTRL_TO_SITE_INSERT_LOG (INSERT_DATE, INSERT_STATUS)
           VALUES (SYSDATE, v_code || ' ' || v_errm);

      COMMIT;
END;
/

-- проверка работы процедуры

SELECT * FROM ATM_CTRL;

SELECT * FROM ATM_CTRL_TO_SITE_INSERT_LOG;

EXEC ATM_CTRL_TO_SITE;

SELECT INSERT_DATE, INSERT_STATUS
  FROM ATM_CTRL_TO_SITE_INSERT_LOG
 WHERE INSERT_DATE > SYSDATE - 1 / 24 AND INSERT_STATUS = 'SUCCESS'