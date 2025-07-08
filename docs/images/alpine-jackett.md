---
description: MultiArch Alpine Linux + S6 + Jackett
alpine_branch: v3.22
arches: [aarch64, armv7l, x86_64]
has_services:
  - compose
  - nomad
  - systemd
has_proxies:
  - nginx
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [Jackett][1] API service to to
search/scrape/track torrent (magnet and/or file) links from
a multitude of [supported tracker][4] sites as requested by quite
a few supported apps.

{{ m.srcimage('alpine-s6') }} with the [jackett][1] `musl` binaries
installed in it. {{ m.ghreleasestr('Jackett/Jackett') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_jackett \
  -p 9117:9117 \
  -v $PWD/config:/config \
  -v $PWD/torrents:/torrents \
woahbase/alpine-jackett
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars             | Default                 | Description
| :---                 | :---                    | :---
| XDG_CONFIG_HOME      | /config                 | (Preset) Configuration directory for `jackett`.
| XDG_DATA_HOME        | /config                 | (Preset) Data directory for `jackett`.
| TORRENTSDIR          | /config/torrents        | (Optional) `BlackholeDir` directory for `jackett`. {{ m.sincev('0.22.2111') }}, previously `/torrents`.
| JACKETT_LN_LOGTXT    | unset                   | If set to `true`, links the logfile `XDG_CONFIG_HOME/Jackett/log.txt` to a different device (or file) mostly to suppress the output, or optionally redirect it. When `false`, removes the link if it exists.
| JACKETT_LN_LOGDST    | /dev/null               | Links the logfile to this device (or file) when `JACKETT_LN_LOGTXT` is `true`.
| JACKETT_SKIP_PERMFIX | unset                   | If set to a **non-empty-string** value (e.g. `1`), skips applying permission fixes to `${XDG_CONFIG_HOME}` and `${TORRENTSDIR}`.
| JACKETT_EXEC         | jackett                 | Customizable executable passed to `jackett` service. Can also be `jackett_launcher.sh` if needed.
| JACKETT_ARGS         | --NoRestart --NoUpdates | Customizable arguments passed to `jackett` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* We can set the `BasePathOverride` to `/jackett` (in
  `${XDG_CONFIG_HOME}/Jackett/ServerConfig.json`) so it plays well
  with already existing reverse-proxy domain configurations
  without the need to setup another subdomain and separate (or
  wildcard) set of certificates.

* Optionally if your downloader has `watch-dir` capability, we can
  set the `BlackholeDir` to the `${TORRENTSDIR}` directory, then
  sharing this directory between the two allows for automatic
  pickup of magnet links by the downloader when it is saved in
  this directory by `jackett`.

* Check the [API][3] for query syntax for custom tracker
  applications.

* Check their [wiki][2] for customizing your own.

* To use `transmission` as your downloader, check the {{
  m.myimage('alpine-transmission') }} image.

[1]: https://github.com/Jackett/Jackett
[2]: https://github.com/Jackett/Jackett/wiki
[3]: https://github.com/Jackett/Jackett/wiki/Jackett-API
[4]: https://github.com/Jackett/Jackett#supported-trackers
[5]: https://github.com/linuxserver/docker-jackett

{% include "all-include.md" %}
