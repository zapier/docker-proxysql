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

handle_term() {
    echo "SIGTERM received... Shutting down proxysql gracefully..."
    pkill -f proxysql
    echo "Exit code of proxysql: $?"
    exit 0
}

exec proxysql -f $CMDARG &
wait $!
