CREATE OR REPLACE PROCEDURE ROUTER_ENC.import_from_production (
   v_remote_db             VARCHAR2 DEFAULT 'ATM_DB', -- db_link to production ATM BD
   v_last_month_in_prod    VARCHAR2 DEFAULT NULL, -- value in YYYYMM format, default will be sysdate - 4 months
   v_remote_schema         VARCHAR2 DEFAULT 'ROUTER') -- name of ATM controller/monitoricg schema in  production DB
IS
   v_archive_table_rows   NUMBER;
   v_prod_table_rows      NUMBER;
   v_counter              NUMBER DEFAULT 0;
   last_month_in_prod     VARCHAR2 (6);
   v_start_time           TIMESTAMP DEFAULT SYSTIMESTAMP;
   v_exec_time            INTERVAL DAY TO SECOND (2);
   v_archive_schema       VARCHAR2 (20);
   JobHandle              NUMBER;
   job_status             VARCHAR2 (9);                -- COMPLETED or STOPPED
BEGIN
   SELECT UPPER (SYS_CONTEXT ('USERENV', 'SESSION_USER'))
     INTO v_archive_schema
     FROM DUAL;

   IF NVL (v_last_month_in_prod, last_month_in_prod) IS NULL
   THEN
      SELECT TO_CHAR (ADD_MONTHS (SYSDATE, -4), 'YYYYMM')
        INTO last_month_in_prod
        FROM DUAL;
   END IF;

   DBMS_OUTPUT.PUT_LINE (
         'work with XX'
      || NVL (v_last_month_in_prod, last_month_in_prod)
      || ' tables');
   DBMS_OUTPUT.PUT_LINE (' ');

   FOR table_cur
      IN (SELECT *
            FROM user_tables
           WHERE TABLE_NAME LIKE
                    '%' || NVL (v_last_month_in_prod, last_month_in_prod))
   LOOP
      EXECUTE IMMEDIATE
            'begin SELECT /* +PARALLEL */  COUNT (1) INTO :n from '
         || table_cur.table_name
         || '; end;'
         USING OUT v_archive_table_rows;

      EXECUTE IMMEDIATE
            'begin SELECT /* +PARALLEL */  COUNT (1) INTO :n from '
         || table_cur.table_name
         || '@'
         || v_remote_db
         || '; end;'
         USING OUT v_prod_table_rows;

      IF     v_archive_table_rows <> v_prod_table_rows
      THEN
         v_counter := v_counter + 1;

         IF v_counter <= 1
         THEN
            DBMS_OUTPUT.PUT_LINE (
               'NON empty tables with different number of rows in archive and production');
            DBMS_OUTPUT.PUT_LINE (' ');
         END IF;

         DBMS_OUTPUT.PUT_LINE (
               'TABLE '
            || table_cur.table_name
            || ' rows count in archive DB '
            || v_archive_table_rows
            || ',in production DB '
            || v_prod_table_rows);

         DBMS_OUTPUT.PUT_LINE (' ');

         DBMS_OUTPUT.PUT_LINE (
               'import table '
            || table_cur.table_name
            || ' using db_link '
            || v_remote_db);
         DBMS_OUTPUT.PUT_LINE (' ');

         JobHandle :=
            DBMS_DATAPUMP.open (operation     => 'IMPORT',
                                job_mode      => 'TABLE',
                                remote_link   => v_remote_db);

         DBMS_DATAPUMP.add_file (
            JobHandle,
            filename    => 'imp_' || table_cur.table_name,
            directory   => 'DATA_PUMP_DIR',
            filetype    => DBMS_DATAPUMP.ku$_file_type_log_file);

         DBMS_DATAPUMP.metadata_remap (handle      => JobHandle,
                                       name        => 'REMAP_SCHEMA',
                                       old_value   => v_remote_schema,
                                       VALUE       => v_archive_schema);

         DBMS_DATAPUMP.metadata_remap (handle      => JobHandle,
                                       name        => 'REMAP_TABLESPACE',
                                       old_value   => 'ANNUAL_DATAENC',
                                       VALUE       => 'ANNUAL_TABLE_ENC');

         DBMS_DATAPUMP.metadata_remap (handle      => JobHandle,
                                       name        => 'REMAP_TABLESPACE',
                                       old_value   => 'ANNUAL_INDEXENC',
                                       VALUE       => 'ANNUAL_INDEX_ENC');

         DBMS_DATAPUMP.metadata_filter (
            handle        => JobHandle,
            name          => 'NAME_EXPR',
            VALUE         => '=''' || table_cur.table_name || '''',
            object_type   => 'TABLE');

         DBMS_DATAPUMP.set_parameter (JobHandle,
                                      'TABLE_EXISTS_ACTION',
                                      'REPLACE');

         DBMS_DATAPUMP.start_job (JobHandle);

         DBMS_DATAPUMP.wait_for_job (JobHandle, job_status);
      ELSE
         IF v_archive_table_rows = 0 OR v_prod_table_rows = 0
         THEN
            v_counter := v_counter + 1;

            IF v_counter <= 1
            THEN
               DBMS_OUTPUT.PUT_LINE (
                  'NON empty tables with different number of rows in archive and production NOT FOUNDED');
               DBMS_OUTPUT.PUT_LINE (' ');
               DBMS_OUTPUT.PUT_LINE ('tables with zero rows');
               DBMS_OUTPUT.PUT_LINE (' ');
            END IF;

            DBMS_OUTPUT.PUT_LINE (
                  'TABLE '
               || table_cur.table_name
               || ' rows count in archive DB '
               || v_archive_table_rows
               || ',in production DB '
               || v_prod_table_rows);
         END IF;
      END IF;
   END LOOP;

   v_exec_time := SYSTIMESTAMP - v_start_time;

   DBMS_OUTPUT.put_line (' ');
   DBMS_OUTPUT.put_line ('procedure started at ' || v_start_time);
   DBMS_OUTPUT.put_line (
         'total execution time '
      || EXTRACT (HOUR FROM v_exec_time)
      || ' hours, '
      || EXTRACT (MINUTE FROM v_exec_time)
      || ' minutes, '
      || EXTRACT (SECOND FROM v_exec_time)
      || ' seconds ');
END;
/
