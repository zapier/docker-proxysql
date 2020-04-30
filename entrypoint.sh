#!/bin/bash
set -e

## ProxySQL entrypoint
## ===================
PROXYSQL_CONF_CHECK_INTERVAL=${PROXYSQL_CONF_CHECK_INTERVAL:-60}
PROXYSQL_CONF_LIVE_RELOAD=${PROXYSQL_CONF_LIVE_RELOAD:-false}
PROXYSQL_CONF_DIR=/tmp/proxysql-conf
PROXYSQL_CONF_TPL_FILE=/tmp/proxysql-conf/proxysql.cnf.tpl
PROXYSQL_CONF_FILE=/etc/proxysql.cnf
PROXYSQL_SECRETS_DIR=/tmp/proxysql-secrets
PROXYSQL_SECRETS_FILE=/tmp/proxysql-secrets/secrets.env
PROXYSQL_CONF_RELOADER_LOCK=/tmp/proxysql-config-reloader.lock

function loadEnv {
    eval $(cat $PROXYSQL_SECRETS_FILE | sed 's/^/export /') && \
    echo "Loaded ProxySQL env vars"
}

function renderProxySQLCnf {
    cat $PROXYSQL_CONF_TPL_FILE | envsubst > $PROXYSQL_CONF_FILE && \
    echo "Rendered $PROXYSQL_CONF_TPL_FILE"
}

function loadProxySQLCnf {
    MYSQL_CMD='mysql -h 127.0.0.1 -P 6032 -u ${proxysql_admin_username} -p${proxysql_admin_password} -D main -e "LOAD MYSQL VARIABLES FROM CONFIG; LOAD MYSQL SERVERS FROM CONFIG; LOAD MYSQL USERS FROM CONFIG; LOAD MYSQL QUERY RULES FROM CONFIG; LOAD MYSQL VARIABLES TO RUNTIME; LOAD MYSQL SERVERS TO RUNTIME; LOAD MYSQL USERS TO RUNTIME; LOAD MYSQL QUERY RULES TO RUNTIME; SAVE MYSQL VARIABLES TO DISK; SAVE MYSQL SERVERS TO DISK; SAVE MYSQL USERS TO DISK; SAVE MYSQL QUERY RULES TO DISK;"'
    echo "$MYSQL_CMD"
    eval $MYSQL_CMD || echo ""
}

function configReloader {
    if [ -f $PROXYSQL_CONF_RELOADER_LOCK ]; then
        return
    fi

    if [ "$PROXYSQL_CONF_LIVE_RELOAD" != true ]; then
        echo "ProxySQL live config reload is disabled."
        return
    fi
    echo "ProxySQL live config reload is enabled. Checking config updates every ${PROXYSQL_CONF_CHECK_INTERVAL}s..."

    touch $PROXYSQL_CONF_RELOADER_LOCK
    echo "Starting ProxySQL config reloader..."
    m1=$(md5sum $PROXYSQL_CONF_TPL_FILE)
    m2=$(md5sum $PROXYSQL_SECRETS_FILE)

    while true; do
        sleep $PROXYSQL_CONF_CHECK_INTERVAL
        echo "Checking for ProxySQL config changes..."
        m1_=$(md5sum $PROXYSQL_CONF_TPL_FILE)
        m2_=$(md5sum $PROXYSQL_SECRETS_FILE)
        if [ "$m1" != "$m1_" ] || [ "$m2" != "$m2_" ]; then
            echo "ProxySQL config changed..."
            loadEnv
            renderProxySQLCnf
            loadProxySQLCnf
        fi
        m1=$m1_
        m2=$m2_
    done
    rm -rf $PROXYSQL_CONF_RELOADER_LOCK
}

function init {
    mkdir -p $PROXYSQL_CONF_DIR
    mkdir -p $PROXYSQL_SECRETS_DIR
    touch $PROXYSQL_CONF_TPL_FILE
    touch $PROXYSQL_SECRETS_FILE
    loadEnv
    renderProxySQLCnf
    configReloader &
}

init

exec $@
