Проект базы данных фреймворка Record
==============

Описание
----------

 Ядро бъектно-реляционного фреймворка Record v2  

Инструкция
----------

1. Установить SQL Server 2017 по мануалам [1](https://docs.microsoft.com/ru-ru/sql/linux/quickstart-install-connect-ubuntu?view=sql-server-2017) и [2](https://docs.microsoft.com/ru-RU/sql/linux/sql-server-linux-setup-tools?view=sql-server-2017#ubuntu)
2. Подключить SSL сертификт по описанию [шифрование](https://docs.microsoft.com/ru-ru/sql/linux/sql-server-linux-encrypted-connections?view=sql-server-2017)
3. Настроить подключение для деплоя миграций Liquibase из репозитория. Для работы Liquibase требуется установить Java
    * Создать файл `prod.properties` по примеру файла `dev.properties`  
    В файле прописать параметры подключения к базе данных
    * Сделать файл деплоя в целевую базу  
    Для системы ОС на ядре linux сделать файл `deploy_prod.sh` по примеру файла `deploy_dev.sh` с контекстом `--contexts="prod"`  
    Для системы на ОС Windows сделать файл `deploy_prod.bat` по примеру файла `deploy_dev.bat` с контекстом `--contexts="prod"`  
    * При успешном завершении деплоя в консоли должна появится надпись `Liquibase Update Successful`

_Rafael Valiullin_  
vrafael@mail.ru