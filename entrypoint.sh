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

exec proxysql -f $CMDARG
