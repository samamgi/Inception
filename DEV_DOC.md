# Developer documentation

## Overview

This document explains how to set up, build and manage the Inception project from scratch.

The project builds a Docker infrastructure composed of:

    MariaDB
    WordPress + PHP-FPM
    NGINX

Each service runs in its own container.

The images are built manually from Debian.  
Ready-made service images such as `nginx`, `wordpress` or `mariadb` are not used.

## Requirements

The project must be developed and run inside a virtual machine.

Required tools:

    docker
    docker compose
    make
    openssl

Useful tools:

    git
    vim
    tree
    curl

## Project structure

Expected structure:

    .
    ├── Makefile
    ├── README.md
    ├── USER_DOC.md
    ├── DEV_DOC.md
    ├── secrets
    │   ├── db_password.txt
    │   ├── db_root_password.txt
    │   ├── wp_admin_password.txt
    │   └── wp_user_password.txt
    └── srcs
        ├── .env
        ├── docker-compose.yml
        └── requirements
            ├── mariadb
            │   ├── Dockerfile
            │   ├── conf
            │   │   └── mariadb.cnf
            │   └── tools
            │       └── init.sh
            ├── nginx
            │   ├── Dockerfile
            │   ├── conf
            │   │   └── nginx.conf
            │   └── tools
            │       └── init.sh
            └── wordpress
                ├── Dockerfile
                ├── conf
                │   └── www.conf
                └── tools
                    └── init.sh

## Environment file

The environment file is located at:

    srcs/.env

It contains non-sensitive configuration.

Example:

    LOGIN=ssadi-ou
    DOMAIN_NAME=ssadi-ou.42.fr

    MYSQL_DATABASE=wordpress
    MYSQL_USER=wp_user

    WP_TITLE=Inception
    WP_ADMIN_USER=chief42
    WP_ADMIN_EMAIL=chief42@example.com

    WP_USER=visitor42
    WP_USER_EMAIL=visitor42@example.com

Passwords are not stored in `.env`.

## Secrets

Secrets are stored locally in:

    secrets/

Required files:

    secrets/db_root_password.txt
    secrets/db_password.txt
    secrets/wp_admin_password.txt
    secrets/wp_user_password.txt

Example setup:

    mkdir -p secrets

    openssl rand -base64 24 > secrets/db_root_password.txt
    openssl rand -base64 24 > secrets/db_password.txt
    openssl rand -base64 24 > secrets/wp_admin_password.txt
    openssl rand -base64 24 > secrets/wp_user_password.txt

These files must be ignored by Git.

The `.gitignore` should contain:

    secrets/*.txt

Inside the containers, secrets are available in:

    /run/secrets/

Example:

    /run/secrets/db_password
    /run/secrets/wp_admin_password

## Persistent data

The subject requires persistent data to be stored in:

    /home/login/data

For this project:

    /home/ssadi-ou/data

Create the directories:

    mkdir -p /home/$USER/data/mariadb
    mkdir -p /home/$USER/data/wordpress

MariaDB data is stored in:

    /home/ssadi-ou/data/mariadb

WordPress files are stored in:

    /home/ssadi-ou/data/wordpress

These directories are used by Docker named volumes.

## Docker Compose

The main Compose file is:

    srcs/docker-compose.yml

It defines:

    services
    networks
    volumes
    secrets

The three services are:

    mariadb
    wordpress
    nginx

The network is:

    inception

The named volumes are:

    mariadb_data
    wordpress_data

Only NGINX exposes a port to the host:

    443:443

MariaDB and WordPress are only reachable through the Docker network.

## MariaDB service

The MariaDB image is built from:

    srcs/requirements/mariadb/Dockerfile

The configuration file is:

    srcs/requirements/mariadb/conf/mariadb.cnf

The initialization script is:

    srcs/requirements/mariadb/tools/init.sh

The script:

    reads the database secrets
    initializes MariaDB if needed
    creates the WordPress database
    creates the WordPress database user
    grants the required privileges
    starts mariadbd in the foreground

MariaDB stores its data in:

    /var/lib/mysql

This path is connected to the Docker volume:

    mariadb_data

## WordPress service

The WordPress image is built from:

    srcs/requirements/wordpress/Dockerfile

The PHP-FPM configuration file is:

    srcs/requirements/wordpress/conf/www.conf

The initialization script is:

    srcs/requirements/wordpress/tools/init.sh

The script:

    reads the secrets
    waits for MariaDB
    downloads WordPress with WP-CLI
    creates wp-config.php
    installs WordPress
    creates the administrator user
    creates a normal user
    starts PHP-FPM in the foreground

PHP-FPM listens on:

    0.0.0.0:9000

NGINX forwards PHP requests to:

    wordpress:9000

WordPress files are stored in:

    /var/www/html

This path is connected to the Docker volume:

    wordpress_data

## NGINX service

The NGINX image is built from:

    srcs/requirements/nginx/Dockerfile

The configuration file is:

    srcs/requirements/nginx/conf/nginx.conf

The initialization script is:

    srcs/requirements/nginx/tools/init.sh

The script:

    creates the SSL directory
    generates a self-signed TLS certificate
    replaces DOMAIN_NAME in the NGINX configuration
    starts NGINX in the foreground

NGINX listens on:

    443

The configuration allows only:

    TLSv1.2
    TLSv1.3

NGINX is the only public entry point of the infrastructure.

## Domain setup

The domain must point to the local machine.

Inside the VM, edit:

    /etc/hosts

Add:

    127.0.0.1 ssadi-ou.42.fr

Test with:

    ping -c 2 ssadi-ou.42.fr

The domain should resolve to:

    127.0.0.1

## Build and launch

From the root of the repository:

    make

This runs:

    docker compose -f srcs/docker-compose.yml up --build -d

It builds the images and starts the containers in detached mode.

## Stop the project

    make down

This stops the containers but keeps the persistent data.

## Clean the project

    make clean

This stops the containers and removes the Docker volumes.

## Full clean

    make fclean

This removes:

    containers
    volumes
    unused Docker resources
    persistent MariaDB data
    persistent WordPress files

Warning: this deletes the data in:

    /home/ssadi-ou/data/mariadb
    /home/ssadi-ou/data/wordpress

## Rebuild

    make re

This performs a full clean and rebuilds the project.

## Logs

    make logs

or:

    docker compose -f srcs/docker-compose.yml logs -f

## Status

    make ps

or:

    docker compose -f srcs/docker-compose.yml ps

## Manual testing

Check running containers:

    docker ps

Expected containers:

    mariadb
    wordpress
    nginx

Only NGINX should expose port 443:

    0.0.0.0:443->443/tcp

Check volumes:

    docker volume ls

Expected volumes:

    mariadb_data
    wordpress_data

Check host data:

    ls -la /home/$USER/data

Test the website:

    curl -k https://ssadi-ou.42.fr

Test headers:

    curl -k -I https://ssadi-ou.42.fr

Check WordPress installation:

    docker exec -it wordpress wp core is-installed --allow-root --path=/var/www/html

List WordPress users:

    docker exec -it wordpress wp user list --allow-root --path=/var/www/html

Test MariaDB connection:

    docker exec -it mariadb sh -c 'mariadb -u "$MYSQL_USER" -p"$(cat /run/secrets/db_password)" "$MYSQL_DATABASE"'

Then inside MariaDB:

    SHOW DATABASES;
    SELECT USER();
    exit;

## Git checks

Check that secrets are ignored:

    git check-ignore -v secrets/db_password.txt
    git check-ignore -v secrets/db_root_password.txt
    git check-ignore -v secrets/wp_admin_password.txt
    git check-ignore -v secrets/wp_user_password.txt

Before committing, check:

    git status

The secret `.txt` files must not appear in the files to be committed.

## Common issues

### Makefile missing separator

If `make` returns:

    missing separator

It usually means a command line in the Makefile uses spaces instead of a tab.

Command lines under a rule must start with a real tab.

### Domain does not resolve

Check `/etc/hosts`.

It should contain:

    127.0.0.1 ssadi-ou.42.fr

### Browser shows a certificate warning

This is expected.

The TLS certificate is self-signed.

### MariaDB access denied

Check that the secrets match the initialized database.

During development, the database can be reset with:

    docker compose -f srcs/docker-compose.yml down -v
    sudo find /home/$USER/data/mariadb -mindepth 1 -delete

Then rebuild.

### WordPress cannot connect to MariaDB

Check that MariaDB is running:

    docker ps

Check WordPress logs:

    docker logs wordpress

Check MariaDB logs:

    docker logs mariadb

The WordPress container connects to MariaDB with:

    mariadb:3306

## Notes

The project is designed to be rebuilt from the Makefile.

Containers are not kept alive with fake commands such as:

    tail -f
    sleep infinity
    while true

Each container runs its real main service in the foreground:

    mariadbd
    php-fpm8.2
    nginx

This keeps the project aligned with Docker best practices.