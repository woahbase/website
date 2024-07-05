---
description: MultiArch Alpine Linux + S6 + Syncthing
svcname: syncthing
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - compose
  - github
  - nomad
  - proxy
  - s6
  - service

s6_userhome: /var/syncthing

---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the statically-linked
[Syncthing][1] daemon, used to setup a continuous decentralized
file sync acrosss multiple devices. Checkout their [docs][3] for
configuration or usage.

{{ m.srcimage('alpine-s6') }} with the the syncthing [binaries][2]
installed in it. {{ m.ghreleasestr('syncthing/syncthing') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_syncthing \
  -p 8384:8384 \
  -p 21027:21027/udp \
  -p 22000:22000/tcp \
  -p 22000:22000/udp \
  -v $PWD/config:/var/syncthing/config \
  -v $PWD/data:/var/syncthing/data \
woahbase/alpine-syncthing
```

--8<-- "multiarch.md"

---
#### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars          | Default                   | Description
| :---              | :---                      | :---
| SYNCTHING_HOME    | {{ s6_userhome }}         | Root directory for configuration and storage.
| SYNCTHING_DATA    | {{ s6_userhome }}/data    | Data directory for `syncthing`, for directory/file storage.
| STHOMEDIR         | {{ s6_userhome }}/config  | Configuration directory for `syncthing`, both for `config.xml` and database.
| STGUIADDRESS      | 0.0.0.0:8384              | Default `host:port` to bind to.
| STNODEFAULTFOLDER | 1                         | By default, do not create default folders on first run.
| STNOUPGRADE       | 1                         | By default, do not check for upgrades.
| SYNCTHING_ARGS    | --no-browser --no-restart | Customizable arguments passed to `syncthing` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Config is loaded from `{{ s6_userhome }}/config/config.xml`, edit
  this file or mount your own. Can also be configured via the web
  GUI. Same goes for certificates.

* Default storage dir is `{{ s6_userhome }}/data`.

* Does not create the default directory by default. Pass a falsy
  value to the env var `STNODEFAULTFOLDER` to disable it.

[1]: https://syncthing.net/
[2]: https://github.com/syncthing/syncthing
[3]: https://docs.syncthing.net/

{% include "all-include.md" %}
