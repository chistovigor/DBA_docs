Выделение журнала аудита в отдельное ТП

1) Create tablespace "AUD"

CREATE TABLESPACE "AUD"  DATAFILE '+DATA' SIZE 128M AUTOEXTEND ON NEXT 128M MAXSIZE unlimited 
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE 
    SEGMENT SPACE MANAGEMENT AUTO ;

2) Move the AUD$ table suing the below script ;

BEGIN
DBMS_AUDIT_MGMT.INIT_CLEANUP(
AUDIT_TRAIL_TYPE =>DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
DEFAULT_CLEANUP_INTERVAL => 12 );
END;
/

BEGIN
DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION(
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
audit_trail_location_value => 'AUD');
END;
/


3) To make additional indexes

create index aud$_s_e_a on aud$(sessionid,entryid,action#) initrans 10 tablespace aud;
create index aud$_ntimestamp# on aud$(ntimestamp#)  initrans 10 tablespace aud;

4) Проверка

col segment_name format a30
select owner, segment_name, tablespace_name from dba_segments where tablespace_name='AUD';

OWNER          |SEGMENT_NAME                  |TABLESPACE_NAME
---------------|------------------------------|---------------
SYS            |SYS_LOB0000000384C00040$$     |AUD
SYS            |SYS_LOB0000000384C00041$$     |AUD
SYS            |SYS_IL0000000384C00040$$      |AUD
SYS            |SYS_IL0000000384C00041$$      |AUD
SYS            |AUD$                          |AUD
SYS            |AUD$_NTIMESTAMP#              |AUD
SYS            |AUD$_S_E_A                    |AUD

7 rows selected.

Настройка минимального аудита 

1) Setup minimum audit settings

alter system set audit_trail=DB scope=spfile sid='*';

audit update, delete on sys.aud$ by access;
audit select, update, delete on sys.dba_common_audit_trail by access;
audit session by access;
audit alter session by access;
audit network by access;
audit system grant by access;
audit system audit by access;
audit user by access;
audit SESSION WHENEVER NOT SUCCESSFUL;

2) Turn off unwanted redundancy options

noaudit SELECT ANY DICTIONARY;
noaudit SELECT ANY TABLE;
noaudit SELECT TABLE ;
noaudit DELETE ANY TABLE;
noaudit DELETE TABLE ;
noaudit insert ANY TABLE;
noaudit insert TABLE ;
noaudit update ANY TABLE;
noaudit update TABLE ;
noaudit execute ANY procedure;
noaudit execute procedure ;
noaudit select ANY sequence;
noaudit select sequence;
noaudit LOCK ANY TABLE;
noaudit LOCK TABLE;

3) Check audit settings

select * from DBA_OBJ_AUDIT_OPTS;
select * from DBA_STMT_AUDIT_OPTS;
select * from DBA_PRIV_AUDIT_OPTS;
select * from ALL_DEF_AUDIT_OPTS;

4) How to analyze audit logs

col db_user format a18
col os_user format a20
col userhost format a30 
col OBJECT_NAME format a20
col OBJECT_SCHEMA format a20

select to_char( extended_timestamp, 'YYYY-MON-DD HH24:MI:SS', 'NLS_DATE_LANGUAGE=AMERICAN') extended_timestamp,
       db_user, 
       os_user, 
       userhost,
       statement_type,
       object_name,
       object_schema,
       case returncode
        when 0    then 'Successful'
        when 1017 then 'Invalid username/password'
        else to_char(returncode)
       end as returncode
from dba_common_audit_trail 
where audit_type='Standard Audit'
order by extended_timestamp;

--Action names count
select t.action_name, returncode, count(*)
  from dba_audit_trail t
  group by t.action_name, returncode
  order by 3;
Удаление старых данных из журнала аудита

1) Процедура удаления исторических данных в журнале аудита 

create index aud$_ntimestamp# on aud$(ntimestamp#)  initrans 10 tablespace aud;

create or replace procedure delete_audit_rows (days integer)
is
begin
 delete /*+ INDEX(a AUD$_NTIMESTAMP#) */ from sys.aud$ a where a.ntimestamp#<(sysdate-days);
 dbms_output.put_line('deleted '||sql%rowcount||' rows...');
 commit;
end;
/

2) Проверка

SQL> exec delete_audit_rows(30);

deleted 0 rows...


3) Создание дЖоба для авто-удаления

P.S. По умолчанию храним 7 суток или если надо другое время то уточняем у заказчика

exec dbms_scheduler.drop_job('"SYS"."DELETE_AUDIT_ROWS_JOB"',TRUE);

BEGIN

sys.dbms_scheduler.create_job( 
         job_name => '"SYS"."DELETE_AUDIT_ROWS_JOB"',
         job_type => 'PLSQL_BLOCK',
        job_class => 'DEFAULT_JOB_CLASS',
         comments => 'To delete rows from audit log',
       job_action => 'begin delete_audit_rows(7); end;',
  repeat_interval => 'FREQ=DAILY;INTERVAL=1;BYHOUR=6;BYMINUTE=0;BYSECOND=0',
       start_date => systimestamp at time zone '+4:00',
        auto_drop => FALSE,
          enabled => FALSE);

END;
/

exec sys.dbms_scheduler.enable('DELETE_AUDIT_ROWS_JOB' );

Подключение к центральному хранилищу ArcSight

1) Создать выделенного пользователя

create profile UNEXPIRED_USERS_PROFILE limit 
  COMPOSITE_LIMIT                  UNLIMITED
  SESSIONS_PER_USER                UNLIMITED
  CPU_PER_SESSION                  UNLIMITED
  CPU_PER_CALL                     UNLIMITED
  LOGICAL_READS_PER_SESSION        UNLIMITED
  LOGICAL_READS_PER_CALL           UNLIMITED
  IDLE_TIME                        UNLIMITED
  CONNECT_TIME                     UNLIMITED
  PRIVATE_SGA                      UNLIMITED
  FAILED_LOGIN_ATTEMPTS 6 – количество неправильных попыток подключения
  PASSWORD_LIFE_TIME               UNLIMITED
  PASSWORD_REUSE_TIME 1800 - количество дней, после которого можно повторно использовать пароль
  PASSWORD_REUSE_MAX               UNLIMITED
  PASSWORD_LOCK_TIME 30/1440 - 30 минут - количество дней, на которое блокируется учетная запись, при превышении количества неудачных попыток регистрации
  PASSWORD_GRACE_TIME 30 - количество дней когда будет напоминаться о необходимости его смены
  PASSWORD_VERIFY_FUNCTION PROFILE_PSWD_VERIFY_FUNCTION – функция проверки сложности пароля
;

CREATE USER "ARCSIGHT" IDENTIFIED BY "Password0"
  DEFAULT TABLESPACE "USERS"
  QUOTA UNLIMITED ON "USERS"
  TEMPORARY TABLESPACE "TEMP"
  PROFILE "UNEXPIRED_USERS_PROFILE"
;

GRANT "CONNECT" TO "ARCSIGHT";
GRANT CREATE VIEW TO "ARCSIGHT";
GRANT CREATE TABLE TO "ARCSIGHT";
GRANT SELECT ON "SYS"."USER$" TO "ARCSIGHT";
GRANT SELECT ON "SYS"."V_$SESSION" TO "ARCSIGHT";
GRANT SELECT ON "SYS"."V_$INSTANCE" TO "ARCSIGHT";
GRANT SELECT ON "SYS"."DBA_USERS" TO "ARCSIGHT";
GRANT SELECT ON "SYS"."DBA_AUDIT_TRAIL" TO "ARCSIGHT";
GRANT SELECT ON "SYS"."DBA_COMMON_AUDIT_TRAIL" TO "ARCSIGHT";
GRANT EXECUTE ON "SYS"."DELETE_AUDIT_ROWS" TO "ARCSIGHT";
ALTER USER "ARCSIGHT" DEFAULT ROLE ALL;

NOAUDIT all BY arcsight;
NOAUDIT select table BY arcsight;
NOAUDIT select any table BY arcsight;

2) Создать необходимые объекты в схеме "ARCSIGHT"

 

Включение аудита системных привилегий согласно корпоративной политике

1) Включить аудит системных привилегий | system_privilege_map BY ACCESS (!) <- important


begin
for l_stmt in (select 'audit '||name||' by access' name from system_privilege_map order by 1)
loop
 dbms_output.put_line(l_stmt.name);
 begin
 execute immediate l_stmt.name;
exception  
   when others then  dbms_output.put_line('ERROR for=>'||l_stmt.name);
 end;
end loop;
end;
/

2) Выключить ненужные | turn off unwanted redundancy options

noaudit SELECT ANY DICTIONARY;
noaudit SELECT ANY TABLE;
noaudit SELECT TABLE ;
noaudit DELETE ANY TABLE;
noaudit DELETE TABLE ;
noaudit insert ANY TABLE;
noaudit insert TABLE ;
noaudit update ANY TABLE;
noaudit update TABLE ;
noaudit execute ANY procedure;
noaudit execute procedure ;
noaudit select ANY sequence;
noaudit select sequence;
noaudit LOCK ANY TABLE;
noaudit LOCK TABLE;


5) Check audit settings

select * from DBA_OBJ_AUDIT_OPTS;
select * from DBA_STMT_AUDIT_OPTS;
select * from DBA_PRIV_AUDIT_OPTS;
select * from ALL_DEF_AUDIT_OPTS;

Настройка аудита пользователя SYS и пользователей подключающихся с ролями SYSDBA и SYSOPER с помощью SYSLOG Audit Trail

Согласно документации: http://docs.oracle.com/cd/E11882_01/network.112/e36292/auditing.htm#CEGCFCJI
для использования SYSLOG Audit Trail необходимо выполнить следующие шаги:
                
	1) Настройка экземпляра БД
		1.1) ALTER SYSTEM SET AUDIT_SYSLOG_LEVEL = 'LOCAL1.WARNING' SCOPE=SPFILE SID='*';
		1.2) ALTER SYSTEM SET AUDIT_SYS_OPERATIONS = TRUE SCOPE=SPFILE SID='*';
	2) Настройка ОС
		2.1) ОС AIX
			Добавить в /etc/syslog.conf строку:
			local1.warning	@10.243.128.239
			Перезапустить syslog: refresh -s syslogd
		2.2) ОС Linux
			Добавить в /etc/syslog.conf строку:
			local1.warning	@10.243.128.239
			Перезапустить syslog: /etc/init.d/syslog restart
	3) Выполнить перезагрузку экземпляра БД

(!) для выполнения настройки данного вида аудита необходимо наличие CMR с участием Unix администраторов
