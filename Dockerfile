FROM debian:stretch
MAINTAINER Ratnadeep Debnath <ratnadeep.debnath@zapier.com>

ENV VERSION 2.2.0

RUN apt-get update && \
    apt-get install -y wget mysql-client inotify-tools procps gettext-base && \
    wget https://github.com/sysown/proxysql/releases/download/v${VERSION}/proxysql_${VERSION}-debian9_amd64.deb -O /opt/proxysql_${VERSION}-debian9_amd64.deb && \
    dpkg -i /opt/proxysql_${VERSION}-debian9_amd64.deb && \
    rm -f /opt/proxysql_${VERSION}-debian9_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

# Static env variables. Value updates will need container restart to reflect changes
ENV PROXYSQL_CONF_CHECK_INTERVAL 60
ENV PROXYSQL_CONF_LIVE_RELOAD true
ENV PROXYSQL_ADMIN_USERNAME admin
ENV PROXYSQL_ADMIN_PASSWORD admin
ENV PROXYSQL_ADMIN_HOST "127.0.0.1"
ENV PROXYSQL_ADMIN_PORT "6032"
ENV PROXYSQL_MYSQL_THREADS 4
ENV PROXYSQL_MYSQL_STACKSIZE 1048576
ENV PROXYSQL_MYSQL_INTERFACES "0.0.0.0:6033;/tmp/proxysql.sock"
ENV PROXYSQL_WORKDIR /proxysql

EXPOSE 6033 6034 6035

RUN mkdir -p $PROXYSQL_WORKDIR

# Template to render /etc/proxysql.cnf. proxysql.cnf.tpl can contain
# env var subsitutions to be rendered from env vars and env vars loaded
# from $PROXYSQL_WORKDIR/secrets/secrets.env
COPY proxysql.cnf.tpl $PROXYSQL_WORKDIR/conf/proxysql.cnf.tpl
COPY secrets.env $PROXYSQL_WORKDIR/secrets/secrets.env

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["proxysql", "-f"]
