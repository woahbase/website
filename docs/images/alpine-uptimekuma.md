---
description: MultiArch Alpine Linux + S6 + NodeJS + UptimeKuma
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, x86_64]
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

This [image][155] containerizes the [UptimeKuma][1] service status
monitor to check/notify local/remote services availability and
show them in the WebUI as a nice status-page.

{{ m.srcimage('alpine-nodejs') }} with the [uptimekuma][2] package
(and binary distributables) installed in it.
{{ m.ghreleasestr('louislam/uptime-kuma') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_uptimekuma \
  -p 3001:3001 \
  -v $PWD/data:/home/alpine/project/data \
woahbase/alpine-uptimekuma
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                             | Default                   | Description
| :---                                 | :---                      | :---
| PROJECTDIR                           | /home/alpine/project      | (Preset) NodeJS project directory.
| DATADIR                              | /home/alpine/project/data | Path to data directory for storing check states.
| UPTIME_KUMA_HOST                     | 0.0.0.0                   | Interface to listen on.
| UPTIME_KUMA_PORT                     | 3001                      | Port to listen on.
| UPTIME_KUMA_DISABLE_FRAME_SAMEORIGIN | false                     | Whether to disable same-origin frames.
| UPTIMEKUMA_SKIP_PERMFIX              | unset                     | Set to **non-empty-string** e.g. `1` to skip fixing permissions on `${PROJECTDIR}` and `${DATADIR}` everytime before starting service.
| UPTIMEKUMA_ARGS                      | --data-dir=${DATADIR}       | Customizable arguments passed to `uptime-kuma` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* **Does not** include `chromium`. You can install it at runtime,
  but if you really need those type of checks you are better off
  using the official image.

* `nscd` (or `musl-nscd`) **does not** seem to work with Alpine Linux.
  Not really important if you don't need to cache DNS queries.

* Checkout their [wiki][3] for customizing your own. Especially
  the [environment-variables][4].

* Includes everything from the {{ m.myimage('alpine-nodejs') }}
  image. Which in turn, includes everything from the {{
  m.myimage('alpine-s6') }} image.

[1]: https://uptime.kuma.pet/
[2]: https://github.com/louislam/uptime-kuma/releases
[3]: https://github.com/louislam/uptime-kuma/wiki
[4]: https://github.com/louislam/uptime-kuma/wiki/Environment-Variables

{% include "all-include.md" %}
