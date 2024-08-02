---
description: Container for Alpine Linux + S6 + NGINX + Laverna Note-taking webapp
svcname: laverna
skip_armv7l: true
skip_aarch64: true
tags:
  - deprecated
  - nginx
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the prebuilt version of
[Laverna][1] Note-taking static webapp.

{{ m.srcimage('alpine-nginx') }} image with [NGINX][3] and the
Laverna static webapp files overlayed in it. Updated according to the
[Laverna/static-laverna][2] (branch `gh-pages`).

{% include "pull-image.md" %}

---
#### Run
---

Running the container starts the service.

``` sh
docker run --rm -it \
  --name docker_laverna \
  -p 80:80 \
  -p 443:443 \
  -v $PWD/config:/config \
woahbase/alpine-laverna:x86_64
```

--8<-- "multiarch.md"

---
##### Configuration
---

* Laverna is located at the endpoint `/laverna/`, with configurations
  at `/config/www/laverna/` and data at `/config/www/laverna/data/`.
  Uploaded images go to `/config/www/laverna/uploads`.

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

[1]: https://laverna.cc/
[2]: https://github.com/Laverna/static-laverna/tree/gh-pages
[3]: https://nginx.org

{% include "all-include.md" %}
