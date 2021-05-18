SET LONG 2000000
SET HEAD OFF
SET ECHO OFF
SET PAGESIZE 0
SET VERIFY OFF
SET FEEDBACK OFF
SET TERMOUT OFF

@get_object.sql "&&1" "packages" "PACKAGE" "PACKAGE"
@get_object.sql "&&1" "sequences" "SEQUENCE" "SEQUENCE"
@get_object.sql "&&1" "triggers" "TRIGGER" "TRIGGER"
@get_object.sql "&&1" "procedures" "PROCEDURE" "PROCEDURE"
@get_object.sql "&&1" "functions" "FUNCTION" "FUNCTION"
@get_object.sql "&&1" "tables" "TABLE" "TABLE"
@get_object.sql "&&1" "views" "VIEW" "VIEW"
@get_object.sql "&&1" "queues" "AQ_QUEUE" "QUEUE"
@get_object.sql "&&1" "java" "JAVA_SOURCE" "JAVA SOURCE"


SPOOL &&1/queue_tables/queue_tables.txt;
SELECT DBMS_METADATA.get_ddl ('AQ_QUEUE_TABLE', queue_table)
  FROM dba_queue_tables
 WHERE owner = USER;


EXIT