---
description: MultiArch Alpine Linux + S6 + Mosquitto server.
svcname: mosquitto
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

This [image][155] containerizes the [Mosquitto][1] Message broker
to setup a pub-sub service using the [MQTT][2] / Websocket protocol.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('mosquitto')
}} package installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_mosquitto \
  -e USERNAME=mosquitto \
  -e PASSWORD=insecurebydefault \
  -p 1883:1883 \
  -p 8883:8883 \
  -v $PWD/data:/mosquitto \
woahbase/alpine-mosquitto
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars       | Default                             | Description
| :---           | :---                                | :---
| MOSQUITTO_ARGS | -c /mosquitto/config/mosquitto.conf | Arguments passed to `mosquitto` service.
| USERNAME       | mosquitto                           | Default username for authentication.
| PASSWORD       | insecurebydefault                   | Default password for authentication.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Config file is at `/mosquitto/config/mosquitto.conf`, edit or
  remount this with your own. A {{
  m.ghfilelink('root/defaults/mosquitto.conf', title='sample')
  }} is provided in the `/defaults/` directory, this gets copied
  if none exist.

* Data stored at `/mosquitto/data`.

* Default configuration listens to ports `1883` and `8883`.

* Anonymous connects are disabled by default.

[1]: https://mosquitto.org/
[2]: http://mqtt.org/

{% include "all-include.md" %}
