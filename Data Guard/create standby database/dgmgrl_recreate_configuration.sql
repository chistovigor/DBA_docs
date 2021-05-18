Шаги по пересозданию конфигурации DGMGRL 

1) Возвращаем резервную базу в режим standby руками:
--------------------------------------------------------------
!Данный шаг нужно делать только если эта процедура выполняется после неудачного перевода резервной базы из snapshot в physical standby!

На резервном сервере oracle@var01vm01

sqlplus "/as sysdba"
alter database convert to physical standby;
exit



2) Останавливаем dgmgrl, удаляем конфигурацию:
--------------------------------------------------------------
На резервном сервере oracle@var01vm01
sqlplus "/as sysdba"
---
alter system set dg_broker_start=false;

show parameter dg_broker_config
exit

[oracle@var01vm01 ~]$ rm /u01/app/oracle/product/12.1.0.2/dbhome_1/dbs/dr1spurstb.dat
[oracle@var01vm01 ~]$ rm /u01/app/oracle/product/12.1.0.2/dbhome_1/dbs/dr2spurstb.dat



На основном сервере oracle@mr01vm01 

sqlplus "/as sysdba"
---
alter system set dg_broker_start=false;

show parameter dg_broker_config
exit


[oracle@mr01vm01 ~]$ rm /u01/app/oracle/product/12.1.0.2/dbhome_1/dbs/dr2spur.dat
[oracle@mr01vm01 ~]$ rm /u01/app/oracle/product/12.1.0.2/dbhome_1/dbs/dr1spur.dat



3) Запускаем dgmgrl:
--------------------------------------------------------------
На основном сервере oracle@mr01vm01 

sqlplus "/as sysdba"
---
alter system set dg_broker_start=true;
exit

На резервном сервере oracle@var01vm01
sqlplus "/as sysdba"
---
alter system set dg_broker_start=true;
exit




4) пересоздаем конфигурацию на основном сервере mr01vm01:
--------------------------------------------------------------
На основном сервере oracle@mr01vm01 

dgmgrl
connect sys

CREATE CONFIGURATION 'spur_pr' AS PRIMARY DATABASE IS 'spur' CONNECT IDENTIFIER IS spurprm; 

ADD DATABASE 'spurstb' AS CONNECT IDENTIFIER IS spurstb MAINTAINED AS PHYSICAL; 

show database  verbose spurstb;

enable configuration ;

show database  verbose spurstb;


5) Редактируем параметры:
--------------------------------------------------------------
На резервном сервере oracle@var01vm01

EDIT DATABASE spur  SET PROPERTY 'LogXptMode'='ARCH';
EDIT DATABASE spur  SET PROPERTY 'DelayMins'=2;
EDIT DATABASE spur  SET PROPERTY 'TransportDisconnectedThreshold'=300;


EDIT DATABASE spurstb  SET PROPERTY 'LogXptMode'='ARCH';
EDIT DATABASE spurstb  SET PROPERTY 'DelayMins'=2;
EDIT DATABASE spurstb  SET PROPERTY 'TransportDisconnectedThreshold'=300;

show database  verbose spurstb;


6) Включаем режим AG
--------------------------------------------------------------
На резервном сервере oracle@var01vm01

dgmgrl
connect sys

EDIT DATABASE spurstb SET STATE='READ-ONLY';

show database  verbose spurstb;

EDIT DATABASE spurstb SET STATE='APPLY-ON';

show database  verbose spurstb;


7) запускаем сервис standby 
--------------------------------------------------------------
--Делаем руками, т.к. dgmgrl не успел это сделать

На резервном сервере oracle@var01vm01

srvctl start service -s dwh_stb -d spurstb
