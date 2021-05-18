CREATE TABLE NEW_YEAR_PARTITIONS_LOG
(
  START_TIME   TIMESTAMP(3),
  ACTION       VARCHAR2(1000 BYTE),
  STATUS       VARCHAR2(1000 BYTE)              DEFAULT 'SUCCESS',
  STEP_NUMBER  NUMBER,
  DETAILS      VARCHAR2(4000 BYTE)
);



CREATE OR REPLACE PROCEDURE DBMAN.NEW_YEAR_PARTITIONS (
   run_mode VARCHAR2 DEFAULT 'script')
IS
   v_n_trx                 NUMBER;
   v_new_part_name         VARCHAR2 (20);
   v_old_part_name         VARCHAR2 (10);
   sql_table               VARCHAR2 (2000);
   sql_index               VARCHAR2 (2000);
   v_high_date             VARCHAR2 (2000);
   v_arc_tablespace_tbl    VARCHAR2 (20);
   v_arc_tablespace_indx   VARCHAR2 (20);
   v_user                  VARCHAR2 (20) DEFAULT 'DBMAN';
   V_STEPS_PROCESSED       NUMBER DEFAULT 0;
   v_errm                  VARCHAR2 (1000);
   v_code                  NUMBER;
   v_start_time            TIMESTAMP DEFAULT SYSTIMESTAMP;
   v_exec_time             INTERVAL DAY TO SECOND (2);
BEGIN
   DBMS_OUTPUT.enable (BUFFER_SIZE => 10000000);

   IF run_mode IN ('script', 'create_partitions')
   THEN
      IF run_mode = 'create_partitions'
      THEN
         DBMS_OUTPUT.put_line (
               'PROMPT *** INPUT parameter '
            || run_mode
            || ': create new year partitions ***');
      ELSE
         DBMS_OUTPUT.put_line (
               'PROMPT *** INPUT parameter '
            || run_mode
            || ' or no input parameter given: generate script for create new year partitions ***');
      END IF;

      DBMS_OUTPUT.put_line (' ');

      SELECT 'Y_' || TO_CHAR (LAST_DAY (SYSDATE) + 1, 'YYYY')
        INTO v_new_part_name
        FROM DUAL;

      SELECT 'Y_' || TO_CHAR (LAST_DAY (SYSDATE), 'YYYY')
        INTO v_old_part_name
        FROM DUAL;

      SELECT MAX (n_trx)
        INTO v_n_trx
        FROM dbman.trx
       -- in test database n_trx less than in prod (depends from the time of test DB creation)
       WHERE     d_trx_orig <
                    (SELECT TO_DATE (
                               TO_CHAR (LAST_DAY (SYSDATE) + 1, 'DD-MM-YYYY'),
                               'dd.mm.yyyy')
                       FROM DUAL)
             AND d_trx_orig >=
                    (SELECT TO_DATE (
                               TO_CHAR (LAST_DAY (SYSDATE)  - 7, 'DD-MM-YYYY'),
                               'dd.mm.yyyy')
                       FROM DUAL);


      SELECT TO_CHAR (
                   '(TO_DATE('' '
                || TO_NUMBER (TO_CHAR (LAST_DAY (SYSDATE), 'YYYY') + 2)
                || '-01-01 00:00:00'', ''YYYY-MM-DD HH24:MI:SS''))')
        INTO v_high_date
        FROM DUAL;

      DBMS_OUTPUT.put_line (
            'PROMPT *** MOVE and COMPRESS table partitions of '
         || v_user
         || ' schema for partitions with NUMBER high value  ***');
      DBMS_OUTPUT.put_line (' ');

      SELECT DISTINCT TABLESPACE_NAME
        INTO v_arc_tablespace_tbl
        FROM all_tab_partitions
       WHERE     table_owner = v_user
             AND TABLESPACE_NAME NOT IN
                    (SELECT TABLESPACE_NAME
                       FROM all_tab_partitions
                      WHERE     table_owner = v_user
                            AND PARTITION_NAME = v_old_part_name);

      SELECT TABLESPACE_NAME
        INTO v_arc_tablespace_indx
        FROM (  SELECT COUNT (1), TABLESPACE_NAME
                  FROM ALL_IND_PARTITIONS
                 WHERE index_owner = v_user
              GROUP BY TABLESPACE_NAME
              ORDER BY 1 DESC)
       WHERE ROWNUM = 1;

      FOR rec
         IN (SELECT *
               FROM all_tab_partitions
              WHERE     table_owner = v_user
                    AND HIGH_VALUE_LENGTH < 15
                    AND PARTITION_NAME = v_old_part_name)
      LOOP
         sql_table :=
               'ALTER TABLE '
            || rec.TABLE_OWNER
            || '.'
            || rec.TABLE_NAME
            || ' SPLIT PARTITION '
            || rec.PARTITION_NAME
            || ' AT ('
            || v_n_trx
            || ') INTO ( PARTITION '
            || v_old_part_name
            || ' PCTFREE 1 PCTUSED 80 TABLESPACE '
            || v_arc_tablespace_tbl
            || ' COMPRESS, PARTITION '
            || v_new_part_name
            || ' TABLESPACE '
            || rec.TABLESPACE_NAME
            || ')';

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_table || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_table;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_table,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;

         sql_table :=
               'ALTER TABLE '
            || rec.TABLE_OWNER
            || '.'
            || rec.TABLE_NAME
            || ' MOVE PARTITION '
            || rec.PARTITION_NAME
            || ' COMPRESS ';

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_table || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_table;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_table,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      DBMS_OUTPUT.put_line (' ');

      DBMS_OUTPUT.put_line (
            'PROMPT *** MOVE and COMPRESS index partitions of '
         || v_user
         || ' schema for partitions with NUMBER high value ***');
      DBMS_OUTPUT.put_line (' ');

      FOR rec
         IN (SELECT *
               FROM ALL_IND_PARTITIONS
              WHERE     index_name IN
                           (SELECT INDEX_NAME
                              FROM all_indexes
                             WHERE table_name IN
                                      (SELECT table_name
                                         FROM all_tab_partitions
                                        WHERE     table_owner = v_user
                                              AND HIGH_VALUE_LENGTH < 15
                                              AND PARTITION_NAME =
                                                     v_old_part_name))
                    AND PARTITION_NAME = v_old_part_name)
      LOOP
         sql_index :=
               'ALTER INDEX '
            || rec.INDEX_OWNER
            || '.'
            || rec.INDEX_NAME
            || ' REBUILD PARTITION '
            || v_old_part_name
            || ' TABLESPACE '
            || v_arc_tablespace_indx;

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_index || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_index;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_index,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;

         sql_index :=
               'ALTER INDEX '
            || rec.INDEX_OWNER
            || '.'
            || rec.INDEX_NAME
            || ' REBUILD PARTITION '
            || v_new_part_name
            || ' TABLESPACE '
            || rec.TABLESPACE_NAME;

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_index || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_index;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_index,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      FOR rec
         IN (SELECT *
               FROM all_tab_partitions
              WHERE     table_owner = v_user
                    AND HIGH_VALUE_LENGTH < 15
                    AND PARTITION_NAME = v_old_part_name)
      LOOP
         sql_table :=
               'ALTER TABLE '
            || rec.TABLE_OWNER
            || '.'
            || rec.TABLE_NAME
            || ' MODIFY PARTITION '
            || v_old_part_name
            || ' REBUILD UNUSABLE LOCAL INDEXES ';

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_table || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_table;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_table,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;

         sql_table :=
               'ALTER TABLE '
            || rec.TABLE_OWNER
            || '.'
            || rec.TABLE_NAME
            || ' MODIFY PARTITION '
            || v_new_part_name
            || ' REBUILD UNUSABLE LOCAL INDEXES ';

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_table || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_table;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_table,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      DBMS_OUTPUT.put_line (' ');
      DBMS_OUTPUT.put_line (
            'PROMPT *** MOVE and COMPRESS table partitions of '
         || v_user
         || ' schema for partitions with DATE high value ***');
      DBMS_OUTPUT.put_line (' ');

      FOR rec
         IN (SELECT *
               FROM all_tab_partitions
              WHERE     table_owner = v_user
                    AND HIGH_VALUE_LENGTH = 83
                    AND PARTITION_NAME = v_old_part_name)
      LOOP
         sql_table :=
               'ALTER TABLE '
            || rec.TABLE_OWNER
            || '.'
            || rec.TABLE_NAME
            || ' MOVE PARTITION '
            || v_old_part_name
            || ' TABLESPACE '
            || v_arc_tablespace_tbl
            || ' COMPRESS ';

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_table || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_table;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_table,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;

         sql_table :=
               'ALTER TABLE '
            || rec.TABLE_OWNER
            || '.'
            || rec.TABLE_NAME
            || ' ADD PARTITION '
            || v_new_part_name
            || ' VALUES LESS THAN '
            || v_high_date
            || ' LOGGING NOCOMPRESS TABLESPACE '
            || rec.TABLESPACE_NAME;

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_table || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_table;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_table,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      DBMS_OUTPUT.put_line (' ');

      DBMS_OUTPUT.put_line (
            'PROMPT *** MOVE and COMPRESS index partitions of '
         || v_user
         || ' schema for partitions with DATE high value ***');

      DBMS_OUTPUT.put_line (' ');

      FOR rec
         IN (SELECT *
               FROM ALL_IND_PARTITIONS
              WHERE     index_name IN
                           (SELECT INDEX_NAME
                              FROM all_indexes
                             WHERE table_name IN
                                      (SELECT table_name
                                         FROM all_tab_partitions
                                        WHERE     table_owner = v_user
                                              AND HIGH_VALUE_LENGTH = 83
                                              AND PARTITION_NAME =
                                                     v_old_part_name))
                    AND PARTITION_NAME = v_old_part_name)
      LOOP
         sql_index :=
               'ALTER INDEX '
            || rec.INDEX_OWNER
            || '.'
            || rec.INDEX_NAME
            || ' REBUILD PARTITION '
            || v_old_part_name
            || ' TABLESPACE '
            || v_arc_tablespace_indx;

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_index || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_index;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_index,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;

         sql_index :=
               'ALTER INDEX '
            || rec.INDEX_OWNER
            || '.'
            || rec.INDEX_NAME
            || ' REBUILD PARTITION '
            || v_new_part_name
            || ' TABLESPACE '
            || rec.TABLESPACE_NAME;

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_index || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_index;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_index,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      FOR rec
         IN (SELECT *
               FROM all_tab_partitions
              WHERE     table_owner = v_user
                    AND HIGH_VALUE_LENGTH = 15
                    AND PARTITION_NAME = v_old_part_name)
      LOOP
         sql_table :=
               'ALTER TABLE '
            || rec.TABLE_OWNER
            || '.'
            || rec.TABLE_NAME
            || ' MODIFY PARTITION '
            || v_old_part_name
            || ' REBUILD UNUSABLE LOCAL INDEXES ';

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_table || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_table;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_table,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;

         sql_table :=
               'ALTER TABLE '
            || rec.TABLE_OWNER
            || '.'
            || rec.TABLE_NAME
            || ' MODIFY PARTITION '
            || v_new_part_name
            || ' REBUILD UNUSABLE LOCAL INDEXES ';

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_table || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_table;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_table,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      FOR rec
         IN (SELECT *
               FROM all_indexes
              WHERE     table_name IN
                           (SELECT table_name
                              FROM all_tab_partitions
                             WHERE     table_owner = v_user
                                   AND HIGH_VALUE_LENGTH = 83
                                   AND PARTITION_NAME = v_old_part_name)
                    AND TABLESPACE_NAME IS NOT NULL)
      LOOP
         sql_table :=
               'ALTER INDEX '
            || rec.TABLE_OWNER
            || '.'
            || rec.INDEX_NAME
            || ' REBUILD TABLESPACE '
            || rec.TABLESPACE_NAME;

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_table || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_table;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_table,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      DBMS_OUTPUT.put_line (' ');

      DBMS_OUTPUT.put_line (
            'PROMPT *** REBUILD unusable INDEX PARTITIONS in '
         || v_user
         || ' schema ***');

      DBMS_OUTPUT.put_line (' ');

      FOR rec IN (SELECT *
                    FROM ALL_IND_PARTITIONS
                   WHERE INDEX_OWNER = v_user AND STATUS != 'USABLE')
      LOOP
         sql_index :=
               'ALTER INDEX '
            || rec.INDEX_OWNER
            || '.'
            || rec.INDEX_NAME
            || ' REBUILD PARTITION '
            || rec.PARTITION_NAME
            || ' PARALLEL';

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_index || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_index;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_index,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      DBMS_OUTPUT.put_line (' ');

      DBMS_OUTPUT.put_line (
         'PROMPT *** REBUILD invalid INDEXES in ' || v_user || ' schema ***');

      DBMS_OUTPUT.put_line (' ');

      FOR rec
         IN (SELECT *
               FROM user_indexes
              WHERE TABLE_OWNER = v_user AND status NOT IN ('VALID', 'N/A'))
      LOOP
         sql_index :=
               'ALTER INDEX '
            || rec.TABLE_OWNER
            || '.'
            || rec.INDEX_NAME
            || ' REBUILD PARALLEL ';

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_index || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_index;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_index,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      v_user := 'ALTAIR';

      DBMS_OUTPUT.put_line (' ');

      DBMS_OUTPUT.put_line (
            'PROMPT *** MOVE and COMPRESS table partitions of '
         || v_user
         || ' schema for partitions with NUMBER high value ***');

      DBMS_OUTPUT.put_line (' ');

      SELECT DISTINCT TABLESPACE_NAME
        INTO v_arc_tablespace_tbl
        FROM all_tab_partitions
       WHERE     table_owner = v_user
             AND TABLESPACE_NAME NOT IN
                    (SELECT TABLESPACE_NAME
                       FROM all_tab_partitions
                      WHERE     table_owner = v_user
                            AND PARTITION_NAME = v_old_part_name);

      SELECT TABLESPACE_NAME
        INTO v_arc_tablespace_indx
        FROM (  SELECT COUNT (1), TABLESPACE_NAME
                  FROM ALL_IND_PARTITIONS
                 WHERE index_owner = v_user
              GROUP BY TABLESPACE_NAME
              ORDER BY 1 DESC)
       WHERE ROWNUM = 1;

      SELECT TO_CHAR (
                   '(2'
                || TO_NUMBER (TO_CHAR (LAST_DAY (SYSDATE), 'Y') + 1)
                || '999999999)')
        INTO v_high_date
        FROM DUAL;

      FOR rec
         IN (SELECT *
               FROM all_tab_partitions
              WHERE     table_owner = v_user
                    AND HIGH_VALUE_LENGTH < 15
                    AND PARTITION_NAME = v_old_part_name)
      LOOP
         sql_table :=
               'ALTER TABLE '
            || rec.TABLE_OWNER
            || '.'
            || rec.TABLE_NAME
            || ' MOVE PARTITION '
            || v_old_part_name
            || ' TABLESPACE '
            || v_arc_tablespace_tbl;

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_table || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_table;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_table,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;

         sql_table :=
               'ALTER TABLE '
            || rec.TABLE_OWNER
            || '.'
            || rec.TABLE_NAME
            || ' ADD PARTITION '
            || v_new_part_name
            || ' VALUES LESS THAN '
            || v_high_date
            || ' LOGGING NOCOMPRESS TABLESPACE '
            || rec.TABLESPACE_NAME;

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_table || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_table;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_table,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      DBMS_OUTPUT.put_line (' ');

      DBMS_OUTPUT.put_line (
            'PROMPT *** MOVE and COMPRESS index partitions of '
         || v_user
         || ' schema for partitions with NUMBER high value ***');

      DBMS_OUTPUT.put_line (' ');

      FOR rec
         IN (SELECT *
               FROM ALL_IND_PARTITIONS
              WHERE     index_name IN
                           (SELECT INDEX_NAME
                              FROM all_indexes
                             WHERE table_name IN
                                      (SELECT table_name
                                         FROM all_tab_partitions
                                        WHERE     table_owner = v_user
                                              AND HIGH_VALUE_LENGTH < 15
                                              AND PARTITION_NAME =
                                                     v_old_part_name))
                    AND PARTITION_NAME = v_old_part_name)
      LOOP
         sql_index :=
               'ALTER INDEX '
            || rec.INDEX_OWNER
            || '.'
            || rec.INDEX_NAME
            || ' REBUILD PARTITION '
            || v_old_part_name
            || ' TABLESPACE '
            || v_arc_tablespace_indx;

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_index || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_index;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_index,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;

         sql_index :=
               'ALTER INDEX '
            || rec.INDEX_OWNER
            || '.'
            || rec.INDEX_NAME
            || ' REBUILD PARTITION '
            || v_new_part_name
            || ' TABLESPACE '
            || rec.TABLESPACE_NAME;

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_index || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_index;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_index,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      FOR rec
         IN (SELECT *
               FROM all_tab_partitions
              WHERE     table_owner = v_user
                    AND HIGH_VALUE_LENGTH < 15
                    AND PARTITION_NAME = v_old_part_name)
      LOOP
         sql_table :=
               'ALTER TABLE '
            || rec.TABLE_OWNER
            || '.'
            || rec.TABLE_NAME
            || ' MODIFY PARTITION '
            || v_old_part_name
            || ' REBUILD UNUSABLE LOCAL INDEXES ';

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_table || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_table;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_table,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;

         sql_table :=
               'ALTER TABLE '
            || rec.TABLE_OWNER
            || '.'
            || rec.TABLE_NAME
            || ' MODIFY PARTITION '
            || v_new_part_name
            || ' REBUILD UNUSABLE LOCAL INDEXES ';

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_table || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_table;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_table,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      FOR rec
         IN (SELECT *
               FROM all_indexes
              WHERE     table_name IN
                           (SELECT table_name
                              FROM all_tab_partitions
                             WHERE     table_owner = v_user
                                   AND HIGH_VALUE_LENGTH < 15
                                   AND PARTITION_NAME = v_old_part_name)
                    AND TABLESPACE_NAME IS NOT NULL)
      LOOP
         sql_table :=
               'ALTER INDEX '
            || rec.TABLE_OWNER
            || '.'
            || rec.INDEX_NAME
            || ' REBUILD TABLESPACE '
            || rec.TABLESPACE_NAME;

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_table || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_table;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_table,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      DBMS_OUTPUT.put_line (' ');

      DBMS_OUTPUT.put_line (
            'PROMPT *** REBUILD unusable INDEX PARTITIONS in '
         || v_user
         || ' schema ***');

      DBMS_OUTPUT.put_line (' ');

      FOR rec IN (SELECT *
                    FROM ALL_IND_PARTITIONS
                   WHERE INDEX_OWNER = v_user AND STATUS != 'USABLE')
      LOOP
         sql_index :=
               'ALTER INDEX '
            || rec.INDEX_OWNER
            || '.'
            || rec.INDEX_NAME
            || ' REBUILD PARTITION '
            || rec.PARTITION_NAME
            || ' PARALLEL';

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_index || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_index;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_index,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      DBMS_OUTPUT.put_line (' ');

      DBMS_OUTPUT.put_line (
         'PROMPT *** REBUILD invalid INDEXES in ' || v_user || ' schema ***');

      DBMS_OUTPUT.put_line (' ');

      FOR rec
         IN (SELECT *
               FROM user_indexes
              WHERE TABLE_OWNER = v_user AND status NOT IN ('VALID', 'N/A'))
      LOOP
         sql_index :=
               'ALTER INDEX '
            || rec.TABLE_OWNER
            || '.'
            || rec.INDEX_NAME
            || ' REBUILD PARALLEL ';

         IF run_mode IN ('script', 'create_partitions')
         THEN
            DBMS_OUTPUT.put_line (sql_index || ';');

            IF run_mode = 'create_partitions'
            THEN
               v_start_time := SYSTIMESTAMP;

               EXECUTE IMMEDIATE sql_index;

               V_STEPS_PROCESSED := V_STEPS_PROCESSED + 1;
               v_exec_time := SYSTIMESTAMP - v_start_time;

               INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                                    ACTION,
                                                    STEP_NUMBER,
                                                    DETAILS)
                    VALUES (
                              v_start_time,
                              sql_index,
                              V_STEPS_PROCESSED,
                                 'step started at '
                              || v_start_time
                              || '. Step execution time: '
                              || EXTRACT (HOUR FROM v_exec_time)
                              || ' hours, '
                              || EXTRACT (MINUTE FROM v_exec_time)
                              || ' minutes, '
                              || EXTRACT (SECOND FROM v_exec_time)
                              || ' seconds ');

               COMMIT;
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      DBMS_OUTPUT.put_line (' ');
      DBMS_OUTPUT.put_line (
         'PROMPT *** CHECK FOR VALIDITY OF ALL INDEXES and all INDEX PARTITIONS on the tables with new year partitions after the script execution, REBUILD IF INVALIDATED *** ');
   ELSE
      DBMS_OUTPUT.put_line (
         'run procedure with no input parameter or ''script'' input parameter to GENERATE partition script OR run procedure with ''create_partitions'' input parameter to EXECUTE partition script');
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      v_start_time := SYSTIMESTAMP;
      v_code := SQLCODE;
      v_errm := SQLERRM;

      INSERT INTO NEW_YEAR_PARTITIONS_LOG (START_TIME,
                                           ACTION,
                                           STEP_NUMBER,
                                           STATUS,
                                           DETAILS)
           VALUES (
                     v_start_time,
                        ' last table statement is: '
                     || sql_table
                     || ', last index statement is: '
                     || sql_index,
                     V_STEPS_PROCESSED,
                     v_code || ' ' || v_errm,
                     'last step started at ' || v_start_time);

      COMMIT;
      raise_application_error (
         -20001,
         'An error has occurred during report run. Check NEW_YEAR_PARTITIONS_LOG table for details');
END;
/
