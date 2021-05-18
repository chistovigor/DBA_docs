/* Formatted on 04.03.2014 5:59:03 (QP5 v5.227.12220.39754) */
EXEC DBMS_SERVICE.CREATE_SERVICE(service_name =>'ATM_ARCHS_SRV',network_name =>'ATM_ARCHS_SRV',aq_ha_notifications=>TRUE,failover_method =>'BASIC',failover_type =>'SELECT',failover_retries =>180,failover_delay => 5);

EXEC DBMS_SERVICE.START_SERVICE('ATM_ARCHS_SRV');

CREATE OR REPLACE TRIGGER startDgServices
   AFTER STARTUP
   ON DATABASE
DECLARE
   db_role        VARCHAR (30);
   db_open_mode   VARCHAR (30);
BEGIN
   SELECT DATABASE_ROLE, OPEN_MODE
     INTO db_role, db_open_mode
     FROM V$DATABASE;

   IF db_role = 'PRIMARY'
   THEN
      DBMS_SERVICE.START_SERVICE ('ATM_ARCHS_SRV');
   END IF;
END;
/


SELECT NAME,
       NAME_HASH,
       CREATION_DATE_HASH,
       GOAL,
       DTP,
       AQ_HA_NOTIFICATIONS,
       CLB_GOAL
  FROM DBA_SERVICES;


CREATE OR REPLACE TRIGGER changeroleDgServices
   AFTER DB_ROLE_CHANGE
   ON DATABASE
DECLARE
   ROLE   VARCHAR (30);
BEGIN
   SELECT DATABASE_ROLE INTO ROLE FROM V$DATABASE;

   IF ROLE = 'PRIMARY'
   THEN
      DBMS_SERVICE.START_SERVICE ('ATM_ARCHS_SRV');
   ELSE
      DBMS_SERVICE.STOP_SERVICE ('ATM_ARCHS_SRV');
   END IF;
END;
/

/*

modify tnsnames.ora 

ATM_ARCHS_SRV =
 (DESCRIPTION =
  (TRANSPORT_CONNECT_TIMEOUT=3)
  (failover=on)
  (ADDRESS = (PROTOCOL = TCP)(HOST = db_host)(PORT = 1521))
  (ADDRESS = (PROTOCOL = TCP)(HOST = db_host)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = ATM_ARCHS_SRV)
    (failover_mode=
   (type=session))
  )
 )

and (if needed) listener.ora

*/


EXEC DBMS_SERVICE.STOP_SERVICE('ATM_ARCHS_SRV');

EXEC DBMS_SERVICE.DELETE_SERVICE('ATM_ARCHS_SRV');