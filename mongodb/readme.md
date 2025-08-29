Ansible


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

проверка работы экспортера:

выполняем со стороны хоста, который будет забирать метрики

curl http://fqdn_of_host:9216/metrics 
ожидается вывод списка метрик

локальная конфигурация / проверка работы экспортера:

конфиг: 
vim /etc/systemd/system/mongodb_exporter.service

перезапуск сервиса:
systemctl daemon-reload && systemctl restart mongodb_exporter && systemctl status mongodb_exporter

проверка выводимых метрик:
curl http://127.0.0.1:9216/metrics > /tmp/mongo_metrics_list_2.log && cat /tmp/mongo_metrics_list_2.log | wc -l


Bash script


Инструкция по использованию:
Сохраните скрипт как install_mongodb_exporter.sh

Сделайте исполняемым: chmod +x install_mongodb_exporter.sh

Запустите с правами root: sudo ./install_mongodb_exporter.sh

Особенности скрипта:
Запрашивает пароль пользователя zabbix при запуске

Автоматически скачивает и устанавливает экспортер
Настраивает systemd сервис с автоперезапуском
Проверяет успешность запуска службы
Открывает порт в firewall (если используется ufw)
Очищает временные файлы после установки

Требования перед запуском:

Убедитесь, что пользователь zabbix создан в MongoDB с нужными правами
Убедитесь, что MongoDB запущен и доступен на localhost:27017
Установите зависимости: sudo apt-get install wget (для Debian/Ubuntu)

После установки экспортер будет доступен по адресу http://сервер:9216/metrics
