1) Download pack from note 822485.1
2) yum install perl-XML-LibXML.x86_64, yum install perl-libxml-perl
3) Do step:
Installing Oracle Enterprise Manager Cloud Control 13c Release 1 on a Standalone Server
from readme
- Copy downloaded data into server in folder with 38 GB free space (for example /u01/emkitbase)
4) Run setup preparation
cd cd /u01/emkitbase
mv p22226601_131000_Linux-x86-64_6of6.zip /tmp
unzip /tmp/p22226601_131000_Linux-x86-64_6of6.zip
perl presetupem.pl
/tmp MUST be more than 11Gb free space
parameter in file /u01/emkitbase/emkit/.rsp MUST be equal to hostname, for example
5) Run OMS setup 
cd /u01/emkitbase/emkit
perl setupem.pl -emOnly
-- enter temporary directory for session (/u01/app/oracle/product/install_session)
-- enter emcc software owner (oracle)
-- enter directory for emcc base (/u01/app/oracle/product/em13c)
6) During setup copy /u01/appem/oracle/MW folder into /u01/app/oracle/product/em13c/oracle !!!
(when repository DB setup completed)
7) IF  "Setup Monitoring for Repository Database" step failed then run 
(for both emcli, in /u01/app/oracle/product/em13c/oracle/MW/bin and /u01/appem/oracle/MW/bin)
emcli sync
emcli login -username=sysman   #(pass=welcome1)
emcli sync
emcli list_plugins_on_server # must succeed

IF "Error: No current OMS. Run setup to establish an OMS connection." error appeared, run:
emcli setup -url=https://emcc:7802/em -username=sysman    #(pass=welcome1)
emcli sync
8) Continue from root
perl setupem.pl -s 5 -recover -emOnly
perl rollback.pl -s 5 -emOnly
perl setupem.pl -r 5-6 -emOnly

9) Open ports

7102 (weblogic console),7802 (web console),9803,15021 (repository db),9851 (BI publisher reports) on EMCC server from workstations for console and DB access
Порт 1521 для доступа С сервера EMCC на адреса db_cell,virlual_db_servers,vip-адреса,scan-listener адреса
Порты 1159,4889,4903 для доступа НА сервер EMCC с адресов db_cell,virlual_db_servers,storage_cells
Порт 3872 для доступа С сервера EMCC на адреса db_cell,virlual_db_servers,storage_cells

При установке на отдельный сервер БД
22,1521 (Listener port),3872 на этом сервере БД для доступа с сервера emcc
4903,3872 (для удаленной установки патчей через EMCC) на сервере emcc для доступа с этого сервера БД
Дополнительно: порт 3872 для доступа с рабочей станции администратора для анализа сбоев в работе с агентом  

10) Control OMS
Enterprise Manager Cloud Control URL: https://emcc:7802/em (default user sysman/welcome1)
/u01/appem/oracle/MW/bin/emctl start oms (Middleware home/u01/appem/oracle/MW)
!!! For control agent use emctl located in agent_home

11) Run agent setup

Install agents on DB_CELLS and virtual machines (mr01mv01 etc.) via web interface of EMCC
(for successful installation hostname IP must be in /etc/hosts !!!)

if installed at host without oracle soft, then add additional file and parameter for user owned egent home:
for example - INVENTORY_LOCATION=/home/apache

12) Deploy Oracle Virtual Infrastructure plugin on agents on physical DB cells (via emcli on EMCC server if not possible in web interface of EMCC)

emcli login -username=sysman
emcli list_plugins_on_agent -agent_names=vardbadm01.moex.com:3872

if plugin "Oracle Virtual Infrastructure" is not listed, then run:

emcli deploy_plugin_on_agent -plugin="oracle.sysman.vi" -agent_names="vardbadm01.moex.com:3872"
emcli get_plugin_deployment_status -plugin=oracle.sysman.vi
emcli list_plugins_on_agent -agent_names=vardbadm01.moex.com:3872

plugin "Oracle Virtual Infrastructure" must be listed now

13) Add Oracle Virtual Platform Target Type for both physical DB cells, then add Oracle Database Machine Target Type using any agent on ONE virtual db cell

!!! add PHYSICAL db hosts name during each Virtual Platform addition (2 DB CELL - 2 Virtual platform, one to one), use root credentials during addition
 
Instructions:

Virtualized Exadata Database Machine
https://docs.oracle.com/cd/E50790_01/doc/doc.121/e27442/ch6_virtualization.htm#EMXIG321

14) For monitoring storage cells add users via cellcli on each cell:

cellcli

LIST USER
CREATE USER celluser password="Dghfvgrhs1234"
create role monitor
grant privilege list on all objects all attributes with all options to role monitor
grant role monitor to user celluser

Add this user credentials in:

Oracle Exadata Storage Server Monitoring Credentials

15) Set Up SNMP Trap Forwarding on Compute Node 

echo 'snmptrapd : ALL' >> /etc/hosts.allow
echo 'authCommunity   log,execute,net public'>> /etc/snmp/snmptrapd.conf
echo 'forward default udp:localhost:3872'>> /etc/snmp/snmptrapd.conf
chkconfig snmptrapd on
service snmptrapd start

16) Control EMCC

https://docs.oracle.com/cd/E24628_01/doc.121/e24473/emctl_cmds.htm#EMADM15067

log of OMS in /u01/appem/oracle/gc_inst/em/EMGC_OMS1/sysman/log/emctl.log

1. Export config

emctl exportconfig oms
backup in file
/u01/appem/oracle/gc_inst/em/EMGC_OMS1/sysman/backup/opf_ADMIN_20160228_222919.bka

2. Restart OMS

2.1 Stop
emctl stop oms -all (or emctl stop oms -all -force)
emctl stop agent (IF needed) --From agent HOME
sqlplus / as sysdba
shutdown immediate
lsnrctl stop

2.2 Start
lsnrctl start
sqlplus / as sysdba
startup
emctl start oms
emctl start agent --From agent HOME
emctl status oms -details [-sysman_pwd <pwd>]

2.3 Solve problems when starting

If BI publisher is not started try:

netstat -antp | grep 9803 (port from log in /u01/appem/oracle/gc_inst/user_projects/domains/GCDomain/servers/BIP/logs)
kill -9 <process used this port>
emctl stop oms -bip_only -force
emctl start oms -bip_only
emctl status oms

3. UNINSTALL Agent (/u01/appem/agent_13.1.0.0.0 - Agent HOME)

/u01/appem/agent_13.1.0.0.0/perl/bin/perl /u01/appem/agent_13.1.0.0.0/sysman/install/AgentDeinstall.pl -agentHome /u01/appem/agent_13.1.0.0.0
/EXAVMIMAGES/appem/agent_13.1.0.0.0/perl/bin/perl /EXAVMIMAGES/appem/agent_13.1.0.0.0/sysman/install/AgentDeinstall.pl -agentHome /EXAVMIMAGES/appem/agent_13.1.0.0.0

4. Remove agent patrnership (mrdbadm02.moex.com:3872 - name of agent in EMCC interface)

runs from emcc server

emcli login -username=sysman

emcli manage_agent_partnership -remove_agent_partnership -monitored_agent="mrdbadm02.moex.com:3872"
emcli manage_agent_partnership -disable_agent_partnership -monitored_agent="mrdbadm02.moex.com:3872"

if need to change partner agent after it:

emcli manage_agent_partnership -enable_agent_partnership -monitored_agent="mr01vm01.moex.com:3872"
emcli manage_agent_partnership -add_agent_partnership -monitored_agent="mr01vm01.moex.com:3872" -partner_agent="emcc:3872"

5. Control agent

list all targets in agent

emctl config agent listtargets

get metrics in scheduler

emctl status agent scheduler

get metric value:

emctl control agent getmetric agent mrsw-iba01.moex.com,oracle_ibnetwork,Response
emctl getmetric agent LISTENER_SCAN1_DWH,oracle_listener,Response
emctl getmetric agent way4db_way4db2,oracle_database,Response

6.

Add memory to OMS

(default values NULL)
emctl get property -name "JAVA_EM_ARGS"
emctl set property -name JAVA_EM_ARGS -value "-Djbo.ampool.maxavailablesize=500 -Djbo.recyclethreshold=500"

To delete the property (revert to original setting)
emctl delete property -name "JAVA_EM_ARGS"

(default value 1740M)
emctl get property -name "OMS_HEAP_MAX"
emctl set property -name "OMS_HEAP_MAX" -value 4096M

Add memory to Weblogic for EMCC
in folder 
/u01/appem/oracle/gc_inst/user_projects/domains/GCDomain/bin

change in files startEMServer.sh and startManagedWebLogic.sh 
variables (was -Xms256M -Xmx1740M)
-Xms512M -Xmx2048M


7. Discover recently added targets:

Setup/add target/configure auto discovery/pick host/discover now

8. Install EMCC patches

Creating a Property File 

oracle@emcc /u01/appem/oracle/MW/OMSPatcher/wlskeys$ ./createkeys.sh -oh /u01/appem/oracle/MW -location /u01/appem/oracle/MW/OMSPatcher/wlskeys
Please enter weblogic admin server username: oracle
Please enter weblogic admin server password:
Warning: weblogic.Admin is deprecated and will be removed in a future release. WLST should be used instead of weblogic.Admin.
Creating the key file can reduce the security of your system if it is not kept in a secured location after it is created. Creating new key...

Trying to get configuration and key files for the given inputs...
This operation will take some time. Please wait for updates...
User configuration file created: /u01/appem/oracle/MW/OMSPatcher/wlskeys/config
User key file created: /u01/appem/oracle/MW/OMSPatcher/wlskeys/key
'createkeys' succeeded.

key stored in file /u01/appem/oracle/MW/OMSPatcher/wlskeys/key

Create file property_file (emcc.moex.com - WLS admin server, 7102 WLS admin port):

AdminServerURL=t3s://emcc.moex.com:7102
AdminConfigFile=/u01/appem/oracle/MW/OMSPatcher/wlskeys/config
AdminKeyFile=/u01/appem/oracle/MW/OMSPatcher/wlskeys/key

export ORACLE_HOME=/u01/appem/oracle/MW

unzip patch file into /u01/app/oracle/oradata/distrib/patches/oms/22920724
cd /u01/app/oracle/oradata/distrib/patches/oms/22920724/22920724 (where bundle.xml file exists)

emctl stop oms

omspatcher apply -analyze  -property_file /u01/appem/oracle/MW/OMSPatcher/wlskeys/property_file (omspatcher from /u01/appem/oracle/MW/OMSPatcher)

If successful, then

omspatcher apply -property_file /u01/appem/oracle/MW/OMSPatcher/wlskeys/property_file

emctl start oms

Log file location: /u01/appem/oracle/MW/cfgtoollogs/omspatcher/22920724/omspatcher_2016-04-27_13-46-37PM_deploy.log

9. Diagnostic of OMS:

EMDIAG Repvfy 12c /13c Kit - How to Use the Repvfy 12c/13c kit (Doc ID 1427365.1)
-- set connection parameters in file $emdiag_home/cfg/repvfy.cfg (Doc ID 421600.1)

after install run (here emrep is TNS service name of OMS database):
repvfy verify -tns emrep -details

-- upgrade:
1. unzip repvfy*.zip into $EMDIAG_HOME:
unzip /u01/app/oracle/oradata/distrib/repvfy12_2016.0909.zip -d /u01/app/oracle/product/em13c/oracle/rep_home/emdiag/
2. run upgrade (with sysman password)
repvfy upgrade -pwd welcome1

detailed analyze:
repvfy verify -level 9 -tns emrep -details (или repvfy verify -level 9 -pwd welcome1 -tns emrep -details)
repvfy verify -level 9 -details

--On completion of a test, a log summary_.log file will be created in the $EMDIAG_HOME/log directory
(/u01/app/oracle/product/em13c/oracle/rep_home/emdiag_backup/log)

10. Selects in OMS repository

-- targets in OMS

select * from sysman.mgmt_targets where TARGET_NAME = '/Farm01_bpelpr/bpelpr/BPEL'; --weblogic_j2eeserver

--collected metrics for target

SELECT DISTINCT metric_group_label as metric_group,
metric_column_label metric_name,
nvl(warning_threshold,' ') as warning_threshold,
nvl(critical_threshold,' ') as critical_threshold,
decode (mc.is_enabled,1,'Yes',0,'No') is_enabled
FROM sysman.gc_metric_columns_target emc,
(SELECT policy_guid metric_guid,
NVL(warn_threshold,' ') warning_threshold,
NVL(crit_threshold,' ') critical_threshold,
coll_name
FROM sysman.mgmt_policy_assoc_cfg_params
WHERE object_guid IN
(SELECT target_guid FROM sysman.mgmt_targets WHERE target_name='&&targetName' AND target_type='&&targetType'
)
AND param_name=' '
) thr, sysman.MGMT_COLLECTIONS mc
WHERE entity_type = '&&targetType'
AND entity_name = '&&targetName'
AND usage_type =0
and entity_guid = mc.object_guid
and thr.coll_name = mc.coll_name
AND emc.metric_column_guid=thr.metric_guid(+)
order by metric_group asc;

-- target metrics history

SELECT *  FROM MGMT$METRIC_DETAILS WHERE TARGET_GUID = 'C0E24346D51785AFAF7B0F7C4C9D91E3';
SELECT *  FROM sysman.MGMT$METRIC_DETAILS@EMCC_REPOSITORY WHERE TARGET_NAME = '172.20.16.224';

select * from sysman.MGMT_COLLECTIONS;


-- latest target metric value 

--Java heap usage
 
     SELECT TARGET_NAME,TARGET_TYPE,METRIC_LABEL,COLUMN_LABEL,COLLECTION_TIMESTAMP,VALUE
       FROM MGMT$METRIC_DETAILS
      WHERE     TARGET_NAME = '/Farm01_bpelpr/bpelpr/BPEL'
            AND METRIC_LABEL = 'JVM Metrics'
            AND COLUMN_LABEL = 'Heap Usage (%)'
            AND COLLECTION_TIMESTAMP > SYSDATE - 2 / 24
   ORDER BY COLLECTION_TIMESTAMP DESC
FETCH FIRST 1 ROW ONLY;

--FS usage

      SELECT TARGET_NAME,TARGET_TYPE,METRIC_LABEL,COLUMN_LABEL,COLLECTION_TIMESTAMP,VALUE
       FROM MGMT$METRIC_DETAILS
      WHERE     TARGET_NAME = '172.20.16.224'
            AND METRIC_LABEL = 'Filesystems'
            AND COLUMN_LABEL = 'Filesystem Space Available (%)'
            AND KEY_VALUE = '/ora_data1'
            AND COLLECTION_TIMESTAMP > SYSDATE - 8 / 24
   ORDER BY COLLECTION_TIMESTAMP DESC
FETCH FIRST 1 ROW ONLY;

-- метрики со смещением во времени

select entity_name, entity_type, metric_group_name from sysman.gc_metric_values_latest where COLLECTION_TIME != COLLECTION_TIME_UTC + 3/24;

-- все метрики для определенного таргета

SELECT TARGET_NAME,
                TARGET_TYPE,
                METRIC_LABEL,
                COLUMN_LABEL,
                COLLECTION_TIMESTAMP,
                VALUE 
           FROM SYSMAN.MGMT$METRIC_DETAILS_SINGLE_NUM WHERE COLLECTION_TIMESTAMP >= sysdate - 1 and TARGET_NAME = 'spur_spur1'  ORDER BY COLLECTION_TIMESTAMP desc;
		   
-- "оптимизированный" селект для быстрого выбора значения нужной метрики

      SELECT TARGET_NAME,TARGET_TYPE,METRIC_LABEL,COLUMN_LABEL,COLLECTION_TIMESTAMP,VALUE,TARGET_GUID,METRIC_GUID
       FROM MGMT$METRIC_DETAILS
      WHERE     TARGET_GUID = '8EB32C1CE58352F5EAB59D6D12DAB5EA'
            AND METRIC_GUID = '6E65075DA52ACA744B4B8C3FCB018289'
            AND COLUMN_LABEL = 'Filesystem Space Available (%)'
            AND KEY_VALUE = '/ora_data3'
            AND COLLECTION_TIMESTAMP > SYSDATE - 8 / 24
   ORDER BY COLLECTION_TIMESTAMP DESC
FETCH FIRST 1 ROW ONLY;

Примеры селектов для монитроранга фс на хосте от имени пользователя MONITOR_PROD в БД DWH:

     SELECT TARGET_NAME,
            TARGET_TYPE,
            METRIC_LABEL,
            COLUMN_LABEL,
            COLLECTION_TIMESTAMP,
            VALUE
       FROM SYSMAN.MGMT$METRIC_DETAILS@EMCC_REPOSITORY
      WHERE     TARGET_GUID = 'E646AAC53102CDC11E7B4A62892F6A86'
            AND METRIC_GUID = '6E65075DA52ACA744B4B8C3FCB018289'
            AND COLUMN_LABEL = 'Filesystem Space Available (%)'
            AND KEY_VALUE = '/ora_data1'
            AND COLLECTION_TIMESTAMP > SYSDATE - 8 / 24
   ORDER BY COLLECTION_TIMESTAMP DESC
FETCH FIRST 1 ROW ONLY;

     SELECT TARGET_NAME,
            TARGET_TYPE,
            METRIC_LABEL,
            COLUMN_LABEL,
            COLLECTION_TIMESTAMP,
            VALUE
       FROM SYSMAN.MGMT$METRIC_DETAILS@EMCC_REPOSITORY
      WHERE     TARGET_GUID = 'E646AAC53102CDC11E7B4A62892F6A86'
            AND METRIC_GUID = '6E65075DA52ACA744B4B8C3FCB018289'
            AND COLUMN_LABEL = 'Filesystem Space Available (%)'
            AND KEY_VALUE = '/ora_data2'
            AND COLLECTION_TIMESTAMP > SYSDATE - 8 / 24
   ORDER BY COLLECTION_TIMESTAMP DESC
FETCH FIRST 1 ROW ONLY;

     SELECT TARGET_NAME,
            TARGET_TYPE,
            METRIC_LABEL,
            COLUMN_LABEL,
            COLLECTION_TIMESTAMP,
            VALUE
       FROM SYSMAN.MGMT$METRIC_DETAILS@EMCC_REPOSITORY
      WHERE     TARGET_GUID = 'E646AAC53102CDC11E7B4A62892F6A86'
            AND METRIC_GUID = '6E65075DA52ACA744B4B8C3FCB018289'
            AND COLUMN_LABEL = 'Filesystem Space Available (%)'
            AND KEY_VALUE = '/ora_data3'
            AND COLLECTION_TIMESTAMP > SYSDATE - 8 / 24
   ORDER BY COLLECTION_TIMESTAMP DESC
FETCH FIRST 1 ROW ONLY;


11. Reconfigure memory for agent (Doc ID 1952592.1)

change memory settings in file:
/u01/appem/agent_inst/sysman/config/emd.properties
---
#agentJavaDefines=-Xmx194M -XX:MaxPermSize=96M
agentJavaDefines=-Xmx512M -XX:MaxPermSize=128M

restart agent

12. Ldap configuration file in OMS (for enterprise user security in DB - manage AD users)

place file ldap.ora in 
/u01/appem/oracle/MW/oracle_common/network/admin/
directory, where /u01/appem/oracle/MW - OMS MW home

13. Для сбора RDA диагностики для emcc 13c нужно взять RDA из patch 24696574, распаковать на сервере OMS куда-нибудь, и запустить его вот так:

sh rda.sh -p CloudControl13c -y (т.к те RDA, который кладут в $MW_HOME/oracle_common/rda и в ORACLE_HOME агента - парадоксальным образом умеют только 12-й Cloud Control)





