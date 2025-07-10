---
description: MultiArch Alpine Linux + S6 + NodeJS + Redis-Commander
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, i386, ppc64le, riscv64, s390x, x86_64]
skip_s390x: 1
svcname: rediscommander
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

This [image][155] containerizes the [Redis-Commander][1] to
monitor/control [Redis][5] instances.

{{ m.srcimage('alpine-nodejs') }} with the {{
m.npmpkg('redis-commander') }} package installed in it.
{{ m.ghreleasestr('joeferner/redis-commander', tracking='tags') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_rediscommander \
  -p 8081:8081 \
  -v $PWD/config:/redis-commander/config \
woahbase/alpine-rediscommander
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars               | Default                 | Description
| :---                   | :---                    | :---
| NODE_CONFIG_DIR        | /redis-commander/config | Default configuration directory.
| NODE_ENV               | config                  | Configuration JSON file to use.
| REDISCMDR_LOCAL_CONFIG | unset                   | If set, creates the file `local.json` in `NODE_CONFIG_DIR` with the value as the content.
| REDISCMDR_SKIP_PERMFIX | unset                   | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `redis-commander` configuration files/directories.
| REDISCMDR_ARGS         | unset                   | Customizable arguments passed to `redis-commander` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/redis-commander/config/config.json',
  src='redis-commander/config/config.json',
  ddir='redis-commander') }}

* Optionally add another file `local.json` inside
  `/redis-commander/config/` or set `REDISCMDR_LOCAL_JSON` with
  the Redis Connections configurations. This helps to keep
  connections separate from configurations.

* Checkout their docs for [configurations][3] and [connections][4]
  options to customize your own.

* **Redis not included**. Checkout {{ m.myimage('alpine-redis') }}
  to configure your own [Redis][5] instance in a container.

* Includes everything from the {{ m.myimage('alpine-nodejs') }}
  image. Which in turn, includes everything from the {{
  m.myimage('alpine-s6') }} image.

[1]: https://joeferner.github.io/redis-commander/
[2]: https://github.com/joeferner/redis-commander
[3]: https://github.com/joeferner/redis-commander/blob/master/docs/configuration.md
[4]: https://github.com/joeferner/redis-commander/blob/master/docs/connections.md
[5]: https://redis.io

{% include "all-include.md" %}
