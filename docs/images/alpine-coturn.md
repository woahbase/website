---
description: MultiArch Alpine Linux + S6 + Coturn STUN/TURN Gateway for VoIP.
alpine_branch: v3.23
arches: [aarch64, armhf, armv7l, i386, ppc64le, riscv64, s390x, x86_64]
has_services:
  - compose
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [Coturn][1] server to setup
a STUN/TURN gateway for VoIP traffic as a microservice.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('coturn') }}
package installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_coturn \
  -p 3478:3478/udp -p 5349:5349/udp \
  -p 3478:3478/tcp -p 5349:5349/tcp \
  -p 49152-65535:49152-65535/udp \
  -v $PWD/data:/var/lib/coturn \
woahbase/alpine-coturn
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars            | Default                         | Description
| :---                | :---                            | :---
| COTURN_DATADIR      | /var/lib/coturn                 | Directory for datadir (for `sqlite` db).
| COTURN_CONF         | /var/lib/coturn/turnserver.conf | Path to configuration file.
| COTURN_CLIPASSWORD  | unset                           | Default CLI password. If set and and using the default configuration, i.e. no configuration file exists at `${COTURN_CONF}`, will set the parameter in the configuration file. {{ m.sincev('4.6.3') }}
| COTURN_CERTFILE     | /etc/ssl/certs/cert.pem         | Path to certificate file. If set and and using the default configuration, i.e. no configuration file exists at `${COTURN_CONF}`, will set the parameter in the configuration file. {{ m.sincev('4.6.3') }}
| COTURN_PKEYFILE     | /etc/ssl/private/privkey.pem    | Path to privatekey file. If set and and using the default configuration, i.e. no configuration file exists at `${COTURN_CONF}`, will set the parameter in the configuration file. {{ m.sincev('4.6.3') }}
| COTURN_LISTENADDR   | 0.0.0.0                         | Default address to listen on. If set and and using the default configuration, i.e. no configuration file exists at `${COTURN_CONF}`, will set the parameter in the configuration file. {{ m.sincev('4.6.3') }}
| COTURN_REALM        | localhost                       | Default realm. If set and and using the default configuration, i.e. no configuration file exists at `${COTURN_CONF}`, will set the parameter in the configuration file. {{ m.sincev('4.6.3') }}
| COTURN_SKIP_PERMFIX | unset                           | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `coturn` files/directories. {{ m.sincev('4.6.3') }}
| COTURN_ARGS         | unset                           | Customizable arguments passed to `coturn` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/var/lib/coturn/turnserver.conf', vname='COTURN_CONF') }}

* Data stored at `/var/lib/coturn`.

* Default configuration listens to ports `3478` and `5349`(TLS),
  for the latter, you need to update the location where your certs
  are in the config file.

* Docker does not handle mapping port-ranges very well, so it may
  be preferred to use `--net=host` and whitelist the relay ports
  in your firewall.

* Check the [docs][2] to customize your own.

[1]: https://github.com/coturn/coturn
[2]: https://github.com/coturn/coturn/blob/master/README.turnserver
[3]: https://github.com/coturn/coturn/raw/master/docker/coturn/turnserver.conf

{% include "all-include.md" %}
