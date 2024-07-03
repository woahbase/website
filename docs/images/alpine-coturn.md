---
description: MultiArch Alpine Linux + S6 + Coturn STUN/TURN Gateway for VoIP.
svcname: coturn
tags:
  - package
  - s6
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

| ENV Vars    | Default | Description
| :---        | :---    | :---
| COTURN_ARGS | -v      | Custom arguments passed to `coturn` service.
{% include "envvars/alpine-s6.md" %}

Also,

* Config file loaded from `/var/lib/coturn/turnserver.conf` edit
  or remount this with your own. A {{
  m.ghfilelink('root/defaults/turnserver.conf', title='sample')
  }} is provided which is auto loaded if there aren't any config
  file to start with.

* Data stored at `/var/lib/coturn`.

* Default configuration listens to ports `3478` and `5349`(TLS),
  for the latter, you need to update the location where your certs
  are in the config file.

* Docker does not handle mapping port-ranges very well, so it may
  be preferred to use `--net=host` and whitelist the relay ports
  in your firewall.

[1]: https://github.com/coturn/coturn

{% include "all-include.md" %}
