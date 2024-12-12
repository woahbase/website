---
description: MultiArch Alpine Linux + S6 + MySQL (actually MariaDB)
svcname: mysql
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

| ENV Vars                  | Default                        | Description
| :---                      | :---                           | :---
| MYSQL_SKIP_MYCNFD         | unset                          | Set to `true` to skip copying default snippets to `/etc/my.cnf.d`.
| MYSQL_SKIP_INITIALIZE     | unset                          | Set to `true` to skip all database initialization/bootstrap tasks. Useful when you only want the service to run.
| MYSQL_HOST                | 127.0.0.1                      | Default host needed to whitelist user access. (part of bootstrap tasks).
| MYSQL_ROOT_PWD            | insecurebydefault              | Default root password. (part of bootstrap tasks).
| MYSQL_SKIP_ROOT_USER      | unset                          | If set to `true`, default root user left as-is, i.e only usable via localhost/socket. (part of bootstrap tasks).
| MYSQL_USER                | {{ s6_user }}                  | Default user to create upon bootstrap.
| MYSQL_USER_PWD            | insecurebydefault              | Default user password. (part of bootstrap tasks).
| MYSQL_USER_GRANTS         | ALL                            | Default user grants. (part of bootstrap tasks).
| MYSQL_SKIP_USER           | unset                          | If set to `true`, default non-root user creation is skipped. (part of bootstrap tasks).
| MYSQL_SOCKET_USER_GRANTS  | USAGE                          | Default socket user grants. (part of bootstrap tasks).
| MYSQL_SKIP_SOCKET_USER    | unset                          | If set to `true`, socket user `{{ s6_user }}` creation is skipped. (part of bootstrap tasks).
| MYSQL_DATABASE            | test                           | Default database to create when bootstrapping, after initialization.
| MYSQL_SKIP_CREATE_DB      | unset                          | Skip default database creation when bootstrapping.
| MYSQL_SKIP_BOOTSTRAP      | unset                          | Set to `true` to skip default database bootstrapping (but not initialization) tasks.
| MYSQL_BOOTSTRAP_FILE      | tempfile                       | Default bootstrapping file to execute on first run, can be replaced with your own.
| MYSQL_KEEP_BOOTSTRAP_FILE | unset                          | Bootstrap file is **deleted after execution** as it contains secret information, set this to `true` if the file is required to persist.
| MYSQL_EXECUTABLE          | /usr/bin/mysqld                | Binary to execute.
| MYSQL_ARGS                | --user={{ s6_user }} --console | Customizable arguments passed to `mysqld` service.
| MYSQL_INIT_DB             | /etc/my.initdb.d               | Default database initialization directory {{ m.sincev('10.11.8') }} used by `/scripts/run.sh`.
| MYSQL_BACKUPDIR           | {{s6_userhome}}_backups        | Default database backup directory. {{ m.sincev('10.11.8') }}, previously `/var/lib/mysql/backups` used by `/scripts/run.sh`.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/etc/my.cnf') }} By default all snippets
  existing in `/etc/my.cnf.d/` are included.

* Data stored at `/var/lib/mysql`.

* Initialization and bootstrapping tasks are **only** run if the
  default `mysql` table does not exist, i.e. on the **first run**.
  Once the database is initialized, the environment vars have not
  effect.

---
##### Script - run.sh
---

A {{ m.ghfilelink('root/scripts/run.sh', title='shellscript') }}
to run a few common tasks is available into the image,

* If you already have customized scripts or `sql` (or `sql.gz`)
  files to initialize your database, mount them in `{{ s6_userhome
  }}/initdb.d`, and execute them via the `/scripts/run.sh`.
  ```
  docker exec -u {{ s6_user }} -it docker_mysql /scripts/run.sh initdb
  ```

* [Backup][2] a **single** database to `{{ s6_userhome }}_backups` with
  ```
  docker exec -u {{ s6_user }} -it docker_mysql /scripts/run.sh backup <db-name>
  ```

* Restore a **single** database from `{{ s6_userhome }}_backups` with
  ```
  docker exec -u {{ s6_user }} -it docker_mysql /scripts/run.sh restore <db-name>
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

{% include "all-include.md" %}
