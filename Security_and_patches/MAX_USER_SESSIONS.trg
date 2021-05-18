DROP TRIGGER SYS.MAX_ATMMON_SESSIONS;

CREATE OR REPLACE TRIGGER SYS.MAX_ATMMON_SESSIONS
   AFTER LOGON
   ON ROUTER.SCHEMA
DECLARE
   v_sid               NUMBER;
   v_program           VARCHAR2 (100);
   v_terminal          VARCHAR2 (30);
   v_serial            NUMBER;
   v_sessions          NUMBER;
   v_processes_limit   NUMBER;
BEGIN
   DBMS_OUTPUT.enable;

   EXECUTE IMMEDIATE 'select distinct sid from sys.v_$mystat' INTO v_sid;

   EXECUTE IMMEDIATE 'select SERIAL# from sys.v_$session where sid = :b1'
      INTO v_serial
      USING v_sid;

   EXECUTE IMMEDIATE
      'select NVL(program,''NONE'') from sys.v_$session where sid = :b1'
      INTO v_program
      USING v_sid;

   EXECUTE IMMEDIATE 'select terminal from sys.v_$session where sid = :b1'
      INTO v_terminal
      USING v_sid;

   EXECUTE IMMEDIATE
      'SELECT VALUE  FROM V$PARAMETER WHERE NAME = ''sessions'' '
      INTO v_processes_limit;

   EXECUTE IMMEDIATE 'select count(1) from v$session' INTO v_sessions;

   IF     LOWER (v_program) = 'monitor24.exe'
      AND UPPER (v_terminal) = 'S-MSK-T-CTRL02'
      AND v_sessions > v_processes_limit * 0.8
   THEN
      raise_application_error (
         -20001,
         'maximum number of ATMMONITORING sessions is reached',
         TRUE);
   END IF;
END;
/
