create or replace procedure register_indexes as

        cursor tbs_c is
        select distinct enc_tbs_name from index_log;

        cursor ind_c(p_tbs varchar2) is
        select index_name, table_name, owner from index_log where enc_tbs_name = p_tbs;

        fhnd utl_file.file_type;

BEGIN
        FOR tbs_rec in tbs_c LOOP
        BEGIN
        fhnd := utl_file.fopen('WORK','04-reg_indexes_in_'||tbs_rec.enc_tbs_name||'.sql','a');
                FOR ind_rec in ind_c(tbs_rec.enc_tbs_name) LOOP
                BEGIN
		utl_file.put_line(fhnd,'exec dbms_redefinition.register_dependent_object('''||ind_rec.owner||''','''||ind_rec.table_name||''',''INT_'||ind_rec.table_name||''',dbms_redefinition.CONS_INDEX,'''||ind_rec.owner||''','''||ind_rec.index_name||''',''INT_'||ind_rec.index_name||''');',true);
		utl_file.put_line(fhnd,'',true);
                END;
                END LOOP;
	utl_file.fclose(fhnd);
        END;
        END LOOP;
END register_indexes;
/
show error;

