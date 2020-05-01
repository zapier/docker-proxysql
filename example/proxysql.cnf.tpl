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
        monitor_username="${proxysql_monitor_username}"
        monitor_password="${proxysql_monitor_password}"
        enforce_autocommit_on_reads=true
        free_connections_pct=100
}

mysql_servers =
(
        { address="${db1_host}" , port=${db1_port} , hostgroup=10, max_connections=10 },
        { address="${db2_host}" , port=${db2_port} , hostgroup=20, max_connections=10 }
)

mysql_users =
(
        { username = "${db1_username}" , password = "${db1_password}" , default_hostgroup = 10 , active = 1 },
        { username = "${db2_username}" , password = "${db2_password}" , default_hostgroup = 20 , active = 1 }
)

mysql_query_rules =
(
        {
                rule_id=100
                active=1
                proxy_port=6033
                destination_hostgroup=10
                apply=1
                username="${db1_username}"
        },
        {
                rule_id=200
                active=1
                proxy_port=6033
                destination_hostgroup=20
                apply=1
                username="${db2_username}"
        }
)
