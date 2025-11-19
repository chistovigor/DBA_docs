rm -rf /backup/
export mg_port=27017
export mg_pass="***"

source ~/.bashrc

mongosh --username root --password $mg_pass --authenticationDatabase admin

# mount encrypted disk

clevis luks bind -f -y -k /tmp/decrypt_password -d /dev/sdaX tang '{"url": "http://tang_ip"}'

# check passphrase works for the disk without remounting

echo "decrypt_password_value" |  cryptsetup luksOpen /dev/sdb1 test-mapper --test-passphrase
echo $?
0 - ok, not 0 - failed

# stop / start DB service

systemctl stop mongod
systemctl start mongod
#systemctl restart mongod
systemctl status mongod

# replication

rs.status()
rs.isMaster()

# check config / priority for nodes

rs.conf()

cfg = rs.conf()
# Изменить приоритеты (например, сделать node2[1] PRIMARY)
cfg.members[0].priority = 1  // Текущий primary
cfg.members[1].priority = 2  // Новая primary нода
cfg.members[2].priority = 1  
rs.reconfig(cfg, {force: true})

# add new RS member

-- on the existing node copy keyfile
cat /etc/mongod.key

-- on the new node create keyfile with the same content and set permissions
sudo mkdir -p /etc
sudo tee /etc/mongod.key <<EOF
<MONGO_REPL_KEY_123456>
EOF
sudo chown mongodb:mongodb /etc/mongod.key
sudo chmod 400 /etc/mongod.key

-- copy config file from existing node to the new one (adjust bindIp )
/etc/mongod.conf

bindIp: 127.0.0.1,192.168.*.<NEW_IP>  # заменить на IP нового сервера

-- on the new node start DB:
sudo systemctl enable mongod
sudo systemctl start mongod
sudo systemctl status mongod
ss -tlnp | grep 27017

-- on the primary node add new member
mongosh --host <PRIMARY_HOST> -u <ADMIN_USER> -p <PASSWORD> --authenticationDatabase admin
rs.add("192.168.*.<NEW_IP>:27017")
or 
rs.add("<NEW_FQDN>:27017")
rs.status()

-- if you need to add member which cannot be elected to primary:
rs.add({
  host: "192.168.*.<NEW_IP>:27017",
  priority: 0
})
rs.reconfig(rs.conf(), {force: true})

-- check status again
rs.status()
rs.conf()


# remove old member of the replicaset

rs.status()
-- on the primary node add new member
mongosh --host <PRIMARY_HOST> -u <ADMIN_USER> -p <PASSWORD> --authenticationDatabase admin
rs.remove("192.168.*.<OLD_IP>:27017")
rs.reconfig(rs.conf(), {force: true})

# add tag for existine member of replicaset

cfg = rs.conf()
cfg.members.forEach((m, i) => print(i, m.host))
cfg.members[1].tags = { dc: 'ams' }
rs.reconfig(cfg)


# set default write concern for the replicaset

-- check current settings
db.adminCommand({ getDefaultRWConcern: 1 })
-- set new settings (commit only after write to 1 node, wtimeout 0 ms)
db.adminCommand({setDefaultRWConcern: 1,defaultWriteConcern: { w: 1, wtimeout: 0 }})


# add additional DB logging

-- checkpoint verbosity level

db.adminCommand({
setParameter: 1,
logComponentVerbosity: {
    storage: {
      wt: {
        wtCheckpoint: { verbosity: 1 }
      }
    }
}
})

-- disable whole verbosity for storage

db.adminCommand({ setParameter: 1, logComponentVerbosity: { storage: { verbosity: 0 } } })


# get all DB parameters

db.adminCommand({ getParameter: "*" })

# docker userful commands

#stop and delete all
docker compose down -v
docker image prune -a

docker compose down -v && echo y | docker image prune -a && rm setup_ferretdb_cockroach.sh

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





