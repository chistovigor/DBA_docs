Включаем трассировку для пользователя (после логона)

CREATE OR REPLACE TRIGGER USERNAME.set_identifier AFTER logon ON USERNAME.schema
BEGIN
EXECUTE immediate 'ALTER SESSION SET TIMED_STATISTICS=TRUE';
dbms_session.set_identifier('TRACEME');
END;

Now you can enable monitoring for all sessions with this flag through DBMS_MONITOR

BEGIN
DBMS_MONITOR.client_id_trace_enable (client_id => 'TRACEME', waits =>
TRUE, binds => TRUE );
END;


Ищем сформированный трейс и обрабатываем его:

tkprof ULTRASTN_ora_14271.trc ULTRASTN_ora_14271.log sys=no

описание tkprof
http://docs.oracle.com/cd/B19306_01/server.102/b14211/sqltrace.htm#i4191

Отключаем трассировку:

Deactivate the same way and if you are really done with this, delete the trigger aswell

BEGIN
DBMS_MONITOR.client_id_trace_disable (client_id => 'TRACEME');
END;

drop trigger USERNAME.set_identifier;