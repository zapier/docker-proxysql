#!/bin/bash
set -e

## ProxySQL entrypoint
## ===================

# Render /etc/proxysql.cnf from proxysql.cnf template
if [ -f /tmp/proxysql.cnf ]; then
	cat /tmp/proxysql.cnf | envsubst > /etc/proxysql.cnf
fi

# If command has arguments, prepend proxysql
if [ "${1:0:1}" = '-' ]; then
	CMDARG="$@"
fi

trap handle_term SIGTERM

PROXYSQL_SHUTDOWN_GRACE_PERIOD=${PROXYSQL_SHUTDOWN_GRACE_PERIOD:=20}

handle_term() {
    echo "SIGTERM received..."
    echo "Waiting for $PROXYSQL_SHUTDOWN_GRACE_PERIOD seconds to existing connections to complete..."
    sleep $PROXYSQL_SHUTDOWN_GRACE_PERIOD
    echo "Killing ProxySQL..."
    pkill -f proxysql
    echo "Exit code of proxysql: $?"
    exit 0
}

exec proxysql -f $CMDARG &
wait $!
