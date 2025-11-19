// === compact_savings_estimate.js ===
// Использование:
// load("compact_savings_estimate.js");
// estimateCompactSavings("<db_name>", "<collection_name>");

function estimateCompactSavings(dbName, collName) {
    const currentDB = db.getSiblingDB(dbName);
    const coll = currentDB.getCollection(collName);
    const stats = coll.stats({ scale: 1024 * 1024 }); // в мегабайтах

    print(`\n=== Estimating Compact Savings for ${dbName}.${collName} ===`);
    if (!stats.ok) {
        print("❌ Failed to retrieve collection stats.");
        return;
    }

    const storage = stats.storageSize || 0;
    const data = stats.size || 0;
    const index = stats.totalIndexSize || 0;
    const total = storage + index;

    // "Фрагментированные" или неиспользуемые блоки
    const wasted = Math.max(storage - data - index, 0);

    print(`📊 Collection Statistics (in MB):`);
    print(`   Data (logical): ${data.toFixed(2)} MB`);
    print(`   Storage (allocated): ${storage.toFixed(2)} MB`);
    print(`   Indexes: ${index.toFixed(2)} MB`);
    print(`   Total on disk: ${total.toFixed(2)} MB`);
    print("");

    if (wasted > 0) {
        const percent = ((wasted / storage) * 100).toFixed(2);
        print(`⚠️  Potential reclaimable space: ${wasted.toFixed(2)} MB (~${percent}% of storage)`);
        print(`💡 Run to reclaim: db.getSiblingDB("${dbName}").getCollection("${collName}").compact();`);
    } else {
        print(`✅ No significant reclaimable space detected.`);
    }

    if (stats.ok && stats.wiredTiger) {
        const wt = stats.wiredTiger;
        const internal = wt["block-manager"] || {};
        const bytesInUse = internal["file bytes in use"];
        const bytesTotal = internal["file size in bytes"];
        if (bytesInUse && bytesTotal) {
            const diff = (bytesTotal - bytesInUse) / (1024 * 1024);
            const perc = ((diff / bytesTotal) * 100).toFixed(2);
            print("");
            print(`🔍 WiredTiger internal stats:`);
            print(`   File size: ${(bytesTotal / (1024 * 1024)).toFixed(2)} MB`);
            print(`   Bytes in use: ${(bytesInUse / (1024 * 1024)).toFixed(2)} MB`);
            print(`   Fragmentation: ${diff.toFixed(2)} MB (${perc}%)`);
        }
    }

    print("\n--- Analysis Complete ---\n");
}
