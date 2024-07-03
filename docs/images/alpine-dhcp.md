---
description: MultiArch Alpine Linux + S6 + ISC DHCP server.
svcname: dhcp
has_services:
  - compose
  - systemd
tags:
  - compose
  - package
  - s6
  - service
  - systemd
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [ISC DHCP][1] to quickly
deploy a DHCP server to serve/manage IP configurations to the
devices in the network.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('dhcp') }}
package installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_dhcp \
  --network=host \
  -e INTERFACES=eth0 \
  -p 67:67/tcp -p 67:67/udp \
  -v $PWD/dhcp:/etc/dhcp \
woahbase/alpine-dhcp
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars   | Default           | Description
| :---       | :---              | :---
| DHCP_ARGS  | -4 -f -d --no-pid | Custom arguments passed to `dhcpd` service.
| INTERFACES | eth0              | Bind to the specific NIC.

Also,

* ISC-DHCP needs the `--network=host` flag to have access to the
  NIC of the host machine.

* A {{ m.ghfilelink('root/defaults/dhcpd.conf', title='sample') }}
  configuration is provided in the `/defaults` directory, this
  gets copied to `/etc/dhcp/dhcpd.conf` if none exist.

[1]: https://www.isc.org/dhcp/

{% include "all-include.md" %}
