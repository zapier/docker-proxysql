# ProxySQL Docker Image

The [ProxySQL](https://proxysql.com) Docker image with support for:
- **Live configuration update**
- Rendering secret data from environment variables to config template

https://hub.docker.com/r/zapier/proxysql

## Usage

### Sample configuration template: proxysql.cnf.tpl

```
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
```

### Sample secrets.env

These secrets can be loaded into environment variables from local file, Docker secrets, Kubernetes secrets, etc. These secrets get rendered in the ProxySQL configuration template above

```
db1_host=db1.example.com
db1_port=3306
db1_username=db1
db1_password=password
db2_host=db2.example.com
db2_port=3306
db2_username=db2
db2_password=password
proxysql_monitor_username=root
proxysql_monitor_password=root
```

### Running

```
docker run -ti --name proxysql \
-v secrets.env:/proxysql/secrets/secrets.env \
-v ./proxysql.cnf.tpl:/proxysql/conf/proxysql.cnf.tpl \
-e PROXYSQL_CONF_CHECK_INTERVAL=15
-e PROXYSQL_CONF_LIVE_RELOAD=true
-e PROXYSQL_ADMIN_PASSWORD=somepassword
-e PROXYSQL_MYSQL_THREADS=6
-p 16032:6032
-p 16033:6033
zapier/proxysql:latest
```
