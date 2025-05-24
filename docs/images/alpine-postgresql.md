---
description: MultiArch Alpine Linux + S6 + PostgreSQL
svcname: postgresql
has_services:
  - compose
  - nomad
tags:
  - service

pgmajor: 16
s6_user: postgres
s6_userhome: /var/lib/postgresql
wb_extra_args_build: PGMAJOR=16

---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base image for applications
/ services that need a [PostgreSQL][1] database running.

If it is required to run in the same container as the app is
running, use this container as the source for your app. Can setup
i.e create the database user and the database specified in the
command line if not already exists.

Has handy **backup** and **restore** commands scripted inside the
image.

{{ m.srcimage('alpine-s6') }} with the
{{ m.alpinepkg('postgresql'~pgmajor, star=true) }} package(s)
installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_postgresql \
  -e POSTGRES_PASSWORD=insecurebydefault \
  -e POSTGRES_DB=test \
  -p 5432:5432 \
  -v $PWD/data:/var/lib/postgresql \
woahbase/alpine-postgresql
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                  | Default                 | Description
| :---                      | :---                    | :---
| PGDATA                    | {{s6_userhome}}/data    | Default database storage directory.
| PGPORT                    | 5432                    | Default database port.
| PGSQL_BACKUPDIR           | {{s6_userhome}}/backups | Default database backup directory. Used by `/scripts/run.sh`.
| PGSQL_INITDIR             | /initdb.d               | Default database initialization files expected in this directory. Executed by `/scripts/run.sh` as part of bootstrap.
| PGSQL_SKIP_BOOTSTRAP      | unset                   | Set to `true` to skip default database bootstrapping (but not initialization) tasks.
| PGSQL_SKIP_INITIALIZE     | unset                   | Set to `true` to skip all database initialization/bootstrap tasks. Useful when you only want the service to run.
| PGSQL_CUSTOM_CONF         | unset                   | Path to custom `postgresql.conf`, if set and the file exists then it is copied into `PGDATA`. (**Replaces** existing configuration)
| PGSQL_CUSTOM_HBA          | unset                   | Path to custom `pg_hba.conf`, if set and the file exists then it is copied into `PGDATA`. (**Replaces** existing configuration)
| PGSQL_CUSTOM_IDENT        | unset                   | Path to custom `pg_ident.conf`, if set and the file exists then it is copied into `PGDATA`. (**Replaces** existing configuration)
| POSTGRES_DB               | test                    | Default database to create when bootstrapping, after initialization.
| POSTGRES_HOST_AUTH_METHOD | unset                   | Default database auth method when bootstrapping, when unset, default method (usually `scram-sha-256`) is extracted from configuration.
| POSTGRES_INITDB_ARGS      | unset                   | Customizable arguments passed to `initdb` task when initializing database from scratch.
| POSTGRES_INITDB_WALDIR    | unset                   | Customizable wal-dir path passed to `initdb` task when initializing database from scratch. Preferably a directory outside of `PGDATA`.
| POSTGRES_USER             | {{ s6_user }}           | Default user to create upon bootstrap.
| POSTGRES_PASSFILE         | unset                   | Default user password file, when unset, points to `/run/s6/container_environment/POSTGRES_PASSWORD`. (either this or `POSTGRES_PASSWORD` is **required** for bootstrap tasks).
| POSTGRES_PASSWORD         | insecurebydefault       | Default user password. (either this or `POSTGRES_PASSFILE` is **required** for bootstrap tasks).
| PGSQL_EXECUTABLE          | /usr/bin/postgres       | Binary to execute for running service.
| PGSQL_ARGS                | unset                   | Customizable arguments passed to `postgres` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Data stored at `/var/lib/postgresql/data`.

* Initialization and bootstrapping tasks are **only** run if the
  default `PG_VERSION` file does not exist insidata datadir,
  i.e. on the **first run**.  Once the database is initialized,
  the relevant environment vars have no effect.

* Checkout the [documentation][2] to customize your instance.
  Here's another [link][6] for securing the service and general
  best-practices.

* The following extension packages are included in the image,

    === "PostgreSQL{{pgmajor}}"

    * {{ m.alpinepkg('postgresql-age', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-bdr-extension', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-citus', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-hypopg', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-mysql_fdw', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-orafce', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-pg_cron', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-pg_roaringbitmap', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-pgvector', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-rum', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-sequential-uuids', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-shared_ispell', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-temporal_tables', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-timescaledb', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-topn', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-uint', branch="v3.20") }}
    * {{ m.alpinepkg('postgresql-url_encode', branch="v3.20") }}

---
##### Script - run.sh
---

A {{ m.ghfilelink('root/scripts/run.sh', title='shellscript') }}
to run a few common tasks is available into the image,

* If you already have customized scripts or `sql` (or `sql.gz`)
  files to initialize your database, mount them in `/initdb.d`,
  and execute them via the `/scripts/run.sh`. These are executed
  automatically when database is being bootstrapped from scratch.
  ```
  docker exec -it -u {{ s6_user }} docker_postgresql /scripts/run.sh initdb (additional args for `psql`...)
  ```

* [Backup][3] a **single** database to `{{ s6_userhome }}/backups` with
  ```
  docker exec -it -u {{ s6_user }} docker_postgresql /scripts/run.sh backup <db-name> (additional args..)
  ```
  If no arguments are specified, by default uses the
  custom-archive format acceptable by `pg_restore` for backups.

* [Restore][4] a **single** database from `{{ s6_userhome }}/backups` with
  ```
  docker exec -it -u {{ s6_user }} docker_postgresql /scripts/run.sh restore <db-name> (additional args..)
  ```

* Optionally run a healthcheck query with
  ```
  /scripts/run.sh healthcheck
  ```

[1]: https://www.postgresql.org/
[2]: https://www.postgresql.org/docs/{{ pgmajor }}/index.html
[3]: https://www.postgresql.org/docs/{{ pgmajor }}/app-pgdump.html
[4]: https://www.postgresql.org/docs/{{ pgmajor }}/app-pgrestore.html
[5]: https://github.com/docker-library/postgres
[6]: https://www.enterprisedb.com/blog/how-to-secure-postgresql-security-hardening-best-practices-checklist-tips-encryption-authentication-vulnerabilities

{% include "all-include.md" %}
