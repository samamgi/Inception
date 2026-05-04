#!/bin/bash

set -e

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

mkdir -p /run/php
mkdir -p /var/www/html

chown -R www-data:www-data /var/www/html

echo "Waiting for MariaDB..."

for i in {1..60}; do
    if mariadb -h mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "SELECT 1;" > /dev/null 2>&1; then
        echo "MariaDB is ready."
        break
    fi

    if [ "$i" -eq 60 ]; then
        echo "MariaDB is not ready after 120 seconds."
        exit 1
    fi

    echo "MariaDB is not ready yet..."
    sleep 2
done

cd /var/www/html

if [ ! -f "wp-config.php" ]; then
    echo "Downloading WordPress..."

    if [ ! -f "index.php" ]; then
        wp core download --allow-root
    fi

    echo "Creating wp-config.php..."

    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="mariadb:3306" \
        --allow-root
fi

if ! wp core is-installed --allow-root > /dev/null 2>&1; then
    echo "Installing WordPress..."

    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root
fi

if ! wp user get "$WP_USER" --allow-root > /dev/null 2>&1; then
    echo "Creating normal WordPress user..."

    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=contributor \
        --allow-root
fi

chown -R www-data:www-data /var/www/html

echo "WordPress is ready."

exec php-fpm8.2 -F
