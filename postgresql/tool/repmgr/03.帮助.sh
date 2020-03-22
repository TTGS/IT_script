[postgres@gpb ~]$ repmgr --version
repmgr 4.4
[postgres@gpb ~]$ repmgr --help
repmgr: replication management tool for PostgreSQL

Usage:
    repmgr [OPTIONS] primary {register|unregister}
    repmgr [OPTIONS] standby {register|unregister|clone|promote|follow|switchover}
    repmgr [OPTIONS] bdr     {register|unregister}
    repmgr [OPTIONS] node    {status|check|rejoin|service}
    repmgr [OPTIONS] cluster {show|event|matrix|crosscheck|cleanup}
    repmgr [OPTIONS] witness {register|unregister}
    repmgr [OPTIONS] daemon  {status|pause|unpause|start|stop}

  Execute "repmgr {primary|standby|bdr|node|cluster|witness|daemon} --help" to see command-specific options

General options:
  -?, --help                          show this help, then exit
  -V, --version                       output version information, then exit
  --version-number                    output version number, then exit

General configuration options:
  -b, --pg_bindir=PATH                path to PostgreSQL binaries (optional)
  -f, --config-file=PATH              path to the repmgr configuration file
  -F, --force                         force potentially dangerous operations to happen

Database connection options:
  -d, --dbname=DBNAME                 database to connect to (default: "postgres")
  -h, --host=HOSTNAME                 database server host
  -p, --port=PORT                     database server port (default: "5432")
  -U, --username=USERNAME             database user name to connect as (default: "postgres")
  -S, --superuser=USERNAME            superuser to use, if repmgr user is not superuser

Node-specific options:
  -D, --pgdata=DIR                    location of the node's data directory 
  --node-id                           specify a node by id (only available for some operations)
  --node-name                         specify a node by name (only available for some operations)

Logging options:
  --dry-run                           show what would happen for action, but don't execute it
  -L, --log-level                     set log level (overrides configuration file; default: NOTICE)
  --log-to-file                       log to file (or logging facility) defined in repmgr.conf
  -q, --quiet                         suppress all log output apart from errors
  -t, --terse                         don't display detail, hints and other non-critical output
  -v, --verbose                       display additional log output (useful for debugging)

