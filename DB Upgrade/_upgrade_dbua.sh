0) Login as oracle user

1) 
unset
ORACLE_HOME
TNS_ADMIN

2) install_oracle into new ORACLE_HOME

./runInstaller -silent -noconfig -responseFile "/mnt/oracle/temp/distrib/database/11.2.0.4/db_install.rsp"

3) set ORACLE_HOME=new_oracle_home (в который ставили новую версию oracle, из файла db_install.rsp)

4) Копируем файлы из старого ORACLE_HOME/network/admin в новый

а каталоги 

ORACLE_HOME/dbs
ORACLE_HOME/network/admin
ORACLE_HOME/owb/bin/admin
ORACLE_HOME/hostname_dbname
ORACLE_HOME/oc4j/j2ee/OC4J_DBConsole_hostname_dbname

сохраняем (с целью восстановления)

5) Установка последнего PSU (Oracle support Doc ID 756671.1) - рекомендованного патча для используемой версии DB

скачиваем и обновляем Opatch из Patch 6880880 (заменяем все файлы нового $ORACLE_HOME/Opatch)

CD $ORACLE_HOME/Opatch
./opatch apply /dir/to/last/PSU (корневой каталог распакованного PSU c файлом patchmd.xml)

6) Отключаем Database Vault в новом ORACLE_HOME (Oracle support Doc ID 453903.1)

cd $ORACLE_HOME/rdbms/lib
make -f ins_rdbms.mk dv_off ioracle

7) Обновляем БД

CD $ORACLE_HOME (указываем в качестве -oracleHome старый ORACLE_HOME)

./dbua -silent -sid ARCHDB -oracleHome /mnt/oracle/product/11.2.0/dbhome_1  -oracleBase /mnt/oracle/product/11.2.0 -sysDBAUserName sys -sysDBAPassword syspwd -recompile_invalid_objects true -degree_of_parallelism 4 -emConfiguration LOCAL -dbsnmpPassword dbsnmppwd -sysmanPassword sysmanpwd -hostUserName oracle -hostUserPassword userpwd

8) Меняем в .bashrc/.bash_profile значение ORACLE_HOME на новое

9) Запускаем dbupgdiag.sql (Oracle support Doc ID 556610.1) для анализа результатов обновления БД

10) Пересоздание EMCA

emca -config dbcontrol db -repos recreate

если не стартует (Oracle support Doc ID 1455760.1):

set | grep TZ - проверить текущую TZ
unset TZ
set | grep TZ - не должно ничего быть
export TZ=Etc/GMT-4 - на TZ для Москвы (с учетом того, что нет перехода на летнее время)
set | grep TZ - должен выдать только TZ=Etc/GMT-4
vim /usr/oracle/app/product/11.2.0/dbhome_1/hostname_dbname/sysman/config/emd.properties - удалить строчку agentTZRegion=
emctl config agent getTZ - должен выдать Etc/GMT-4
emctl resetTZ agent
sqlplus /nolog
conn sysman/sysman
exec mgmt_target.set_agent_tzrgn('hostname:3938','Etc/GMT-4') - тут hostname:3938 - инфо Agent URL (emctl status agent)
emctl stop dbconsole
emctl start dbconsole
emctl status dbconsole
emctl status agent

Если не получается выполнить exec mgmt_target.set_agent_tzrgn() пропускаем его.

11) Информация о последних установленных на сервере патчах Oracle (Oracle support Doc ID 821263.1)

$ORACLE_HOME/Opatch/opatch lsinventory -detail

12) Поменять ORACLE_HOME в файле автозапуска СУБД: vim /etc/init.d/oracle