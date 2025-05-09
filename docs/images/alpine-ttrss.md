---
description: MultiArch Alpine Linux + S6 + NGINX + PHP-fpm + Tiny Tiny RSS
svcname: ttrss
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - package
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [Tiny Tiny RSS][3] feed reader
webapp along with its php dependencies to aggregate/manage feeds
for one single-user (or a small group).

{{ m.srcimage('alpine-php') }} with [NGINX][1], [PHP][2] and
the [tt-rss][4] (previously at [tt-rss][7]) scripts overlayed on it.

??? info "PHP 7->8 migration for MySQL"

    For `php7` to `php8` migration there is one additional step to
    modify the MySQL database due to the change in article GUID
    format that had quotes but now doesn't. E.g
    ``` sh
    # in php 7
    {"ver":2,"uid":"2","hash":"SHA1:2b10b494802dc70e9d9d7676cdef0cf0f9969b78"}
    # in php 8
    {"ver":2,"uid":2,"hash":"SHA1:2b10b494802dc70e9d9d7676cdef0cf0f9969b78"}
    ```
    This can be updated in the database with the following script, (credit goes to
    [Alan Doyle][12], their [repo][13])
    ```
    USE <ttrss-database-name>;

    UPDATE ttrss_entries
    SET guid = replace(replace(guid,'"uid":"', '"uid":'),'", "hash":', ',"hash":')
    WHERE guid LIKE '%"uid":"%"%';
    ```

??? warning "MySQL unsupported after 0e4b8bd65"

    There has been talk about dropping MySQL support and going
    PostgreSQL-only for a while. But after commit [0e4b8bd65][5],
    that seems to have become official and the MySQL schema
    (**v149**) files have been removed from the [repository][4].
    Without those, our future releases will also be supporting
    PostgreSQL only. Those who require MySQL support may stick to
    the image {{ m.myimagetag('0e4b8bd65') }} that is the last
    image that supports both databases, however, **no updates**
    until a more recent commit (or a fork maintained by someone
    else) is found. Otherwise, checkout their [data-migration
    plugin][11] to move the articles from MySQL to PostgreSQL.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_ttrss \
  -p 80:80 \
  -p 443:443 \
  -e TTRSS_DB_TYPE=pgsql \
  -e TTRSS_DB_HOST=your.postgres.local \
  -e TTRSS_DB_PORT=5432 \
  -e TTRSS_DB_USER=postgres \
  -e TTRSS_DB_PASS=insecurebydefault \
  -e TTRSS_DB_NAME=ttrss
  -v $PWD/config:/config \
woahbase/alpine-ttrss
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                      | Default              | Description
| :---                          | :---                 | :---
| TTRSSDIR                      | /config/www/ttrss    | (Preset) Path to `tt-rss` installation.
| TTRSSCONFIG                   | /defaults/config.php | Path to default `config.php`, if set and the file exists, it is copied into installation directory.
| TTRSSUPDATE                   | unset                | If set to `true`, will reinstall `tt-rss` at `$TTRSSDIR` even if a previous installation exists. Useful if you're persisting your whole installation. Generates a backup of the previous installation at `$WEBDIR/ttrss-backup-yyyy-MM-dd.tar.gz` before updating.
| TTRSS_*                       | unset                | If defined (with using the default `config.php` included in the image), these variables are set in the configuration. See [wiki/GlobalConfig][8].
| TTRSS_WORKER_ARGS             | unset                | Customizable arguments passed to `tt-rss` worker service.
| ADMIN_USER_PASS               | unset                | If set, updates the administrator user password. If unset on first-run, a random password is generated.
| ADMIN_USER_ACCESS_LEVEL       | unset                | If set, updates the administrator access level.
| AUTO_CREATE_USER              | unset                | If set, adds a user to the database.
| AUTO_CREATE_USER_PASS         | unset                | Password for `AUTO_CREATE_USER`, **required** for creating the user.
| AUTO_CREATE_USER_ACCESS_LEVEL | unset                | If set, updates the `AUTO_CREATE_USER` access level.
| AUTO_CREATE_USER_ENABLE_API   | unset                | If set, enables API-access for `AUTO_CREATE_USER`.
| NO_STARTUP_PLUGIN_UPDATES     | unset                | Set to non-empty string e.g. `1` to skip updating plugins inside `plugins.local` directory. Only has effect when `git` is installed in the container, by default, **which is not**.
| NO_STARTUP_SCHEMA_UPDATES     | unset                | Set to non-empty string e.g. `1` to skip updating database schema before starting services, **not recommened** unless you know what you're doing.
| XDEBUG_ENABLED                | unset                | Toggles `xdebug`.
| XDEBUG_HOST                   | unset                | Host for `xdebug` service listener.
| XDEBUG_PORT                   | 9000                 | Port for `xdebug` service listener.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Tiny Tiny RSS is located at the endpoint `/ttrss/`, with the
  webapp at `/config/www/ttrss/`. If not exists, (or if
  `TTRSSUPDATE` is set) the release included in the image gets
  unpacked at this path.

* Tiny Tiny RSS release is located at
  `/opt/ttrss/ttrss-$VERSION.tar.gz`. Also includes the
  [nginx_xaccel][6] plugin.

* **Database not included**. Checkout {{ m.myimage('alpine-mysql')
  }} or {{ m.myimage('alpine-postgresql') }} to configure your own
  database server as another container.

* `git` is also **not available** by default, to install it at
  runtime for updating local plugins, set `S6_NEEDED_PACKAGES="git"`.

* {{ m.defcfgfile('/config/www/ttrss/config.php') }} By default
  the environment varibles are **NOT** exposed to `php`, but the
  default configuration included with the image supports reading
  `TTRSS_*` variables, as well as any snippet files found in
  `$TTRSSDIR/config.d`, and for legacy plugins use `define()` like
  before. Check the [wiki][8], [docs][9], or the [source
  class][10] for all available configuration parameters.

* You can either mount individual directories like `cache`,
  `config.d`, `feed-icons`, `themes.local`, `plugins.local`, and
  `sql/post-init.d` to persist between updates, or mount the whole
  `/config` directory to have better (but manual) control over
  your installation.

* SQL snippets inside `$TTRSSDIR/sql/post-init.d/` are executed
  automatically before services are started. Remember to not
  provide MySQL snippets when your database is PostgreSQL (or
  vice-versa).

* The feed update service is started by default and uses the
  configuration from `/config/www/ttrss/config.php` after setup.

* Includes everything from the {{ m.myimage('alpine-php') }} image.

* Which in turn, includes everything from the {{ m.myimage('alpine-nginx') }} image.

* Which in turn, includes everything from the {{ m.myimage('alpine-s6') }} image.

[1]: https://nginx.org
[2]: http://php.net/
[3]: https://tt-rss.org/
[4]: https://gitlab.tt-rss.org/tt-rss/tt-rss/
[5]: https://gitlab.tt-rss.org/tt-rss/tt-rss/-/commit/0e4b8bd65
[6]: https://gitlab.tt-rss.org/tt-rss/plugins/ttrss-nginx-xaccel
[7]: https://git.tt-rss.org/fox/tt-rss.git
[8]: https://tt-rss.org/wiki/GlobalConfig
[9]: https://srv.tt-rss.org/ttrss-docs/classes/Config.html
[10]: https://git.tt-rss.org/fox/tt-rss.git/tree/classes/Config.php
[11]: https://gitlab.tt-rss.org/tt-rss/plugins/ttrss-data-migration
[12]: https://alandoyle.com/blog/new-tiny-tiny-rss-docker-image/
[13]: https://github.com/alandoyle/docker-tt-rss-mysql

{% include "all-include.md" %}
