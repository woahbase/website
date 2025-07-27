---
description: MultiArch Alpine Linux + S6 + Redis.
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, i386, ppc64le, riscv64, s390x, x86_64]
has_services:
  - compose
  - nomad
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [Redis][1] Cache/Message broker
to setup a key-value store / pub-sub service.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('redis') }}
package installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_redis \
  -p 6379:6379 \
  -v $PWD/data:/var/lib/redis \
woahbase/alpine-redis
```

--8<-- "multiarch.md"

---
#### Configuration Defaults
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars           | Default            | Description
| :---               | :---               | :---
| REDIS_CONF         | /etc/redis.conf    | Path to configuration.
| REDIS__(parameter) | unset              | If set and no configuration file exists at `${REDIS_CONF}`, will set the parameter (if exists) with the value. E.g. `REDIS__dir=/var/lib/redis`. (Note the **double** underscores). {{ m.sincev('7.2.5') }}
| REDIS__dir         | /var/lib/redis     | Path to datastore. {{ m.sincev('7.2.5') }} Previously `REDIS_HOME`.
| REDIS__pidfile     | /var/run/redis.pid | Path to pidfile. {{ m.sincev('7.2.5') }}
| REDIS__logfile     | unset              | Path to log destination (will create file if set e.g. `/var/log/redis.log`). {{ m.sincev('7.2.5') }} Previously `REDIS_LOGS`.
| REDIS_SKIP_PERMFIX | unset              | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `redis` configuration files/directories. {{ m.sincev('8.0.2') }}
| REDIS_ARGS         | /etc/redis.conf    | Customizable arguments passed to `redis` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/etc/redis.conf', vname='REDIS_CONF') }}

* Data stored at `/var/lib/redis`, logs go to `stdout` by default,
  or `/var/log/redis` when logging to file enabled in configuration.

* Default configuration listens to ports `6379`.

[1]: https://redis.io

{% include "all-include.md" %}
