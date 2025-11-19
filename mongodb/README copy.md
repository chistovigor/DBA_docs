# readme from infra mongodb repository

repository for mongodb, into which everything related to mongo will move

description of playbooks:
___
mongodb-install-playbook.yml playbook used to install MongoDB and create
configuration files (mongod.conf, mongod.key), retrieve existing mongod.conf
and mongod.key files if necessary, configure logrotate, open port 27017 in nftables,
and customize sysctl config.
The playbook includes the following roles:

    - install-mongodb-role
    - logrotate-mongodb
    - sysctl-config
    - nftables-config
    - mongodb-conf-fetch

___
mongodb-autocluster.yml - playbook used to autoconfigure MongoDB cluster,
it works in conjunction with the script mongodb-scr-auto-pwd.py for generating users,
uncomment the security lines in mongod.conf after adding users,
then sequentially restart MongoDB,
after the restart, it connects to the replica set to perform a check,
displaying the output of rs.status() and a list of users with passwords.

when running playbook from macOS setup python environment locally (for generation of db user passwords):

--do setup

python3 -m venv myenv
source myenv/bin/activate
pip install --upgrade pip

--check setup (must be executed successfully)

python3 -c "import yaml; print(yaml.__version__)"

___
mongodb-cert-copy.yml role creates a directory for the certificate and copies
the certificate file located in /files into it.

___
mongo-scr-generate-pwd.py  script generates passwords for users and saves them
in the required format in a file, which can then be used with mongosh, with
the ability for manual password input and convenient output after execution.

___
mongodb-remove-playbook.yml playbook is used for removing MongoDB from the server
default, it does not delete /etc/mongod.conf, /etc/mongod.key, and /opt/mongodb.
To delete them, you need to uncomment the lines

___
mongodb-get-key-playbook.yml playbook retrieves the mongod.key from the target
server and sends it to the templates of the MongoDB installation role for further
deployment to the other nodes of the cluster.

____
templates/mongodb-scr-auto-pwd.py script is used to automatically build the cluster,
modified by mongo-scr-generate-pwd.py

# mongodb_bda

## Getting started

repository for mongodb after migration it from infrastructure to big data team

# documentation

related to mongodb

# scripts

useful scripts

python script for glpi update:

python3 glpi_set_notes.py mongo_servers_2025-10-09_12-10.csv > glpi_set_notes.py.log_20251008_10

mongo_servers_2025-10-09_12-10.csv - uploaded csv with updates (last mongo inventory)
glpi_set_notes.py.log_20251008_10 - execution log (see run results inside)

# roles

install_mongodb_exporter

ansible-playbook -i ~/git_repos/infrastructure/mongodb install_mongodb_exporter.yml --limit some_server / group --extra-vars "mongodb_exporter_password=<zabbix_password> mongo_password=***"

проверка работы экспортера:

выполняем со стороны хоста, который будет забирать метрики

curl http://fqdn_of_host:9216/metrics
ожидается вывод списка метрик

локальная конфигурация / проверка работы экспортера:

конфиги:
vim /etc/systemd/system/mongodb_exporter.service
vim /etc/systemd/system/node_exporter.service

перезапуск сервиса:
systemctl daemon-reload && systemctl restart mongodb_exporter && systemctl status mongodb_exporter
systemctl daemon-reload && systemctl restart node_exporter && systemctl status node_exporter

проверка выводимых метрик:
curl http://127.0.0.1:9216/metrics > /tmp/mongo_metrics_list_2.log && cat /tmp/mongo_metrics_list_2.log | wc -l
curl http://127.0.0.1:50420/metrics > /tmp/exporter_metrics_list_2.log && cat /tmp/exporter_metrics_list_2.log | wc -l


Bash script install_mongodb_exporter.sh

Инструкция по использованию:
Сохраните скрипт как install_mongodb_exporter.sh

Сделайте исполняемым: chmod +x install_mongodb_exporter.sh

Запустите с правами root: sudo ./install_mongodb_exporter.sh

Особенности скрипта:
Запрашивает пароль пользователя zabbix при запуске

Автоматически скачивает и устанавливает экспортер
Настраивает systemd сервис с автоперезапуском
Проверяет успешность запуска службы
Открывает порт в firewall (если используется ufw)
Очищает временные файлы после установки

Требования перед запуском:

Убедитесь, что пользователь zabbix создан в MongoDB с нужными правами
Убедитесь, что MongoDB запущен и доступен на localhost:27017
Установите зависимости: sudo apt-get install wget (для Debian/Ubuntu)

После установки экспортер будет доступен по адресу http://сервер:9216/metrics


update_ram_mongo

создать файл паролей перед этим (в нем - параметры, которые указаны в основном playbook):

ansible-vault edit vars/secrets.yml

vault_mongo_admin_user: ***
vault_mongo_admin_password: ***

запуск:

выполнение в использованием шифрованного файла паролей для ansible-vault

ansible-playbook ~/Desktop/work_files/update_ram_mongo.yml -i ~/git_repos/infrastructure/mongodb --limit server_or_group_name -D --ask-vault-pass

переопределить значение для % выделенной памяти (60% по умолчанию)

ansible-playbook ~/Desktop/work_files/update_ram_mongo.yml -i ~/git_repos/infrastructure/mongodb --limit server_or_group_name -D --ask-vault-pass --extra-vars "wt_cache_percent 70"

mongodb_update

обновляет MongoDB до указанной версии (8 по умолчанию) на Ubuntu >=2*.04:

- Проверяет статус членов replicaset для переданного набора серверов перед обновлением
- Останавливает службу MongoDB
- Устанавливает ключ и репозиторий MongoDB указанной версии
- Обновляет пакеты MongoDB и инструменты
- Запускает MongoDB после обновления

### запуск в режиме проверки feature compatibility version для СУБД

ansible-playbook mongodb_update.yml -b -D -i ../infrastructure/mongodb --limit some_server --extra-vars "vault_mongo_admin_password=***" --tags=fcv

### запуск в режиме обновления

ansible-playbook -i ~/git_repos/infrastructure/mongodb mongodb_update.yml --limit some_server --extra-vars "vault_mongo_admin_password=***"

mongodb_upgrade

обновляет MongoDB до указанной версии (8 по умолчанию) на Ubuntu >=2*.04 последовательно для всех членов replicaset

см. подробный readme в каталоге роли

ansible-playbook -i ~/git_repos/infrastructure/mongodb mongodb_upgrade.yml --limit some_server/server_group


mongodb_memory_report

Эта роль выполняет анализ потребления памяти:

- На уровне ОС (процессы MongoDB и прочие, с группировкой <1% RAM).
- Внутри MongoDB (WiredTiger cache по базам и коллекциям, с порогом фильтрации).

## Переменные роли

| Переменная       | Default             | Описание |
|------------------|---------------------|----------|
| mongo_user       | —                   | Имя пользователя с правами root |
| mongo_password   | —                   | Пароль пользователя mongo_user |

## Запуск

ansible-playbook -i ~/git_repos/infrastructure/mongodb mongodb_memory_report.yml --limit some_server / group --extra-vars "mongo_user=db_admin_username mongo_password=***"


mongodb_cpu_report

Эта роль выполняет анализ потребления CPU:

- На уровне ОС (процессы MongoDB и прочие).
- Внутри MongoDB (по queryhash, базам и коллекциям, с выводом топ результатов).

## Переменные роли

| Переменная       | Default             | Описание |
|------------------|---------------------|----------|
| mongo_user       | —                   | Имя пользователя с правами root |
| mongo_password   | —                   | Пароль пользователя mongo_user |

## Запуск

ansible-playbook -i ~/git_repos/infrastructure/mongodb mongodb_cpu_report.yml --limit some_server / group --extra-vars "mongo_user=db_admin_username mongo_password=***"


mongodb_set_log_level

This role manages the MongoDB logging level and operation profiling settings across all nodes of a MongoDB cluster (replica set or sharded cluster).

It performs:
Enabling/disabling or checking the MongoDB log level (setParameter logLevel).
Managing profiling settings (profilingLevel, slowms_threshold).
Synchronizing the slowOpThresholdMs value in /etc/mongod.conf with the desired threshold (slowms_threshold).
Non-destructive checks (no changes mode).

## Переменные роли

| Variable         | Default Value.      | Description |
|------------------|---------------------|----------|
| log_action       | "enable"            | Action: `enable`, `disable` или `check` |
| log_level        | 1                   | Log verbosity level when enabled  (0-5) |
| script_path      | "~/log_level_manage_cluster.js" | Path to the management script on the remote node |
| ProfilingLevel   | 0                   | Profiling level: 0 – disabled, 1 – slow operations only, 2 – all operations |
| slowms_threshold | 100                 | slow operations Threshold; also applied to slowOpThresholdMs in MongoDB config |
| mongo_user       | —                   | MongoDB user with root privileges |
| mongo_password   | —                   | Password for mongo_user |

# Run in check mode to view current values (no changes)

ansible-playbook -i ~/git_repos/infrastructure/mongodb mongodb_set_log_level.yml --limit some_host_from_replicaset -D --extra-vars "mongo_user=db_admin_username mongo_password=***"

# Run to apply recommended settings for enabling logging of all queries at the standard level (sufficient for most cases)

ansible-playbook -i ~/git_repos/infrastructure/mongodb mongodb_set_log_level.yml --limit some_host_from_replicaset -D --extra-vars "ProfilingLevel=0 slowms_threshold=0 mongo_user=db_admin_username mongo_password=***"

# Run to apply default recommended settings (used after deploying a new cluster)

ansible-playbook -i ~/git_repos/infrastructure/mongodb mongodb_set_log_level.yml --limit some_host_from_replicaset -D --extra-vars "log_action=disable ProfilingLevel=0 slowms_threshold=100 mongo_user=db_admin_username mongo_password=***"


mongodb_storage_report

# Analyze disk usage on MongoDB servers

### Run to get a detailed report on MongoDB and OS disk usage for the directory /var/lib/mongodb

ansible-playbook -i ~/git_repos/infrastructure/mongodb mongodb_storage_report.yml --limit some_host_from_replicaset --extra-vars "mongo_user=admin mongo_password=*** mongo_analysis_target_dir=/var/lib/mongodb"

### Run to get a detailed report on MongoDB and OS disk usage

ansible-playbook -i ~/git_repos/infrastructure/mongodb mongodb_storage_report.yml --limit some_host_from_replicaset --extra-vars "mongo_user=db_admin_username mongo_password=***"

mongodb_systemd_override

used for HW servers for enable DB startup after autodecrypt of the disk with DB files. 
Doing modification of the file 
/etc/systemd/system/mongod.service.d/override.conf

ansible-playbook -i ~/git_repos/infrastructure/mongodb mongodb_systemd_override.yml --limit some_server / group 

mongodb_replica_set_priority

role retrieves MongoDB replica set members, displays them in a formatted ASCII table, and optionally normalizes all member priorities to `1`.

## Features

- Retrieves members with `host`, `priority`, `votes`, and `tags`.
- Shows members in a readable ASCII table.
- Checks if priorities differ and optionally sets all priorities to `1`.

### Run to get a info for replicaset members of MongoDB

ansible-playbook -i inventory.yml manage_replica_set.yml --limit some_host_from_replicaset --extra-vars "mongo_password=***"

### Run to update priority to 1 for all members of replicaset

ansible-playbook -i inventory.yml manage_replica_set.yml --limit some_host_from_replicaset --extra-vars "mongo_password=*** update_priority=y"