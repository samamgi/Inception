#!/bin/bash

set -e

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/inception.crt ] || [ ! -f /etc/nginx/ssl/inception.key ]; then
    echo "Generating self-signed TLS certificate..."

    openssl req -x509 -nodes \
        -out /etc/nginx/ssl/inception.crt \
        -keyout /etc/nginx/ssl/inception.key \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=${DOMAIN_NAME}" \
        -newkey rsa:2048 \
        -days 365
fi

sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" /etc/nginx/sites-available/default

echo "Starting NGINX..."

exec nginx -g "daemon off;"
