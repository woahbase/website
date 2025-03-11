---
description: MultiArch Alpine Linux + S6 + NGINX + PHP-fpm + Adminer
svcname: adminer
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

This [image][155] containerizes [Adminer][3], providing a database web gui to
connect and administrate/view multiple databases e.g MySQL, PostgreSQL or
SQLite3.

{{ m.srcimage('alpine-php') }} with [NGINX][1], [PHP81][2] and the
[adminer][4] scripts installed in it. {{ m.ghreleasestr('vrana/adminer') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm --name docker_adminer -p 80:80 -p 443:443 woahbase/alpine-adminer
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars            | Default           | Description
| :---                | :---              | :---
| CSSURL              | (default-css-url) | If set to a custom css url, overrides the default theme.
| ADMINER_SKIP_EDITOR | unset             | Set to `true` if you don't need editor functionality.

Also,

* Adminer is located at the endpoint `/adminer/`, and the editor
  at `/editor`.  The latter is provided as is so little setup may
  be required to set proper authentication and access. The scripts
  are located in `/config/www/adminer/`, mount this in your local
  for any customizations.

* Includes everything from the {{ m.myimage('alpine-php') }} image.

* Which in turn, includes everything from the {{ m.myimage('alpine-nginx') }} image.

* Which in turn, includes everything from the {{ m.myimage('alpine-s6') }} image.

[1]: https://nginx.org
[2]: http://php.net/
[3]: https://www.adminer.org/
[4]: https://github.com/vrana/adminer/releases/latest
[5]: https://github.com/adminerevo/adminerevo/releases/latest
[6]: https://github.com/TimWolla/docker-adminer

{% include "all-include.md" %}
