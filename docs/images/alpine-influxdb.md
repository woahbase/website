---
description: MultiArch Alpine Linux + S6 + InfluxDB
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - service

s6_user: alpine
s6_userhome: /var/lib/influxdb

---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base image for applications
/ services that need a [Influx][1] (v1) database running.

Usually coupled with {{ m.myimage('alpine-chronograf') }}/{{
m.myimage('alpine-kapacitor') }} or {{ m.myimage('alpine-grafana')
}} image for the dashboard, and using [telegraf][2] or {{
m.myimage('alpine-netdata') }} to collect the metrics.
(Enable the **OpenTSDB** listener for netdata and such.)

{{ m.srcimage('alpine-s6') }} with the {{
m.alpinepkg('influxdb', branch='v3.17') }} package installed in
it.

???+ warning "InfluxDB Version 1.8.10"

    InfluxDB has since dropped providing binaries for ARM V7/V6,
    so packages are unavailable in Alpine Linux Repositories since
    `v3.17`. This image uses the final pre-built packages from
    that repository. Newer builds will follow suit.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_influxdb \
  -p 8086:8086 \
  -e INFLUXDB_HTTP_AUTH_ENABLED=true \
  -e INFLUXDB_ADMIN_USER=influxadmin \
  -e INFLUXDB_ADMIN_PWD=insecurebydefault \
  -e INFLUXDB_USER=influxu \
  -e INFLUXDB_USER_PWD=insecurebydefault \
  -e INFLUXDB_DB=test \
  -v $PWD/data:/var/lib/influxdb \
woahbase/alpine-influxdb
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                         | Default                    | Description
| :---                             | :---                       | :---
| INFLUXDB_CONFIG_PATH             | /etc/influxdb.conf         | Default path to configuration file.
| INFLUXDB_HOME                    | {{ s6_userhome }}          | Default path to datastore.
| INFLUXDB_`varname`               | unset                      | Override default configurations. Check [this link][3] for supported variables.
| INFLUXDB_INITDIR                 | {{ s6_userhome }}/initdb.d | Directory for `.sh` or `.iql` scripts needed to initialize database. {{ m.sincev('1.8.10_20250522') }} (Used by `/scripts/run.sh`) Previously named `INFLUXDB_INIT_DB`.
| INFLUXDB_BACKUPDIR               | {{ s6_userhome }}/backups  | Directory for backups. (Used by `/scripts/run.sh`)
| INFLUXDB_SKIP_INITIALIZE         | unset                      | Set to `true` to skip all database initialization/bootstrap tasks. Useful when you only want the service to run. {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_HTTP_AUTH_ENABLED       | unset                      | Set to `true`/`false` in environment (or configuration) when authentication is required, default is unset.
| INFLUXDB_ADMIN_USER              | influxadmin                | Default admin user, **required** for database initialization if authentication is enabled. (part of bootstrap tasks). {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_ADMIN_PWD               | unset                      | Admin user password **required** for database initialization if authentication is enabled. (part of bootstrap tasks). {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_DATABASE                | test                       | Default database to create when initializiting, or after initialization when authentication enabled. {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_SKIP_BOOTSTRAP          | unset                      | Set to `true` to skip database bootstrap tasks. Useful when you only want the initialization tasks. {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_USER                    | influxuser                 | Default user for remote connections, created during bootstrap if authentication is enabled. {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_USER_PWD                | unset                      | Password for User **required** for creation. {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_USER_GRANTS             | ALL                        | Default user privileges, if database is set, applies only to the database, implies admin otherwise. {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_HEALTHCHECK_USER        | influxhc                   | Default user for healthchecks, created during bootstrap if authentication is enabled. {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_HEALTHCHECK_USER_PWD    | unset                      | Password for healthcheck user **required** for creation. {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_HEALTHCHECK_USER_GRANTS | READ                       | Default healthcheck user privileges, if not `ALL`, **requires** database to be set, not applied otherwise. {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_READ_USER               | influxr                    | Default user for reads, created during bootstrap if authentication is enabled. {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_READ_USER_PWD           | unset                      | Password for read user **required** for creation. {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_READ_USER_GRANTS        | READ                       | Default read user privileges, if not `ALL`, **requires** database to be set, not applied otherwise. {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_WRITE_USER              | influxw                    | Default user for writes, created during bootstrap if authentication is enabled. {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_WRITE_USER_PWD          | unset                      | Password for write user if not `ALL`, **required** for creation. {{ m.sincev('1.8.10_20250522') }}
| INFLUXDB_WRITE_USER_GRANTS       | WRITE                      | Default write user privileges, **requires** database to be set, not applied otherwise. {{ m.sincev('1.8.10_20250522') }}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/etc/influxdb.conf', vname='INFLUXDB_CONFIG_PATH') }}

* Default [configuration][3] starts the database server **without any
  authorization**. (Not recommended other than development
  or one-off testing purposes. Check the [security guides][6] for more)

* To enable [authentication/authorization][4] during
  initialization, update the configuration file or set
  `INFLUXDB_HTTP_AUTH_ENABLED` environment variable to `true`
  before starting the container.

    * Then, for images released after {{
      m.myimagetag('1.8.10_20250522') }}, set the required
      environment variables. At the minimum, setting
      `INFLUXDB_ADMIN_PWD` is required. Now we can start the
      container and these configurations are applied while the
      database is being initialized/bootstrapped.
      <br/>
      Initialization and bootstrapping tasks are **only** run if
      the `{{ s6_userhome  }}/meta/meta.db` file does not exist,
      i.e. on the **first run**. Once the database is initialized,
      the relevant environment vars have no effect.

    * But for older images, or when the database is already
      initialized, this can be done manually by getting
      a [user-scoped shell](#shell-access) inside the container,
      e.g. we can create the administrator user with,
      ``` sh
      influx -execute "CREATE USER \"influxadmin\" WITH PASSWORD 'insecurebydefault' WITH ALL PRIVILEGES";
      ```
      Any following executions will require `-username` and
      `-password` arguments set. E.g. for creating another non-root
      administrator (recommended to use/export these credentials as
      administrator, while keeping the actual administrator secret),
      ``` sh
      # export INFLUXDB_ADMIN_USER=influxadmin
      # export INFLUXDB_ADMIN_PASSWORD=insecurebydefault
      influx \
        -username "${INFLUXDB_ADMIN_USER}" \
        -password '${INFLUXDB_ADMIN_PASSWORD}' \
      -execute "CREATE USER \"influx\" WITH PASSWORD 'insecurebydefault' WITH ALL PRIVILEGES";
      ```

    * For creating databases (and optionally limiting user-access
      specific to that database), execute the following as an example,
      check the [docs][5] for writing your own.
      ``` sql
      CREATE DATABASE "test";
      -- following users operate ONLY on test-db
      -- test writer
      CREATE USER "testwriter" WITH PASSWORD 'insecurebydefaultwritetest';
      REVOKE ALL PRIVILEGES FROM "testwriter";
      GRANT WRITE ON "test" TO "testwriter";
      -- test reader
      CREATE USER "testreader" WITH PASSWORD 'insecurebydefaultreadtest';
      REVOKE ALL PRIVILEGES FROM "testreader";
      GRANT READ ON "test" TO "testreader";
      ```

---
##### Script - run.sh
---

A {{ m.ghfilelink('root/scripts/run.sh', title='shellscript') }}
to run a few common tasks is available into the image,

* If you already have customized scripts or `iql` files to
  initialize your database, mount them in `{{ s6_userhome
  }}/initdb.d`, and execute them via `/scripts/run.sh`. Loaded
  automatically as part of bootstrap tasks.{{ m.sincev('1.8.10_20250522') }}
  ```
  docker exec -u {{ s6_user }} -it docker_influxdb /scripts/run.sh initdb
  ```

* [Backup][7] a **single** database to `{{ s6_userhome }}/backups` with
  ```
  docker exec -u {{ s6_user }} -it docker_influxdb /scripts/run.sh backup <db-name>
  ```

* [Restore][7] a **single** database from `{{ s6_userhome }}/backups` with
  ```
  docker exec -u {{ s6_user }} -it docker_influxdb /scripts/run.sh restore <db-name>
  ```

* Optionally run a healthcheck query (if authentication is
  enabled, make sure to set either `INFLUXDB_HEALTHCHECK_USER` and
  `INFLUXDB_HEALTHCHECK_USER_PWD` or `INFLUXDB_USER` and
  `INFLUXDB_USER_PWD`) with
  ```
  /scripts/run.sh healthcheck
  ```
  The healthcheck query can be customized by `INFLUXDB_HEALTHCHECK_QUERY`
  environment variable (defaults to `SHOW DATABASES`).

[1]: https://www.influxdata.com
[2]: https://www.influxdata.com/time-series-platform/telegraf/
[3]: https://docs.influxdata.com/influxdb/v1/administration/config/
[4]: https://docs.influxdata.com/influxdb/v1/administration/authentication_and_authorization/
[5]: https://docs.influxdata.com/influxdb/v1/query_language/spec/
[6]: https://docs.influxdata.com/influxdb/v1/administration/security/
[7]: https://docs.influxdata.com/influxdb/v1/administration/backup_and_restore/
[8]: https://github.com/influxdata/influxdata-docker

{% include "all-include.md" %}
