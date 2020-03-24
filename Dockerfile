FROM debian:stretch
MAINTAINER Ratnadeep Debnath <ratnadeep.debnath@zapier.com>

ENV VERSION 2.0.7

RUN apt-get update && \
    apt-get install -y wget mysql-client inotify-tools procps gettext-base && \
    wget https://github.com/sysown/proxysql/releases/download/v${VERSION}/proxysql_${VERSION}-debian9_amd64.deb -O /opt/proxysql_${VERSION}-debian9_amd64.deb && \
    dpkg -i /opt/proxysql_${VERSION}-debian9_amd64.deb && \
    rm -f /opt/proxysql_${VERSION}-debian9_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

VOLUME /var/lib/proxysql
EXPOSE 6032 6033 6034

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]