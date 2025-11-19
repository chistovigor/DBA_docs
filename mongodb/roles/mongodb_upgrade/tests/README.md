Команды для тестирования

Подготовка VM:

ansible-playbook -i roles/mongodb_upgrade/tests/inventory.yml roles/mongodb_upgrade/tests/prepare.yml -D


Применение роли mongodb_upgrade:

ansible-playbook -i roles/mongodb_upgrade/tests/inventory.yml roles/mongodb_upgrade/tests/converge.yml -D -e "mongodb_version=8.0"


Проверка работы MongoDB и реплика-сета:

ansible-playbook -i roles/mongodb_upgrade/tests/inventory.yml roles/mongodb_upgrade/tests/verify.yml -D


Очистка VM после тестов:

ansible-playbook -i roles/mongodb_upgrade/tests/inventory.yml roles/mongodb_upgrade/tests/cleanup.yml -D

4️⃣ Интерпретация результатов

MongoDB сервис: Проверяется через systemd. Если failed — сервис не запущен.

Реплика-сет: Статус выводится через rs.status() в verify.yml.

PRIMARY — основной узел

SECONDARY — вторичные узлы

health: 1 — узел здоров

Логи роли: Если роль создаёт логи, они находятся на VM в /var/log/mongodb_upgrade.log.

Ошибки Ansible: Любые ошибки в failed показывают проблемы на конкретной VM.