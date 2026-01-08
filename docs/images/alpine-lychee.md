---
description: Container for Alpine Linux + S6 + NGINX + PHP7 + Lychee
alpine_branch: v3.10
arches: [armhf, x86_64]
tags:
  - deprecated
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [Lychee][3] Image Gallery along
with its php dependencies to setup a pesonal image repository.
**Database and images not included**. Checkout {{
m.myimage('alpine-mysql') }} to configure your own MySQL
server in a container.

{{ m.srcimage('alpine-php') }} with [NGINX][1], [PHP7][2] and the
[Lychee][4] scripts overlayed on it. {{
m.ghreleasestr('electerious/Lychee') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm -it \
  --name docker_lychee \
  -p 80:80 \
  -p 443:443 \
  -v $PWD/config:/config \
  -v $PWD/uploads:/config/www/lychee/uploads \
woahbase/alpine-lychee:x86_64
```

--8<-- "multiarch.md"

---
##### Configuration
---

* Lychee is located at the endpoint `/lychee/`, with configurations
  at `/config/lychee/` and data at `/config/lychee/data/`.
  Uploaded images go to `/config/www/lychee/uploads`.

* Lychee source is located at `/opt/lychee/lychee.zip`.

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
[3]: https://lychee.electerious.com/
[4]: https://github.com/electerious/Lychee

{% include "all-include.md" %}
