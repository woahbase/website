---
description: MultiArch Alpine Linux + S6 + GNU LibC + Chronograf
alpine_branch: v3.23
arches: [aarch64, armhf, armv7l, i386, x86_64]
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [Chronograf][1] to administrate or
display dashboards from an [Influx][2] database service running
somewhere in the network. Checkout their [docs][4] for configurations.

Usually coupled with the {{ m.myimage('alpine-influxdb') }} and {{
m.myimage('alpine-kapacitor') }} for the monitoring, and
[telegraf][5] or {{ m.myimage('alpine-netdata') }} to collect
the metrics from the hosts.

{{ m.srcimage('alpine-glibc') }} with the [chronograf][1]
([binaries][3]) installed in it. {{
  m.ghreleasestr('influxdata/chronograf') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_chronograf \
  -p 8888:8888 \
  -v $PWD/data:/var/lib/chronograf \
woahbase/alpine-chronograf
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                | Default                              | Description
| :---                    | :---                                 | :---
| BASE_PATH               | /chronograf                          | The URL path prefix under which all chronograf routes will be mounted.
| BOLT_PATH               | /var/lib/chronograf/chronograf-v1.db | The file path to the BoltDB file.
| CANNED_PATH             | /usr/share/chronograf/canned         | The path to the directory of canned dashboards files.
| REPORTING_DISABLED      | true                                 | Disables reporting of usage statistics.
| RESOURCES_PATH          | /usr/share/chronograf/resources      | Path to directory of sources (.src files), Kapacitor connections (.kap files), organizations (.org files), and dashboards (.dashboard files).
| CHRONOGRAF_SKIP_PERMFIX | unset                                | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `chronograf` configuration/data files/directories. {{ m.sincev('1.10.7_20250806') }}
| CHRONOGRAF_ARGS         | unset                                | Customizable arguments passed to `chronograf` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* By default, `chronograf` is available at
  `http://localhost:8888/chronograf`.

* Check the [configuration][6] options for customizing the service
  via either runtime arguments, or environment variables.

* Check the [chronoctl][7] docs for tasks like migration or
  superadmin generation.

[1]: https://www.influxdata.com/time-series-platform/chronograf/
[2]: https://www.influxdata.com/products/influxdb-overview/
[3]: https://portal.influxdata.com/downloads/
[4]: https://docs.influxdata.com/chronograf/
[5]: https://www.influxdata.com/time-series-platform/telegraf/
[6]: https://docs.influxdata.com/chronograf/v1/administration/config-options/
[7]: https://docs.influxdata.com/chronograf/v1/tools/chronoctl/

{% include "all-include.md" %}
