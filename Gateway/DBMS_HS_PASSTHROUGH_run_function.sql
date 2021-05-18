create or replace procedure set_term_keys(l_action  varchar2, l_terminal_num  varchar2,
       l_tpkunderlmk_key  varchar2,l_tpkunderlmk_kcv  varchar2, l_tpkunderlmk_type  varchar2,
        l_tpkunderlmk_des  smallint, l_pinblckfmt   varchar2) is

l_cursor            BINARY_INTEGER;
l_condition         VARCHAR2(250);
l_return             INTEGER;

BEGIN

l_condition:='execute procedure set_term_keys('||''''||l_action||''''||','||''''||l_terminal_num||''''||','||''''||rtrim(l_tpkunderlmk_key)||''''||','||''''||rtrim(l_tpkunderlmk_kcv)||''''||','||''''||l_tpkunderlmk_type||''''||','||''''||l_tpkunderlmk_des||''''||','||''''||l_pinblckfmt||''''||');';
/*DBMS_OUTPUT.put_line(l_condition);*/

l_cursor := DBMS_HS_PASSTHROUGH.open_cursor@DG4IFMX;

DBMS_HS_PASSTHROUGH.parse@DG4IFMX(l_cursor, l_condition);
    WHILE DBMS_HS_PASSTHROUGH.fetch_row@DG4IFMX(l_cursor) > 0
LOOP
DBMS_HS_PASSTHROUGH.get_value@DG4IFMX(l_cursor, 1, l_return);
DBMS_OUTPUT.put_line(l_return);
END LOOP;
    DBMS_HS_PASSTHROUGH.close_cursor@DG4IFMX(l_cursor);
exception
when others then
DBMS_HS_PASSTHROUGH.close_cursor@DG4IFMX(l_cursor);
raise;

end set_term_keys;