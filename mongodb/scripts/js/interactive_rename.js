// Скрипт переименования БД через переменные окружения / --eval
// Использование:
// export MG_PASS="SuperSecretPassword"
// mongosh --username root --password $MG_PASS --authenticationDatabase admin --eval "var OLD_DB='test', NEW_DB='new_test'" rename_db_env.js

// Проверяем, что переменные переданы
if (typeof OLD_DB === 'undefined' || typeof NEW_DB === 'undefined') {
    print("❌ Ошибка: нужно передать OLD_DB и NEW_DB через --eval");
    print("Пример: mongosh --username root --password $MG_PASS --authenticationDatabase admin --eval \"var OLD_DB='test', NEW_DB='new_test'\" rename_db_env.js");
    quit(1);
}

print("=== Переименование базы данных MongoDB ===");
print("Старая БД: " + OLD_DB);
print("Новая БД: " + NEW_DB);
print("Хост: " + db.getMongo().host + "\n");

// Проверяем существование старой БД
try {
    const dbs = db.getSiblingDB('admin').adminCommand({ listDatabases: 1 });
    const oldExists = dbs.databases.some(d => d.name === OLD_DB);
    const newExists = dbs.databases.some(d => d.name === NEW_DB);

    if (!oldExists) {
        print("❌ Ошибка: база данных '" + OLD_DB + "' не существует");
        quit(1);
    }
    if (newExists) {
        print("❌ Ошибка: база данных '" + NEW_DB + "' уже существует");
        quit(1);
    }
} catch (e) {
    print("❌ Ошибка при проверке баз: " + e.message);
    quit(1);
}

// Копирование коллекций
try {
    const oldDb = db.getSiblingDB(OLD_DB);
    const newDb = db.getSiblingDB(NEW_DB);
    const collections = oldDb.getCollectionNames();

    if (collections.length === 0) {
        print("⚠️ В старой базе нет коллекций");
    }

    collections.forEach(collName => {
        print("Копирую коллекцию: " + collName);
        const docs = oldDb[collName].find().toArray();
        if (docs.length > 0) {
            newDb[collName].insertMany(docs);
        }
    });

    // Удаляем старую БД
    print("\nУдаляю старую базу: " + OLD_DB);
    oldDb.dropDatabase();

    print("\n✅ Переименование успешно завершено!");
} catch (e) {
    print("❌ Ошибка при переименовании: " + e.message);
    quit(1);
}
