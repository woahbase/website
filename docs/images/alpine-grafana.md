---
description: MultiArch Alpine Linux + S6 + Grafana
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, x86_64]
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

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars              | Default                            | Description
| :---                  | :---                               | :---
| GRAFANA_HOME          | /var/lib/grafana                   | (Preset) Path to `grafana` home directory.
| GF_PATHS_CONFIG       | /var/lib/grafana/conf/defaults.ini | Path to configuration file.
| GF_PATHS_DATA         | /var/lib/grafana/data              | Path to data directory.
| GF_PATHS_HOME         | ${GRAFANA_HOME}                    | Path to `grafana` home directory. (Passed as arguments to the service process)
| GF_PATHS_LOGS         | /var/lib/grafana/logs              | Path where logs are stored.
| GF_PATHS_PLUGINS      | /var/lib/grafana/plugins           | Path to plugins directory.
| GF_PATHS_PROVISIONING | /var/lib/grafana/provisioning      | Path where provisioning configuration should exist.
| GF_INSTALL_PLUGINS    | empty string                       | **Comma**-separated list of plugins (or urls) to install before running server.
| GF_UPDATE_PLUGINS     | unset                              | Set to `true` to run plugin-update (uses `grafana cli`).
| GF_LOG_MODE           | console                            | Default log mode, can be `console` or `file`.
| GRAFANA_SKIP_PERMFIX  | unset                              | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `grafana` configuration/data files/directories. {{ m.sincev('12.1.0') }}
| GRAFANA_ARGS          | see below                          | Customizable arguments passed to `grafana server` service. (Overrides default arguments)
| GRAFANA_ARGS_EXTRA    | empty string                       | Customizable extra arguments passed to `grafana server` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/var/lib/grafana/conf/defaults.ini', vname='GF_PATHS_CONFIG') }}

* By default `grafana server` is run with the following arguments,
    ```
    cfg:default.log.mode=${GF_LOG_MODE} \
    cfg:default.paths.data=${GF_PATHS_DATA} \
    cfg:default.paths.logs=${GF_PATHS_LOGS} \
    cfg:default.paths.plugins=${GF_PATHS_PLUGINS} \
    cfg:default.paths.provisioning=${GF_PATHS_PROVISIONING}
    ```
  So that customized paths get used instead of the defaults in
  configuration. Override the `${GRAFANA_ARGS}` environment variable
  to customize these, or add extra args in `${GRAFANA_ARGS_EXTRA}` as
  needed.

[1]: https://grafana.com
[2]: https://www.influxdata.com/products/influxdb-overview/
[3]: https://www.influxdata.com/time-series-platform/telegraf/
[4]: https://grafana.com/grafana/download
[5]: https://github.com/fg2it/grafana-on-raspberry/releases
[6]: https://github.com/grafana/grafana/blob/main/Dockerfile

{% include "all-include.md" %}
