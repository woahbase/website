---
description: Container for Alpine Linux + S6 + NGINX + PHP7 + Pydio
alpine_branch: v3.10
arches: [x86_64]
tags:
  - deprecated
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [Pydio][3] Community edition,
providing a FOSS solution to sync & share files among members and
collaboration.

{{ m.srcimage('alpine-php') }} with [NGINX][1], [PHP7][2] and the
[pydio][4] scripts overlayed on it. {{ m.ghreleasestr('pydio/pydio-core') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm -it \
  --name docker_pydio \
  -p 80:80 \
  -p 443:443 \
  -v $PWD/config:/config \
  -v $PWD/data:/data \
woahbase/alpine-pydio:x86_64
```

--8<-- "multiarch.md"

---
##### Configuration
---

* Pydio is located at the endpoint `/pydio/`, with configurations
  at `/config/pydio/` and data at `/data`.

* Pydio source is located at `/opt/pydio/pydio.zip`.

* These configurations are inherited from the nginx image:

    * Drop privileges to `alpine` whenever configured to. Respects
      `PUID` / `PGID`.

    * Binds to both http(80) and https(443). Publish whichever you
      need, or both.

    * Default configs setup a static site at `/` by copying
      `/defaults/index.html` at the webroot location
      `/config/www/`.  Mount the `/config/` locally to persist
      modifications (or your webapps). NGINX configs are at
      `/config/nginx`, and vhosts at `/config/nginx/site-confs/`.

    * 4096bit Self-signed SSL certificate is generated in first
      run at `/config/keys`. Pass the runtime variable
      `SSLSUBJECT` with a valid info string to make your own.

    * `.htpasswd` is generated with default credentials
      `admin/insecurebydefault` at `/config/keys/.htpasswd`

    * Sets up a https and auth protected web location at `/secure`.

    * If you're proxying multiple containers at the same host, or
      reverse proxying multiple hosts at the same container, you
      may need to add `--net=host` and/or add entries in your
      firewall to allow traffic.

[1]: https://nginx.org
[2]: http://php.net/
[3]: https://pydio.com/
[4]: https://github.com/pydio/pydio-core/releases

{% include "all-include.md" %}
