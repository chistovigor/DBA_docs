
install_mongodb_exporter.yml

Использование
Создайте файл с защищенными переменными (паролем):

bash
ansible-vault create vars/secrets.yml
Добавьте содержимое:

yaml
vault_mongodb_password: "your_secure_password_here"
Запустите playbook:

bash
ansible-playbook -i inventory install_mongodb_exporter.yml --ask-vault-pass
Особенности роли
Безопасность: Пароль передается через ansible-vault

Гибкость: Настройки можно легко изменить через переменные
Идемпотентность: Роль можно запускать многократно без побочных эффектов
Уведомления: Сервис автоматически перезапускается при изменении конфигурации
Кросс-платформенность: Поддержка разных ОС (с условием для ufw)

Перед использованием убедитесь, что:

Пользователь MongoDB (zabbix) с правами мониторинга уже создан
Хосты добавлены в inventory файл Ansible
Ansible имеет доступ к целевым серверам
