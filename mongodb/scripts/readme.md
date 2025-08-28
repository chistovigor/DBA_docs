interactive_rename.js - интерактивное переименование БД для mongodb

Запуск скрипта
export MG_PASS="SuperSecretPassword"

mongosh --username root \
        --password $MG_PASS \
        --authenticationDatabase admin \
        --eval "var OLD_DB='test', NEW_DB='new_test'" \
        interactive_rename.js

-- bash examples (rename one db, revert back)
mongosh --username root --password $mg_pass --authenticationDatabase admin --eval "var OLD_DB='test', NEW_DB='new_test'" interactive_rename.js
mongosh --username root --password $mg_pass --authenticationDatabase admin --eval "var OLD_DB='new_test', NEW_DB='test'" interactive_rename.js

✅ Особенности:

Пароль хранится в переменной окружения $MG_PASS — безопасно, не передаётся в командной строке как plain text.
Имена баз передаются через --eval

Скрипт проверяет существование старой базы и отсутствие новой базы, чтобы избежать потери данных.
Коллекции копируются с помощью insertMany, после чего старая база удаляется.
