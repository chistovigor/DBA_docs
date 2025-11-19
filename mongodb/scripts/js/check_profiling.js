// check_profiling.js
// --- Проверка уровня профилирования во всех БД (поддержка MongoDB 6–8, primary и secondary) ---

const defaultProfilingLevel = 0;
const defaultSlowMs = 100;

print("=== Default profiling settings used for comparison ===");
print(`profilingLevel=${defaultProfilingLevel}, slowms=${defaultSlowMs}`);
print(`To reset profiling to defaults in a DB, run in mongosh:`);
print(`   db.setProfilingLevel(${defaultProfilingLevel}, { slowms: ${defaultSlowMs} })\n`);

// --- Безопасная установка readPreference для secondary ---
try {
    const mongo = db.getMongo();

    // Разрешаем чтение с вторичных узлов
    if (typeof mongo.setSecondaryOk === "function") {
        mongo.setSecondaryOk(true);
    }

    // Проверяем текущие настройки
    const rp = mongo.getReadPref ? mongo.getReadPref() : null;
    const rpMode = rp && rp.mode ? rp.mode : null;

    // Меняем только если реально отличается (иначе mongosh спамит "Leaving read preference unchanged")
    if (rpMode !== "secondaryPreferred") {
        mongo.setReadPref("secondaryPreferred");
    }

} catch (e) {
    print("⚠️  Unable to set read preference for secondary access: " + e.message);
}

// --- Получение списка баз данных ---
let databases = [];
try {
    const res = db.adminCommand({ listDatabases: 1 });
    if (res.ok && res.databases) {
        databases = res.databases;
    }
} catch (e) {
    // Без подробного спама — только общее уведомление
    print("⚠️  listDatabases failed (secondary or permissions). Falling back to basic DBs...");
    databases = [{ name: "admin" }, { name: "config" }, { name: "local" }];
}

let overridden = [];
let defaults = [];

// --- Проверка статуса профилирования по каждой БД ---
databases.forEach(function (d) {
    const dbName = d.name;
    try {
        const database = db.getSiblingDB(dbName);
        const status = database.getProfilingStatus();

        const level = status.was;
        const slowms = status.slowms;

        if (level !== defaultProfilingLevel || slowms !== defaultSlowMs) {
            overridden.push(`DB: ${dbName} | profilingLevel=${level} | slowms=${slowms}`);
        } else {
            defaults.push(dbName);
        }
    } catch (err) {
        print(`⚠️  Unable to get profiling status for DB: ${dbName} (${err.message})`);
    }
});

// --- Вывод результатов ---
if (overridden.length > 0) {
    print("=== Databases with overridden profiling settings ===");
    overridden.forEach(line => print(line));
} else {
    print("No databases with overridden profiling settings");
}

if (defaults.length > 0) {
    print(`\n=== Databases with default profiling settings (level=${defaultProfilingLevel}, slowms=${defaultSlowMs}) ===`);
    print(defaults.join(", "));
}
