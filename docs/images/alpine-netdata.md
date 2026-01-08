---
description: Container for Alpine Linux + S6 + GNU LibC + Netdata
alpine_branch: v3.10
arches: [aarch64, armhf, armv7l, x86_64]
has_services:
  - compose
tags:
  - deprecated
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as a host or container monitor using
[Netdata][1].  Usually coupled with my {{
m.myimage('alpine-influxdb') }} image which has the OpenTSDB
listener enabled to collect the metrics, and {{
m.myimage('alpine-grafana') }} to visualize the metrics.

{{ m.srcimage('alpine-s6') }} with [netdata][2] installed in it.
{{ m.ghreleasestr('netdata/netdata') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the host monitor service.

``` sh
docker run --rm -it \
  --cap-add SYS_PTRACE \
  --name docker_netdata \
  -p 19999:19999 \
  -v /etc/hosts:/etc/hosts:ro \
  -v /etc/localtime:/etc/localtime:ro \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v $PWD/netdata:/etc/netdata \
woahbase/alpine-netdata:x86_64
```

--8<-- "multiarch.md"

---
#### Configuration
---

* Configs are read from  `/etc/netdata/netdata.conf`. Use the {{
  m.ghfilelink('root/defaults/default.conf', title='sample') }} or
  mount your own here. The example above has the `/proc` and
  `/sys` mounted, and privilege to monitor the host.

[1]: https://www.netdata.cloud/
[2]: https://github.com/netdata/netdata

{% include "all-include.md" %}
