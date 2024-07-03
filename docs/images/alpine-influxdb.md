---
description: MultiArch Alpine Linux + S6 + InfluxDB
svcname: influxdb
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - compose
  - nomad
  - package
  - proxy
  - s6
  - service

s6_user: alpine
s6_userhome: /var/lib/influxdb

---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base image for applications
/ services that need a [Influx][1] (v1) database running.

Usually coupled with {{ m.myimage('alpine-grafana') }} image for
the dashboard, and using [telegraf][2] or {{
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
docker run --rm -it \
  --name docker_influxdb \
  -p 8086:8086 \
  -p 8088:8088 \
  -p 4242:4242 \
  -v $PWD/data:/var/lib/influxdb \
woahbase/alpine-influxdb
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars             | Default                    | Description
| :---                 | :---                       | :---
| INFLUXDB_CONFIG_PATH | /etc/influxdb.conf         | Default path to configuration file.
| INFLUXDB_HOME        | {{ s6_userhome }}          | Default path to datastore.
| INFLUXDB_(var_name)  | unset                      | Override default configurations. Check [this link][3] for supported variables.
| INFLUXDB_INIT_DB     | {{ s6_userhome }}/initdb.d | Directory for `.sh` or `.iql` scripts needed to initialize database. (Used by `/scripts/run.sh`)
| INFLUXDB_BACKUPDIR   | {{ s6_userhome }}/backups  | Directory for backups. (Used by `/scripts/run.sh`)
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* A {{ m.ghfilelink('root/defaults/influxdb.conf', title='sample') }}
  configuration is provided in the `/defaults` directory, this
  gets copied to `/etc/influxdb.conf` if none exist.

* Default [configuration][3] starts the database server **without any
  authorization**. (Not recommended other than development
  or one-off testing purposes. Check the [security guides][6] for more)

* To enable [authentication/authorization][4],
  first update the configuration file or set
  `INFLUXDB_HTTP_AUTH_ENABLED` environment variable to `true`.
  Then create the administrator user with,
  ```
  influx -execute "CREATE USER \"root\" WITH PASSWORD 'insecurebydefaultroot' WITH ALL PRIVILEGES";
  ```
  Any following executions will require `-username` and
  `-password` arguments set. E.g. for creating another non-root
  administrator (recommended to use/export these credentials as
  administrator, while keeping the above secret),
  ```
  # export INFLUXDB_ADMIN_USER=root
  # export INFLUXDB_ADMIN_PASSWORD=insecurebydefaultroot
  influx \
    -username "${INFLUXDB_ADMIN_USER}" \
    -password '${INFLUXDB_ADMIN_PASSWORD}' \
  -execute "CREATE USER \"influx\" WITH PASSWORD 'insecurebydefaultinflux' WITH ALL PRIVILEGES";
  ```

* For creating databases (and optionally limiting user-access
  specific to that database), execute the following as an example,
  check the [docs][5] for writing your own.
  ```
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

A script to run a few common tasks is available into the image,

* If you already have customized scripts or `iql` files to
  initialize your database, mount them in `{{ s6_userhome
  }}/initdb.d`, and execute them via the {{
  m.ghfilelink('root/scripts/run.sh', title='script') }}
  provided in `/scripts/run.sh`.
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

{% include "all-include.md" %}
