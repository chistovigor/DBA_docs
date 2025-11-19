# Как использовать роль MongoDB Upgrade

## Основной playbook

Главный playbook для запуска роли обновления MongoDB находится в:
```
mongodb_bda/mongodb_upgrade.yml
```

## Структура проекта

```
mongodb_bda/
├── mongodb_upgrade.yml          # Главный playbook для обновления MongoDB
├── inventory.yml               # Файл инвентаря (нужно создать)
├── group_vars/                 # Переменные для групп серверов
│   └── mongodb_replicaset.yml  # Конфигурация для группы MongoDB
├── roles/
│   └── mongodb_upgrade/        # Роль для обновления MongoDB
└── USAGE.md                    # Эта инструкция
```

## Шаг 1: Создание инвентаря

Создайте файл `inventory.yml` с описанием ваших MongoDB серверов:

```yaml
# mongodb_bda/inventory.yml
all:
  children:
    mongodb_replicaset:
      hosts:
        mongo-primary:
          ansible_host: 10.0.1.10
          mongodb_role: primary
        mongo-secondary1:
          ansible_host: 10.0.1.11
          mongodb_role: secondary
        mongo-secondary2:
          ansible_host: 10.0.1.12
          mongodb_role: secondary
      vars:
        ansible_user: ubuntu
        ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

## Шаг 2: Конфигурация переменных

Создайте файл `group_vars/mongodb_replicaset.yml`:

```yaml
# mongodb_bda/group_vars/mongodb_replicaset.yml
---
# Целевая версия MongoDB для обновления
mongodb_version: "8.0"

# Настройки аутентификации
mongodb_auth_enabled: true
mongodb_admin_user: "admin"

# Название replica set
replicaset_name: "rs0"

# Пакеты для установки
mongodb_packages:
  - mongodb-org

# Дополнительные настройки
mongodb_bind_ip: "0.0.0.0"
mongodb_port: 27017
```

## Шаг 3: Настройка паролей (опционально)

Если используется парольная аутентификация, создайте/отредактируйте зашифрованный файл:

```bash
# Создание зашифрованного файла с паролями
ansible-vault create roles/mongodb_upgrade/vars/secrets.yml

# Или редактирование существующего
ansible-vault edit roles/mongodb_upgrade/vars/secrets.yml
```

Содержимое файла `secrets.yml`:
```yaml
---
mongodb_admin_password: "your_secure_password_here"
```

## Шаг 4: Запуск обновления

### Проверка конфигурации (dry-run)
```bash
cd mongodb_bda
ansible-playbook -i inventory.yml mongodb_upgrade.yml --check
```

### Запуск обновления с запросом пароля от vault
```bash
cd mongodb_bda
ansible-playbook -i inventory.yml mongodb_upgrade.yml --ask-vault-pass
```

### Запуск с файлом пароля vault
```bash
cd mongodb_bda
ansible-playbook -i inventory.yml mongodb_upgrade.yml --vault-password-file ~/.vault_pass
```

### Запуск с дополнительными параметрами
```bash
cd mongodb_bda
ansible-playbook -i inventory.yml mongodb_upgrade.yml \
  --ask-vault-pass \
  --extra-vars "mongodb_version=8.0" \
  --verbose
```

## Шаг 5: Мониторинг выполнения

Во время выполнения playbook'а вы увидите:

1. **Проверку совместимости ОС** - убедится, что на всех серверах Ubuntu 22.04 или 24.04
2. **Проверку статуса Replica Set** - определит PRIMARY и SECONDARY узлы
3. **Валидацию версий** - проверит, что текущие версии MongoDB поддерживают обновление до версии 8.0
4. **Добавление репозитория MongoDB** - настроит репозиторий для новой версии
5. **Последовательное обновление** - обновит узлы по одному, начиная с SECONDARY

## Примеры использования

### Базовое обновление всех серверов до MongoDB 8.0
```bash
ansible-playbook -i inventory.yml mongodb_upgrade.yml
```

### Обновление до конкретной версии
```bash
ansible-playbook -i inventory.yml mongodb_upgrade.yml \
  --extra-vars "mongodb_version=7.0"
```

### Запуск только на определенной группе серверов
```bash
ansible-playbook -i inventory.yml mongodb_upgrade.yml \
  --limit mongodb_replicaset
```

### Запуск с дополнительным логированием
```bash
ansible-playbook -i inventory.yml mongodb_upgrade.yml \
  --ask-vault-pass -vvv
```

## Поддерживаемые версии обновления

| От версии | До версии 8.0 | Ubuntu 22.04 | Ubuntu 24.04 |
|-----------|---------------|--------------|---------------|
| 4.x       | ❌             | Не поддерживается | Не поддерживается |
| 5.0.x     | ✅             | ✅            | ✅             |
| 6.0.x     | ✅             | ✅            | ✅             |
| 7.0.x     | ✅             | ✅            | ✅             |

## Устранение неполадок

### Проверка статуса выполнения
```bash
# Проверить статус MongoDB на всех серверах
ansible mongodb_replicaset -i inventory.yml -m systemd -a "name=mongod"

# Проверить версию MongoDB
ansible mongodb_replicaset -i inventory.yml -m shell -a "mongosh --eval 'print(db.version())'"

# Проверить статус replica set
ansible mongo-primary -i inventory.yml -m shell -a "mongosh --eval 'rs.status()'"
```

### Откат изменений
Если что-то пошло не так, можно вернуться к предыдущей версии:
```bash
# Остановить MongoDB
ansible mongodb_replicaset -i inventory.yml -m systemd -a "name=mongod state=stopped"

# Установить предыдущую версию (например, 7.0)
ansible-playbook -i inventory.yml mongodb_upgrade.yml \
  --extra-vars "mongodb_version=7.0"
```

## Безопасность

1. **Всегда делайте резервную копию** перед обновлением
2. **Используйте ansible-vault** для хранения паролей
3. **Тестируйте сначала в dev/staging окружении**
4. **Убедитесь в наличии мониторинга** статуса replica set

## Логи и отладка

Логи MongoDB находятся в:
```bash
# Системные логи
journalctl -u mongod -f

# Логи MongoDB (если настроены)
tail -f /var/log/mongodb/mongod.log
```

Для отладки роли используйте:
```bash
ansible-playbook -i inventory.yml mongodb_upgrade.yml -vvv --step
```