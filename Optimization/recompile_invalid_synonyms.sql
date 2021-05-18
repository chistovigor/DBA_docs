/* Formatted on 06.02.2014 17:31:27 (QP5 v5.163.1008.3004) */
DECLARE
   vC_SQL   VARCHAR2 (500);
BEGIN
   FOR MANIA IN (SELECT object_name
                   FROM dba_objects
                  WHERE status = 'INVALID' AND object_type = 'SYNONYM')
   LOOP
      BEGIN
         vC_SQL := 'alter public synonym ' || MANIA.object_name || ' compile';

         EXECUTE IMMEDIATE vC_SQL;
      END;
   END LOOP;
END;
/

SELECT 'alter public synonym ' || object_name || ' compile'
  FROM dba_objects
 WHERE status = 'INVALID' AND object_type = 'SYNONYM';
