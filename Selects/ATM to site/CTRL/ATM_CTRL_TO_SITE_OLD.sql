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