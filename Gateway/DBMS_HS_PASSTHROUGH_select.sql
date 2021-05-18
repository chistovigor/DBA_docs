DECLARE
   v_type   VARCHAR2(15);
   v_state  VARCHAR2(15);
   v_cursor            BINARY_INTEGER;
   v_select         VARCHAR2(200);
BEGIN
 dbms_output.enable;
 v_select:='select state,type from sysmaster:sysdri;';
 v_cursor := DBMS_HS_PASSTHROUGH.open_cursor@onldb02;
 DBMS_HS_PASSTHROUGH.parse@onldb02(v_cursor, v_select);
 WHILE DBMS_HS_PASSTHROUGH.fetch_row@onldb02(v_cursor) > 0
 loop 
  DBMS_HS_PASSTHROUGH.GET_VALUE@onldb02(v_cursor,1,v_state);
  DBMS_HS_PASSTHROUGH.GET_VALUE@onldb02(v_cursor,2,v_type);
  end loop;
  dbms_output.put_line('state '||v_state);
  dbms_output.put_line('type '||v_type);
  DBMS_HS_PASSTHROUGH.close_cursor@onldb02(v_cursor);
  IF v_type not in ('Secondary','Not Initialized')
   THEN
      RETURN;
   END IF;
  dbms_output.put_line('aaa');
END;
/