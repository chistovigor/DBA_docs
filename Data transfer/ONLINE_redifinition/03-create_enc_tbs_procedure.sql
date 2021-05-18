create or replace procedure create_tbs_scripts as

        cursor tbs_c is
        select enc_tbs_name from otr_log;

        cursor tab_c(p_tbs varchar2) is
        select table_name from tables_in_tbs where enc_tbs_name = p_tbs;

        fhnd utl_file.file_type;

BEGIN
        fhnd := utl_file.fopen('WORK','create_enc_tbs_script.sql','a');
	utl_file.put_line(fhnd, 'set timing off;',true);
        utl_file.put_line(fhnd, 'set long 100000;',true);
        utl_file.put_line(fhnd, 'set heading off;',true);
        utl_file.put_line(fhnd, 'set feedback off;',true);
        utl_file.put_line(fhnd, 'set echo off;',true);
        utl_file.put_line(fhnd, 'set pages 100;',true);
        utl_file.put_line(fhnd, 'set trimspool on;',true);
        utl_file.put_line(fhnd, 'set linesize 2500;',true);

        FOR tbs_rec in tbs_c
        LOOP
        BEGIN
        utl_file.put_line(fhnd, 'spool ./work/01-create_tbs_'||tbs_rec.enc_tbs_name||'.sql', true);
        utl_file.put_line(fhnd, 'select enc_tbs_ddl from otr_log where enc_tbs_name = '''||tbs_rec.enc_tbs_name||''';', true);
                FOR tab_rec in tab_c(tbs_rec.enc_tbs_name)
                LOOP
                BEGIN
                utl_file.put_line(fhnd, 'select int_table_ddl from tables_in_tbs where table_name = '''||tab_rec.table_name||''';',true);
                END;
                END LOOP;
        utl_file.put_line(fhnd, 'spool off',true);
        END;
        END LOOP;
utl_file.fclose(fhnd);
END create_tbs_scripts;
/
show error;

