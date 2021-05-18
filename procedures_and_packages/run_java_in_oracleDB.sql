CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED "Hello" AS
 public class Hello
 {
   public static String world()
   {
     return "ZDAROVA IGOR!";
   }
 };
 /

CREATE OR REPLACE
FUNCTION helloworld RETURN VARCHAR2 AS
LANGUAGE JAVA NAME 'Hello.world () return java.lang.String';
/

DECLARE
   my_string VARCHAR2(400);
BEGIN
   my_string := helloworld();
   dbms_output.put_line('The value of the string is ' || my_string);
END;
/
