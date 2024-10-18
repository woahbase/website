---
description: MultiArch Alpine Linux + S6 + NGINX + PHP8 + Kanboard
svcname: kanboard
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - github
  - php
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [Kanboard][3] kanban webapp and
the background worker using [Beanstalk][5] along with its php
dependencies to track tasks for an individual or small group.

{{ m.srcimage('alpine-php') }} with [NGINX][1], [PHP][2] and
the [kanboard][4] scripts overlayed on it. {{
m.ghreleasestr('kanboard/kanboard') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_kanboard \
  -e KANBOARD_URL="http://localhost/kanboard/" \
  -p 443:443 \
  -p 80:80 \
  -v $PWD/data:/config/www/kanboard/data \
  -v $PWD/plugins:/config/www/kanboard/plugins \
woahbase/alpine-kanboard
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                 | Default                     | Description
| :---                     | :---                        | :---
| KANBOARDDIR              | /config/www/kanboard        | (Preset) Path to Kanboard installation.
| KANBOARD_URL             | http://localhost/kanboard/  | FQDN of your kanboard host including subpath, (kanboard is available at path `/kanboard/`). Required to set the first-run URL in database. (Relevant [issue][7])
| KANBOARD_BACKUPDIR       | /config/www                 | Path to directory where current installation backup is generated during an update.
| KANBOARD_UPDATE          | unset                       | If set to `true`, will reinstall kanboard at `$KANBOARDDIR` even if a previous installation exists. Useful if you're persisting your whole installation. Also generates a backup of the previous installation at `$KANBOARD_BACKUPDIR/kanboard-VERSION-YYYY-MM-DD.zip`
| KANBOARD_PRESERVEFILES   | data,plugins,config.php     | **Comma**-separated list of files/dirs that are excluded from deletion during an update.
| KANBOARD_CRONFILE        | /etc/crontabs/root          | Cron-registry file of a user (defaults to `root`). This file is modified to contain the periodic task script that will be executed.
| KANBOARD_CRONJOB         | /defaults/cronjob.sh        | File to execute on `cron` invocation.
| KANBOARD_CRONTIME        | 0 8 * * *                   | `cron`-formatted invocation timings.
{% include "envvars/alpine-php.md" %}
{% include "envvars/alpine-nginx.md" %}
{% include "envvars/cron.md" %}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* By itself, **only SQLITE Database storage included**. Checkout {{
  m.myimage('alpine-mysql') }} to configure your own MySQL server
  as another container.

* Kanboard is located at the endpoint `/kanboard/`, with the
  webapp at `/config/www/kanboard/`. If not exists, (or if
  `KANBOARD_UPDATE` is set) the release included in the image gets
  unzipped at this path.

* {{ m.defcfgfile('/config/www/kanboard/config.php') }}

* You can either mount only the `data` and `plugins` directories
  to persist between updates, or mount the whole `/config`
  directory to have better (but manual) control over your
  installation.

* For first-time-right setups provide correct `KANBOARD_URL` to be set in
  the database. (Relevant [issue][7])

* Kanboard source is located at `/opt/kanboard/kanboard-$VERSION.zip`.

* Includes [Beanstalk][5] and the supporting [plugin][6].

* 8-hourly cronjob is enabled by default.

* Includes everything from the {{ m.myimage('alpine-php') }} image.

* Which in turn, includes everything from the {{ m.myimage('alpine-nginx') }} image.

* Which in turn, includes everything from the {{ m.myimage('alpine-s6') }} image.

[1]: https://nginx.org
[2]: http://php.net/
[3]: https://kanboard.org/
[4]: https://github.com/kanboard/kanboard/releases
[5]: http://kr.github.io/beanstalkd/
[6]: https://github.com/kanboard/plugin-beanstalk/
[7]: https://github.com/kanboard/kanboard/issues/4119

{% include "all-include.md" %}
