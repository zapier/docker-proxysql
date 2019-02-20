#!/bin/bash
set -e

## ProxySQL entrypoint
## ===================
##
## Supported environment variable:
##
## MONITOR_CONFIG_CHANGE={true|false}
## - Monitor /etc/proxysql.cnf for any changes and reload ProxySQL automatically

# Render /etc/proxysql.cnf from proxysql.cnf template
if [ -f /tmp/proxysql.cnf ]; then
	cat /tmp/proxysql.cnf | envsubst > /etc/proxysql.cnf
fi

# If command has arguments, prepend proxysql
if [ "${1:0:1}" = '-' ]; then
	CMDARG="$@"
fi

if [ $MONITOR_CONFIG_CHANGE ]; then

	echo 'Env MONITOR_CONFIG_CHANGE=true'
	CONFIG=/etc/proxysql.cnf
	oldcksum=$(cksum ${CONFIG})

	# Start ProxySQL in the background
	proxysql --reload -f $CMDARG &

	echo "Monitoring $CONFIG for changes.."
	inotifywait -e modify,move,create,delete -m --timefmt '%d/%m/%y %H:%M' --format '%T' ${CONFIG} | \
	while read date time; do
		newcksum=$(cksum ${CONFIG})
		if [ "$newcksum" != "$oldcksum" ]; then
			echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
			echo "At ${time} on ${date}, ${CONFIG} update detected."
			echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
			oldcksum=$newcksum
			echo "Reloading ProxySQL.."
		        killall -15 proxysql
			proxysql --initial --reload -f $CMDARG
		fi
	done
fi

# Start ProxySQL with PID 1
exec proxysql -f $CMDARG
