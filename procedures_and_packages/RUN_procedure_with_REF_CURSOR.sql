/* Formatted on 24/06/2014 17:54:25 (QP5 v5.227.12220.39754) */
SET SERVEROUTPUT ON FEEDBACK OFF LINESIZE 450

DECLARE
   v_cursor_1   sys_refcursor;
   v_data varchar2(500);
BEGIN
   chbk_mc_1 (v_cursor => v_cursor_1);
-- for set 2 days before sysdate (default = 1)
--  chbk_mc_1 (chbk_days=>2,v_cursor => v_cursor_1);
   loop
   fetch v_cursor_1 into v_data;
   exit when v_cursor_1%NOTFOUND;
   DBMS_OUTPUT.PUT_LINE(v_data);
  END LOOP;
   CLOSE v_cursor_1;
  commit;
END;
/

--запуск из процедуры

CREATE OR REPLACE
PROCEDURE TCTDBS.chbk_mc_run IS
   v_cursor_1   sys_refcursor;
   v_data varchar2(500);
BEGIN
   chbk_mc (v_cursor => v_cursor_1);
-- for set 2 days before sysdate (defaul = 1)
--  chbk_mc (chbk_days=>2,v_cursor => v_cursor_1);
   loop
   fetch v_cursor_1 into v_data;
   exit when v_cursor_1%NOTFOUND;
   DBMS_OUTPUT.PUT_LINE(v_data);
  END LOOP;
   CLOSE v_cursor_1;
  commit;
END chbk_mc_run;


exec chbk_mc_run;