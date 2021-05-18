-- variant 1

CREATE OR REPLACE PACKAGE ARDB_USER.LONG_HELP1
   /*

   select partitions for the USER

   select *
   FROM TABLE(LONG_HELP1.get_all_tab_partitions('USERNAME'));

   */



   AUTHID CURRENT_USER
AS
   FUNCTION GET_ALL_TAB_PARTITIONS (VOWNER_NAME IN VARCHAR2 DEFAULT NULL)
      RETURN TOUTREC_SET;
END;
/

CREATE OR REPLACE PACKAGE BODY ARDB_USER.LONG_HELP1
AS
    /*==========================================================*/
    FUNCTION GET_ALL_TAB_PARTITIONS (VOWNER_NAME IN VARCHAR2 DEFAULT NULL)
        RETURN TOUTREC_SET
    AS
        G_CURSOR          NUMBER := DBMS_SQL.OPEN_CURSOR;
        F                 INTEGER;
        P_FROM            NUMBER := 1;
        P_FOR             NUMBER := 4000;
        P_NAME1           VARCHAR2 (5) := 'owner';
        P_QUERY           VARCHAR2 (1000)
            :=    'select TABLE_OWNER, TABLE_NAME, PARTITION_NAME, TABLESPACE_NAME, HIGH_VALUE '
               || 'from all_tab_partitions where table_owner = :owner';
        TABLE_OWNER       VARCHAR2 (100);
        TABLE_NAME        VARCHAR2 (100);
        PARTITION_NAME    VARCHAR2 (100);
        TABLESPACE_NAME   VARCHAR2 (100);
        HIGH_VALUE        VARCHAR2 (4000);
        VALUE_LEN         NUMBER;
        REC_C             TOUTREC_TYPE;
        V_RESULT          TOUTREC_SET:=TOUTREC_SET();
    BEGIN
        IF (NVL (P_FROM, 0) <= 0)
        THEN
            RAISE_APPLICATION_ERROR (-20002,
                                     'From must be >= 1 (positive numbers)');
        END IF;

        IF (NVL (P_FOR, 0) NOT BETWEEN 1 AND 4000)
        THEN
            RAISE_APPLICATION_ERROR (-20003,
                                     'For must be between 1 and 4000');
        END IF;

        IF (UPPER (TRIM (NVL (P_QUERY, 'x'))) NOT LIKE 'SELECT%')
        THEN
            RAISE_APPLICATION_ERROR (-20001, 'This must be a select only');
        END IF;

        DBMS_SQL.PARSE (G_CURSOR, P_QUERY, DBMS_SQL.NATIVE);
        DBMS_SQL.BIND_VARIABLE (G_CURSOR, P_NAME1, VOWNER_NAME);
        DBMS_SQL.DEFINE_COLUMN (G_CURSOR,
                                1,
                                TABLE_OWNER,
                                100);
        DBMS_SQL.DEFINE_COLUMN (G_CURSOR,
                                2,
                                TABLE_NAME,
                                100);
        DBMS_SQL.DEFINE_COLUMN (G_CURSOR,
                                3,
                                PARTITION_NAME,
                                100);
        DBMS_SQL.DEFINE_COLUMN (G_CURSOR,
                                4,
                                TABLESPACE_NAME,
                                100);
        DBMS_SQL.DEFINE_COLUMN_LONG (G_CURSOR, 5);
        F := DBMS_SQL.EXECUTE (G_CURSOR);

        LOOP
            IF DBMS_SQL.FETCH_ROWS (G_CURSOR) > 0
            THEN
                -- get column values of the row
                DBMS_SQL.COLUMN_VALUE (G_CURSOR, 1, TABLE_OWNER);
                DBMS_SQL.COLUMN_VALUE (G_CURSOR, 2, TABLE_NAME);
                DBMS_SQL.COLUMN_VALUE (G_CURSOR, 3, PARTITION_NAME);
                DBMS_SQL.COLUMN_VALUE (G_CURSOR, 4, TABLESPACE_NAME);
                DBMS_SQL.COLUMN_VALUE_LONG (G_CURSOR,
                                            5,
                                            P_FOR,
                                            P_FROM - 1,
                                            HIGH_VALUE,
                                            VALUE_LEN);
                REC_C:=TOUTREC_TYPE(TABLE_OWNER,TABLE_NAME,PARTITION_NAME,TABLESPACE_NAME,HIGH_VALUE,VALUE_LEN);                            
                V_RESULT.EXTEND;
                V_RESULT (V_RESULT.COUNT) := REC_C;
            ELSE
                EXIT;
            END IF;
        END LOOP;

        DBMS_SQL.CLOSE_CURSOR (G_CURSOR);
        RETURN V_RESULT;                                                   --;
    END GET_ALL_TAB_PARTITIONS;
END;
/

CREATE OR REPLACE PACKAGE ARDB_USER.LONG_HELP
   /*

   select partitions for the USER

   select *
   FROM TABLE(long_help.get_all_tab_partitions('USERNAME'));

   */



   AUTHID CURRENT_USER
AS
   TYPE TOUTREC_TYPE IS RECORD
   (
      TABLE_OWNER       VARCHAR2 (100),
      TABLE_NAME        VARCHAR2 (100),
      PARTITION_NAME    VARCHAR2 (100),
      TABLESPACE_NAME   VARCHAR2 (100),
      HIGH_VALUE        VARCHAR2 (4000),
      VALUE_LEN         NUMBER (6)
   );

   TYPE TOUTREC_SET IS TABLE OF TOUTREC_TYPE;

   FUNCTION GET_ALL_TAB_PARTITIONS (VOWNER_NAME IN VARCHAR2 DEFAULT NULL)
      RETURN TOUTREC_SET
      PIPELINED;
END;
/

-- variant 2


CREATE OR REPLACE PACKAGE BODY ARDB_USER.LONG_HELP
AS
   /*==========================================================*/
   FUNCTION GET_ALL_TAB_PARTITIONS (VOWNER_NAME IN VARCHAR2 DEFAULT NULL)
      RETURN TOUTREC_SET
      PIPELINED
   AS
      G_CURSOR          NUMBER := DBMS_SQL.OPEN_CURSOR;
      F                 INTEGER;

      P_FROM            NUMBER := 1;
      P_FOR             NUMBER := 4000;
      P_NAME1           VARCHAR2 (5) := 'owner';

      P_QUERY           VARCHAR2 (1000)
         :=    'select TABLE_OWNER, TABLE_NAME, PARTITION_NAME, TABLESPACE_NAME, HIGH_VALUE '
            || 'from all_tab_partitions where table_owner = :owner';

      TABLE_OWNER       VARCHAR2 (100);
      TABLE_NAME        VARCHAR2 (100);
      PARTITION_NAME    VARCHAR2 (100);
      TABLESPACE_NAME   VARCHAR2 (100);
      HIGH_VALUE        VARCHAR2 (4000);
      VALUE_LEN         NUMBER;

      REC_C             TOUTREC_TYPE;
   BEGIN
      IF (NVL (P_FROM, 0) <= 0)
      THEN
         RAISE_APPLICATION_ERROR (-20002,
                                  'From must be >= 1 (positive numbers)');
      END IF;

      IF (NVL (P_FOR, 0) NOT BETWEEN 1 AND 4000)
      THEN
         RAISE_APPLICATION_ERROR (-20003, 'For must be between 1 and 4000');
      END IF;

      IF (UPPER (TRIM (NVL (P_QUERY, 'x'))) NOT LIKE 'SELECT%')
      THEN
         RAISE_APPLICATION_ERROR (-20001, 'This must be a select only');
      END IF;

      DBMS_SQL.PARSE (G_CURSOR, P_QUERY, DBMS_SQL.NATIVE);
      DBMS_SQL.BIND_VARIABLE (G_CURSOR, P_NAME1, VOWNER_NAME);

      DBMS_SQL.DEFINE_COLUMN (G_CURSOR,
                              1,
                              TABLE_OWNER,
                              100);
      DBMS_SQL.DEFINE_COLUMN (G_CURSOR,
                              2,
                              TABLE_NAME,
                              100);
      DBMS_SQL.DEFINE_COLUMN (G_CURSOR,
                              3,
                              PARTITION_NAME,
                              100);
      DBMS_SQL.DEFINE_COLUMN (G_CURSOR,
                              4,
                              TABLESPACE_NAME,
                              100);
      DBMS_SQL.DEFINE_COLUMN_LONG (G_CURSOR, 5);

      F := DBMS_SQL.EXECUTE (G_CURSOR);

      LOOP
         IF DBMS_SQL.FETCH_ROWS (G_CURSOR) > 0
         THEN
            -- get column values of the row

            DBMS_SQL.COLUMN_VALUE (G_CURSOR, 1, TABLE_OWNER);
            DBMS_SQL.COLUMN_VALUE (G_CURSOR, 2, TABLE_NAME);
            DBMS_SQL.COLUMN_VALUE (G_CURSOR, 3, PARTITION_NAME);
            DBMS_SQL.COLUMN_VALUE (G_CURSOR, 4, TABLESPACE_NAME);
            DBMS_SQL.COLUMN_VALUE_LONG (G_CURSOR,
                                        5,
                                        P_FOR,
                                        P_FROM - 1,
                                        HIGH_VALUE,
                                        VALUE_LEN);

            REC_C.TABLE_OWNER := TABLE_OWNER;
            REC_C.TABLE_NAME := TABLE_NAME;
            REC_C.PARTITION_NAME := PARTITION_NAME;
            REC_C.TABLESPACE_NAME := TABLESPACE_NAME;
            REC_C.HIGH_VALUE := HIGH_VALUE;
            REC_C.VALUE_LEN := VALUE_LEN;

            PIPE ROW (REC_C);
         ELSE
            EXIT;
         END IF;
      END LOOP;

      DBMS_SQL.CLOSE_CURSOR (G_CURSOR);

      RETURN;                                                              --;
   END GET_ALL_TAB_PARTITIONS;
END;
/



