---
description: Container for Alpine Linux + S6 + Proxy DNS Daemon
svcname: pdnsd
has_services:
  - compose
skip_aarch64: true
skip_armv7l: true
tags:
  - compose
  - deprecated
  - s6
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [PDNSd][1] DNS server with
persistent caching-to-disk and recursion/forwarding, mainly used
to resolve domain names (both local devices and outsiders) and
blocking ads inside the local network.

{{ m.srcimage('alpine-s6') }} with the compiled `pdnsd` binaries
installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm -it \
  --name docker_pdnsd \
  -p 53:53/tcp \
  -p 53:53/udp \
  -v $PWD/data:/data \
  -v /etc/hosts:/etc/hosts:ro \
woahbase/alpine-pdnsd:x86_64
```

--8<-- "multiarch.md"

---
#### Configuration
---

* Config file is at `/etc/pdnsd.conf`, edit or remount this with
  your own. A {{ m.ghfilelink('root/defaults/pdnsd.conf',
  title='sample') }} is provided in `/defaults`, this gets copied
  if none exists. Put your custom config file at
  `/data/pdnsd.conf` and it will be used instead.

* Local names are served from `/data/hosts/hosts.local`, if not
  found, `/etc/hosts` is copied.

* A default blocklist from the following sources are provided as
  default at `/etc/hosts.blocked`. On start, this is copied over
  to `/data/hosts/hosts.blocked`, if not existing already. Replace
  this file to use your own blocking list. Current build
  combines the following lists ..

    * [AdAway's Sources](https://github.com/AdAway/AdAway/wiki/hostssources)
    * [Someonewhocares](http://someonewhocares.org/hosts/zero/hosts)
    * [StevenBlack's List](https://github.com/StevenBlack/hosts)
    * [hpHosts](https://hosts-file.net/)

* To unblock a specific domain from the blocklist, put it inside
  `/data/hosts/hosts.whitelisted` (needs restart).
  To manually unblock using `sed`..
  ```
  sed -i -e 's/\([ . ]\)rt.com/\1notrt.com/g' /data/hosts/*
  ```

* On many systemd derivations e.g. Ubuntu, 53/udp may be
  already in-use by `systemd-resolved`. In that case, it will need to
  be stopped first before dns server is started, with,
  ```
  sudo systemctl stop systed-resolved
  ```

[1]: http://members.home.nl/p.a.rombouts/pdnsd/

{% include "all-include.md" %}
