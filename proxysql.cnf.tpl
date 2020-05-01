datadir="/var/lib/proxysql"

admin_variables=
{
        admin_credentials="${PROXYSQL_ADMIN_USERNAME}:${PROXYSQL_ADMIN_PASSWORD}"
        mysql_ifaces="${PROXYSQL_ADMIN_HOST}:${PROXYSQL_ADMIN_PORT}"
        refresh_interval=2000
}

mysql_variables=
{
        threads=${PROXYSQL_MYSQL_THREADS}
        max_connections=2048
        default_query_delay=0
        default_query_timeout=36000000
        have_compress=true
        poll_timeout=2000
        interfaces="${PROXYSQL_MYSQL_INTERFACES}"
        default_schema="information_schema"
        stacksize=${PROXYSQL_MYSQL_STACKSIZE}
        server_version="5.7"
        connect_timeout_server=10000
        monitor_history=60000
        monitor_connect_interval=200000
        monitor_ping_interval=200000
        ping_interval_server_msec=10000
        ping_timeout_server=200
        commands_stats=true
        sessions_sort=true
        autocommit_false_is_transaction=true
        init_connect="SET SESSION TX_ISOLATION='READ-COMMITTED'"
        monitor_username="root"
        monitor_password="root"
        enforce_autocommit_on_reads=true
        free_connections_pct=100
}
