create or replace procedure create_sync_finish_scripts as

        cursor tbs_c is
        select enc_tbs_name from otr_log where enc_tbs_name != 'PSINDEX_ENC';

        cursor tab_c(p_tbs varchar2) is
        select table_name, owner from tables_in_tbs where enc_tbs_name = p_tbs;

        fhnd utl_file.file_type;
BEGIN
        FOR tbs_rec in tbs_c
        LOOP
        BEGIN
        fhnd := utl_file.fopen('WORK','06-sync_finish_tables_in_' ||tbs_rec.enc_tbs_name || '.sql','a');

                FOR tab_rec in tab_c(tbs_rec.enc_tbs_name)
                LOOP
                BEGIN

                utl_file.put_line(fhnd, 'execute dbms_redefinition.sync_interim_table('''||tab_rec.owner||''', '''||tab_rec.table_name||''', ''INT_'||tab_rec.table_name||''')',true);
                utl_file.put_line(fhnd, 'execute dbms_redefinition.finish_redef_table('''||tab_rec.owner||''', '''||tab_rec.table_name||''', ''INT_'||tab_rec.table_name||''')',true);
                END;
                END LOOP;

        utl_file.fclose(fhnd);
        END;
        END LOOP;

END create_sync_finish_scripts;
/
show error;

