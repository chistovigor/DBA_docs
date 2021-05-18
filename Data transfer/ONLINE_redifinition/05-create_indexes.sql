create or replace procedure create_index_scripts as

        cursor tbs_c is
        select distinct enc_tbs_name from tables_in_tbs;

        fhnd utl_file.file_type;

BEGIN
        fhnd := utl_file.fopen('WORK','create_int_index_script.sql','a');
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
        utl_file.put_line(fhnd, 'spool ./work/03-create_index_for_'||tbs_rec.enc_tbs_name||'.sql',true);

        utl_file.put_line(fhnd, 'select int_index_ddl from index_log where enc_tbs_name = '''||tbs_rec.enc_tbs_name||''';',true);

        utl_file.put_line(fhnd, 'spool off',true);
        END;
        END LOOP;
utl_file.fclose(fhnd);
END create_index_scripts;
/
show error;

