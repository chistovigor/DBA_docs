-- select partition borders into VARCHAR2 format
-- выбор границ партиций в формате VARCHAR2

Prompt drop Package LONG_HELP;
DROP PACKAGE LONG_HELP;

Prompt Package LONG_HELP;
CREATE OR REPLACE package long_help

/*

select partitions for the USER

select *
FROM TABLE(long_help.get_all_tab_partitions('USERNAME'));

*/

authid current_user
AS

  TYPE TOutRec_Type IS RECORD (TABLE_OWNER        VARCHAR2(100), 
                               TABLE_NAME         VARCHAR2(100), 
                               PARTITION_NAME     VARCHAR2(100), 
                               TABLESPACE_NAME    VARCHAR2(100), 
                               HIGH_VALUE         varchar2(4000),
                               VALUE_LEN          NUMBER(6));    
    
  TYPE TOutRec_Set IS TABLE OF TOutRec_Type;
    
  function get_all_tab_partitions(vOwner_Name in varchar2 default NULL)  return TOutRec_Set PIPELINED;

end;
/

--SHOW ERRORS;
--Prompt drop Package Body LONG_HELP;
--DROP PACKAGE BODY LONG_HELP;

--Prompt Package Body LONG_HELP;
CREATE OR REPLACE package body long_help
as

/*==========================================================*/
function get_all_tab_partitions(vOwner_Name in varchar2 default NULL)  return TOutRec_Set  PIPELINED
AS
  g_cursor number := dbms_sql.open_cursor;
  F        INTEGER;
  
  p_from   number      := 1;
  p_for    NUMBER      := 4000;
  p_name1  VARCHAR2(5) := 'owner';
                                
  p_query  VARCHAR2(1000) := 'select TABLE_OWNER, TABLE_NAME, PARTITION_NAME, TABLESPACE_NAME, HIGH_VALUE '||
                             'from all_tab_partitions where table_owner = :owner';
  
  TABLE_OWNER        VARCHAR2(100); 
  TABLE_NAME         VARCHAR2(100); 
  PARTITION_NAME     VARCHAR2(100);  
  TABLESPACE_NAME    VARCHAR2(100);    
  HIGH_VALUE         varchar2(4000);   
  VALUE_LEN          number;
   
  Rec_C              TOutRec_Type;
begin
    if ( nvl(p_from,0) <= 0 ) then
      raise_application_error (-20002, 'From must be >= 1 (positive numbers)' );
    end if;
    
    if ( nvl(p_for,0) not between 1 and 4000 ) then
      raise_application_error(-20003, 'For must be between 1 and 4000' );
    end if;

    if ( upper(trim(nvl(p_query,'x'))) not like 'SELECT%') then
      raise_application_error (-20001, 'This must be a select only' );
    end if;
        
    dbms_sql.parse( g_cursor, p_query, dbms_sql.native );
    dbms_sql.bind_variable( g_cursor, p_name1, vOwner_Name);

    dbms_sql.define_column(g_cursor     , 1 ,TABLE_OWNER,        100);
    dbms_sql.define_column(g_cursor     , 2 ,TABLE_NAME,         100);
    dbms_sql.define_column(g_cursor     , 3 ,PARTITION_NAME,     100);
    dbms_sql.define_column(g_cursor     , 4 ,TABLESPACE_NAME,    100);
    dbms_sql.define_column_long(g_cursor, 5);
  
    F := dbms_sql.execute(g_cursor); 

    LOOP 
     IF DBMS_SQL.FETCH_ROWS(g_cursor)>0 THEN 
       -- get column values of the row 

       dbms_sql.column_value(g_cursor, 1, TABLE_OWNER       );
       dbms_sql.column_value(g_cursor, 2, TABLE_NAME        );
       dbms_sql.column_value(g_cursor, 3, PARTITION_NAME    );
       dbms_sql.column_value(g_cursor, 4, TABLESPACE_NAME   );
       dbms_sql.column_value_long(g_cursor, 5, p_for, p_from-1, HIGH_VALUE, VALUE_LEN );
       
       Rec_C.TABLE_OWNER          := TABLE_OWNER;       
       Rec_C.TABLE_NAME           := TABLE_NAME;        
       Rec_C.PARTITION_NAME       := PARTITION_NAME;    
       Rec_C.TABLESPACE_NAME      := TABLESPACE_NAME;   
       Rec_C.HIGH_VALUE           := HIGH_VALUE;
       Rec_C.VALUE_LEN            := VALUE_LEN;

       PIPE ROW (Rec_C); 
      ELSE 
        EXIT; 
      END IF; 
    END LOOP; 
    
    dbms_sql.close_cursor(g_cursor);
    
    RETURN; --;
end get_all_tab_partitions;

end;
/

SHOW ERRORS;
