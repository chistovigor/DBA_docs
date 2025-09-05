rm -rf /backup/
export mg_port=27017
export mg_pass="***"

source ~/.bashrc

mongosh --username root --password $mg_pass --authenticationDatabase admin

# docker userful commands

#stop and delete all
docker compose down -v
docker image prune -a

#run with docker-compose.yml config
docker compose up -d

# run ansible playbooks

# Dry run для отслеживания фактических целей внесения изменений

ansible-playbook ~/Desktop/work_files/ubuntu_upgrade.yml -i ../infrastructure/mongodb --limit x_test_chistov -C -D

# Выполнение в режиме отслеживания изменений

ansible-playbook ~/Desktop/work_files/ubuntu_upgrade.yml -i ../infrastructure/mongodb --limit x_test_chistov -D

# выполнение в использованием шифрованного файла поролей для ansible-vault

ansible-playbook ~/Desktop/work_files/update_ram_mongo.yml -i ~/git_repos/infrastructure/mongodb --limit x_test_chistov -D --ask-vault-pass

# переопределить значение для % выделенной памяти

ansible-playbook ~/Desktop/work_files/update_ram_mongo.yml -i ~/git_repos/infrastructure/mongodb --limit x_test_chistov -D --ask-vault-pass --extra-vars "wt_cache_percent 70"

# запуск на одном хосте

ansible-playbook ~/Desktop/work_files/update_ram_mongo.yml -i ~/git_repos/infrastructure/mongodb --limit sc-lux99-x-test-chistov-mongo-2 -D --ask-vault-pass

# создать файл паролей перед этим (в нем - параметры, которые указаны в основном playbook):

ansible-vault create mongo_creds.yml

# backup / restore

-- not working !!!

mongodump --host x_test_chistov/sc-lux99-x-test-chistov-mongo-1.xbet.lan:$mg_port,sc-lux99-x-test-chistov-mongo-2.xbet.lan:$mg_port,sc-lux99-x-test-chistov-mongo-3.xbet.lan:$mg_port \
  --username root --password "$mg_pass" --authenticationDatabase admin --readPreference=secondary --oplog --gzip --out /backup/mongodb_cluster_$(date +%Y%m%d)

mongodump --username root --password "$mg_pass" --authenticationDatabase admin

mongodump --host x_test_chistov/sc-lux99-x-test-chistov-mongo-1.xbet.lan:$mg_port,sc-lux99-x-test-chistov-mongo-2.xbet.lan:$mg_port,sc-lux99-x-test-chistov-mongo-3.xbet.lan:$mg_port \
  --username root --password "$mg_pass" --authenticationDatabase admin --oplog --gzip --out /backup/mongodb_cluster_$(date +%Y%m%d)

# restore it
mongosh --username root --password "$mg_pass" --authenticationDatabase admin replicaset_management_mode.js
./replicaset_restore.sh "$mg_pass"

echo $mg_pass | mongosh --host x_test_chistov/sc-lux99-x-test-chistov-mongo-1.xbet.lan:$mg_port,sc-lux99-x-test-chistov-mongo-2.xbet.lan:$mg_port,sc-lux99-x-test-chistov-mongo-3.xbet.lan:$mg_port

-- working approach

mkdir test_backup && cd test_backup/
mongodump --username root --password "$mg_pass" --authenticationDatabase admin
cd test_backup/. # same folder as above !
mongorestore --username root --password "$mg_pass" --authenticationDatabase admin --drop --stopOnError

-- check / upload key to the server (example)

cd /home/***/.ssh/authorized_keys
cat /home/***/.ssh/authorized_keys
ssh-ed25519 ***

-- ansible

ansible-playbook -i inventory.ini ubuntu_upgrade.yml \
  --check -e "dry_run=true" -t check


-- upgrade db to version 8

https://www.mongodb.com/docs/manual/release-notes/8.0-upgrade-replica-set/#std-label-8.0-upgrade-replica-set

## on any secondary node:

mongosh --username root --password $mg_pass --authenticationDatabase admin

sudo systemctl stop mongod
sudo apt-get install gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
sudo systemctl status mongod
sudo systemctl enable mongod

## switch primary node to the upgraded node

cfg = rs.conf()
cfg.members[0].priority = 1
cfg.members[1].priority = 2
rs.reconfig(cfg, {force: true})
print(rs.isMaster().primary)

# must be upgraded node name !

# upgrade another secondary node

sudo systemctl stop mongod
sudo apt-get install gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
sudo systemctl status mongod
sudo systemctl enable mongod

# switch back to original primary not required, set back priority only

cfg = rs.conf()
cfg.members[0].priority = 1
cfg.members[1].priority = 1
rs.reconfig(cfg, {force: true})
print(rs.isMaster().primary)

# On the primary, run the setFeatureCompatibilityVersion command in the admin database:

db.adminCommand( { setFeatureCompatibilityVersion: "8.0",  confirm: true } )

# check results

db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )


# web UI for work with DB

https://www.jetbrains.com/datagrip/features/mongodb/
Там сервер лицензий jb-license.office.lan, надо указать в настройках ПО, он доступен только в пределах локальной сети или нашего vpn

@mongodb://root:dBKcxsiyuDGYOGhGRvb83kau@sc-lux99-x-test-chistov-mongo-1.xbet.lan:27017,sc-lux99-x-test-chistov-mongo-2.xbet.lan:27017,sc-lux99-x-test-chistov-mongo-3.xbet.lan:27017/?replicaSet=x_test_chistov&/myDefaultDB?authSource=admin

# вывод текущего размера cacheSizeGB в MongoDB

function getCacheSizeGB() {
  const bytes = db.serverStatus().wiredTiger.cache["maximum bytes configured"];
  const gb = bytes / (1024 * 1024 * 1024);
  print(`Current WiredTiger cache size: ${gb.toFixed(1)} GB`);
}

getCacheSizeGB();

# checksum данных коллекций в БД

mongosh --quiet "$MONGO_URI_BASE/$SOURCE_DB" --authenticationDatabase="admin"   --eval '
var collections = db.getCollectionNames();
for (var i = 0; i < collections.length; i++) {
  var c = collections[i];
  var checksum = db.mycollection.aggregate([с]).next().checksum;
  print("collection: " + c);
  print("Checksum: " + checksum));
}'





