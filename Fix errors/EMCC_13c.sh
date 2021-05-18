Availability evaluation Error for agent (EMCC could not reach agent URL)

1) On agent host execute

emctl config agent addinternaltargets
emctl upload agent

2) Last successful upload must change after it


If host is DOWN (detected by partner agent) error shown then:

1) Check the agent availability from the partner agent:

telnet <agent host name> 3872
2) change (if agent is unavailable) partner agen of disable it:

runs from emcc server

emcli login -username=sysman

emcli manage_agent_partnership -remove_agent_partnership -monitored_agent="mrdbadm02.moex.com:3872"
emcli manage_agent_partnership -disable_agent_partnership -monitored_agent="mrdbadm02.moex.com:3872"

if need to change partner agent after it:

emcli manage_agent_partnership -enable_agent_partnership -monitored_agent="mr01vm01.moex.com:3872"
emcli manage_agent_partnership -add_agent_partnership -monitored_agent="mr01vm01.moex.com:3872" -partner_agent="emcc:3872"

3) Restart agent on that host (for which down error is detected)

emctl stop agent
emctl start agent

Diagnostic of OMS:

EMDIAG Repvfy 12c /13c Kit - How to Use the Repvfy 12c/13c kit (Doc ID 1427365.1)


Установка БД/GRID на хосты с помощью процедуры PROVISIONING требует открытия порта 3872 (порт агента на сервере OMS)
 на сервере с SOWTWARE LIBRARY (обычно это основной OMS) для хоста, куда ставим БД
 
4) Patch OMS (u01/appem/oracle/MW/OMSPatcher/wlskeys/property_file - prorepty file, created beforehand)
 
 As oracle user:
 
export ORACLE_HOME=/u01/appem/oracle/MW (OMS ORACLE_HOME)

update omspatcher (in /u01/appem/oracle/MW/OMSPatcher directory) to latest version (from Patch 19999993, the same as OPatch from Doc ID 224346.1)

./omspatcher version
 
unzip patch file into /u01/app/oracle/oradata/distrib/patches/oms/22920724
cd /u01/app/oracle/oradata/distrib/patches/oms/22920724/22920724 (where bundle.xml file exists)

omspatcher apply -analyze  -property_file /u01/appem/oracle/MW/OMSPatcher/wlskeys/property_file
 
if all apply and rollback step were analyzed successfuly, then run:
 
emctl stop oms 
omspatcher apply -property_file /u01/appem/oracle/MW/OMSPatcher/wlskeys/property_file
emctl start oms

Information about patches using java (OPatch 13.9.1.0.0):

/u01/appem/oracle/MW/OPatch/opatch lsinventory -jre /u01/appem/oracle/MW/oracle_common/jdk/jre

-- Нужно ставить еще BUNDLE патчи для FMW 12.1.3.0.0 (WLS PATCH SET UPDATE ...)

-- патч для устранения ошибки ORA-01422 при добавлении новых TARGETS (Doc ID 2149984.1) 

22985211 
 
5) Diagnostic of OMS:

EMDIAG Repvfy 12c /13c Kit - How to Use the Repvfy 12c/13c kit (Doc ID 1427365.1)

after install run (here emrep is TNS service name of OMS database):

repvfy verify -tns emrep -details

detailed analyze:
repvfy verify -level 9 -tns emrep -details

--enable DEBUG mode for OMS

emctl set property -name log4j.rootCategory -value 'DEBUG, emlogAppender, emtrcAppender' -module logging

-- disable DEBUG mode for OMS after testing

emctl set property -name log4j.rootCategory -value 'INFO, emlogAppender, emtrcAppender' -module logging

6) Change timezone for OMS agent (1005. Active Agents with clock-skew problems in repvfy output)

agent_13.1.0.0.0/bin/emctl config agent getTZ

set | grep TZ

export TZ=Etc/GMT-3

unset _

agent_13.1.0.0.0/bin/emctl config agent getTZ

--must be Etc/GMT-3

agent_13.1.0.0.0/bin/emctl stop agent

agent_13.1.0.0.0/bin/emctl resetTZ agent

as REPOSITORY USER (sysman) in OMS DB:

exec mgmt_target.set_agent_tzrgn('172.20.16.173:3872','Etc/GMT-3');
commit;

agent_13.1.0.0.0/bin/emctl start agent

In analysis result time zone missmatch for that agent must be dissapeared
(section Active Agents with clock-skew problems):

repvfy verify -level 9 -tns emrep -details

7) Metric names and targets in METRIC_NAME column of MGMT$METRIC_COLLECTION view (OMS DB).

'get metric from agent:'
./emctl getmetric agent SPURSTB,oracle_database,problemTbsp

'get metric collection schedule for the given target (pdu)'
emctl status agent scheduler | grep pdu
'try to get the metric from schedule manually'
emctl control agent runCollection mrsw-pdub01.moex.com:oracle_exa_pdu PDUModule1PhaseValues

8) Загрузка патчей через emcli

emcli login -username=chistoviy

emcli upload_patches -from_host="emcc" -patch_files="/u01/app/oracle/oradata/distrib/patches/database/p19325810_121029ProactiveBP_American English_M.xml;/u01/app/oracle/oradata/distrib/patches/database/p19325810_121029DBEngSysandDBIM_Linux-x86-64.zip"
(сначала указываем метафайл, затем архив с патчем, копируем на указанный хост (OMS))
!!! Для хоста должны быть заданы preferred credentials для успешной загрузки

9) Работа с targets через emcli

--просмотр

emcli list -help
-- resource берем из листинга предыдущей команды
emcli list -resource="Targets" -search="TARGET_NAME LIKE 'var%.moex.com'" -search="TARGET_TYPE='oracle_si_host_remote'" -colsize="TARGET_GUID:50,TARGET_NAME:30"
emcli list -resource="TargetProperties"

--удаление

emcli delete_target -name="vardbadm02.moex.com" -type="oracle_si_host_remote"

10) Проталкивание метрик для агентов в репозиторий (когда метрики не обновляются/загружаются)

-- выполнять после решения проблемы с clock-skew для агента (см. п. 6 выше)

Full blackout of agent's' host in OMS for 10 mins (blackout must be finished automaticaly) --or 15 mins

emctl stop agent
emctl clearstate agent
sleep 10m
cd /u01/appem/agent_inst/sysman/emd; rm -rf a*/* b*/* c*/c d*/* l*/* m*/* s*/* t*/* u*/*
emctl start agent
emctl status agent

--IN OMS at agent page within 10-30 minutes all monitored targets for this agent must be "Yes" for Uploading

12) Backup конфигурации OMS в заданный каталог

emctl exportconfig oms -sysman_pwd welcome1 -dir /u01/app/oracle/oradata/backup/exportconfig_oms

13) Backup OMS_HOME binaries

zip -r9 /u01/app/oracle/oradata/backup/oracle_home/u01_appem_oracle/MW_20170103_before_patch_25155095/MW.zip /u01/app/oracle/product/em13c/oracle/MW > /u01/app/oracle/oradata/backup/oracle_home/u01_appem_oracle/MW_20170103_before_patch_25155095/archive.log

14) Перезапуск процесса агента, когда невозможно выполнить это через emctl

--проблема
emctl start agent
Oracle Enterprise Manager Cloud Control 13c Release 1
Copyright (c) 1996, 2015 Oracle Corporation.  All rights reserved.
Agent status could not be determined.  Check the agent process

ps -ef |grep java | grep $AGENT_HOME
kill -9 <agent_process_pid>
emctl start agent

15) Отключить java connection pool в OMS (ошибка java.lang.NullPointerException в Top Activity для БД)

emctl set property -name use_pooled_target_connections -value false
restart oms

сбросить на значение по умолчанию

emctl reset property -name use_pooled_target_connections

16) Выполнение резервного копирования бинарных файлов OMS и создание точки отката в БД репозитория OMS перед установкой патчей

-- скрипту передаются 2 параметра: номер устанавливаемого патча/патчсета, каталог, куда нужно архивировать MW_HOME OMS
~/backup_before_patch_OMS_or_OMS_repository.sh 24897689 /u01/app/oracle/oradata/backup/oracle_home/u01_appem_oracle > ~/backup_before_patch_24897689.log

-- после успешного выполнения бекапа и последующей установки патчей нужно удалить самый старый каталог из каталога с бекапами (должно остаться 2 последних каталога)
-- и самую старую RESTORE POINT из БД репозитория (должно быть 2 последних RESTORE POINT, соответствующих бекапам файлов MW_HOME OMS) через sqlplus

17) Обновление JAVA для агента

в <agent_home>/oracle_common/jdk -> на новый, старый каталог <agent_home>oracle_common/jdk переименовать.

cd /u01/appem/java_1.8
unzip p25300639_180121_Linux-x86-64.zip
tar zxvf server-jre-8u121-linux-x64.tar.gz
-- JAVA will be unzipped in /u01/appem/java_1.8/jdk1.8.0_121

emctl stop agent
cd /u01/appem/agent_13.1.0.0.0/oracle_common
mv jdk jdk_old
ln -s /u01/appem/java_1.8/jdk1.8.0_121 jdk
emctl start agent

--проверка корректности сбора метрик (ошибки Unsupported ciphersuite TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 не будет)
emctl control agent runCollection mrceladm01.moex.com:oracle_exadata Response

18) Сбор информации по доступности ILOM после выполнения процедуры ILOM Reset (Doc ID 2278219.1, Doc ID 2099390.1)

emctl config agent listtargets |grep -i ilom
emctl control agent runCollection mrdbadm02-ilom.moex.com:oracle_exa_ilom Response
emctl control agent runCollection mrdbadm01-ilom.moex.com:oracle_exa_ilom Response

19) После выполнения UPGRADE агентов до версии 13.2 

Agent Home             : /u01/app/oracle/appem/agent_inst
Agent Log Directory    : /u01/app/oracle/appem/agent_inst/sysman/log
Agent Binaries         : /u01/app/oracle/appem/agent_13.2.0.0.0

для устранения ошибки "EM Configuration issue.  not found." см. Doc ID 2181554.1, нужно выполнить

export DEFAULT_EMSTATE=/u01/app/oracle/appem/agent_inst (DEFAULT_EMSTATE=$AGENT_HOME)

20) java.sql.SQLException: Connection Cache with this Cache Name does not exist

update OMS and agents with latest patches from Doc ID 2219797.1

cd <OMS_HOME>/bin 
./emctl set property -name oracle.sysman.db.perf.reposconn.inactivity_timeout -value "0" 
./emctl set property -name oracle.sysman.db.perf.reposconn.abandoned_connection_timeout -value "0" 
./emctl stop oms -all 
./emctl start oms 

if not helps:

<OMS_HOME>/bin/emctl get property -name use_pooled_target_connections 
<OMS_HOME>/bin/emctl set property -name use_pooled_target_connections -value false 
<OMS_HOME>/bin/stop oms -force 
<OMS_HOME>/bin/start oms 


