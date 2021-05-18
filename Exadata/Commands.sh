-- Прайслисты

http://www.oracle.com/us/corporate/pricing/price-lists/index.html

-- Сбор диагностики:

Весь стек: RDA (Doc ID 314422.1), пример запуска: ./rda.sh -vCRP -e DFT/N_SQL_TIMEOUT=120,DFT/N_ATTEMPTS=25 -p Maa_Exa_Assessment
Health Check Validation Engine (HCVE) - pre & post install tests (Doc ID 1534723.1): ./rda.sh -T hcve
Кластерный стек (Clusterware): TFA diagcollect  (Doc ID 289690.1) и (Doc ID 1513912.2), пример запуска за период: 
$GI_HOME/tfa/bin/tfactl diagcollect -from "Aug/11/2016 01:50:00" -to "Aug/11/2016 02:00:00"
Инциденты: adrci (Doc ID 443529.1)
-- сбор диагностики для анализа внутренних ошибок (Doc ID 2165632.1) для помещения в ORA-XXXX-Troubleshooting Tool

--Инструкция сбору диангостики при обнаружении проблемы пропадания дисков Storage cell для ASM при высокой нагрузке на сервере БД:
В случае если проблема воспроизведется на ядре 2.6.39-400.294.4.el6uek.25316767 на domU необходимо собрать диагностику следующим образом:

--После обнаружения проблемы (недоступность дисков одного или нескольких cell для domU)  как root выполнить ДО ПЕРЕЗАГРУЗКИ domU

/root/rds-info.diag -v 1> rdsinfodiag.snapshot 2>&1
sleep 60
/root/rds-info.diag -v 1>> rdsinfodiag.snapshot 2>>&1
sleep 60
/root/rds-info.diag -v 1>> rdsinfodiag.snapshot 2>>&1

Starting and Stopping a Host Console

To start a serial console session to the host server from the Oracle ILOM CLI, console (r) role privileges are required in Oracle ILOM and the host server must be powered on.
To establish a serial console session to the host server from the Oracle ILOM CLI, type:

start /SP/console

To send a break to the host console press the Escape key and type: B
To exit the serial console session, press these keys: ESC and (

Для проверки наличия проблемы смотрим (сообщения вида "mr01vm01 kernel: RDS/IB: connection <192.168.10.12,192.168.10.8,7> dropped due to 'send completion error'"):

cat /var/log/messages | grep "192.168.10.*error" | more

-- анализ различных проблем с помощью tfactl

-- вывод возможных видов анализа

tfactl diagcollect -srdc -help

-- анализ ORA-00600

tfactl diagcollect -srdc ora600

-- быстрая проверка всех компонент через tfactl (от root)

tfactl summary

-- сравнительный анализ проблем производительности БД за период (указать проблемный и непроблемный период и имя БД)

tfactl diagcollect -srdc dbperf

-- сбор диагностики по проблемному sql_id через SQLT (sqlt, Doc ID 1683772.1)

cd /backup2/scripts/sqlt/run/
--sqlplus SQLTXPLAIN/Ahde%19y
sqlplus ARDB_USER
START sqltxtrxec.sql 59c2nm0m8jsvr Ahde%19y
START sqltxtract.sql 5zpcy29sgx73k Ahde%19y --упрощенный вариант (XTRACT Method)

-- очистка таблиц БД после выполнения sqlt (по идентификатору выполнения вида sqlt_s29381*)

sqlplus / as sysdba
@sqlt_s29381_purge.sql

--просмотр прогресса выполнения этой операции: SELECT * FROM SQLTXADMIN.sqlt$_log_v order by 1 desc;
(для более быстрого сбора SQLT можно использовать экспресс-методы (например, XPREXT, XPREXC))

-- анализ БД на предмет сравнения проблемного и непроблемного периодов

tfactl diagcollect -srdc dbperf
--вводим проблемный период
--вводим имя БД
--вводим кол-во дней до беспроблемного периода

Storage cell

-- сбор логов ExaWatcher за период (как на физических так и на виртуальных серверах - включая db_cell - dom0 и virtual db servers - domU)
/opt/oracle.ExaWatcher/GetExaWatcherResults.sh --from 08/26/2017_15:00:00 --to 08/26/2017_23:00:00
-- архив с результатом в /opt/oracle.ExaWatcher/archive/ExtractedResults
-- Sundiag
/opt/oracle.SupportTools/sundiag.sh
--ILOM snapshot
/opt/oracle.SupportTools/sundiag.sh snapshot

-- проверка IB switches (Doc ID 1538237.1)

Suppressing errors is done using following command (on IB switch as root):
 
ibqueryerrors.pl -rR -s RcvSwRelayErrors,XmtDiscards,XmtWait,VL15Dropped

--What I can suggest here is to clear the counters then stress the links so we can see which counters were generated a long time ago (as a result of nodes reboots, switch reboots or operations taken on site). 

-- clear errors
ibclearerrors 
ibclearcounters 

-- check errors
ibcheckerrors -v 
ibqueryerrors.pl 
ibdiagnet -c 500 
ibcheckerrors -v 
ibqueryerrors.pl 
ibnetdiscover 

--Please wait 30-60 minutes and then please invoke: 

ibdiagnet -c 500 
ibcheckerrors -v 
ibqueryerrors.pl 
ibnetdiscover 

Для очистки fault используйте в ILOM:
set component_path clear_fault_action=true
https://docs.oracle.com/cd/E19860-01/E21549/z4002bd41037689.html

-- информация о процессорах

dmidecode
DBMCLI> LIST DBSERVER attributes coreCount

-- изменение кол-ва ядер на DB сервере (http://docs.oracle.com/cd/E80920_01/DBMMN/maintaining-exadata-database-servers.htm#GUID-6177B070-EF7C-4858-869D-E82C5F8293C0)

-- Управление TFA Collector - Tool for Enhanced Diagnostic Gathering (Doc ID 1513912.2) 

/etc/init.d/init.tfa -h
tfactl print config --Настройки параметров
tfactl set autodiagcollect=ON --включение автосбора логов
tfactl set reposizeMB=10240 --установка размера репозитория в МБ
tfactl set help --просмотр вариантов изменения конфигурации
tfactl analyze --поиск ошибок за последний час
tfactl analyze -search "ORA-" -since 2d --поиск ошибок ORA в логах за последние 2 дня !!! запускать 2 раза, если первый раз нет результата и выполняется быстро 

-- перелинковка бинарников ORACLE_HOME для разрешения кластера:

https://docs.oracle.com/database/121/RACAD/cvt2rac.htm#RACAD8867

change the directory to the lib subdirectory in the rdbms directory under the Oracle home.

make -f ins_rdbms.mk rac_on
make -f ins_rdbms.mk ioracle

-- Если кластерные сервисы (любые команды через crsctl) не стартуют с сообщением:

crsctl status res -t
CRS-4535: Cannot communicate with Cluster Ready Services
CRS-4000: Command Status failed, or completed with errors.

нужно сделать следующее (проблема на domU после зависания dom0):

1) cd /tmp
2) cp -R .oracle/ .oracle_bak/
3) chmod 1777 .oracle_bak
4) chown root:oinstall .oracle_bak
5) ls -ld .oracle*
6) cd /tmp/.oracle
7) rm -rf *
8) crsctl enable has
9) crsctl enable crs
10) reboot 
11) если не стартует, делаем руками: crsctl start crs
12) reboot и проверяем, что сервисы поднимаются автоматом

ocrcheck
ocrcheck -local
$GRID_HOME/bin/crsctl check crs
$GRID_HOME/bin/crsctl stat res -t –init
ps -ef | egrep 'init|d.bin'

-- см. описание в документах
--How to remove Network socket files in a RAC Environment for Cluster/Resource startup issues (Doc ID 2099377.1)
--Troubleshoot Grid Infrastructure Startup Issues (Doc ID 1050908.1)

-- если не помогает,то рестартовать стек:

1.- Stop any process running of CRS
crsctl stop crs -f
2.- Unlock the software
# <CRS_HOME>/crs/install/rootcrs.pl -unlock
3.- Lock the software
# <CRS_HOME>/crs/install/rootcrs.pl -patch

-- Изменение параметров ресурсов  (пример для изменения двух параметров одновременно)

crsctl modify resource ora.net1.network -attr "CHECK_INTERVAL=10,CHECK_TIMEOUT=120" -unsupported

-- Остановка ресурсов clusterware при использовании Oracle restart

crsctl disable has
crsctl stop has

--запуск

crsctl enable has
crsctl start has

При использовании кластерной конфигурации:

crsctl disable crs
crsctl stop crs

crsctl enable crs
crsctl start crs
crsctl check crs

-- вывод используемой версии Clusterware и используемого патчлевела

crsctl query crs activeversion -f

-- если после отката/установки патчей GI/RDBMS возникает ошибка CRS-6706 при старте кластерных ресурсов, то выполняем root:

$GI_HOME/crs/install/roothas.pl -postpatch

-- перевод всех дисков из одной FAILGROUP (Storage cell) в ONLINE вручную:
. .setASM
sqlplus / as sysasm
ALTER DISKGROUP DATAC1 ONLINE DISKS in FAILGROUP MRCELADM02;
ALTER DISKGROUP RECOC1 ONLINE DISKS in FAILGROUP MRCELADM02;

-- возможно перед этим потребуется рестарт сервисов на Storage cell (можно сделать от имени celladmin)
cellcli
alter cell restart services all;

-- перезагрузка STORAGE CELL без влияния на БД (Doc ID 1188080.1)

as sysasm:

-- show disk_repair_time
select dg.name,a.value from v$asm_diskgroup dg, v$asm_attribute a where dg.group_number=a.group_number and
a.name='disk_repair_time';
-- change disk_repair_time
ALTER DISKGROUP DATAC1 SET ATTRIBUTE 'DISK_REPAIR_TIME'='16.0h';

on cell as celladmin (all results should by Yes)

cellcli -e list griddisk attributes name,asmmodestatus,asmdeactivationoutcome

--if the results of above statement were Yes for all, proceed with the next step (could run 10+ minutes):

cellcli -e alter griddisk all inactive

-- check results
cellcli -e list griddisk attributes name,asmmodestatus,asmdeactivationoutcome
cellcli -e list griddisk

--reboot CELL
shutdown -F -r now
-- if need shutdown, run
shutdown -h now

-- when reboot will proceed back all disks online

cellcli -e alter griddisk all active

-- check its status (must be ONLINE or SYNCING)

cellcli -e list griddisk
cellcli -e list griddisk attributes name, asmmodestatus

-- список патчей из БД версии 12с

with a as (select dbms_qopatch.get_opatch_lsinventory patch_output from dual)
    select x.*
      from a,
           xmltable('InventoryInstance/patches/*'
              passing a.patch_output
              columns
                 patch_id number path 'patchID',
                 patch_uid number path 'uniquePatchID',
                 description varchar2(80) path 'patchDescription',
                applied_date varchar2(30) path 'appliedDate',
                sql_patch varchar2(8) path 'sqlPatch',
                rollbackable varchar2(8) path 'rollbackable'
          ) x;

-- Задание трассировки для SCAN_LISTENER в lsnrctl

set current_listener LISTENER_SCAN1
show trc_level
set trc_level 16
save_config

--Настройки и ресурсы гипервизора - вывод команды 

xm info (на физическом db_cell)

Файлы настроек виртуальных серверов:

на физическом db_cell в /etc/xen/auto

информация по виртуальным процессорам

xm vcpu-list
xenpm get-cpu-topology

-- Доступ к БД на Exadata

нужен доступ к порту 1521 scan-listener (пример mr-scan.moex.com),
VIP IP (пример mr01vm01-vip.moex.com),
client ip вирт. сервера БД (mr01vm01.moex.com)

-- Управление виртуальными машинами (XEN)

с физического сервера БД (mrdbadm01	10.63.142.1 либо mrdbadm02 10.63.142.2)

запускаем chkconfig, ищем сервис xendomains (при необходимости отключаем его автозапуск, чтобы машины не стартовали)

Выключение виртуальных машин: 

xm shutdown mr01vm01.moex.com -w (либо xm -shutdown -a)

Включение виртуальных машин (указываем конфигурационный файл для включения): 

xm create /EXAVMIMAGES/GuestImages/mr01vm05.moex.com/vm.cfg

При перезагрузке DB_CELL машины должны подниматься автоматически, если не поднялись, команда для их старта

service xendomains start

-- Доступ к консоли из ILOM

To access the host serial console, type the command:
-> start /HOST/console

The serial console output appears on the screen.

Note - If the serial console is in use, stop and restart it using the stop /HOST/console command followed by the start /HOST/console command.

To return to the ILOM console, press ESC followed by the “(“ character (Shift-9).

-- оповещения по e-mail непосредственно с ILOM database cells и storage cells:

cd /SP/alertmgmt/rules/2
set type=email
set level=major
set destination=… (адреса почты администраторов через запятую)
set email_custom_sender=… (имя отправителя)

cd /SP/clients/smtp
set address=… (адрес почтового сервера)
set port=25
set state=enabled

Отправка тестового письма выполняется при помощи:

cd /SP/alertmgmt/rules/2
set testrule=true

(То письмо, которое будет результатом теста, будет иметь тему вида mrdbadm01-ilom:Test:Test:major и содержимое вида: --Alert Rule TEST MESSAGE-- This is a test of alert rule: 2)

--просмотр текущей конфигурации
show

-- оповещения на DB_CELLs (через dbmcli) --общий e-mail для оповещений: osa@moex.com

LIST DBSERVER DETAIL
alter dbserver smtpServer='osmtp.moex.com', smtpFromAddr='mrdbadm02.moex.com', smtpFrom='mrdbadm02', smtpToAddr='Andrey.Belorybkin@moex.com,Dmitriy.Savvateev@moex.com,Igor.Chistov@moex.com,Vladimir.Molostov@moex.com', notificationMethod='mail,snmp'
LIST DBSERVER DETAIL

-- оповещения на STORAGE_CELLs (через cellcli)

list cell attributes all detail
alter cell smtpServer='osmtp.moex.com', smtpFromAddr='mrceladm01.moex.com', smtpFrom='mrceladm01', smtpToAddr='Andrey.Belorybkin@moex.com,Dmitriy.Savvateev@moex.com,Igor.Chistov@moex.com,Vladimir.Molostov@moex.com', notificationMethod='mail,snmp'
list cell attributes all detail

--Включение write-back на флеш-кеше (По документиции Оракла число IOPs на запись должно увеличится до 10 раз)

Оракловые ноты:

Exadata Write-Back Flash Cache - FAQ (Doc ID 1500257.1)
Oracle Sun Database Machine Setup/Configuration Best Practices (Doc ID 1274318.1)

drop flashcache
list griddisk attributes name,asmmodestatus,asmdeactivationoutcome
alter griddisk all inactive
alter cell shutdown services cellsrv
alter cell flashCacheMode=writeback (операция заняла 10 мин на первом узле)
alter cell startup services cellsrv
alter griddisk all active
list griddisk attributes name, asmmodestatus
create flashcache all
list cell attributes flashCacheMode (должны получить: writeback)

-- тест Environment на IB switch (от имени root)

env_test

-- Использование oplan (подготовка инструкций для установки патчей)

set ORACLE_HOME to home to be patched

unzip patch: mkdir ~/17654567 && unzip ~/p17654567_121020_Generic.zip -d ~/17654567

$ORACLE_HOME/OPatch/oplan/oplan generateSteps ~/17654567/17654567

-- НЕЛЬЗЯ СТАВИТЬ MEMORY_TARGET когда стоит параметр USE_LARGE_PAGES=ONLY (тогда исп. SGA и PGA отдельно)

Если экземаляр не стартует из-за spfile:
1) startup pfile = '/u01/app/oracle/admin/spur/pfile/initspur1.ora.20160307';
2) create SPFILE='+DATAC1/spur/spfilespur.ora' (имя берем в $ORACLE_HOME/dbs/initspur1.ora) from pfile = '/u01/app/oracle/admin/spur/pfile/initspur1.ora.20160307';
3) shutdown immediate;
4) startup;

--Create Oracle RAC Database in Silent Mode on Exadata
cd $ORACLE_HOME/bin
/dbca -silent -createDatabase -templateName General_Purpose.dbc -g dbName EBSPROD -sid EBSPROD -sysPassword welcome1 -systemPassword welcome1 -sysm anPassword welcome1 -dbsnmpPassword welcome1 -emConfiguration LOCAL -storageType ASM -diskGroupName DATA_DAH1 -datafileJarLocation $ORACLE_HOME/assistants/dbca/ templates -nodeinfo dbserver1,dbserver2 -characterset AL32UTF8 -obfuscatedPass words false -sampleSchema false -asmSysPassword welcome1

-- space usage on ASM diskgroups
. oraenv
+ASM

asmcmd lsdg

sqlplus / as sysdba
SELECT name, free_mb, total_mb, free_mb/total_mb*100 as percentage FROM v$asm_diskgroup; (тем же запросом видно на БД, испоьзующей этот ASM экземпляр)

-- информация о дисках ASM

select * from v$asm_disk;

select * from V$ASM_DISKGROUP;
Для открытия доступа для БД на внешние сервера нужно открыть порт LISTENER (1521)
на внешнем сервере для адресов клиентской сети виртуальной машины: Client Scan IPs,Client IP Address, например:
mr-scan.moex.com (3 адреса) и mr01vm01.moex.com (1 адрес)

-- space usage of EACH database

  SELECT SUBSTR (alias_path,
                 2,
                   INSTR (alias_path,
                          '/',
                          1,
                          2)
                 - 2)
            Database,
         ROUND (SUM (alloc_bytes) / 1024 / 1024 / 1024, 1) "GB"
    FROM (    SELECT SYS_CONNECT_BY_PATH (alias_name, '/') alias_path, alloc_bytes
                FROM (SELECT g.name disk_group_name,
                             a.parent_index pindex,
                             a.name alias_name,
                             a.reference_index rindex,
                             f.space alloc_bytes,
                             f.TYPE TYPE
                        FROM v$asm_file f
                             RIGHT OUTER JOIN v$asm_alias a
                                USING (group_number, file_number)
                             JOIN v$asm_diskgroup g USING (group_number))
               WHERE TYPE IS NOT NULL
          START WITH (MOD (pindex, POWER (2, 24))) = 0
          CONNECT BY PRIOR rindex = pindex)
GROUP BY SUBSTR (alias_path,
                 2,
                   INSTR (alias_path,
                          '/',
                          1,
                          2)
                 - 2)
ORDER BY 2 DESC;

-- если DB_LINK на БД вне Exadata (БД с тем же именем, что и на Exadata) выдает ошибку ORA-02085:

select name, value from v$parameter where name in ('db_name', 'db_domain', 'global_names');

--отключаем параметр global_names на уровне сессии, должно заработать

alter session set global_names = false; 
select * from v$instance@spur30;
select min(TRADEDATE) from curr.trades_base@spur30;

-- Включение INmemory option

alter system set inmemory_size = 15G scope = both sid = '*';

select * from v$inmemory_area;
select  * FROM v$im_segments; 
select  * FROM v$IM_COLUMN_LEVEL;

-- Просмотр инфорации об объектах во Flash Cashe

cellcli:

list flashcache detail
list cell attributes flashcachemode
list metriccurrent where objectType = 'FLASHCACHE'
list metricdefinition attributes name, description where objectType = 'FLASHCACHE'
list flashcachecontent where objectNumber = 131044 detail;
list flashcachecontent where dbUniqueName = SPUR;

sql:

SELECT * FROM DBA_SEGMENTS WHERE SEGMENT_NAME LIKE 'EXA%';
SELECT * FROM DBA_SEGMENTS where CELL_FLASH_CACHE <> 'DEFAULT';

SELECT
    cellname cv_cell_path
  , CAST(extract(xmltype(confval), '/cli-output/cell/name/text()') AS VARCHAR2(20))  cv_cellname
  , CAST(extract(xmltype(confval), '/cli-output/cell/releaseVersion/text()') AS VARCHAR2(20))  cv_cellVersion 
  , CAST(extract(xmltype(confval), '/cli-output/cell/flashCacheMode/text()') AS VARCHAR2(20))  cv_flashcachemode
  , CAST(extract(xmltype(confval), '/cli-output/cell/cpuCount/text()')       AS VARCHAR2(10))  cpu_count
  , CAST(extract(xmltype(confval), '/cli-output/cell/upTime/text()')         AS VARCHAR2(20))  uptime
  , CAST(extract(xmltype(confval), '/cli-output/cell/kernelVersion/text()')  AS VARCHAR2(40))  kernel_version
  , CAST(extract(xmltype(confval), '/cli-output/cell/makeModel/text()')      AS VARCHAR2(100))  make_model
FROM 
    v$cell_config  -- gv$ is not needed, all cells should be visible in all instances
WHERE 
    conftype = 'CELL'
ORDER BY
    cv_cellname;
	
SELECT STATISTIC#, VALUE VAL FROM V$MYSTAT WHERE STATISTIC# IN (SELECT STATISTIC# FROM V$STATNAME WHERE NAME = 'cell flash cache read hits');


-- Перерегистрация базы  в clusterware

[root@var01vm01 trace]# srvctl config database -d spurstb -verbose Database unique name: spurstb Database name: var01vm01 Oracle home: /u01/app/oracle/product/12.1.0.2/dbhome_1
Oracle user: oracle
Spfile: +DATAC1/ASM/PARAMETERFILE/spfilespurstb.ora.966.910094509
Password file: +DATAC1/ASM/PASSWORD/pwdasm.967.910094607
Domain:
Start options: read only
Stop options: immediate
Database role: PHYSICAL_STANDBY
Management policy: AUTOMATIC
Server pools:
Disk Groups: DATAC1,RECOC1
Mount point paths:
Services:
Type: RAC
Start concurrency:
Stop concurrency:
OSDBA group: dba
OSOPER group: dba
Database instances: spurstb
Configured nodes: var01vm01
Database is administrator managed

srvctl stop database -d spurstb

srvctl remove database -d spurstb
srvctl add database -d spurstb -o /u01/app/oracle/product/12.1.0.2/dbhome_1 -p +DATAC1/ASM/PARAMETERFILE/spfilespurstb.ora.966.910094509 -r PHYSICAL_STANDBY -pwfile +DATAC1/ASM/PASSWORD/pwdasm.967.910094607 -s mount 'read only' -t IMMEDIATE -n var01vm01 srvctl add instance -d spurstb -i  spurstb -n var01vm01 srvctl start database -d spurstb

-- Вывод параметров БД в clusterware

crsctl status resource ora.spur.db -p
srvctl config database -d spurstb -verbose
crsctl status resource -w "TYPE = ora.database.type" -v

-- Перезапуск БД (и Primary и Standby)

srvctl stop database -d spurstb
srvctl start database -d spurstb


Создание дисков на storage cells (Doc ID 1513068.1), see: 3.4 Resizing Grid Disks in "Oracle® Exadata Database Machine Maintenance Guide" and Doc ID 1551288.1

cellcli

list celldisk attributes name,freespace, freespacemap
list griddisk attributes name,size,offset

-- содержимое файла инициализации для ASM экземпляра (sqlplus / as sysasm, create pfile from spfile;)

--12.2

+ASM1.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from in memory value
*.asm_diskgroups='RECOC6'#Manual Mount
*.asm_diskstring='o/*/DATAC6_*','o/*/RECOC6_*'
*.asm_power_limit=1
*.audit_sys_operations=TRUE
*.audit_syslog_level='local0.info'
+ASM1.cluster_interconnects='192.168.10.39:192.168.10.40'
*.large_pool_size=12M
*.memory_target=0
*.pga_aggregate_target=419430400
*.processes=1024
*.remote_login_passwordfile='EXCLUSIVE'
*.sga_target=3221225472

12.1

+ASM1.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from in memory value
+ASM1.asm_diskgroups='RECOC1'#Manual Mount
*.asm_diskstring='o/*/DATAC1_*','o/*/RECOC1_*'
*.asm_power_limit=1
*.audit_sys_operations=TRUE
*.audit_syslog_level='local0.info'
+ASM1.cluster_interconnects='192.168.11.11:192.168.11.12'
*.large_pool_size=12M
*.memory_target=0
*.pga_aggregate_target=419430400
*.processes=1024
*.remote_login_passwordfile='EXCLUSIVE'
*.sga_target=2147483648




