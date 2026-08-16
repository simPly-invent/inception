#!/bin/bash

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ ! -d /var/lib/mysql/mysql ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null 2>&1
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &

    sleep 5
    mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"
    mysql -uroot -p"${DB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS ${NAME_DATABASE}; CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}'; GRANT ALL PRIVILEGES ON ${NAME_DATABASE}.* TO '${DB_USER}'@'%'; FLUSH PRIVILEGES;"
    mysqladmin -uroot -p"${DB_ROOT_PASSWORD}" shutdown
fi

exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0