---
description: MultiArch Alpine Linux + S6 + NGINX Web Server/Reverse Proxy.
svcname: nginx
has_services:
  - compose
  - nomad
tags:
  - compose
  - dev
  - nomad
  - package
  - s6
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
  -p 80:80 -p 443:443 \
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
| SSLSUBJECT | see below | Default SSL Subject for certificate generation on first run.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Default configs generate a 4096-bit self-signed certificate. By
  default the value of `SSLSUBJECT` is
  ```
  /C=US/ST=NY/L=EXAMPLE/O=EXAMPLE/OU=WOAHBase/CN=*/emailAddress=everybodycanseethis@mailinator.com
  ```

* Default configs setup a static site at `/` by copying
  `/defaults/index.html` at the webroot location `/config/www/`.
  Mount the `/config/` locally to persist modifications (or your
  webapps). NGINX config is at `/config/nginx`, and vhosts are at
  `/config/nginx/http.d/`. For JSON indexable (requires custom
  configuration) storage mount the data partition at `/storage/`.

* Includes two default site configuration (for http(80) and
  https(443)) in `/defaults` directory which are used as a starter
  configuration if none exist, these are no way intended to be
  used in production, you are better off rolling your own.

* Includes a placeholder script for further customizations.
  Override this shell script located at
  `/etc/s6-overlay/s6-rc.d/p1-end/dependencies.d/p12-nginx-customize/run`
  with your custom pre-tasks.

* Default configs set up a https and auth protected web location
  at /secure.

* If you're proxying multiple containers at the same host, or
  reverse proxying multiple hosts through the same container, you
  may need to add `--net=host` and/or add entries in your firewall
  to allow traffic.

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
