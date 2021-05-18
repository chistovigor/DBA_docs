CREATE OR REPLACE PROCEDURE create_copy_deps_scripts
AS
   CURSOR tbs_c
   IS
      SELECT enc_tbs_name FROM otr_log;

   CURSOR tab_c (p_tbs VARCHAR2)
   IS
      SELECT table_name
        FROM tables_in_tbs
       WHERE enc_tbs_name = p_tbs;

   fhnd       UTL_FILE.file_type;
   gen_code   VARCHAR2 (4000);
   num_err    PLS_INTEGER;
BEGIN
   FOR tbs_rec IN tbs_c
   LOOP
      fhnd :=
         UTL_FILE.fopen (
            'WORK',
            '04-copy_deps_in_' || tbs_rec.enc_tbs_name || '.sql',
            'a');
      gen_code := 'declare num_err pls_integer; begin';
      UTL_FILE.put_line (fhnd, gen_code, TRUE);

      FOR tab_rec IN tab_c (tbs_rec.enc_tbs_name)
      LOOP
         gen_code :=
               'dbms_redefinition.copy_table_dependents (''SYSADM'','''
            || tab_rec.table_name
            || ''', ''INT_'
            || tab_rec.table_name
            || ''', 0, true, false, true, true, num_err, true, false);';
         UTL_FILE.put_line (fhnd, gen_code, TRUE);
         UTL_FILE.put_line (fhnd, '', TRUE);
      END LOOP;

      gen_code := 'end;';
      UTL_FILE.put_line (fhnd, gen_code, TRUE);
      UTL_FILE.put_line (fhnd, '/', TRUE);
      UTL_FILE.fclose (fhnd);
   END LOOP;
END create_copy_deps_scripts;
/