---
description: MultiArch Alpine Linux + S6 + Mosquitto server.
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

| ENV Vars                        | Default                              | Description
| :---                            | :---                                 | :---
| MOSQUITTO_CONFDIR               | /mosquitto/config                    | Path to configuration directory. Expected to contain `mosquitto.conf`.
| MOSQUITTO__(parameter)          | unset                                | If set and no configuration file exists at `$MOSQUITTO_CONFDIR/mosquitto.conf`, will set the parameter (if exists) with the value. E.g. `MOSQUITTO__persistence=false`. (Note the **double** underscores.) {{ m.sincev('2.0.18_20240903') }}
| MOSQUITTO__persistence_location | /mosquitto/data                      | Path to datastore directory. {{ m.sincev('2.0.18_20240903') }}
| MOSQUITTO__log_dest             | stderr                               | Path to log destination (will create file if set to `file /path/to/file.log`). {{ m.sincev('2.0.18_20240903') }}
| MOSQUITTO__password_file        | $MOSQUITTO_CONFDIR/.passwd           | Path to auth file. {{ m.sincev('2.0.18_20240903') }}
| MOSQUITTO_SKIP_PERMFIX          | unset                                | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `mosquitto` configuration files/directories. {{ m.sincev('2.0.21') }}
| USERNAME                        | mosquitto                            | Default username for authentication.
| PASSWORD                        | insecurebydefault                    | Default password for authentication.
| MOSQUITTO_ARGS                  | -c $MOSQUITTO_CONFDIR/mosquitto.conf | Customizable arguments passed to `mosquitto` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/mosquitto/config/mosquitto.conf') }}

* Data stored at `/mosquitto/data`.

* Default configuration listens to ports `1883` and `8883`.

* Anonymous connects are disabled by default. Generates password
  file with `USERNAME` and `PASSWORD` if not exists.

* Check the [docs][3] or [configuration][4] options for
  customizing your own.

* For debugging or monitoring, check out [mqttui][5].

[1]: https://mosquitto.org/
[2]: http://mqtt.org/
[3]: https://mosquitto.org/documentation/
[4]: https://mosquitto.org/man/mosquitto-conf-5.html
[5]: https://github.com/EdJoPaTo/mqttui

{% include "all-include.md" %}
