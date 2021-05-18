1) 

CREATE OR REPLACE DIRECTORY 
REPORTS AS 
'/mnt/oracle/temp/REPORTS';
GRANT READ, WRITE ON DIRECTORY REPORTS TO TCTDBS;


2) 

CREATE OR REPLACE FUNCTION TCTDBS.LOAD_CSV (
   p_table                IN VARCHAR2,
   p_dir                  IN VARCHAR2 DEFAULT 'REPORTS',
   P_FILENAME             IN VARCHAR2,
   p_ignore_headerlines   IN INTEGER DEFAULT 1,
   p_delimiter            IN VARCHAR2 DEFAULT ',',
   p_optional_enclosed    IN VARCHAR2 DEFAULT '"')
   RETURN NUMBER
IS
   /***************************************************************************
   -- PROCEDURE LOAD_CSV
   -- PURPOSE: This Procedure read the data from a CSV file.
   -- And load it into the target oracle table.
   -- Finally it renames the source file with date.
   --
   -- P_FILENAME
   -- The name of the flat file(a text file)
   --
   -- P_DIRECTORY
   -- Name of the directory where the file is been placed.
   -- Note: The grant has to be given for the user to the directory
   -- before executing the function
   --
   -- P_IGNORE_HEADERLINES:
   -- Pass the value as '1' to ignore importing headers.
   --
   -- P_DELIMITER
   -- By default the delimiter is used as ','
   -- As we are using CSV file to load the data into oracle
   --
   -- P_OPTIONAL_ENCLOSED
   -- By default the optionally enclosed is used as '"'
   -- As we are using CSV file to load the data into oracle
   --
   -- AUTHOR:
   -- Sloba
   -- Version 1.0
   -- Vani (bobba.vani31@gmail.com)
   -- Version 1.1
   **************************************************************************/
   l_input       UTL_FILE.file_type;
   l_theCursor   INTEGER DEFAULT DBMS_SQL.open_cursor;
   l_lastLine    VARCHAR2 (4000);
   l_cnames      VARCHAR2 (4000);
   l_bindvars    VARCHAR2 (4000);
   l_status      INTEGER;
   l_cnt         NUMBER DEFAULT 0;
   l_rowCount    NUMBER DEFAULT 0;
   l_sep         CHAR (1) DEFAULT NULL;
   L_ERRMSG      VARCHAR2 (4000);
   V_EOF         BOOLEAN := FALSE;
BEGIN
   l_cnt := 1;

   FOR TAB_COLUMNS IN (  SELECT column_name, data_type
                           FROM user_tab_columns
                          WHERE table_name = p_table
                       ORDER BY column_id)
   LOOP
      l_cnames := l_cnames || tab_columns.column_name || ',';
      l_bindvars :=
            l_bindvars
         || CASE
               WHEN tab_columns.data_type IN ('DATE', 'TIMESTAMP(6)')
               THEN
                  'to_date(:b' || l_cnt || ',"YYYY-MM-DD HH24:MI:SS"),'
               ELSE
                  ':b' || l_cnt || ','
            END;

      l_cnt := l_cnt + 1;
   END LOOP;

   l_cnames := RTRIM (l_cnames, ',');
   L_BINDVARS := RTRIM (L_BINDVARS, ',');

   L_INPUT := UTL_FILE.FOPEN (P_DIR, P_FILENAME, 'r');

   IF p_ignore_headerlines > 0
   THEN
      BEGIN
         FOR i IN 1 .. p_ignore_headerlines
         LOOP
            UTL_FILE.get_line (l_input, l_lastLine);
         END LOOP;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_eof := TRUE;
      END;
   END IF;

   IF NOT v_eof
   THEN
      DBMS_SQL.parse (
         l_theCursor,
            'insert into '
         || p_table
         || '('
         || l_cnames
         || ') values ('
         || l_bindvars
         || ')',
         DBMS_SQL.native);

      LOOP
         BEGIN
            UTL_FILE.get_line (l_input, l_lastLine);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               EXIT;
         END;

         IF LENGTH (l_lastLine) > 0
         THEN
            FOR i IN 1 .. l_cnt - 1
            LOOP
               DBMS_SQL.bind_variable (
                  l_theCursor,
                  ':b' || i,
                  RTRIM (
                     RTRIM (
                        LTRIM (LTRIM (REGEXP_SUBSTR (l_lastline,
                                                     '(^|,)("[^"]*"|[^",]*)',
                                                     1,
                                                     i),
                                      p_delimiter),
                               p_optional_enclosed),
                        p_delimiter),
                     p_optional_enclosed));
            END LOOP;

            BEGIN
               l_status := DBMS_SQL.execute (l_theCursor);
               l_rowCount := l_rowCount + 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  L_ERRMSG := SQLERRM;

                  INSERT INTO BADLOG (TABLE_NAME,
                                      ERRM,
                                      data,
                                      ERROR_DATE)
                       VALUES (P_TABLE,
                               l_errmsg,
                               l_lastLine,
                               SYSTIMESTAMP);
            END;
         END IF;
      END LOOP;

      DBMS_SQL.close_cursor (l_theCursor);
      UTL_FILE.fclose (l_input);
      COMMIT;
   END IF;

   INSERT INTO IMPORT_HIST (FILENAME,
                            TABLE_NAME,
                            NUM_OF_REC,
                            IMPORT_DATE)
        VALUES (P_FILENAME,
                P_TABLE,
                l_rowCount,
                SYSDATE);

   UTL_FILE.FRENAME (
      P_DIR,
      P_FILENAME,
      P_DIR,
      REPLACE (
         P_FILENAME,
         '.csv',
         '_' || TO_CHAR (SYSDATE, 'DD_MON_RRRR_HH24_MI_SS_AM') || '.csv'));
   COMMIT;
   RETURN L_ROWCOUNT;
END LOAD_CSV;
/


3) 

run procedure for inmpotr data from file

CREATE OR REPLACE PROCEDURE TCTDBS.visa_rr (
   p_table       VARCHAR2 DEFAULT 'TTT_RR_VISA1',
   p_filename    VARCHAR2 DEFAULT 'ROL170.csv')
   AUTHID CURRENT_USER
IS
   v_rows_inserted   NUMBER;
BEGIN
   EXECUTE IMMEDIATE 'truncate table ' || p_table;

   v_rows_inserted := LOAD_CSV (p_table => p_table, p_filename => p_filename);
   DBMS_OUTPUT.put_line (
      'number of rows inserted from CSV file = ' || v_rows_inserted);
END;
/