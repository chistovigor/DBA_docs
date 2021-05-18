описание

http://www.oracle-base.com/articles/misc/email-from-oracle-plsql.php

sqlplus / as sysdba;

1) просмотр существующих листов:

SELECT * FROM dba_network_acls;

для конкретного пользователя:

SELECT * FROM dba_network_acl_privileges
 WHERE principal = 'ROUTER';
 
2) создание листа

BEGIN
   DBMS_NETWORK_ACL_ADMIN.create_acl (acl           => 'ports_permissions.xml', -- or any other file name
                                      description   => 'network access',
                                      principal     => 'ROUTER', -- the user name trying to access the network resource
                                      is_grant      => TRUE,
                                      privilege     => 'connect',
                                      start_date    => NULL,
                                      end_date      => NULL);
END;
/
commit;

3) Добавление разрешений для пользователя в лист

BEGIN
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl         => 'monitor_permissions.xml',
                                         principal   => 'BPEL',
                                         is_grant    => TRUE,
                                         privilege   => 'connect');
END;
/

COMMIT;

BEGIN
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl         => 'monitor_permissions.xml',
                                         principal   => 'BPEL',
                                         is_grant    => TRUE,
                                         privilege   => 'resolve');
END;
/

COMMIT;

BEGIN
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl         => 'acl_permissions.xml',
                                         principal   => 'BPEL',
                                         is_grant    => TRUE,
                                         privilege   => 'resolve');
END;
/

COMMIT;

4) Добавление сервера в лист (Only one ACL can be assigned to a specific host and port-range combination)

BEGIN
   DBMS_NETWORK_ACL_ADMIN.assign_acl (acl          => 'monitor_permissions.xml',
                                      HOST         => 'smtp.raiffeisen.ru',
                                      lower_port   => 1,
                                      upper_port   => 65000);
END;
/

COMMIT;

5) Добавление разрешений пользователю (можно не запускать):

grant execute on UTL_SMTP  to router;
grant execute on UTL_TCP   to router;
grant execute on UTL_INADDR   to router;
grant execute on UTL_HTTP   to router;

6) Проверка

SELECT * FROM dba_network_acls;

для конкретного пользователя:

SELECT *
  FROM dba_network_acl_privileges
 WHERE principal = 'ROUTER';
 
 7) Отправка почты пакетом mail_pkg:
 
 BEGIN
   Mail_Pkg.send (
      p_sender_email   => 'LANIT-ARCHIVE',
      p_from           => 'LANIT-ARCHIVE',
      p_to             => MAIL_PKG.ARRAY ('IRUACII2'),
      p_subject        =>   'ROUTER'
                         || ' TABLES COMPRESSION FOR '
                         || TO_CHAR (TO_DATE ('201311', 'YYYYMM'), 'MM/YYYY')
                         || ' FINISHED',
      p_body           => 'DO NOT SHUTDOWN LANIT ARCHIVE SERVER',
      p_ContentType    => 'text/plain');
END;
/

8) Создание пакета для отправки почты

CREATE OR REPLACE PROCEDURE send_mail (p_to        IN VARCHAR2,
                                       p_from      IN VARCHAR2,
                                       p_message   IN VARCHAR2,
                                       p_smtp_host IN VARCHAR2,
                                       p_smtp_port IN NUMBER DEFAULT 25)
AS
  l_mail_conn   UTL_SMTP.connection;
BEGIN
  l_mail_conn := UTL_SMTP.open_connection(p_smtp_host, p_smtp_port);
  UTL_SMTP.helo(l_mail_conn, p_smtp_host);
  UTL_SMTP.mail(l_mail_conn, p_from);
  UTL_SMTP.rcpt(l_mail_conn, p_to);
  UTL_SMTP.data(l_mail_conn, p_message || UTL_TCP.crlf || UTL_TCP.crlf);
  UTL_SMTP.quit(l_mail_conn);
END;
/

отправка этим пакетом

EXEC router.send_mail(p_to=>'Igor.CHISTOV@raiffeisen.ru',p_from=>'Igor.CHISTOV@raiffeisen.ru',p_message=> 'This is a test message.',p_smtp_host => 'smtp.reiffeisen.ru');

или из командной строки

declare
l_mail_conn   UTL_SMTP.connection;
begin
l_mail_conn := UTL_SMTP.open_connection('smtp.raiffeisen.ru', 25);
   UTL_SMTP.helo(l_mail_conn, 'smtp.raiffeisen.ru');
  UTL_SMTP.mail(l_mail_conn, 'IRUACII2');
  UTL_SMTP.rcpt(l_mail_conn, 'IRUACII2');
  UTL_SMTP.data(l_mail_conn, 'aaa' || UTL_TCP.crlf || UTL_TCP.crlf);
  UTL_SMTP.quit(l_mail_conn);
END;
