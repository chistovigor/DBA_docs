create or replace procedure replace_CT_with_ENC as
        cursor tbs_c is
        select distinct tbs_name from tables_in_tbs where has_lob='YES';

        cursor tab_c(p_tbs varchar2) is
        select table_name from tables_in_tbs where tbs_name=p_tbs and has_lob='YES';

BEGIN
        FOR tbs_rec in tbs_c
        LOOP
        BEGIN
                FOR tab_rec in tab_c(tbs_rec.tbs_name)
                LOOP
                BEGIN
                update tables_in_tbs set int_table_ddl = replace(int_table_ddl,'TABLESPACE "'||tbs_rec.tbs_name||'"','TABLESPACE "'||tbs_rec.tbs_name||'_ENC"') where table_name = tab_rec.table_name;
                END;
                END LOOP;

        END;
        END LOOP;
END replace_CT_with_ENC;
/
show error;

