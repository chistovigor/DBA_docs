select * from dba_network_acls;

select * from dba_network_acl_privileges;

BEGIN
   DBMS_NETWORK_ACL_ADMIN.create_acl (acl           => 'ports_permissions_ARDB_USER.xml', -- or any other file name
                                      description   => 'network access',
                                      principal     => 'ARDB_USER', -- the user name trying to access the network resource
                                      is_grant      => TRUE,
                                      privilege     => 'connect',
                                      start_date    => NULL,
                                      end_date      => NULL);
END;
/
commit;

BEGIN
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl         => 'ports_permissions_ARDB_USER.xml',
                                         principal   => 'ARDB_USER',
                                         is_grant    => TRUE,
                                         privilege   => 'connect');
END;
/

COMMIT;

BEGIN
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl         => 'ports_permissions_ARDB_USER.xml',
                                         principal   => 'ARDB_USER',
                                         is_grant    => TRUE,
                                         privilege   => 'resolve');
END;
/

BEGIN
   DBMS_NETWORK_ACL_ADMIN.assign_acl (acl          => 'ports_permissions_ARDB_USER.xml',
                                      HOST         => '*',
                                      lower_port   => 1,
                                      upper_port   => 65000);
END;
/

COMMIT;


/* Formatted on 27-05-2016 14:10:03 (QP5 v5.287) */
CREATE OR REPLACE FUNCTION TELNET (IPADDRESS VARCHAR2, PORTNUM NUMBER)
   RETURN NUMBER
   AUTHID DEFINER
IS
   SOCKET   UTL_TCP.CONNECTION;
BEGIN

   SOCKET :=
      UTL_TCP.OPEN_CONNECTION (REMOTE_HOST   => IPADDRESS,
                               REMOTE_PORT   => PORTNUM,
                               TX_TIMEOUT    => 5);

   UTL_TCP.CLOSE_CONNECTION (SOCKET);



   RETURN 1;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN 0;
END;
/

-- или (со временем доступа)

/* Formatted on 27-05-2016 13:27:27 (QP5 v5.287) */
CREATE FUNCTION TELNET (IPADDRESS VARCHAR2, PORTNUM NUMBER)
   RETURN VARCHAR2
   AUTHID DEFINER
IS
   SOCKET   UTL_TCP.CONNECTION;

   T1       TIMESTAMP WITH LOCAL TIME ZONE;
BEGIN
   T1 := SYSTIMESTAMP;

   SOCKET :=
      UTL_TCP.OPEN_CONNECTION (REMOTE_HOST   => IPADDRESS,
                               REMOTE_PORT   => PORTNUM,
                               TX_TIMEOUT    => 5);

   UTL_TCP.CLOSE_CONNECTION (SOCKET);



   RETURN (   IPADDRESS
           || ':'
           || TO_CHAR (PORTNUM)
           || ' is alive. ('
           || TO_CHAR (SYSTIMESTAMP - T1)
           || ')');
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN (   IPADDRESS
              || ':'
              || TO_CHAR (PORTNUM)
              || ' did not respond. ('
              || SQLERRM (SQLCODE)
              || ')');
END;
/


-- run function (0 - no access, 1 - OK)

select TELNET( '172.22.9.36', 1433 ) from dual;