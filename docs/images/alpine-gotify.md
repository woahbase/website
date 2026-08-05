---
description: MultiArch Alpine Linux + S6 + GNU LibC + Gotify Server (and CLI)
alpine_branch: v3.24
arches: [aarch64, armhf, armv7l, i386, x86_64]
has_services: [compose, nomad]
has_proxies: [nginx]
tags: [service]
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as a notification cache using [Gotify][1].

{{ m.srcimage('alpine-glibc') }} with the gotify [server][2] and
[cli][3] binaries installed in it. {{ m.ghreleasestr('gotify/server') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_gotify \
  -p 80:80 \
  -v $PWD/data:/gotify/data \
woahbase/alpine-gotify
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                 | Default                | Description
| :---                     | :---                   | :---
| GOTIFY_CONFIG_FILE       | /etc/gotify/server.env | Optional configuration file path. {{ m.sincev('3.0.0_20260905') }}, unset to configure only using environment variables.
| ~~GOTIFY_CONFIG~~        | /etc/gotify/config.yml | Deprecated YAML configuration file path. {{ m.sincev('3.0.0_20260905') }}.
| ~~GOTIFY_HOME~~          | /gotify                | Removed {{ m.sincev('2.6.3_20250807') }}. Set `${GOTIFY_DATADIR}` instead. ~~Used to set the root directory for server application data.~~
| GOTIFY_DATADIR           | /gotify/data           | Datastore for server application. Previously named `GOTIFY_DATA`, renamed {{ m.sincev('3.0.0_20260905') }}
| GOTIFY_PLUGINSDIR        | /gotify/data/plugins   | Plugins directory.
| GOTIFY_UPLOADEDIMAGESDIR | /gotify/data/images    | Cache for uploaded images.
| GOTIFY_SERVER_PORT       | 80                     | Port to listen on.
| GOTIFY_SKIP_PERMFIX      | unset                  | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `gotify` configuration/data files/directories. {{ m.sincev('2.6.3_20250807') }}
| GOTIFY_ARGS              | unset                  | Customizable arguments passed to `gotify-server` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/etc/gotify/server.env', vname='GOTIFY_CONFIG_FILE')
  }} The example configuration may also be found [here][8]. Optionally
  you may unset this variable if all your configurations are from
  environment variables. Previously preset as `GOTIFY_CONFIG`, example
  [here][7], deprecated {{ m.sincev('3.0.0_20260905') }}.

* Data stored at `/gotify/data`.

* Checkout their [docs][5] for configuration/usage.

* Link to [Android][4] companion app.

[1]: https://gotify.net/
[2]: https://github.com/gotify/server
[3]: https://github.com/gotify/cli
[4]: https://github.com/gotify/android
[5]: https://gotify.net/docs/index
[6]: https://gotify.net/docs/config
[7]: https://github.com/gotify/server/blob/v2.9.1/config.example.yml
[8]: https://github.com/gotify/server/raw/refs/heads/master/gotify-server.env.example

{% include "all-include.md" %}
