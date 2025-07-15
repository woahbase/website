---
description: MultiArch Alpine Linux + S6 + MySQL (actually MariaDB)
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, i386, ppc64le, riscv64, s390x, x86_64]
has_services:
  - compose
  - nomad
tags:
  - service

s6_user: mysql
s6_userhome: /var/lib/mysql

---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base image for applications
/ services that need a [MySQL][1] database running.

If it is required to run in the same container as the app is
running, use this container as the source for your app. Can setup
i.e create the database user and the database specified in the
command line if not already exists.

Has handy **backup** and **restore** commands scripted inside the
image.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('mariadb')
}} package(s) installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_mysql \
  -e MYSQL_ROOT_PWD=insecurebydefault \
  -e MYSQL_USER=mysql \
  -e MYSQL_USER_PWD=insecurebydefault \
  -e MYSQL_USER_DB=test \
  -p 3306:3306 \
  -v $PWD/data:/var/lib/mysql \
woahbase/alpine-mysql
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                      | Default                        | Description
| :---                          | :---                           | :---
| MYSQL_HOME                    | {{s6_userhome}}                | (Preset) Default database storage directory {{ m.sincev('11.4.5') }}.
| MYSQL_CONF                    | /etc/my.cnf                    | Default database configuration file {{ m.sincev('11.4.5_20250715') }}. Default configurations are read from the following files in the given order: `/etc/my.cnf`, `/etc/mysql/my.cnf`, `{{ s6_userhome }}/my.cnf`, `~/.my.cnf`.
| MYSQL_CONFD                   | /etc/my.cnf.d                  | Default database configuration snippets directory {{ m.sincev('11.4.5_20250715') }}.
| MYSQL_SKIP_MYCNFD             | unset                          | Set to `true` to skip copying default snippets to `/etc/my.cnf.d`.
| MYSQL_BACKUPDIR               | {{s6_userhome}}_backups        | Default database backup directory. {{ m.sincev('10.11.8') }}, previously `/var/lib/mysql/backups` (used by `/scripts/run.sh`).
| MYSQL_SKIP_PERMFIX            | unset                          | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `mysql` configuration files/directories. {{ m.sincev('11.4.5_20250715') }}
| MYSQL_INITDIR                 | /initdb.d                      | Default database initialization directory {{ m.sincev('11.4.5') }} (used by `/scripts/run.sh`). Previously named `MYSQL_INIT_DB` at `/etc/my.initdb.d` {{ m.sincev('10.11.8') }}
| MYSQL_SKIP_INITIALIZE         | unset                          | Set to `true` to skip all database initialization/bootstrap tasks. Useful when you only want the service to run.
| MYSQL_HOST                    | 127.0.0.1                      | Default host needed to whitelist user access. (part of bootstrap tasks).
| MYSQL_ROOT_PWD                | unset                          | Default root password **required** for database initialization. (part of bootstrap tasks).
| MYSQL_SKIP_ROOT_USER          | unset                          | If set to `true`, default root user left as-is, i.e only usable via localhost/socket. (part of bootstrap tasks).
| MYSQL_USER                    | myadmin                        | Default user to create upon bootstrap.
| MYSQL_USER_PWD                | unset                          | Default user password **required** for database initialization. (part of bootstrap tasks).
| MYSQL_USER_GRANTS             | ALL                            | Default user grants. (part of bootstrap tasks).
| MYSQL_SKIP_USER               | unset                          | If set to `true`, default non-root user creation is skipped. (part of bootstrap tasks).
| MYSQL_HEALTHCHECK_USER        | myhcuser                       | Default healthcheck user to create upon bootstrap. {{ m.sincev('11.4.5') }}
| MYSQL_HEALTHCHECK_USER_PWD    | unset                          | Default healthcheck user password. (part of bootstrap tasks). {{ m.sincev('11.4.5') }}
| MYSQL_HEALTHCHECK_USER_GRANTS | USAGE                          | Default healthcheck user grants. (part of bootstrap tasks).{{ m.sincev('11.4.5') }}
| MYSQL_SKIP_HEALTHCHECK_USER   | unset                          | If set to `true`, default healthcheck user creation is skipped. (part of bootstrap tasks). {{ m.sincev('11.4.5') }}
| MYSQL_REPLICA_MASTER          | unset                          | Default replica master to connect to. Used to determine if database role is master or slave. For slave, master connection details are updated instead of creating replica user. {{ m.sincev('11.4.5') }}
| MYSQL_REPLICA_PORT            | 3306                           | Default replica master port to connect to. {{ m.sincev('11.4.5') }}
| MYSQL_REPLICA_USER            | myreplica                      | Default replica user to create upon bootstrap. {{ m.sincev('11.4.5') }}
| MYSQL_REPLICA_USER_PWD        | unset                          | Default replica user password. (part of bootstrap tasks). {{ m.sincev('11.4.5') }}
| MYSQL_SKIP_REPLICA_USER       | unset                          | If set to `true`, default replica user creation is skipped. (part of bootstrap tasks). {{ m.sincev('11.4.5') }}
| MYSQL_SOCKET_USER_GRANTS      | USAGE                          | Default socket user grants. (part of bootstrap tasks).
| MYSQL_SKIP_SOCKET_USER        | unset                          | If set to `true`, socket user `{{ s6_user }}` creation is skipped. (part of bootstrap tasks).
| MYSQL_DATABASE                | test                           | Default database to create when bootstrapping, after initialization.
| MYSQL_SKIP_CREATE_DB          | unset                          | Skip default database creation when bootstrapping.
| MYSQL_SKIP_BOOTSTRAP          | unset                          | Set to `true` to skip default database bootstrapping (but not initialization) tasks.
| MYSQL_INITDB_SKIP_TZINFO      | unset                          | Set to `true` to skip adding `tzinfo`-specific SQL statements to database bootstrap script. {{ m.sincev('11.4.5') }}
| MYSQL_BOOTSTRAP_FILE          | /tmp/filename                  | Default bootstrapping file to execute on first run, can be replaced with your own.
| MYSQL_KEEP_BOOTSTRAP_FILE     | unset                          | By default, the bootstrap file is **deleted after execution** as it contains secret information, set this to `true` if the file is required to persist.
| MYSQL_UPGRADE_SYSTEM          | unset                          | If set, will backup the system database and run `upgrade-db` task from `run.sh` after. (Not needed for fresh installs). {{ m.sincev('11.4.5') }}
| MYSQL_EXECUTABLE              | /usr/bin/maridbd               | Binary to execute. Previously used `/usr/bin/mysqld` {{ m.sincev('11.4.5') }}.
| MYSQLD_ARGS                   | --console                      | Customizable arguments passed to `mariadbd` service. Previously named `MYSQL_ARGS` {{ m.sincev('11.4.5') }}.
| MYSQL_SOCKET_PATH             | /run/mysqld/mysqld.sock        | Default socket path. (part of bootstrap tasks). {{ m.sincev('11.4.5') }}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/etc/my.cnf') }} By default all snippets
  existing in `/etc/my.cnf.d/` are included.

* Data stored at `{{ s6_userhome }}`.

* Initialization and bootstrapping tasks are **only** run if the
  default `mysql` table does not exist, i.e. on the **first run**.
  Once the database is initialized, the environment vars have no
  effect.

* RocksDB plugin {{ m.alpinepkg('mariadb-plugin-rocksdb',
  title="package", arch='') }} is not available for the
  following architectures, namely `linux/386` and `linux/s390x`.

---
##### Script - run.sh
---

A {{ m.ghfilelink('root/scripts/run.sh', title='shellscript') }}
to run a few common tasks is available into the image,

* If you already have customized scripts or `sql` (or `sql.gz`)
  files to initialize your database, mount them in `/initdb.d`,
  and execute them via the `/scripts/run.sh`. (Loaded
  automatically as part of bootstrap tasks.{{ m.sincev('11.4.5') }})
  ```
  docker exec -u {{ s6_user }} -it docker_mysql /scripts/run.sh initdb <additional args>
  ```

* [Backup][3] a **single** database to `{{ s6_userhome }}_backups` with
  ```
  docker exec -u {{ s6_user }} -it docker_mysql /scripts/run.sh backup <db-name> <additional args>
  ```

* [Restore][4] a **single** database from `{{ s6_userhome }}_backups` with
  ```
  docker exec -u {{ s6_user }} -it docker_mysql /scripts/run.sh restore <db-name> <additional args>
  ```

* Optionally run a healthcheck query (if authentication or is
  enabled, make sure to set either `MYSQL_HEALTHCHECK_USER` and
  `MYSQL_HEALTHCHECK_USER_PWD` or `MYSQL_USER` and
  `MYSQL_USER_PWD`, or uses socket user by default) with
  ```
  /scripts/run.sh healthcheck
  ```

[1]: https://www.mysql.com/
[2]: https://dev.mysql.com/doc/refman/8.4/en/mysqldump.html
[3]: https://mariadb.com/kb/en/mariadb-dump/
[4]: https://mariadb.com/kb/en/mariadb-command-line-client/

{% include "all-include.md" %}
