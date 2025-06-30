---
description: MultiArch Alpine Linux + S6 + NGINX Web Server/Reverse Proxy.
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, i386, ppc64le, riscv64, s390x, x86_64]
has_services:
  - compose
  - nomad
tags:
  - dev
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as a standalone web/reverse proxy server,
or as the base image for applications / services that use or
require [NGINX][1].

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('nginx') }}
package installed in it. Also includes modules for `stream` and
`http-headers-more` for those who need it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_nginx \
  -p 80:80 \
  -p 443:443 \
  -v $PWD/config:/config \
woahbase/alpine-nginx
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars   | Default   | Description
| :---       | :---      | :---
{% include "envvars/alpine-nginx.md" %}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Mount the `/config/` locally to persist
  modifications (or your webapps). NGINX configurations are at
  `/config/nginx`, and vhosts at `/config/nginx/http.d/`. For JSON
  indexable (requires custom configuration) storage mount the data
  partition at `/storage/`.

* Default `nginx.conf` includes files in `${CONFSDIR}` that ends
  with `.root.conf` in the root context, similarly `.http.conf` in
  `http` context as well as all files in `${SITESDIR}` and
  `.stream.conf` and files in `${STREAMSDIR}` for streams. {{
  m.sincev('1.28.0')  }}

* Includes two default site configuration (for {{
  m.ghfilelink('root/defaults/default_http', title='http:80') }}
  and {{ m.ghfilelink('root/defaults/default_https',
  title='https:443') }}) in `/defaults` directory which are used
  as a starter configuration if none exist, these are no way
  intended to be used in production, you are better off rolling
  your own.

* Default configs setup a static site at `/` by copying
  `/defaults/index.html` at `${WEBDIR}` (default `/config/www/`),
  along with a HTTPS and HtPassword protected web location at
  `/secure`.

* {{ m.customscript('p12-nginx-customize') }}

* Includes a {{ m.ghfilelink('root/usr/local/bin/nginx-reconf.sh',
  title='nginx-reconf.sh') }} script to check and reload `nginx`
  configurations (only when valid) without restarting the
  container. {{ m.sincev('1.26.2_20250225') }}

* If running the container as a non-root user (with
  `--user=${UID}:${GID}`), consider passing the prefix flag, i.e.
  `-p /config/nginx` in `${NGINX_ARGS}` so that `nginx` does not
  try to read/write files it does not have permissions to, e.g any
  file in `/etc/nginx` or `/var/lib/nginx` or `/var/log/nginx`.

* If you're proxying multiple containers at the same host, or
  reverse proxying multiple hosts through the same container, you
  may need to add `--net=host` and/or add entries in your firewall
  to allow traffic.

###### SSL Subject

Default configs generate a 4096-bit self-signed certificate. By
default the value of `SSLSUBJECT` is
```
/C=US/ST=NY/L=EXAMPLE/O=EXAMPLE/OU=EXAMPLE/CN=*/emailAddress=me@example.com
```

??? info "Did you know?"
    To validate the configuration when modified, we could just
    get a debug shell into the container and run

    ```
    nginx -c /config/nginx/nginx.conf -t
    ```

    And if that is `ok`, we could reload the configuration without
    stopping nginx with

    ```
    nginx -c /config/nginx/nginx.conf -s reload
    ```

[1]: https://nginx.org

{% include "all-include.md" %}
