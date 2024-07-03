---
description: MultiArch Alpine Linux + S6 + Grafana
svcname: grafana
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - compose
  - github
  - nomad
  - proxy
  - s6
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as a monitor/visualization dashboard
server using [Grafana][1] from an [Influx][2] database service
running somewhere in the network. Usually coupled with the {{
m.myimage('alpine-influxdb') }} image, using [telegraf][3] or {{
m.myimage('alpine-netdata') }} to collect the metrics from the
hosts.

{{ m.srcimage('alpine-s6') }} with the [Grafana][4] OSS binaries
installed in it. {{ m.ghreleasestr('grafana/grafana') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_grafana \
  -p 3000:3000 \
  -v $PWD/data:/var/lib/grafana/data \
  -v $PWD/conf:/var/lib/grafana/conf \
woahbase/alpine-grafana
```

--8<-- "multiarch.md"

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars              | Default                            | Description
| :---                  | :---                               | :---
| GF_PATHS_CONFIG       | /var/lib/grafana/conf/defaults.ini | Path to configuration file.
| GF_PATHS_DATA         | /var/lib/grafana/data              | Path to data directory.
| GF_PATHS_LOGS         | /var/lib/grafana/log               | Path where logs are stored.
| GF_PATHS_PLUGINS      | /var/lib/grafana/plugins           | Path to plugins directory.
| GF_PATHS_PROVISIONING | /var/lib/grafana/provisioning      | Path where provisioning configuration should exist.
| GF_INSTALL_PLUGINS    | empty string                       | Comma separated list of plugins (or urls) to install before running server.
| GF_UPDATE_PLUGINS     | unset                              | Set to `true` to run plugin-update (uses `grafana cli`).
| GF_LOG_MODE           | console                            | Default log mode, can be `console` or `file`.
| GRAFANA_ARGS          | see below                          | Arguments passed to `grafana server` service.
| GRAFANA_ARGS_EXTRA    | empty string                       | Custom arguments passed to `grafana server` service.
{% include "envvars/alpine-s6.md" %}

Also,

* A {{ m.ghfilelink('root/defaults/defaults.ini', title='sample')
  }} configuration is provided in the `/defaults` directory, this
  gets copied to `/var/lib/grafana/conf/defaults.ini` if none
  exist.

* By default `grafana server` is run with the following arguments,
    ```
    cfg:default.log.mode=$GF_LOG_MODE \
    cfg:default.paths.data=$GF_PATHS_DATA \
    cfg:default.paths.logs=$GF_PATHS_LOGS \
    cfg:default.paths.plugins=$GF_PATHS_PLUGINS \
    cfg:default.paths.provisioning=$GF_PATHS_PROVISIONING
    ```
  So that customized paths get used instead of the defaults in
  configuration. Override the `GRAFANA_ARGS` environment variable
  to customize these, or add extra args in `GRAFANA_ARGS_EXTRA` as
  needed.

[1]: https://grafana.com
[2]: https://www.influxdata.com/products/influxdb-overview/
[3]: https://www.influxdata.com/time-series-platform/telegraf/
[4]: https://grafana.com/grafana/download
[5]: https://github.com/fg2it/grafana-on-raspberry/releases

{% include "all-include.md" %}
