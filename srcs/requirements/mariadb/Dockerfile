FROM	debian:12

RUN	apt-get update && apt-get install -y \
	mariadb-server \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mysql/* \

COPY	conf/mariadb.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY	tools/init.sh /usr/local/bin/init.sh

RUN	chmod +x /usr/local/bin/init.sh

ENTRYPOINT ["/usr/local/bin/init.sh"]
