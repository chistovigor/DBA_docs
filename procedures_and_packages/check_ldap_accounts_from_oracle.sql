CREATE OR REPLACE FUNCTION DBMAN.AD_AUTHENTICATE_USER(cUSR_NAME VARCHAR2,cPASSWORD VARCHAR2,cMESSAGE OUT VARCHAR2)
RETURN INTEGER
IS
  sessid   dbms_ldap.SESSION;
  TYPE host_array IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
  hosts host_array;
  portnum  PLS_INTEGER   := 389;
  res      PLS_INTEGER   := 0;
  
BEGIN

--    hosts(1) := 's-msk00-adc004.raiffeisen.ru';
    hosts(1) := 's-msk08-adc001.raiffeisen.ru';
    hosts(2) := 's-msk20-adc003.raiffeisen.ru';
    hosts(3) := 's-msk00-adc001.raiffeisen.ru';
    FOR i IN 1..3 LOOP
-- trying to connect to AD
          BEGIN
          sessid := dbms_ldap.init(hosts(i),portnum);
          EXCEPTION
            WHEN OTHERS THEN
               IF (i = 3) THEN
                  cMESSAGE := 'Connection to Domain Controller failed';
                  RETURN -1;
               END IF;
          END;
          EXIT;
    END LOOP;
-- check login/password
    BEGIN
       res := dbms_ldap.simple_bind_s(sessid,'raiffeisen\' || cUSR_NAME,cPASSWORD);
    EXCEPTION 
       WHEN dbms_ldap.general_error THEN
          cMESSAGE := SQLERRM;
          cMESSAGE := substr(cMESSAGE,instr(cMESSAGE,'AcceptSecurityContext error, data ')+length('AcceptSecurityContext error, data '),3);
          CASE cMESSAGE 
             WHEN '525' THEN cMESSAGE := 'User not found';
             WHEN '52e' THEN cMESSAGE := 'Invalid username or password';
             WHEN '530' THEN cMESSAGE := 'Not permitted to logon at this time';
             WHEN '531' THEN cMESSAGE := 'Not permitted to logon from this workstation';
             WHEN '532' THEN cMESSAGE := 'Password expired';
             WHEN '533' THEN cMESSAGE := 'Account disabled';
             WHEN '701' THEN cMESSAGE := 'Account expired';
             WHEN '773' THEN cMESSAGE := 'User must reset password';
             WHEN '775' THEN cMESSAGE := 'Account locked out';
             ELSE cMESSAGE := substr(SQLERRM,1,100);
          END CASE;
          dbms_output.put_line(cMESSAGE);
          res := dbms_ldap.unbind_s(sessid);
          RETURN -1;
    END;
res := dbms_ldap.unbind_s(sessid);
cMESSAGE := 'OK';
RETURN 0;
EXCEPTION
    WHEN OTHERS THEN
       cMESSAGE := substr(SQLERRM,1,100);
       RETURN -2;
END;