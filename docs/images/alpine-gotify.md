---
description: MultiArch Alpine Linux + S6 + GNU LibC + Gotify Server (and CLI)
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
| GOTIFY_CONFIG            | /etc/gotify/config.yml | Configuration file path.
| GOTIFY_HOME              | /gotify                | Root directory for server application data.
| GOTIFY_DATA              | /gotify/data           | Datastore for server application.
| GOTIFY_PLUGINSDIR        | /gotify/data/plugins   | Plugins directory.
| GOTIFY_UPLOADEDIMAGESDIR | /gotify/data/images    | Cache for uploaded images.
| GOTIFY_SERVER_PORT       | 80                     | Port to listen on.
| GOTIFY_ARGS              | unset                  | Customizable arguments passed to `gotify-server` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/etc/gotify/config.yml', vname='GOTIFY_CONFIG') }}

* Data stored at `/gotify/data`.

* Checkout their [docs][5] for configuration/usage.

* Link to [Android][4] companion app.

[1]: https://gotify.net/
[2]: https://github.com/gotify/server
[3]: https://github.com/gotify/cli
[4]: https://github.com/gotify/android
[5]: https://gotify.net/docs/index

{% include "all-include.md" %}
