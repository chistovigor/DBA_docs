-- создание JAVA SOURCE для выполнения команды ОС из PL\SQL

CREATE OR REPLACE AND RESOLVE JAVA SOURCE NAMED MONITOR_PROD."OSCommand" as import java.io.*;
import java.lang.*;
public class OSCommand{


        public static String Run(String Command){

                Runtime rt = Runtime.getRuntime();
                int     rc = -1;

                try{

                        Process p = rt.exec( Command );
                        int bufSize = 32000;
                        int len = 0;
                        byte buffer[] = new byte[bufSize];
                        String s = null;

                        BufferedInputStream bis = new BufferedInputStream( p.getInputStream(), bufSize );
                        len = bis.read( buffer, 0, bufSize );

                        rc = p.waitFor();

                        if ( len != -1 ){
                                s = new String( buffer, 0, len );
                                return( s );
                        }

                        return( rc+"" );
                }

                catch (Exception e){
                        e.printStackTrace();
                        return(  "-1\ncommand[" + Command + "]\n" + e.getMessage() );
                }

        }
}
/

-- создание функции, возвращающей результаты выполнения команды ОС из PL\SQL

CREATE OR REPLACE FUNCTION MONITOR_PROD.OSexec(
                         p_CMD IN VARCHAR2
                        )
    RETURN varchar2
    AS
      LANGUAGE JAVA
      NAME 'OSCommand.Run(java.lang.String) return varchar2';
/

-- пользователю нужно выдать права на запуск процедур для работы с ОС

EXEC DBMS_JAVA.grant_permission('SCHEMA-NAME', 'java.io.FilePermission', '<<ALL FILES>>', 'read ,write, execute, delete');
EXEC DBMS_JAVA.grant_permission('SCHEMA-NAME', 'SYS:java.lang.RuntimePermission', 'writeFileDescriptor', '');
EXEC DBMS_JAVA.grant_permission('SCHEMA-NAME', 'SYS:java.lang.RuntimePermission', 'readFileDescriptor', '');
GRANT JAVAUSERPRIV TO SCHEMA-NAME;

-- пример запуска для отслеживания места на дисках (:OBJECT_NAME: - интересующая точка монтирования)

select decode(sign(100-to_number(substr(s, instr(s,'%',1,2)-3,3))-:HISTORY_LAG:),1,1,0) from (select OSexec('df -h | grep :OBJECT_NAME: ') s from dual)

