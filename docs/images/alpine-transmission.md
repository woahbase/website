---
description: MultiArch Alpine Linux + S6 + Transmission Daemon (and CLI)
svcname: transmission
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - compose
  - nomad
  - package
  - proxy
  - s6
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [Transmission][1] daemon with
the WebUI running on port 9091.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('transmission-daemon') }}
(and {{ m.alpinepkg('transmission-cli') }}) packages installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_transmission \
  -p 52437:52437/tcp \
  -p 52437:52437/udp \
  -p 9091:9091 \
  -v $PWD/config:/var/lib/transmission/config \
  -v $PWD/downloads:/var/lib/transmission/downloads \
  -v $PWD/watched:/var/lib/transmission/torrents \
woahbase/alpine-transmission
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars          | Default                                     | Description
| :---              | :---                                        | :---
| TRANSMISSION_ARGS | --foreground --no-portmap --log-level=error | Customizable arguments passed to `transmission-daemon` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Config file is at `/var/lib/transmission/config/settings.json`,
  edit or remount this file with your own. A {{
  m.ghfilelink('root/defaults/settings.json', title='sample') }}
  is provided in `/defaults/`, that gets copied if none exists.

* Default download location is `/var/lib/transmission/downloads`.

* Default configuration makes the service available at the subpath
  `/transmission/`.

* Default configuration listens to ports `9091` for the web-ui and
  `52437` for peer communications. These may need to be
  whitelisted in your firewall.

[1]: http://transmissionbt.com/

{% include "all-include.md" %}
