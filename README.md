*This project has been created as part of the 42 curriculum by ssadi-ou*

# Inception

## Description

Inception is a system administration project based on Docker.

The goal of this project is to build a small web infrastructure inside a virtual machine.  
Each service runs in its own Docker container and communicates through a private Docker network.

This project includes:

    A MariaDB container
    A WordPress + PHP-FPM container
    An NGINX container with TLS enabled
    A Docker network
    Two persistent Docker volumes
    Docker secrets
    A Makefile to build and run the infrastructure

The project does not use ready-made service images such as `nginx`, `wordpress` or `mariadb`.  
Each image is built manually from Debian.

## Project description

The infrastructure is composed of three main services.

MariaDB is the database server.  
It stores the WordPress database, users, posts, pages and website configuration.

WordPress is the web application.  
It runs with PHP-FPM and communicates with MariaDB through the Docker network.

NGINX is the web server.  
It is the only entry point into the infrastructure and only exposes port 443 with TLSv1.2 / TLSv1.3.

The request flow is:

    Browser
        -> NGINX on port 443
            -> WordPress / PHP-FPM on port 9000
                -> MariaDB on port 3306

Only NGINX exposes a port to the host machine.  
MariaDB and WordPress are only reachable inside the Docker network.

## Features

Custom Docker image for MariaDB

Custom Docker image for WordPress + PHP-FPM

Custom Docker image for NGINX

TLS configuration with a self-signed certificate

WordPress automatic installation with WP-CLI

Two WordPress users:

    One administrator
    One normal user

The administrator username does not contain `admin` or `administrator`.

Persistent Docker volumes:

    mariadb_data
    wordpress_data

The volume data is stored in:

    /home/ssadi-ou/data/mariadb
    /home/ssadi-ou/data/wordpress

Docker secrets are used for passwords.

Environment variables are stored in:

    srcs/.env

Secrets are stored locally in:

    secrets/

The secret files are ignored by Git.

## Technical choices

### Virtual Machines vs Docker

A virtual machine virtualizes a complete operating system.  
It has its own kernel, memory, disk and system environment.

Docker containers are lighter.  
They share the host kernel and isolate only what each service needs, such as processes, filesystem and network.

For this project, the virtual machine is used as the host environment.  
Docker is then used inside the VM to isolate each service.

### Secrets vs Environment Variables

Environment variables are used for non-sensitive configuration, such as:

    DOMAIN_NAME
    MYSQL_DATABASE
    MYSQL_USER
    WP_ADMIN_USER
    WP_USER

Secrets are used for passwords, such as:

    db_password
    db_root_password
    wp_admin_password
    wp_user_password

Passwords are not written in Dockerfiles, scripts or the Git repository.  
They are read inside the containers from:

    /run/secrets/

### Docker Network vs Host Network

The project uses a Docker bridge network named `inception`.

This allows containers to communicate with each other by service name:

    wordpress -> mariadb
    nginx -> wordpress

The host network is not used because it removes part of Docker's network isolation.  
It could also expose services that should remain private.

### Docker Volumes vs Bind Mounts

The project uses Docker named volumes:

    mariadb_data
    wordpress_data

These volumes are configured to store their data inside:

    /home/ssadi-ou/data

This keeps the database and WordPress files persistent even if the containers are removed.

## Instructions

### Requirements

The project must be run inside a virtual machine.

Required tools:

    docker
    docker compose
    make

### Configuration

Create the data directories:

    mkdir -p /home/$USER/data/mariadb
    mkdir -p /home/$USER/data/wordpress

Create the required secret files inside the `secrets/` directory:

    secrets/db_root_password.txt
    secrets/db_password.txt
    secrets/wp_admin_password.txt
    secrets/wp_user_password.txt

Example:

    openssl rand -base64 24 > secrets/db_root_password.txt
    openssl rand -base64 24 > secrets/db_password.txt
    openssl rand -base64 24 > secrets/wp_admin_password.txt
    openssl rand -base64 24 > secrets/wp_user_password.txt

The domain must point to the local machine.

For this project:

    127.0.0.1 ssadi-ou.42.fr

This line can be added to:

    /etc/hosts

### Build and run

From the root of the repository:

    make

This builds the images and starts the containers in detached mode.

### Stop the project

    make down

### Clean containers and volumes

    make clean

### Full clean

    make fclean

This removes containers, volumes, unused Docker resources and the persistent data directories.

### Rebuild from scratch

    make re

### Logs

    make logs

### Container status

    make ps

## Access

Website:

    https://ssadi-ou.42.fr

WordPress administration panel:

    https://ssadi-ou.42.fr/wp-admin

The certificate is self-signed, so the browser may show a warning.

The administrator username is defined in:

    srcs/.env

The administrator password is stored locally in:

    secrets/wp_admin_password.txt

## Useful commands

List containers:

    docker ps

List volumes:

    docker volume ls

Check exposed ports:

    docker ps

Only the NGINX container should expose port 443.

Enter the MariaDB container:

    docker exec -it mariadb bash

Enter the WordPress container:

    docker exec -it wordpress bash

Check WordPress users:

    docker exec -it wordpress wp user list --allow-root --path=/var/www/html

Check the Docker network:

    docker network ls

Check the project volumes:

    ls -la /home/$USER/data

## Services

### MariaDB

MariaDB stores the WordPress database.

The database files are kept in the `mariadb_data` volume and stored on the host in:

    /home/ssadi-ou/data/mariadb

MariaDB is not exposed to the host.  
It is only reachable by other containers through the Docker network.

### WordPress + PHP-FPM

WordPress is installed automatically with WP-CLI.

PHP-FPM executes the PHP files of WordPress and listens on port 9000 inside the Docker network.

WordPress files are kept in the `wordpress_data` volume and stored on the host in:

    /home/ssadi-ou/data/wordpress

### NGINX

NGINX is the only public entry point.

It listens on port 443 with TLS enabled.  
It serves the WordPress files and forwards PHP requests to:

    wordpress:9000

The configuration only allows:

    TLSv1.2
    TLSv1.3

## Directory structure

Expected project structure:

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

The secret files must stay local and must not be pushed to Git.

## Resources

This project is based on Docker and system administration concepts.

Useful resources:

    Docker documentation
    Docker Compose documentation
    Debian documentation
    MariaDB documentation
    NGINX documentation
    WordPress documentation
    WP-CLI documentation
    PHP-FPM documentation
    OpenSSL documentation

AI was used as a support tool to understand Docker concepts, read error logs, compare configuration choices and prepare test commands.

All configuration files were reviewed, tested and adjusted manually inside the virtual machine.