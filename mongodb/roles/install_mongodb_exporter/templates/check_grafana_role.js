(function() {
  try {
    print("== Проверка serverStatus ==");
    db.getSiblingDB("admin").runCommand({ serverStatus: 1 });
    print("✓ serverStatus работает");

    print("== Проверка dbStats ==");
    db.getSiblingDB("test").runCommand({ dbStats: 1 });
    print("✓ dbStats работает");

    print("== Проверка collStats ==");
    db.getSiblingDB("test").runCommand({ collStats: "system.indexes" });
    print("✓ collStats работает");

    print("== Проверка запроса к данным (findOne) ==");
    var result = db.getSiblingDB("test").getCollection("system.users").findOne();
    if (result) {
      print("✗ ОШИБКА: findOne вернул результат: " + JSON.stringify(result));
    } else {
      print("✓ findOne вернул null (прав доступа нет)");
    }
  } catch (e) {
    if (e.codeName === "Unauthorized" || e.code === 13) {
      print("✓ findOne запрещён (как и должно быть)");
    } else {
      print("✗ Неожиданная ошибка при findOne: " + JSON.stringify(e));
    }
  }
})();
