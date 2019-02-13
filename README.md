# ProxySQL Docker Image

## Example Configurations, proxysql.cnf ##

### Just as a connection pool ###

This is useful, when an application, e.g., a Django app, is managing
database routing.

```bash
datadir="/var/lib/proxysql"

admin_variables=
{
        admin_credentials="admin:admin"
        mysql_ifaces="0.0.0.0:6032"
        refresh_interval=2000
}

mysql_variables=
{
        threads=4
        max_connections=2048
        default_query_delay=0
        default_query_timeout=36000000
        have_compress=true
        poll_timeout=2000
        interfaces="0.0.0.0:6033;0.0.0.0:6034;/tmp/proxysql.sock"
        default_schema="information_schema"
        stacksize=1048576
        server_version="5.6.9"
        connect_timeout_server=10000
        monitor_history=60000
        monitor_connect_interval=200000
        monitor_ping_interval=200000
        ping_interval_server_msec=10000
        ping_timeout_server=200
        commands_stats=true
        sessions_sort=true
        monitor_username="proxysql"
        monitor_password="proxysqlpassword"
}

mysql_servers =
(
        { address="master.replication.local" , port=3306 , hostgroup=10, max_connections=100 , max_replication_lag = 5 },
        { address="slave1.replication.local" , port=3306 , hostgroup=20, max_connections=100 , max_replication_lag = 5 },
)

mysql_users =
(
        { username = "sbtest" , password = "password" , default_hostgroup = 10 , active = 1 }
)

mysql_query_rules =
(
        {
                rule_id=100
                active=1
                proxy_port=6033
                destination_hostgroup=10
                apply=1
        },
        {
                rule_id=200
                active=1
                proxy_port=6034
                destination_hostgroup=20
                apply=1
        }
)
```


