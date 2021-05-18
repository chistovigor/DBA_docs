Удаление строк из таблицы в цикле (commit каждые 100 строк)

/* Formatted on 06.02.2014 13:54:03 (QP5 v5.163.1008.3004) */
DECLARE
   max_id      NUMBER;
   v_counter   NUMBER := 0;
BEGIN
   SELECT MAX (ID)
     INTO max_id
     FROM DDDSPROC_TRANSACT_INFO_ARC
    WHERE TRUNC (TRANSDATE) < TRUNC (ADD_MONTHS (SYSDATE, -24));

   FOR i IN 1 .. ROUND (max_id / 100) + 1
   LOOP
      DELETE FROM DDDSPROC_TRANSACT_INFO_ARC
            WHERE ID < max_id AND ROWNUM < 100;
      v_counter := v_counter + SQL%ROWCOUNT;
      COMMIT;
   END LOOP;

   DBMS_OUTPUT.put_line (v_counter || ' rows deleted');
END;

Вариант для каждой строки

BEGIN
   FOR Rec_T IN (SELECT ID, ROWNUM
                   FROM DDDSPROC_TRANSACT_INFO_ARC
                  WHERE ID < (select max(ID) from DDDSPROC_TRANSACT_INFO_ARC where TRUNC(TRANSDATE) < TRUNC(ADD_MONTHS(SYSDATE, -24))))
   LOOP
      DELETE FROM DDDSPROC_TRANSACT_INFO_ARC;
      IF MOD (Rec_T.ROWNUM, 100) = 0
      THEN
         COMMIT;
      END IF;
   END LOOP;
END;