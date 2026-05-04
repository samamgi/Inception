FROM	debian:12

RUN	apt-get update && apt-get install -y \
	php-fpm \
	php-cli \
	php-mysql \
	php-curl \
	php-curl \
	php-gd \
	php-intl \
	php-mbstring \
	php-xml \
	php-zip \
	mariadb-client \
	curl \
	ca-certificates \
	unzip \
	&& rm -rf /var/lib/apt/lists/*

RUN	curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x /usr/local/bin/wp

COPY	conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY	tools/init.sh	/usr/local/bin/init.sh

RUN	chmod +x /usr/local/bin/init.sh

ENTRYPOINT ["/usr/local/bin/init.sh"]
