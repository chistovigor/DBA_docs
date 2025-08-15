-- information from https://learn.mongodb.com/learn/learning-path/mongodb-database-admin-self-managed-path

разделитель кода: $$%% 

Общие замечания:

-- полезные особенности оболочки mongosh
Node.js shell 
 
Вывод результатов выполнения запроса сразу:
Использовать флаг --eval "запрос" --quiet
Кастомизация: через mongosh.conf
Добавление функциональности вас mongosh
через файл .mongoshrc.js 
В этот файл добавить информацию по подробностям текущего подключения к бд для всех подключений! - customize prompt 
Оболочка может работать с локальными файлами через js !
Запись в файл через fs.writeFileSync
const customers = db.sales.find({}, {customer: 1, _id: 0})
fs.writeFileSync('customers.json', EJSON.stringify(customers.toArray()), null, 2)
Generate fake data:
You can also use npm packages in mongosh, as they support external scripts and require statements
Note: To use the faker package, you must first install it by using npm install @faker-js/faker --save-dev in the same directory as your external script. Or, you can install the package globally by using npm install -g @faker-js/faker
 
const { faker } = require("@faker-js/faker"); const users = []; for (let i = 0; i < 10; i++) { users.push({   name: faker.person.fullName(),   email: faker.internet.email(),   phone: faker.phone.number(), }); } console.log("Inserting fake users ..."); db.getSiblingDB("test_data").users.insertMany(users);

-- Инструмент для подключения в БД (GUI) - compass
cli - mongosh 
мой тестовый кластер - пользователь:
adm-chistovi / !4QrAfZv

mongodb+srv://adm-chistovi:!4QrAfZv @cluster0.srplwou.mongodb.net/

mongosh connection:
mongosh "mongodb+srv://cluster0.srplwou.mongodb.net/" --apiVersion 1 --username adm-chistovi

1) вставка документа:

-- один (пример javascript кода из deepSeek)

$$%%

const { MongoClient } = require('mongodb');

async function insertDocument() {
  const uri = "mongodb://localhost:27017";
  const client = new MongoClient(uri);
  
  try {
    await client.connect();
    const database = client.db("mydatabase");
    const collection = database.collection("mycollection");

    const document = {
      name: "John Doe",
      age: 30,
      email: "john@example.com",
      createdAt: new Date(),
      hobbies: ["reading", "hiking"],
      address: {
        city: "New York",
        country: "USA"
      }
    };

    const result = await collection.insertOne(document);
    console.log(`Документ успешно вставлен с _id: ${result.insertedId}`);
  } finally {
    await client.close();
  }
}

insertDocument().catch(console.error);

    const result = await collection.insertOne(document);
    console.log(`Документ успешно вставлен с _id: ${result.insertedId}`);
  } finally {
    await client.close();
  }
}

insertDocument().catch(console.error);

$$%% 

-- несколько (пример кода из mongo University)

-- фактический код для вставки:

$$%%

db.accounts.insertMany(
    [
    # Add new documents separated by a comma:
    ]
) 

2) поиск документа

Find a Document with Equality

$$%% 

db.zips.find({ _id: ObjectId("5c8eccc1caa187d17ca6ed16") })

$$%% 

using IN operator

$$%% 

db.zips.find({ city: { $in: ["PHOENIX", "CHICAGO"] } })

$$%% 

find documents which are less than or equal

$$%% 

db.sales.find({ "items.price": { $lt: 50}})

$$%% 

find with matched elements for array: 

$$%% 

// Найти студентов, у которых есть оценка по математике > 80
db.students.find({
  scores: {
    $elemMatch: {
      subject: "math",
      score: { $gt: 80 }
    }
  }
})

$$%% 

--Use the $and operator to use multiple $or expressions in your query 

$$%% 

db.routes.find({
  $and: [
    { $or: [{ dst_airport: "SEA" }, { src_airport: "SEA" }] },
    { $or: [{ "airline.name": "American Airlines" }, { airplane: 320 }] },
  ]
})

$$%% 

4) изменения документов

-- замена документа db.collection.replaceOne()

$$%% 

db.books.replaceOne(
  {
    _id: ObjectId("6282afeb441a74a98dbbec4e"),
  },
  {
    title: "Data Science Fundamentals for Python and MongoDB",
    isbn: "1484235967",
    publishedDate: new Date("2018-5-10"),
    thumbnailUrl:
      "https://m.media-amazon.com/images/I/71opmUBc2wL._AC_UY218_.jpg",
    authors: ["David Paper"],
    categories: ["Data Science"],
  }
)

$$%% 

$set
The $set operator replaces the value of a field with the specified value, as shown in the following code:

$$%% 

db.podcasts.updateOne(
  {
    _id: ObjectId("5e8f8f8f8f8f8f8f8f8f8f8"),
  },

  {
    $set: {
      subscribers: 98562,
    },
  }
)

$$%% 

upsert
The upsert option creates a new document if no documents match the filtered criteria. Here's an example:

$$%% 

db.podcasts.updateOne(
  { title: "The Developer Hub" },
  { $set: { topics: ["databases", "MongoDB"] } },
  { upsert: true }
)

$$%% 

--The findAndModify() method is used to find and replace a single document in MongoDB. It accepts a filter document, a replacement document, and an optional options object. The following code shows an example:

$$%% 

db.podcasts.findAndModify({
  query: { _id: ObjectId("6261a92dfee1ff300dc80bf1") },
  update: { $inc: { subscribers: 1 } },
  new: true,
})

$$%% 

--To update multiple documents, use the updateMany() method. This method accepts a filter document, an update document, and an optional options object. The following code shows an example:

$$%% 

db.books.updateMany(
  { publishedDate: { $lt: new Date("2019-01-01") } },
  { $set: { status: "LEGACY" } }
)

$$%% 

-- Delete One Document
The following code shows an example of the deleteOne() method:

$$%% 

db.podcasts.deleteOne({ _id: Objectid("6282c9862acb966e76bbf20a") })

$$%% 

-- Delete Many Documents
The following code shows an example of the deleteMany() method:

$$%% 

db.podcasts.deleteMany({category: “crime”})

$$%% 

5) изменения результатов запросов

-- Sort Syntax:
db.collection.find(<query>).sort(<sort>)
Example:
// Return data on all music companies, sorted alphabetically from A to Z.

$$%% 

db.companies.find({ category_code: "music" }).sort({ name: 1 });

$$%% 

To ensure documents are returned in a consistent order, include a field that contains unique values in the sort. An easy way to do this is to include the _id field in the sort. Here's an example:
// Return data on all music companies, sorted alphabetically from A to Z. Ensure consistent sort order

$$%% 

db.companies.find({ category_code: "music" }).sort({ name: 1, _id: 1 });

$$%% 

-- projection (исключение части ключей документа в результатах запроса):

db.collection.find( <query>, { <field> : 1 })
Example:
// Return all restaurant inspections - business name, result, and _id fields only

$$%% 

db.inspections.find(
  { sector: "Restaurant - 818" },
  { business_name: 1, result: 1 }
)

$$%% 

// Count number of docs in trip collection

$$%% 

db.trips.countDocuments({})

$$%% 

// Count number of trips over 120 minutes by subscribers

$$%% 

db.trips.countDocuments({ tripduration: { $gt: 120 }, usertype: "Subscriber" })

$$%% 

5) --Indexes

Create a Unique Single Field Index
Add {unique:true} as a second, optional, parameter in createIndex() to force uniqueness in the index field values. Once the unique index is created, any inserts or updates including duplicated values in the collection for the index field/s will fail.

$$%% 

db.customers.createIndex({
  email: 1
},
{
  unique:true
})

$$%% 

-- check index usage

$$%% 

db.customers.explain().find({
  birthdate: {
    $gt:ISODate("1995-08-01")
    }
  })

$$%% 

-- create index

$$%% 

db.customers.createIndex({
  accounts: 1
})

$$%% 

drop several indexes:

$$%% 

db.collection.dropIndexes([
  'index1name', 'index2name', 'index3name'
  ])

$$%% 

-- one index

Delete index by name:

$$%% 

db.customers.dropIndex(
  'active_1_birthdate_-1_name_1'
)

$$%% 

Delete index by key:

$$%% 

db.customers.dropIndex({
  active:1,
  birthdate:-1, 
  name:1
})

or 

await collection.dropIndex(indexName, { maxTimeMS: 3600000 }); // 1 час

$$%% 

--hide before dropping to check impact

$$%% 

db.restaurants.hideIndex( { borough: 1, ratings: 1 } );
--check
db.restaurants.getIndexes()
-- inhide
db.restaurants.unhideIndex( "borough_1_ratings_1" ); 
--or
db.restaurants.unhideIndex( { borough: 1, ratings: 1 } ); 

$$%% 

6) explain hints

--additional explain information

$$%% 

db.collection.explain('queryPlanner').find()
-- include winning plan only
db.collection.find().explain().queryPlanner.winningPlan
-- rejected plan only
db.collection.find().explain().queryPlanner.rejectedPlans 
-- all possible verbosity modes
db.collection.explain().help()

$$%% 

-- hint for using an index

To force MongoDB to use the compound index, use the hint method on the query itself, like so:

$$%% 

db.users.find({
  dob: { $gte: new Date("1988"), $lte: new Date("1990") },
  inactive: false,
}).hint({
  dob: 1, inactive: 1
}).explain("executionStats").executionStats

$$%% 

--wildcard index creation syntax

db.product.createIndex({"product_attributes.$**" : 1 } ) ;

-- from mongodb 7.* we can create compound wildcard indexes (!) - support queries agains unknown / arbitary fields
wildcard projection option to exclude / include fields from wildcard index 

$$%% 

db.products.createIndex(
  { "$**": 1 },
  { wildcardProjection: { _id: 1, stock: 0, prices: 0 } }
)

$$%% 

-- partial indexes - for queries with $* 

$$%% 

db.zips.createIndex(
  { state: 1 },
  { partialFilterExpression: { pop: { $gte: 10000 } } }
)

$$%% 

-- spacre index - for the fileds when values can be null in some documents

$$%% 

db.sparseExample.createIndex({ avatar_url: 1 }, { sparse: true });

$$%% 

-- index stats for the collection method

db.collection.aggregate([ { $indexStats: { } } ]);

note OPS number in the output!

-- enable database profiler - results will be in the system.profile collection (enable creates performance impact!)

$$%% 

db.setProfilingLevel(1, {slowms: 50 }); --operations slower than 50 miliseconds

--check results (5 longest query operations)

db.system.profile.find({op: 'query', ns: 'sample.table'}).sort(ts:-1}).limit(5);

$$%% 

6) -- db logs

default location on linux is 

/var/log/mongodb/mongod.log

--for the config file:

/etc/mongod.conf

--The mongosh helper show log global internally calls the getLog command to return recent log messages from the RAM cache:

$$%% 

db.adminCommand( { getLog:'global'} )

$$%% 

--in the following example, the command leaves the profile disabled but changes the slowms threshold to 30 milliseconds:

db.setProfilingLevel(0, { slowms: 30 })

set verbosity in the /etc/mongod.conf file, then restart db

-- set verbosity for logs in DB

$$%% 

db.setLogLevel(1, "index");
db.getLogComponents().index;
db.setProfilingLevel(0, { slowms: 20 });
db.getProfilingStatus(); 

$$%% 

-- Rotating Logs
To rotate logs for a self-managed mongod deployment, use the db.adminCommand() in mongosh:

$$%% 

db.adminCommand( { logRotate : 1 } )

$$%% 

Alternatively, you can issue the SIGUSR1 signal to the mongod process with the following command:

$$%% 

sudo kill -SIGUSR1 $(pidof mongod)

$$%% 

-- конфигурация для logrotate
--2. Оптимизированная конфигурация для высоконагруженных систем
file should be created in /etc/logrotate.d/ and named mongod.conf 

bash
/var/log/mongodb/*.log {
    hourly                     # Ротация ежечасно
    rotate 168                 # 7 дней (24*7)
    size 500M                  # Макс. размер файла
    compress                   # Сжатие
    delaycompress
    missingok
    notifempty
    copytruncate
    dateext
    sharedscripts
    postrotate
        pkill -USR1 mongod || true
    endscript
}

--Get the most recent lines in the log by using the 
db.adminCommand({getLog: <type}) method, show log <name>, and show logs

7) backup / restore 

https://www.mongodb.com/docs/manual/tutorial/backup-and-restore-tools/#std-label-manual-tutorial-backup-and-restore

-- online
--oplog option with mongodump in conjunction with mongorestore --oplogReplay
roles required: backup and restore
built-in roles dbAdmin and dbAdminAnyDatabase - for restore system.profile

You may also consider using the mongorestore --objcheck option to check the integrity of objects while inserting them into the database, or you may consider the mongorestore --drop option to drop each collection from the database before restoring from backups.

8) Config TLS / SSL

https://www.mongodb.com/docs/manual/tutorial/configure-ssl/#configure-mongod-and-mongos-for-tls-ssl

9) switch between primary and secondary

https://www.mongodb.com/docs/manual/reference/method/rs.stepDown/#mongodb-method-rs.stepDown

10) installation

OS setup (ulimit)
https://www.mongodb.com/docs/manual/reference/ulimit/#recommended-ulimit-settings

11) Mongodb tools

Follow these steps to install MongoDB 6.0 Community Edition on LTS (long-term support) releases of Ubuntu Linux, using the apt package manager.
In the terminal, use the following command to import the public key used by the package management system:
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
Create a list file for MongoDB:
echo “deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse” | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
Reload the local package database:
sudo apt-get update
Install the latest stable version of MongoDB Community Edition:
sudo apt-get install -y mongodb-org

mongodump - cannot be used for sharded clusters, oplog cannot be used with db / collection options (!)

mongorestore - use option --noIndexRestore for prevent indexes from being restored (!)

mongoexport tool used for export collection (may be with query as well)
mongoimport - can do merge while impopting data

mongostat - can include only custom fields (-o option)
mongotop shows which colleacions are top for reads and writes in DB / replica set
bsondump - can help to resolve issues related to mongorestore, for example
convert bson dump to json file

monofiles - cli interface to gridFS
mongofiles \
 -v \
 put myVideoFile.mp4 \
 “mongodb+srv://dbaTestAdmin@cluster0.mntqoh9.mongodb.net/myFiles”

12) monitoring of a DB

code, which demonstrates how to configure the Percona MongoDB Exporter tool as a Prometheus target, so that it can gather metrics from a MongoDB deployment and make them available to display with Grafana.
Install Percona MongoDB Exporter on Ubuntu Linux
Follow these steps to install the Percona MongoDB Exporter tool.
Download version 0.39.0 of the Percona MongoDB exporter:
wget
https://github.com/percona/mongodb_exporter/releases/download/v0.39.0/mongodb_exporter-0.39.0.linux-amd64.tar.gz

Extract the downloaded tarball:
tar xvzf mongodb_exporter-0.39.0.linux-amd64.tar.gzMove the mongodb_exporter binary to the /usr/local/bin/ directory:
sudo mv mongodb_exporter-0.39.0.linux-amd64/mongodb_exporter /usr/local/bin/
Create a New User
Follow these steps to create a user with sufficient privilege so that Percona MongoDB Exporter can read metrics from the MongoDB deployment.
Connect to your local MongoDB instance:
mongoshSwitch to the admin database within your mongosh shell session:
use adminCreate a new database user (test) with the clusterMonitor role:
db.createUser({user: "test",pwd: "testing",roles: [{ role: "clusterMonitor", db: "admin" },{ role: "read", db: "local" }]})

Exit the mongosh shell session:
exit
Create a Service for Percona MongoDB Exporter
Follow these steps to create a new service for the Percona MongoDB exporter and have it run as the prometheus user.
Create a new service file for the mongodb_exporter:
sudo nano /lib/systemd/system/mongodb_exporter.serviceAdd the following contents to the new service file:
[Unit]
Description=MongoDB Exporter
User=prometheus

[Service]
Type=simple
Restart=always
ExecStart=/usr/local/bin/mongodb_exporter \
--collect-all \
--mongodb.uri=mongodb://test:testing@localhost:27017

[Install]
WantedBy=multi-user.target
Save and exit.
Restart the system daemon to reload the unit files:
sudo systemctl daemon-reloadStart the mongodb_exporter system service:
sudo systemctl start mongodb_exporterEnable the mongodb_exporter system service so that it automatically starts on boot:
sudo systemctl enable mongodb_exporterConfirm that the mongodb_exporter system service is running and enabled by reviewing it’s status:
sudo systemctl status --full mongodb_exporterConfirm that MongoDB metrics are being collected and available via the mongodb_exporter /metrics endpoint:
curl http://localhost:9216/metrics
Configure Percona MongoDB Exporter as a Prometheus Target
Open the Prometheus configuration file:
sudo nano /etc/prometheus/prometheus.ymlAppend the below scrape configuration snippet to the scrape_configs section of the template Prometheus configuration:
...
scrape_configs:
...
  - job_name: 'mongodb_exporter'
    static_configs:
      - targets: ['localhost:9216']
...
Restart the prometheus system service to apply the configuration change:
sudo systemctl restart prometheusUse the Prometheus server API to confirm that the local MongoDB exporter target is present and healthy:
curl http://localhost:9090/api/v1/targets | jq --raw-output '.data.activeTargets[] | .scrapeUrl + " " + .health'

Now you’re ready to start creating Grafana visualizations using the Prometheus data source

Command Line Metrics

Review the following code, which demonstrates how to retrieve metrics from the MongoDB Shell.
serverStatus
To return a document that provides an overview of the database’s state, run:
db.runCommand(
   {
     serverStatus: 1
   }
)
To return a specific object, like connections, run:
db.runCommand( { serverStatus: 1 } ).connections
currentOp
To return a document that provides all currently active operations, run:
db.adminCommand(
   {
     currentOp: true,
     "$all": true
   }
)

killOp
To kill an active operations, run:
db.adminCommand(
   {
     killOp: 1,
     op: <opid>,
     comment: <any>
   }
)

13) backup restore

using lvm snapshots

Lock the Database

db.fsyncLock();

Create a Snapshot Volume

sudo lvcreate --size 100M --snapshot --name mdb-snapshot /dev/vg0/mdb;
Unlock the Database

mongosh

db.fsyncUnlock();

Archive the Snapshot

sudo dd status=progress if=/dev/vg0/mdb-snapshot | gzip > mdb-snapshot.gz

Restore the Archived Snapshot

sudo lvcreate --size 1G --name mdb-new vg0;
Next, extract the snapshot and write it to the new logical volume:
gzip -d -c mdb-snapshot.gz | sudo dd status=progress of=/dev/vg0/mdb-new
Then, stop the MongoDB service before mounting to the source directory:
sudo systemctl stop -l mongod; sudo systemctl status -l mongod;
Delete any existing MongoDB data files. This is for demonstration purposes to show how the entire deployment is restored.
sudo rm -r /var/lib/mongodb/*
Next, unmount the MongoDB deployment so that you can mount the newly restored logical volume in its place.
sudo umount /var/lib/mongodb
Mount the restored logical volume on the MongoDB database directory:
sudo mount /dev/vg0/mdb-new /var/lib/mongodb

sudo systemctl start -l mongod; sudo systemctl status -l mongod;
mongosh
show dbs

Backup using mongodump

mongosh admin

db.createUser({
   user: "backup-admin",
   pwd: "backup-pass",
   roles: ["backup"]
 })

mongodump \
--oplog \
--gzip \
--archive=mongodump-april-2023.gz  \
“mongodb://backup-admin@mongod0.repleset.com:27017,mongod1.replset.com:27017,mongod2.replset.com:27017/?authSource=admin&replicaSet=replset&readPreference=secondary”

restrore DB

mongosh admin

db.createUser({
   user: "restore-admin",
   pwd: "restore-pass",
   roles: ["restore"]
 })

mongorestore \
--drop \
--gzip \
--oplogReplay \
--noIndexRestore \
--archive=mongodump-april-2023.gz \
“mongodb://restore-admin@mongod0.repleset.com:27017,mongod1.replset.com:27017,mongod2.replset.com:27017/?authSource=admin&replicaSet=replset”

14) upgrade DB (rolling upgrade for replica set)

-- check drivers compatibility with db version

https://www.mongodb.com/docs/drivers/node/current/reference/compatibility/





