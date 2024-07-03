---
description: MultiArch Alpine Linux + S6 + Redis.
svcname: redis
has_services:
  - compose
  - nomad
tags:
  - compose
  - nomad
  - package
  - s6
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

| ENV Vars         | Default                       | Description
| :---             | :---                          | :---
| REDIS_ARGS       | /etc/redis.conf               | Customizable arguments passed to `redis` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Config file is at `/etc/redis.conf`, edit or remount this
  with your own. A default is provided in `/default`, this gets
  copied if none exists.

* Data stored at `/var/lib/redis`, logs go to `stdout` by default,
  or `/var/log/redis` when logging to file enabled in configuration.

* Default configuration listens to ports `6379`.

[1]: https://redis.io

{% include "all-include.md" %}
