/* Formatted on 27/02/2014 13:02:05 (QP5 v5.227.12220.39754) */
CREATE OR REPLACE PROCEDURE ADD_DROP_PARTITION (
   V_USER       VARCHAR2 DEFAULT 'TCTDBS',
   V_TABLE      VARCHAR2 DEFAULT 'AUTHORIZATIONS',
   DAYS_KEEP    NUMBER DEFAULT 1200)
IS
   add_partition    VARCHAR2 (500);
   drop_partition   VARCHAR2 (500);
BEGIN
   DBMS_OUTPUT.enable;

   SELECT    'ALTER TABLE '
          || table_name
          || ' ADD PARTITION '
          || SUBSTR (PARTITION_NAME, 0, 16)
          || (TO_NUMBER (SUBSTR (PARTITION_NAME, 17)) + 1)
          || ' values less than  (TIMESTAMP'' '
          || TO_CHAR (
                ADD_MONTHS (
                   TO_DATE ( (SUBSTR (high_value, 11, 20)),
                            'YYYY-MM-DD HH24:MI:SS'),
                   3),
                'YYYY-MM-DD')
          || ' 00:00:00'') LOGGING NOCOMPRESS'
     INTO add_partition
     FROM TABLE (long_help.get_all_tab_partitions (V_USER))
    WHERE     table_name = V_TABLE
          AND TO_NUMBER (SUBSTR (PARTITION_NAME, 17)) =
                 (SELECT MAX (TO_NUMBER (SUBSTR (PARTITION_NAME, 17)))
                    FROM TABLE (long_help.get_all_tab_partitions (V_USER))
                   WHERE table_name = V_TABLE)
          AND TO_DATE ( (SUBSTR (high_value, 11, 20)),
                       'YYYY-MM-DD HH24:MI:SS') >= SYSDATE;

   SELECT    'ALTER TABLE '
          || table_name
          || ' DROP PARTITION '
          || PARTITION_NAME
          || ' UPDATE GLOBAL INDEXES PARALLEL 3'
     INTO drop_partition
     FROM TABLE (long_help.get_all_tab_partitions (V_USER))
    WHERE     table_name = V_TABLE
          AND TO_NUMBER (SUBSTR (PARTITION_NAME, 17)) =
                 (SELECT MIN (TO_NUMBER (SUBSTR (PARTITION_NAME, 17)))
                    FROM TABLE (long_help.get_all_tab_partitions (V_USER))
                   WHERE table_name = V_TABLE)
          AND TO_DATE ( (SUBSTR (high_value, 11, 20)),
                       'YYYY-MM-DD HH24:MI:SS') < SYSDATE - DAYS_KEEP;

   DBMS_OUTPUT.put_line ('adding new partition');
   DBMS_OUTPUT.put_line (add_partition || ';');
   execute immediate add_partition;
   DBMS_OUTPUT.put_line ('dropping old partition');
   DBMS_OUTPUT.put_line (drop_partition || ';');
   execute immediate drop_partition;
END;
/