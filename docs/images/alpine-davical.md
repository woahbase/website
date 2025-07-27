---
description: MultiArch Alpine Linux + S6 + NGINX + PHP-fpm + DAViCal
has_services:
  - compose
#   - nomad
# has_proxies:
#   - nginx
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [DAViCal][3], providing shared
calendars (with CalDAV) as well as support for CardDAV and WebDAV
clients.

{{ m.srcimage('alpine-php') }} with [NGINX][1], [PHP][2] and the
[davical][4] (with [awl][5]) scripts installed in it.
{{ m.gltagstr('davical-project/davical', search='^r') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_davical \
  -p 80:80 \
  -p 443:443 \
  -e PGHOST=your.postgres.local \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=insecurebydefault \
  -e DAVI_HOSTNAME=localhost \
  -e DAVI_DATABASE=davical \
  -e DAVI_DBAUSER=davical_dba \
  -e DAVI_DBAPASS=insecurebydefault \
  -e DAVI_APPUSER=davical_app \
  -e DAVI_APPPASS=insecurebydefault \
  -e WEBADMIN=admin \
  -e PASSWORD=nimda \
woahbase/alpine-davical
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars            | Default                    | Description
| :---                | :---                       | :---
| PGHOST              | your.postgres.local        | Hostname of PostgreSQL database.
| PGPORT              | 5432                       | Default port of PostgreSQL database.
| POSTGRES_USER       | postgres                   | Postgres user with administator privileges for database and user(s) creation on first-run.
| POSTGRES_PASSWORD   | unset                      | Password of `${POSTGRES_USER}`.
| DAVI_DATABASE       | davical                    | Default name of database.
| DAVI_ADMMAIL        | calendar-admin@localhost   | Application administator contact email. (To request user credentials)
| DAVI_APPUSER        | davical_app                | Database user for application with limited privileges over `${DAVI_DATABASE}`.
| DAVI_APPPASS        | unset                      | Password of `${DAVI_APPUSER}`.
| DAVI_HOSTNAME       | localhost                  | Hostname of DAViCal server.
| DAVI_LOCALE         | en_US                      | Default locale of application.
| DAVI_SYSTNAME       | "DAViCal CalDAV Server"    | System name of application.
| DAVI_DBAUSER        | davical_dba                | Database user with administator privileges over `${DAVI_DATABASE}`. Required to run migrations or changing application administator password.
| DAVI_DBAPASS        | unset                      | Password of `${DAVI_DBAUSER}`.
| DAVI_SCHEMA         | davical_dba                | Schema name of database.
| WEBADMIN            | admin                      | Application administator username for login.
| PASSWORD            | unset                      | Application administator password, if set, is updated in database. (Defaults to `nimda` on first-run)
| DAVI_SKIP_PERMFIX   | unset                      | Set to `true` to skip running permission fixes over project files on every startup.
| DAVI_SKIP_DBSETUP   | unset                      | Set to `true` to skip modifying database, also disables checking for readiness.
| DAVI_SKIP_MIGRATION | unset                      | Set to `true` to skip running migration tasks on every startup.

Also,

* Check our {{ m.myimage('alpine-postgresql') }} image to run your
  own [PostgreSQL][10]-as-a-service.

* DAViCal is located at base endpoint e.g.
  `http://localhost/index.php`, The scripts are located (or
  unpacked if not exists) in `/config/www/davical/` and
  `/config/www/awl` respectively, mount these in your local for
  any customizations.

* {{ m.defcfgfile('/etc/davical/config.php') }} Uses values from
  environment to substitute `DAVI_*` variable names.

* `POSTGRES_USER` credentials are only needed for the first-run to
  create the database and user(s) from scratch. These (can be
  left unset for subsequent runs) fallback to `${DAVI_APPUSER}`
  credentials for database readiness check, or to `${DAVI_DBAUSER}`
  for migrations.

* After first-run, if migrations are not required to be run on
  every startup (i.e. `${DAVI_SKIP_MIGRATION}` is set), the
  `DAVI_DBAUSER` credentials can be omitted as well to reduce
  exposed secrets. Optionally set `${DAVI_SKIP_DBSETUP}` to not
  modify the database at all, but that also skips the readiness
  check.

* Includes everything from the {{ m.myimage('alpine-php') }} image.

* Which in turn, includes everything from the {{ m.myimage('alpine-nginx') }} image.

* Which in turn, includes everything from the {{ m.myimage('alpine-s6') }} image.

[1]: https://nginx.org
[2]: http://php.net/
[3]: https://www.davical.org/index.php
[4]: https://gitlab.com/davical-project/davical
[5]: https://gitlab.com/davical-project/awl
[6]: https://wiki.davical.org/index.php?title=Nginx_Config
[7]: https://gitlab.com/fintechstudios/davical-docker
[8]: https://github.com/fintechstudios/davical-docker
[9]: https://github.com/Elrondo46/davical-docker-standalone
[10]: https://www.postgresql.org/


{% include "all-include.md" %}
