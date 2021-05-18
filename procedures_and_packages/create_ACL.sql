sqlplus / as sysdba;

1) просмотр существующих листов:

SELECT * FROM dba_network_acls;

для конкретного пользователя:

SELECT *
  FROM dba_network_acl_privileges
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
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl         => 'ports_permissions.xml',
                                         principal   => 'ROUTER',
                                         is_grant    => TRUE,
                                         privilege   => 'connect');
END;
/

COMMIT;

BEGIN
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl         => 'ports_permissions.xml',
                                         principal   => 'ROUTER',
                                         is_grant    => TRUE,
                                         privilege   => 'resolve');
END;
/

COMMIT;

4) Добавление сервера в лист

BEGIN
   DBMS_NETWORK_ACL_ADMIN.assign_acl (acl          => 'ports_permissions.xml',
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

