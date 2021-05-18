-- Check privileges for particular table for particular user

select
    RP.GRANTEE,
    TP.GRANTEE   GRANTED_VIA,
    TP.owner     TABLE_OWNER,
    TP.TABLE_NAME,
    TP.privilege GRANTED_PRIVILEGE
from
    DBA_ROLE_PRIVS RP,
    DBA_TAB_PRIVS TP
where
    RP.GRANTEE = 'OWS_READ'
    and RP.GRANTED_ROLE in (
        select
            GRANTEE
        from
            DBA_TAB_PRIVS
        where
            TABLE_NAME = 'DOC'
    )
    and ( RP.GRANTEE = TP.GRANTEE
          or RP.GRANTED_ROLE = TP.GRANTEE )
    and TP.TABLE_NAME = 'DOC';


-- CTADUMP report analyzing

select max(sample_time) from dba_hist_active_sess_history;
SELECT
    sql_id,
    sql_plan_hash_value,
    MIN(sample_time),
    MAX(sample_time)
FROM
    dba_hist_active_sess_history
WHERE
    sql_id IN (
        SELECT
            sql_id
        FROM
            dba_hist_sqltext
        WHERE
            LOWER(sql_text) LIKE '%insert /*+ append */ into opt_egcc_collection_result%'
    )
    AND sample_time > TRUNC(sysdate - 3)
    AND top_level_sql_id = 'gskp4c9t3cza9' --BEGIN OPT_EGCC_COLLECTION_EXTRACT(:1,:2); END;
GROUP BY
    sql_id,
    sql_plan_hash_value
HAVING
    sql_plan_hash_value <> 0
ORDER BY
    MIN(sample_time);

select * from dba_hist_sqltext where sql_id in (
select distinct top_level_sql_id from dba_hist_active_sess_history where sql_id IN (
        SELECT
            sql_id
        FROM
            dba_hist_sqltext
        WHERE
            lower(sql_text) LIKE '%insert /*+ append */ into opt_egcc_collection_result%'
    ) and sample_time > trunc(sysdate-3));

select * from dba_hist_active_sess_history;
select min(sample_time) from V$ACTIVE_SESSION_HISTORY;

--

select * from dba_dependencies where referenced_name = 'CONTRACT_ADDRESSES_LC';
select * from dba_dependencies where referenced_name = 'YQ_CONTRACT_ADDRESSES_LC';


DECLARE
    v_sql      VARCHAR2(4000);
    v_object   VARCHAR2(100) DEFAULT 'CONTRACT_ADDRESSES_LC';
BEGIN
    dbms_output.enable;
    FOR rec IN (
        SELECT
            'revoke '
            || privilege
            || ' on '
            || table_name
            || ' from '
            || grantee AS sql_stmt
        FROM
            dba_tab_privs
        WHERE
            table_name = v_object
            AND privilege <> 'SELECT'
        ORDER BY
            grantee,
            privilege
    ) LOOP
        v_sql := rec.sql_stmt;
        dbms_output.put_line(v_sql);
   --execute immediate v_sql;
    END LOOP;
END;


-- password verify function difference

create or replace FUNCTION VERIFY_FUNCTION   (username varchar2,
  password varchar2,
  old_password varchar2)
  RETURN boolean IS
   n boolean;
   m integer;
   differ integer;
   isdigit boolean;
   ischar  boolean;
   ispunct boolean;
   digitarray varchar2(20);
   punctarray varchar2(25);
   chararray varchar2(52);

BEGIN
   digitarray:= '0123456789';
   chararray:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
   punctarray:='!"#$%&()``*+,-/:;<=>?_';
   -- Check if the password is same as the username
   IF NLS_LOWER(password) = NLS_LOWER(username) THEN
     raise_application_error(-20001, 'Password same as or similar to user');
   END IF;
   -- Check for the minimum length of the password
   IF length(password) < 8 THEN
      raise_application_error(-20002, 'Password length less than 8');
   END IF;
   -- Check if the password is too simple. A dictionary of words may be
   -- maintained and a check may be made so as not to allow the words
   -- that are too simple for the password.
   IF NLS_LOWER(password) IN ('welcome', 'database', 'account', 'user', 'password', 'oracle', 'computer', 'abcd') THEN
      raise_application_error(-20002, 'Password too simple');
   END IF;
   -- Check if the password contains at least one letter, one digit and one
   -- punctuation mark.
   -- 1. Check for the digit
   isdigit:=FALSE;
   m := length(password);
   FOR i IN 1..10 LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(digitarray,i,1) THEN
            isdigit:=TRUE;
             GOTO findchar;
         END IF;
      END LOOP;
   END LOOP;
   IF isdigit = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least one digit, one character and one punctuation');
   END IF;
   -- 2. Check for the character
   <<findchar>>
   ischar:=FALSE;
   FOR i IN 1..length(chararray) LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(chararray,i,1) THEN
            ischar:=TRUE;
             GOTO findpunct;
         END IF;
      END LOOP;
   END LOOP;
   IF ischar = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least one \
              digit, one character and one punctuation');
   END IF;
   -- 3. Check for the punctuation
   <<findpunct>>
   ispunct:=FALSE;
   FOR i IN 1..length(punctarray) LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(punctarray,i,1) THEN
            ispunct:=TRUE;
             GOTO endsearch;
         END IF;
      END LOOP;
   END LOOP;
   IF ispunct = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least one \
              digit, one character and one punctuation');
   END IF;
   <<endsearch>>
   -- Check if the password differs from the previous password by at least
   -- 3 letters
   IF old_password IS NOT NULL THEN
     differ := length(old_password) - length(password);
     IF abs(differ) < 3 THEN
       IF length(password) < length(old_password) THEN
         m := length(password);
       ELSE
         m := length(old_password);
       END IF;
       differ := abs(differ);
       FOR i IN 1..m LOOP
         IF substr(password,i,1) != substr(old_password,i,1) THEN
           differ := differ + 1;
         END IF;
       END LOOP;
       IF differ < 3 THEN
         raise_application_error(-20004, 'Password should differ by at \
         least 3 characters');
       END IF;
     END IF;
   END IF;
   -- Everything is fine; return TRUE ;
   RETURN(TRUE);
END;


-- the only difference is:

punctarray:='@\!"#$%&()``*+,-/:;<=>?_';
punctarray:='!"#$%&()``*+,-/:;<=>?_';