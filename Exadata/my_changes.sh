# One OFF patches 

21.09.2017 !!! When installing  AUG QFDSP see Bug 26820978 : ORA-00600 [KTLIFLSPRVTBLKS_1] !!! - need fix for it or DB with UNIFIED audit will not work !
22.09.2017 - !!! Doc ID 2305283.1 Bug 26555609 - Database crash with ORA-600 [kszprocskgxpmap3] after storage server offline with database home software 12.1.0.2.170718 and later

to fix error: ORA-00600:[ktspfmtrng_al-2] during merge into EQ.ORDERS_BASE A using (...
apply both patches: 21542577 and 21957762

to awoid potential problems with NFS using for RMAN/DATA_PUMP:
apply both patches: 20513399 and 22515353 (for Oracle 12.1.0.2.160419)

to avoid slow gather table stats with incremental stats enabled (SLOW SQL_ID: ahpp2wqmx515j):
apply patch (already applied on spurdev): 19450139 (for Oracle 12.1.0.2.160719),
 
Patch 20582405: DGMGRL VALIDATE DATABASE SHOWS "STANDBY REDO LOGS NOT CONFIGURED FOR THREAD 0"
Patch 20144669: ILM POLICY SPECIFIED IN SPLIT PARTITION IS IGNORED

-- to be installed

17609164 for 12c Release 12.1.0.2.6ProactiveBP (ORA-7445 [kkoiqb] when select data - SR 3-14163700481)
 
--to be installed during next PSU (24340679 DATABASE PROACTIVE BUNDLE PATCH 12.1.0.2.161018) installation

24901520 (diagnostic patch for RA-07445 [lxkTrim()+930] error when selecting data - SR 3-13652822821)
19383839: UNIFIED AUDIT - NO LOGON OR FAILED LOGON ACTION CAPTURED
20582405 (DGMGRL VALIDATE DATABASE SHOWS "STANDBY REDO LOGS NOT CONFIGURED FOR THREAD 0")
19450139 (slow gather table stats with incremental stats enabled, SLOW SQL_ID: ahpp2wqmx515j)(if exists for Oct 2016 PSU)
 
1. Remove: 19450139 12.1.0.2.160719ProactiveBP >>>>>>>>>>>>> As 19450139 for version 12.1.0.2.160719 is conflicting on DB BP - 12.1.0.2.161018 
2. Apply: 24340679 12.1.0.2.0 DATABASE BUNDLE PATCH 12.1.0.2.161018 
3. Apply: 19450139 ON TOP OF DATABASE BP 12.1.0.2.161018 FOR LINUX X86-64 >>>>>>>>> Apply 19450139 available for version 12.1.0.2.161018 

Patch 20144669 is not required to be applied again as it was already part of your installation - 12.1.0.2.160719 

--already deinstalled

20783358 (ORA-07445: EXCEPTION ENCOUNTERED: CORE DUMP [KDSTHICOL()+408] [SIGSEGV])

--already installed

24901520 (diagnostic patch for RA-07445 [lxkTrim()+930] error when selecting data - SR 3-13652822821)
19450139 (slow gather table stats with incremental stats enabled, SLOW SQL_ID: ahpp2wqmx515j, for Oracle 12.1.0.2.160719)
21239530 (DIFFERENCES IN DBA_TABLESPACES AND DBA_TABLESPACE_USAGE_METRICS)
20144669 (ILM POLICY SPECIFIED IN SPLIT PARTITION IS IGNORED)(if exists for Oct 2016 PSU)

# Start db at mr01vm01 (disaster 05.10.2016)

Startup mount pfile=/home/oracle/pfile.793.905904501
Alter database open read only;

# Init parameters

--for change during the next DB restart


--changed already 

--fix error ORA 3137 [kpotxpop: no ATX frame] (Doc ID 2169788.1)

alter system set open_links = 8 COMMENT='changed from default (4) by chistoviy 16.12.2016' scope = spfile sid = '*';
alter system set open_links_per_instance = 8 COMMENT='changed from default (4) by chistoviy 16.12.2016' scope = spfile  sid = '*';

# ASM1 (mr,var)

ALTER DISKGROUP DATAC1 SET ATTRIBUTE 'DISK_REPAIR_TIME'='16.0h';
ALTER DISKGROUP RECOC1 SET ATTRIBUTE 'DISK_REPAIR_TIME'='16.0h';

# Oracle TFA tool upgrade (done at all domU except mr01vm01) Doc ID 1513912.1

run as oracle user
cd ~/patches && mkdir 21757377 && unzip p21757377_121020_Generic.zip -d 21757377/ && rm p21757377_121020_Generic.zip && . ~/.setASM && tfactl print config

run as root user
/home/oracle/patches/21757377/installTFALite -silent && tfactl print config

# Fix errors

1) ORA-07445: exception encountered: core dump [kdstHiCol()+590] [SIGSEGV] [ADDR:0x41]  (SR 3-13432150911)

alter session set OPTIMIZER_ADAPTIVE_FEATURES=false;

2) If you find the ORA-07445 error with [kdstHiCol] you can please update this SR with the alert log file and trace files into 	SR 3-1296423620

3) ORA-07445: exception encountered: core dump [kkoiqb()+17209] [SIGSEGV] (SR 3-14163700481)

alter session set "_optimizer_cost_based_transformation" = off; 
OR 
alter session set "_complex_view_merging" = false; 
OR 
alter session set "_optimizer_vector_transformation"=FALSE; 

# PDU snmp configuration

https://docs.oracle.com/cd/E19657-01/html/E23956/z40001422037985.html#scrolltoc , это значит, что SNMP просто выключен.

Правильно должно быть (snmp версии 2c для Cloud Control должно хватить):

set net_snmp_version=1

И, поскольку тут у вас пустой список контроля доступа, то (делаем read-only доступ для всех, community public)

set snmp_nms_host.1=0.0.0.0
set snmp_nms_community_readonly.1=public
set snmp_nms_accessright.1=0
set snmp_nms_enable.1=On

#Physical DB cell
vi /etc/ssh/sshd_config
AllowGroups dbmusers root
service sshd restart

echo 'snmptrapd : ALL' >> /etc/hosts.allow
echo 'authCommunity   log,execute,net public'>> /etc/snmp/snmptrapd.conf
echo 'forward default udp:localhost:3872'>> /etc/snmp/snmptrapd.conf
chkconfig snmptrapd on
service snmptrapd start

vi /etc/hosts
# oracle enterprise manager 13c server
10.63.140.31 emcc.moex.com emcc

#Storage cell

vi /etc/hosts
# oracle enterprise manager 13c server
10.63.140.31 emcc.moex.com emcc

install telnet

#DB cell

# Изменение pingtarget для Сlusterware на localhost для устранения ошибки с перезагрузкой сетевого интерфейса
# при этом listener становится недоступен (перезапускается)

crsctl stat res -t
crsctl stop res ora.net1.network -f -unsupported
srvctl modify network -netnum 1 -pingtarget '127.0.0.1'
srvctl start scan_listener
srvctl start listener
srvctl start cvu
crsctl start res ora.ons -unsupported
crsctl stat res -t
# if some resourses still offline, start them
srvctl start service -db dbm02 -service "vdrf_prim"
srvctl start vip -vip mr01vm05 -verbose

#ping targets was before my changes (default GW in OS)
mr01vm01: 10.63.140.247
mr01vm02: 10.63.141.247
mr01vm03: 10.63.141.247
mr01vm04: 10.63.143.247
mr01vm05: 10.63.144.247

# Предложенное Oracle решение - изменение CHECK_INTERVAL
# для ресурса ora.net1.network на 10 сек (по умолчанию 1 сек)

crsctl stat res -t
crsctl status resource ora.net1.network -p | grep CHECK | grep -v OFFLINE
crsctl modify resource ora.net1.network -attr "CHECK_INTERVAL=10" -unsupported
crsctl modify resource ora.net1.network -attr "CHECK_TIMEOUT=120" -unsupported
crsctl status resource ora.net1.network -p | grep CHECK | grep -v OFFLINE
crsctl stat res -t

# Изменение ping target на адрес балансировщика для каждой из Exadata
# Для EXADATA DSP: 10.63.14.240, Для EXADATA M1: 196.3.4.240, это «балансировщики F5». Соотвественно на М1 и DSP

crsctl modify resource ora.net1.network -attr "CHECK_INTERVAL=1" -unsupported
crsctl modify resource ora.net1.network -attr "CHECK_TIMEOUT=0" -unsupported
crsctl stat res -t
crsctl stop res ora.net1.network -f -unsupported
srvctl modify network -netnum 1 -pingtarget '10.63.14.240' #либо '196.3.4.240'
srvctl start scan_listener
srvctl start listener
srvctl start cvu
crsctl start res ora.ons -unsupported
crsctl status resource ora.net1.network -p
crsctl stat res -t
# if some resourses still offline, start them
srvctl start service -db dbm02 -service "vdrf_prim"
srvctl start service -db spur -service "dwh_prim"
srvctl start scan
srvctl start vip -vip mr01vm01 -verbose

сделал для всех mr* и всех var* (изменил ping targets на DSP: 10.63.14.240, M1: 196.3.4.240)

проверка на появление ошибок в логе LISTENER после изменения:

grep 12537 /u01/app/oracle/diag/tnslsnr/`hostname -s`/listener/trace/listener.log | tail -15 | grep -v PORT=

grep "state changed from: ONLINE to: OFFLINE" /u01/app/oracle/diag/crs/`hostname -s`/crs/trace/crsd_orarootagent_root.trc

информация о проблемах ICMP PING в логе: */crs/trace/crsd_orarootagent_root.trc

# Уменьшить время блокировки после неудачного логина с 10 мин. до 10 сек серверах БД:

MOS Note: "Exadata - Exalogic: SSH long wait between retries, or user account locked out." (Doc ID 1458480.1)
Нужно отредактировать два файла:
  /etc/pam.d/sshd 
  /etc/pam.d/login
И в обоих изменить lock_time с 600 сек до 10:

Было: auth required pam_tally2.so deny=5 onerr=fail lock_time=600
Стало: auth required pam_tally2.so deny=5 onerr=fail lock_time=10

После редактирования нужно перезапустить ssh: 
service sshd restart

Просмотр и сброс неудачных попыток авторизации для пользовтеля (от root)

pam_tally2 --user oracle
pam_tally2 --user oracle --reset

после этого проверить вход (по tail -f /var/log/secure)

hand_award-non

# резрешение исопльзовать crontab для oracle

echo oracle > /etc/cron.allow

# Отменить окончание действия пароля пользователя oracle на серверах БД для резервной Экзадаты:

Команда изменения: chage -I -1 -m 0 -M 99999 -E -1 oracle
Проверка результата: chage -l oracle

vi /etc/hosts
# oracle enterprise manager 13c server
10.63.140.31 emcc.moex.com emcc

echo 'snmptrapd : ALL' >> /etc/hosts.allow
echo 'authCommunity   log,execute,net public'>> /etc/snmp/snmptrapd.conf
echo 'forward default udp:localhost:3872'>> /etc/snmp/snmptrapd.conf
chkconfig snmptrapd on
service snmptrapd start

install telnet

# .bash_profile for root

export ORAENV_ASK=NO
export ORACLE_SID=+ASM1
source /usr/local/bin/oraenv
unset ORAENV_ASK

# allow cron for oracle

echo oracle >> /etc/cron.allow

В кластере базе DWH в базах spur и spurstb cозданы три новых сервиса:
DWH_PRIM DWH_STB DWH_SNAP

DWH_PRIM  - для режима основной базы, 
DWH_STB  - для стендбайн
DWH_SNAP – для стендбай в режиме снапшота


На mr01vm01:
srvctl add service -d spur -service DWH_PRIM -role PRIMARY -preferred spur1
srvctl add service -d spur -service DWH_STB -role PHYSICAL_STANDBY -preferred spur1
srvctl add service -d spur -service DWH_SNAP -role SNAPSHOT_STANDBY -preferred spur1

На var01vm01:
srvctl add service -d spurstb -service DWH_PRIM -role PRIMARY -preferred spurstb
srvctl add service -d spurstb -service DWH_STB -role PHYSICAL_STANDBY -preferred spurstb
srvctl add service -d spurstb -service DWH_SNAP -role SNAPSHOT_STANDBY -preferred spurstb

# data guard configuration

EDIT DATABASE spur SET PROPERTY LogXptMode = 'ARCH';

# domU *vm01.moex.com,*vm02.moex.com,*vm05.moex.com

C:\Work\Docs\dba_docs\DB Tasks\Exadata\Administrator_procedures\Adding a New LVM Disk to a User Domain.sh

for mr01vm01.moex.com,mr01vm02.moex.com reboot and step 4 are required

#Changing memory structures (add more SGA and PGA) 

vm.nr_hugepages задается в единицах, равных 2Mb. 
vm.nr_hugepages должен включать SGA всех экземпляров БД и ASM (~2ГБ) (при условии, что для них задан memory_target = 0). Для этого хоста следует учитывать экземпляры dbm051, -MGMTDB (~1ГБ) и +ASM1.

Последние два, исходя из /proc/meminfo вместе использовали 1018 hugepages. Таким образом, общий объем hugepages равен ~ SGA в МБ/2МБ + 1020 (Размер одной memory hugepage ~ 2МБ)

значение параметра ядра (/etc/sysctl.conf) vm.nr_hugepages

Нужно устанавливать параметры 
pga_aggregate_target и pga_aggregate_limit (реальное ограничение PGA) равным макс. размеру PGA

добавить лимиты памяти в /etc/security/limits.conf (в Кбайтах, равные макс. размеру SGA из всех экз. БД на хосте) memlock задается в единицах, равных 1kb.

oracle    soft     memlock 
oracle    hard     memlock 

#mr01vm01.moex.com

vi /etc/security/limits.conf

было
oracle    soft     memlock 59487120
oracle    hard     memlock 59487120

стало
oracle    soft     memlock 146800640
oracle    hard     memlock 146800640

vi /etc/sysctl.conf

было
vm.nr_hugepages=13954

стало
vm.nr_hugepages=68000

sysctl -p

#mr01vm03.moex.com

vi /etc/security/limits.conf

было
oracle    soft     memlock 29711340
oracle    hard     memlock 29711340

стало
oracle    soft     memlock 59422680
oracle    hard     memlock 59422680

vi /etc/sysctl.conf

было
vm.nr_hugepages=7474

стало
vm.nr_hugepages=25000

sysctl -p

#(mr/var01)vm03.moex.com

vi /etc/sysctl.conf

было
vm.nr_hugepages=4242 #для 16ГБ

стало
vm.nr_hugepages=14000 #для 32ГБ (hugepages используются ТОЛЬКО для SGA!)

sysctl -p

# cron for oracle

# chistoviy

# daily tasks

# delete archivelogs from local DB (enable if daily backup task in emcc is disabled)
#00 05,10,15,20 * * * . ~/.setSpur; echo 'delete noprompt archivelog all;' | rman target / >> /home/oracle/delete_archivelog.log 2>&1

# non periodic tasks


# cron for oracle on standby servers:

# mikhaylovlv
# Database restart script for ADG; Restarts standby database after crash and failed recovery.
*/10 * * * * /home/oracle/jet/adg_check_recovery.sh spurstb >> /home/oracle/jet/adg_check_recovery.log 2>&1

# chistoviy

# daily tasks

# delete archivelogs from local DB (enable if daily backup task in emcc is disabled)
00 16 * * * . ~/.setSpur; rman target / cmdfile=rman_backup_archivelog.rman >> /home/oracle/rman_backup_archivelog.log 2>&1

#mr01vm04.moex.com,#mr01vm05.moex.com

/etc/ssh/sshd_config строки ListenAddress 10.63.143.40 и ListenAddress 10.63.144.29 соответсвенно


Бекапные скрипты (dpump и rman) выложил в SVN:
---
http://172.20.16.132:18080/svn/CSD/MOEX_COMMON/development/LDWH/BACKUP/

#mr01vm05.moex.com

Добавил маршрут для двух AD серверов НРД для интерфейса bondeth0:

vi /etc/sysconfig/network-scripts/route-bondeth0
#строка
172.20.18.0/24 via 10.63.144.247

