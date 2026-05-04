# User documentation

## Overview

This project provides a small WordPress infrastructure using Docker.

The stack contains three services:

    NGINX
    WordPress + PHP-FPM
    MariaDB

NGINX is the only public entry point.  
It exposes port 443 and serves the website through HTTPS.

WordPress runs with PHP-FPM and generates the website pages.

MariaDB stores the WordPress database.

The services communicate through a private Docker network.

## Services

### NGINX

NGINX receives HTTPS requests from the browser.

It listens on:

    443

It uses TLSv1.2 and TLSv1.3 only.

NGINX serves the WordPress files and forwards PHP requests to the WordPress container.

### WordPress + PHP-FPM

WordPress is the web application.

It is installed automatically with WP-CLI when the container starts for the first time.

PHP-FPM executes the PHP files used by WordPress.

The WordPress files are stored in the persistent volume:

    wordpress_data

On the host machine, the data is stored in:

    /home/ssadi-ou/data/wordpress

### MariaDB

MariaDB is the database server used by WordPress.

It stores:

    WordPress users
    Posts
    Pages
    Comments
    Website settings

The database files are stored in the persistent volume:

    mariadb_data

On the host machine, the data is stored in:

    /home/ssadi-ou/data/mariadb

MariaDB is not exposed to the host.  
It is only reachable inside the Docker network.

## Starting the project

From the root of the repository:

    make

This command builds the Docker images and starts the containers in detached mode.

It starts:

    mariadb
    wordpress
    nginx

## Stopping the project

To stop the containers:

    make down

This stops the services but keeps the persistent data.

## Cleaning the project

To stop the containers and remove the Docker volumes:

    make clean

To fully clean the project:

    make fclean

This removes:

    containers
    volumes
    unused Docker resources
    persistent data directories

Warning: `make fclean` deletes the WordPress files and the MariaDB database stored in `/home/ssadi-ou/data`.

## Restarting from scratch

To clean everything and rebuild:

    make re

## Accessing the website

The website is available at:

    https://ssadi-ou.42.fr

The domain must point to the local machine.

In the VM, the following line can be added to `/etc/hosts`:

    127.0.0.1 ssadi-ou.42.fr

The TLS certificate is self-signed, so the browser may show a warning.  
This is expected.

## Accessing the WordPress administration panel

The WordPress administration panel is available at:

    https://ssadi-ou.42.fr/wp-admin

The administrator username is defined in:

    srcs/.env

The administrator password is stored locally in:

    secrets/wp_admin_password.txt

To display it:

    cat secrets/wp_admin_password.txt

The administrator username does not contain `admin` or `administrator`.

## Credentials

Passwords are stored as Docker secrets.

The secret files are located in:

    secrets/

Required secret files:

    db_root_password.txt
    db_password.txt
    wp_admin_password.txt
    wp_user_password.txt

These files must stay local and must not be pushed to Git.

Inside the containers, Docker makes the secrets available in:

    /run/secrets/

## Checking if the services are running

To see the status of the containers:

    make ps

or:

    docker compose -f srcs/docker-compose.yml ps

Expected services:

    mariadb
    wordpress
    nginx

To check the exposed ports:

    docker ps

Only NGINX should expose a port:

    0.0.0.0:443->443/tcp

MariaDB and WordPress should not expose ports to the host.

## Viewing logs

To see the logs:

    make logs

or:

    docker compose -f srcs/docker-compose.yml logs -f

## Useful commands

List running containers:

    docker ps

List Docker volumes:

    docker volume ls

Check the persistent data directories:

    ls -la /home/ssadi-ou/data

Check WordPress users:

    docker exec -it wordpress wp user list --allow-root --path=/var/www/html

Enter the WordPress container:

    docker exec -it wordpress bash

Enter the MariaDB container:

    docker exec -it mariadb bash

## Notes

The project must be run inside a virtual machine.

The repository contains the configuration files and Dockerfiles.  
The generated data is stored outside the repository in:

    /home/ssadi-ou/data

The secret files are local and ignored by Git.