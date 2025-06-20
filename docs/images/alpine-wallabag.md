---
description: MultiArch Alpine Linux + S6 + NGINX + PHP-fpm + Wallabag
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] provides [Wallabag][1] to archive web pages or
extract content from articles and save them locally for later
reading.

{{ m.srcimage('alpine-php') }} with the application scripts
installed in it. {{ m.ghreleasestr('wallabag/wallabag') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_wallabag \
  -p 80:80 \
  -p 443:443 \
  -v $PWD/config:/config \
woahbase/alpine-wallabag
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                  | Default                  | Description
| :---                      | :---                     | :---
| WALLABAGDIR               | /config/www/wallabag     | (Preset) Path to Wallabag installation. If not found, the source archive is unpacked in this directory.
| WALLABAG_PARAMSFILE       | /defaults/parameters.yml | Path to `wallabag` parameters file.
| WALLABAG_DBINSTALL        | unset                    | Set to `true` to run database installation task (**enabled** for first-run).
| WALLABAG_MIGRATE          | unset                    | Set to `true` to run database migration task.
| WALLABAG_CLEAR_CACHE      | unset                    | Set to a non-empty-string (e.g `1`) to force a cleanup of cached files.
| WALLABAG_SKIP_CACHEWARMUP | unset                    | Set to a non-empty-string (e.g `1`) to skip warming up cached files before service start.
| WALLABAG_UPDATE_DEPS      | unset                    | Set to a non-empty-string (e.g `1`) to run `composer` installation task. (Installs `composer` in the container)
| SYMPHONY_ENV              | prod                     | (Preset) Environment profile.
{% include "envvars/alpine-php.md" %}
{% include "envvars/alpine-nginx.md" %}
| SSLSUBJECT | see [here](alpine-nginx.md#ssl-subject) | Default SSL Subject for self-signed certificate generation on first run.
{% include "envvars/cron.md" %}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/config/www/wallabag/parameters.yml', vname='WALLABAG_PARAMSFILE') }}

* Checkout their [docs][3] for customizing your own. Especially
  [console-commands][7], and [parameters][8].

* Supported [applications][4] e.g mobile-apps
  ([Android][5]/[iOS][6]), browser [extensions][10]. All compatible
  readers can be found [here][9].

* By itself, **only SQLITE Database storage included**. Checkout
  {{ m.myimage('alpine-mysql') }} or {{
  m.myimage('alpine-postgresql') }} to configure your own
  database server as another container.

* On first-run the default login credentials are
  `wallabag`/`wallabag`.

* Wallabag source is located at `/opt/wallabag/wallabag-$VERSION.tar.gz`.

* Includes everything from the {{ m.myimage('alpine-php') }} image.

* Which in turn, includes everything from the {{ m.myimage('alpine-nginx') }} image.

* Which in turn, includes everything from the {{ m.myimage('alpine-s6') }} image.

[1]: https://www.wallabag.it/en
[2]: https://github.com/wallabag/wallabag
[3]: https://doc.wallabag.org/en/
[4]: https://www.wallabag.it/en/applications
[5]: https://doc.wallabag.org/en/apps/android
[6]: https://doc.wallabag.org/en/apps/ios
[7]: https://doc.wallabag.org/en/admin/console_commands
[8]: https://doc.wallabag.org/en/admin/parameters
[9]: https://github.com/wallabag/wallabag/wiki/wallabag-ecosystem
[10]: https://github.com/wallabag/wallabagger

{% include "all-include.md" %}
