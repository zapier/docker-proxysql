FROM debian:stretch
MAINTAINER Ratnadeep Debnath <ratnadeep.debnath@zapier.com>

ENV VERSION 2.0.10

RUN apt-get update && \
    apt-get install -y wget mysql-client inotify-tools procps gettext-base && \
    wget https://github.com/sysown/proxysql/releases/download/v${VERSION}/proxysql_${VERSION}-debian9_amd64.deb -O /opt/proxysql_${VERSION}-debian9_amd64.deb && \
    dpkg -i /opt/proxysql_${VERSION}-debian9_amd64.deb && \
    rm -f /opt/proxysql_${VERSION}-debian9_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

ENV PROXYSQL_CONF_CHECK_INTERVAL 60
ENV PROXYSQL_CONF_LIVE_RELOAD true
ENV PROXYSQL_ADMIN_USERNAME admin
ENV PROXYSQL_ADMIN_PASSWORD admin
ENV PROXYSQL_ADMIN_HOST "127.0.0.1"
ENV PROXYSQL_ADMIN_PORT "6032"
ENV PROXYSQL_MYSQL_THREADS 4
ENV PROXYSQL_MYSQL_STACKSIZE 1048576
ENV PROXYSQL_MYSQL_INTERFACES "0.0.0.0:6033;/tmp/proxysql.sock"

EXPOSE 6033 6034 6035

RUN mkdir -p /proxysql
COPY proxysql.cnf.tpl /tmp/proxysql-conf/proxysql.cnf.tpl
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["proxysql", "-f"]
