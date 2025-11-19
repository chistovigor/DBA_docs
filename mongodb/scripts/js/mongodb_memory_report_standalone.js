// mongodb_memory_report_standalone.js - Standalone version for local execution without Ansible templates
function formatMB(bytes) {
    return (bytes / (1024 * 1024)).toFixed(2);
}

// Cache report: только коллекции, у которых estimatedCacheMB >= thresholdMB
function cacheReport(thresholdMB) {
    let dbs = db.getMongo().getDBNames();
    let report = [];

    dbs.forEach(function(dbName) {
        let database = db.getSiblingDB(dbName);
        let collections = [];
        let dbCacheMB = 0;

        database.getCollectionNames().forEach(function(collName) {
            try {
                let stats = database.getCollection(collName).stats();
                let estimatedCache = stats.size - stats.storageSize;

                if (parseFloat(formatMB(estimatedCache)) >= thresholdMB) {
                    dbCacheMB += estimatedCache;

                    collections.push({
                        collectionName: collName,
                        count: stats.count,
                        storageSizeMB: formatMB(stats.storageSize),
                        totalIndexSizeMB: formatMB(stats.totalIndexSize),
                        estimatedCacheMB: formatMB(estimatedCache)
                    });
                }
            } catch(e) {
                // Пропускаем, если collection является view или недоступен
            }
        });

        if (collections.length > 0) {
            report.push({
                dbName: dbName,
                dataSizeMB: formatMB(database.stats().dataSize),
                storageSizeMB: formatMB(database.stats().storageSize),
                indexSizeMB: formatMB(database.stats().indexSize),
                estimatedCacheMB: formatMB(dbCacheMB),
                collections: collections
            });
        }
    });

    print(JSON.stringify(report, null, 2));
}

// Default execution with threshold from defaults or command line
// Default threshold is 1MB (can be overridden with --eval "var thresholdMB=X")
if (typeof thresholdMB === 'undefined') {
    var thresholdMB = 1;
}
cacheReport(thresholdMB);