RecordSQL.Database
==============

Description
----------

Database core of object-relational framework RecordSQL (Record v2)

Based on four architectural patterns:
1) Class Table Inheritance
2) Finite-state machine
3) Code generation
4) Scuffolding (interface)

Links
----------
* [recordsql-backend](https://github.com/vrafael/recordsql-backend)
* [recordsql-frontend](https://github.com/vrafael/recordsql-frontend)

Instruction
----------

1. Install SQL Server 2017 
    * [Quickstart install SQL Server 2017 to Ubuntu](https://docs.microsoft.com/ru-ru/sql/linux/quickstart-install-connect-ubuntu?view=sql-server-2017) 
    * [Setup SQL Server 2017 Tools to Ubuntu](https://docs.microsoft.com/ru-RU/sql/linux/sql-server-linux-setup-tools?view=sql-server-2017#ubuntu)
2. Configure SSL certificate [SQL Server Linux encripted connections](https://docs.microsoft.com/ru-ru/sql/linux/sql-server-linux-encrypted-connections?view=sql-server-2017)
3. Configure Liquibase. For Liquibase required install Java
    * Write parameters **server address**, **login**, **password** in `dev.properties`  
4. Create database with script `database_create.sql`
5. Run `deploy_dev.bat` or `deploy_dev.sh` 
On finish deployment you will see `Liquibase Update Successful`

_Rafael Valiullin_
vrafael@mail.ru
