DECLARE
   V_TABLE    VARCHAR2 (30) DEFAULT 'DELIVERY_REPORT';
   V_CURSOR   PLS_INTEGER := DBMS_SQL.OPEN_CURSOR;
   V_RESULT   NUMBER;
BEGIN
   FOR REC_TAB IN (SELECT OWNER, TABLE_NAME
                     FROM ALL_TABLES
                    WHERE TABLE_NAME = V_TABLE)
   LOOP
      DBMS_SQL.PARSE (
         V_CURSOR,
            'ALTER TABLE '
         || REC_TAB.OWNER
         || '.'
         || REC_TAB.TABLE_NAME
         || ' MOVE',
         DBMS_SQL.NATIVE);
      V_RESULT := DBMS_SQL.EXECUTE (V_CURSOR);

      FOR REC_IND IN (SELECT OWNER, INDEX_NAME
                        FROM ALL_INDEXES
                       WHERE TABLE_NAME = REC_TAB.TABLE_NAME)
      LOOP
         DBMS_SQL.PARSE (
            V_CURSOR,
               'ALTER INDEX '
            || REC_IND.OWNER
            || '.'
            || REC_IND.INDEX_NAME
            || ' REBUILD ',
            DBMS_SQL.NATIVE);
         V_RESULT := DBMS_SQL.EXECUTE (V_CURSOR);
      END LOOP;
   END LOOP;

   DBMS_SQL.CLOSE_CURSOR (V_CURSOR);
END;

SELECT DBMS_SQL.LAST_SQL_FUNCTION_CODE FROM DUAL;