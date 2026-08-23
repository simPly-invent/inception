#!/bin/bash

set -e

WP_PATH="/var/www/html"
mkdir -p ${WP_PATH}
cd ${WP_PATH}

until mysqladmin ping -h mariadb -u"${DB_USER}" -p"${DB_PASSWORD}" --silent; do
    echo "Waiting for MariaDB..."
    sleep 2
done

if [ ! -f "${WP_PATH}/wp-config.php" ]; then
    wp core download --allow-root

    wp config create \
        --dbname="${NAME_DATABASE}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root

    wp core install \
        --url="localhost" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    wp user create "${WP_USER_USERNAME}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root
fi

chown -R www-data:www-data ${WP_PATH}

exec php-fpm8.2 -F