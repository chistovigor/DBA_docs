# MongoDB Replicaset Sequential Update Role

Роль Ansible для последовательного обновления MongoDB replica set с версий 4,5,6,7 до версии 8 на серверах Ubuntu 22.04/24.04 с поддержкой парольной аутентификации.

## Особенности

- ✅ **Последовательное обновление**: Обновляет узлы replica set поочередно (сначала secondary, затем primary)
- ✅ **Безопасное переключение**: Автоматическое stepDown primary узла перед обновлением
- ✅ **Проверка совместимости**: Валидация ОС (Ubuntu 22.04/24.04) и путей обновления MongoDB
- ✅ **Поддержка версий**: Обновление с MongoDB 4.x, 5.x, 6.x, 7.x до 8.x
- ✅ **Парольная аутентификация**: Поддержка MongoDB с включенной аутентификацией
- ✅ **Автоматические тесты**: Полное покрытие тестами с использованием Molecule

## Требования

### Система
- Ubuntu 22.04 LTS или Ubuntu 24.04 LTS
- Архитектура x86_64
- Systemd

### Пакеты
- `curl` - для загрузки ключей репозитория
- `gnupg` - для работы с GPG ключами

### MongoDB
- Рабочий MongoDB replica set с версиями 4.x, 5.x, 6.x, или 7.x
- Настроенная аутентификация (если используется)
- Mongosh client установлен и доступен

## Установка и использование

### 1. Подготовка инвентаря

```yaml
# inventory.yml
all:
  children:
    mongodb_replicaset:
      hosts:
        mongo1.example.com:
          mongodb_role: primary
        mongo2.example.com:
          mongodb_role: secondary
        mongo3.example.com:
          mongodb_role: secondary
```

### 2. Конфигурация переменных

```yaml
# group_vars/mongodb_replicaset.yml
mongodb_version: "8.0"
mongodb_auth_enabled: true
mongodb_admin_user: "admin"
mongodb_admin_password: "{{ vault_mongodb_admin_password }}"
replicaset_name: "rs0"
```

### 3. Создание playbook

```yaml
# mongodb_upgrade.yml
---
- hosts: mongodb_replicaset
  become: yes
  vars_files:
    - group_vars/mongodb_replicaset.yml
    - roles/mongodb_upgrade/vars/secrets.yml
  roles:
    - role: mongodb_upgrade
      vars:
        mongodb_version: "8.0"
```

### 4. Запуск обновления

```bash
# Проверка (dry-run)
ansible-playbook -i inventory.yml mongodb_upgrade.yml --check

# Выполнение обновления
ansible-playbook -i inventory.yml mongodb_upgrade.yml
```

## Переменные роли

### Обязательные переменные

| Переменная | Описание | Пример |
|------------|----------|--------|
| `mongodb_version` | Целевая версия MongoDB | `"8.0"` |

### Опциональные переменные

| Переменная | Описание | По умолчанию |
|------------|----------|--------------|
| `mongodb_packages` | Список пакетов MongoDB | `["mongodb-org"]` |
| `mongodb_repo_map` | Маппинг Ubuntu версий на кодовые имена | См. defaults/main.yml |
| `replicaset_inventory_group` | Группа инвентаря replica set | `""` |
| `servers_to_update` | Список серверов для обновления | `[]` |

## Структура роли

```
mongodb_upgrade/
├── defaults/main.yml           # Переменные по умолчанию
├── tasks/
│   ├── main.yml               # Главный файл задач
│   ├── check_os_compatibility.yml      # Проверка ОС
│   ├── check_replicaset_status.yml     # Проверка статуса RS
│   ├── validate_versions.yml          # Валидация версий
│   ├── sequential_replicaset_update.yml # Последовательное обновление
│   ├── update_single_node.yml         # Обновление одного узла
│   ├── add_repo.yml                   # Добавление репозитория
│   ├── install_mongodb.yml            # Установка MongoDB
│   └── stop_start_service.yml         # Управление сервисом
├── handlers/main.yml          # Обработчики событий
├── vars/
│   ├── main.yml              # Переменные роли
│   └── secrets.yml           # Секретные данные (пароли)
├── molecule/                 # Автоматические тесты
└── README.md                # Документация
```

## Процесс обновления

1. **Проверка совместимости ОС** - Валидация Ubuntu 22.04/24.04
2. **Анализ replica set** - Определение PRIMARY/SECONDARY узлов и текущих версий
3. **Валидация версий** - Проверка путей обновления с 4.x/5.x/6.x/7.x до 8.x
4. **Добавление репозитория** - Настройка MongoDB 8.0 репозитория
5. **Последовательное обновление**:
   - Обновление SECONDARY узлов поочередно
   - StepDown PRIMARY узла (если требуется обновление)
   - Обновление бывшего PRIMARY узла
6. **Финальная проверка** - Валидация состояния replica set

## Автоматические тесты

Роль включает полное покрытие тестами с использованием Molecule:

```bash
# Запуск всех тестов
molecule test

# Запуск только проверки
molecule verify

# Создание тестовой среды
molecule converge
```

### Тестовые сценарии:

- **3 узла**: Primary (MongoDB 7.0), Secondary1 (MongoDB 6.0), Secondary2 (MongoDB 5.0)
- **ОС**: Ubuntu 22.04 и Ubuntu 24.04
- **Обновление**: Все узлы до MongoDB 8.0
- **Проверки**: Статус сервисов, connectivity, replica set health

## Безопасность

### Парольная аутентификация

```yaml
# vars/secrets.yml (зашифрован с ansible-vault)
mongodb_admin_user: "admin"
mongodb_admin_password: "secure_password_here"
mongodb_auth_enabled: true
```

### Шифрование паролей

```bash
# Создание зашифрованного файла с паролями
ansible-vault create roles/mongodb_upgrade/vars/secrets.yml

# Редактирование зашифрованного файла
ansible-vault edit roles/mongodb_upgrade/vars/secrets.yml
```

## Поддерживаемые пути обновления

| От версии | До версии | Ubuntu 22.04 | Ubuntu 24.04 | Статус |
|-----------|-----------|--------------|---------------|--------|
| 4.0.x     | 8.0.x     | ❌            | ❌             | Не поддерживается |
| 4.2.x     | 8.0.x     | ❌            | ❌             | Не поддерживается |
| 4.4.x     | 8.0.x     | ❌            | ❌             | Не поддерживается |
| 5.0.x     | 8.0.x     | ✅            | ✅             | Поддерживается |
| 6.0.x     | 8.0.x     | ✅            | ✅             | Поддерживается |
| 7.0.x     | 8.0.x     | ✅            | ✅             | Поддерживается |

## Устранение неполадок

### Типичные ошибки

1. **"Неподдерживаемая версия Ubuntu"**
   - Проверьте, что используется Ubuntu 22.04 или 24.04

2. **"Неподдерживаемые версии MongoDB"**
   - Убедитесь, что текущие версии: 5.0, 6.0, или 7.0

3. **"Replica set находится в неисправном состоянии"**
   - Проверьте статус всех узлов: `rs.status()`
   - Убедитесь, что все узлы доступны

### Логи и диагностика

```bash
# Проверка статуса MongoDB
systemctl status mongod

# Проверка логов MongoDB
journalctl -u mongod -f

# Проверка replica set из mongosh
rs.status()
rs.conf()
```

## Примеры использования

### Базовое обновление
```yaml
- hosts: mongodb_replicaset
  become: yes
  roles:
    - role: mongodb_upgrade
      vars:
        mongodb_version: "8.0"
```

### Обновление с аутентификацией
```yaml
- hosts: mongodb_replicaset
  become: yes
  vars_files:
    - roles/mongodb_upgrade/vars/secrets.yml
  roles:
    - role: mongodb_upgrade
      vars:
        mongodb_version: "8.0"
        mongodb_auth_enabled: true
```

## Лицензия

MIT License

## Автор

Создано для обновления MongoDB replica set с обеспечением высокой доступности и безопасности данных.