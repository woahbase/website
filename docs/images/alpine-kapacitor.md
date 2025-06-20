---
description: MultiArch Alpine Linux + S6 + GNU LibC + Kapacitor
has_services:
  - compose
  - nomad
skip_armhf: 1
skip_armv7l: 1
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [Kapacitor][1] to process/monitor
time-series data from an [Influx][2] database service running
somewhere in the network. [Docs][3] can be found here.

Usually coupled with {{ m.myimage('alpine-influxdb') }} and
{{ m.myimage('alpine-chronograf') }} image for the dashboard.
(using [telegraf][5] or {{ m.myimage('alpine-netdata') }} to
collect the metrics from the hosts)

{{ m.srcimage('alpine-glibc') }} with the [kapacitor][1]
([binaries][4]) installed in it. {{
m.ghreleasestr('influxdata/kapacitor') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_kapacitor \
  -p 9002:9002 \
  -v $PWD/data:/var/lib/kapacitor \
woahbase/alpine-kapacitor
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars          | Default                       | Description
| :---              | :---                          | :---
| KAPACITOR_URL     | http://localhost:9092         | Url for `kapacitor`.
| KAPACITOR_CONFIG  | /etc/kapacitor/kapacitor.conf | Path to `kapacitor` configuration.
| KAPACITOR_AS_ROOT | unset                         | If set, runs service as `root` user, default is non-root `alpine`.
| KAPACITOR_ARGS    | unset                         | Customizable arguments passed to `kapacitord` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/etc/kapacitor/kapacitor.conf', vname='KAPACITOR_CONFIG') }}

* Check the [configuration][6] options for customizing the service
  via either runtime arguments, or environment variables.

[1]: https://www.influxdata.com/time-series-platform/kapacitor/
[2]: https://www.influxdata.com
[3]: https://docs.influxdata.com/kapacitor
[4]: https://portal.influxdata.com/downloads/
[5]: https://www.influxdata.com/time-series-platform/telegraf/
[6]: https://docs.influxdata.com/kapacitor/v1/administration/configuration/

{% include "all-include.md" %}
