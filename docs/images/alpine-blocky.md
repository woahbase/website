---
description: MultiArch Alpine Linux + S6 + Blocky DNS-Resolver (and Ad-Blocker)
svcname: blocky
has_services:
  - compose
  - systemd
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [Blocky][1] DNS server. Mainly used to
resolve domain names (both local devices and outsiders) and blocking ads inside
the local network.

{{ m.srcimage('alpine-s6') }} with the [blocky][2] binaries
installed in it. {{ m.ghreleasestr('0xERR0R/blocky') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_blocky \
  -p 53:53/tcp \
  -p 53:53/udp \
  -p 4000:4000 \
  -v $PWD/config:/config \
  -v /etc/hosts:/etc/hosts:ro \
woahbase/alpine-blocky
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars           | Default                          | Description
| :---               | :---                             | :---
| BLOCKY_CONFIG_FILE | /config/config.yml               | (Preset) Path to `blocky` configuration file. (Setting this path to a directory is **unsupported**, use `$BLOCKY_CONFDIR` instead.)
  | BLOCKY_CONFDIR     | unset                            | If set to a directory containing YML snippets, the files in this directory are merged (using `yq`) to generate `$BLOCKY_CONFIG_FILE`.
| BLOCKY_CONFURL     | unset                            | If set, will fetch `config.yml` from this url. If the url points to a `.tar.gz` file, it is automatically unpacked inside `${BLOCKY_CONFDIR}` (`/config/snippets` by default) and subsequently merged to generate `$BLOCKY_CONFIG_FILE`.
| BLOCKY_ARGS        | --apiHost 0.0.0.0 --apiPort 4000 | Customizable arguments passed to `blocky` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/config/config.yml', vname='BLOCKY_CONFIG_FILE') }}

* By default, allow/deny lists are sourced from `/config/lists/`.
  Logs are written to `/config/logs` (or `stdout`).

* Checkout their docs for [configuration][3], the default
  `config.yml` provided in the image may be found [here][4].

* For caching and syncing multiple server states using `redis`,
  check the {{ m.myimage('alpine-redis') }} image.

[1]: https://0xerr0r.github.io/blocky/
[2]: https://github.com/0xERR0R/blocky/releases
[3]: https://0xerr0r.github.io/blocky/configuration/
[4]: https://raw.githubusercontent.com/0xERR0R/blocky/main/docs/config.yml

{% include "all-include.md" %}
