---
description: MultiArch Alpine Linux + S6 + Transmission Daemon (and CLI)
svcname: transmission
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - compose
  - nomad
  - package
  - proxy
  - s6
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [Transmission][1] daemon with
the WebUI running on port 9091.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('transmission-daemon') }}
(and {{ m.alpinepkg('transmission-cli') }}) packages installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_transmission \
  -p 52437:52437/tcp \
  -p 52437:52437/udp \
  -p 9091:9091 \
  -v $PWD/config:/var/lib/transmission/config \
  -v $PWD/downloads:/var/lib/transmission/downloads \
  -v $PWD/watched:/var/lib/transmission/torrents \
woahbase/alpine-transmission
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                   | Default                                     | Description
| :---                       | :---                                        | :---
| TRANSMISSION_ROOTDIR       | /var/lib/transmission                       | (Preset) Default application directory. {{ m.sincev('4.0.5_20240905') }}
| TRANSMISSION_CONFDIR       | $TRANSMISSION_ROOTDIR/config                | Default configuration directory. {{ m.sincev('4.0.5_20240905') }}
| TRANSMISSION_DOWNLOADDIR   | $TRANSMISSION_ROOTDIR/downloads             | Default download directory. Only set if custom `settings.json` does not exist. {{ m.sincev('4.0.5_20240905') }}
| TRANSMISSION_INCOMPLETEDIR | $TRANSMISSION_ROOTDIR/incomplete            | Default directory for running downloads. Only set if custom `settings.json` does not exist. {{ m.sincev('4.0.5_20240905') }}
| TRANSMISSION_WATCHDIR      | $TRANSMISSION_ROOTDIR/torrents              | Default directory for watching torrents to add. Only set if custom `settings.json` does not exist. (not to be confused with currently running torrents in `$TRANSMISSION_CONFDIR/torrents`) {{ m.sincev('4.0.5_20240905') }}
| TRANSMISSION_ARGS          | --foreground --no-portmap --log-level=error | Customizable arguments passed to `transmission-daemon` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Config file is at `/var/lib/transmission/config/settings.json`,
  edit or remount this file with your own. A {{ m.ghfilelink('root/defaults/settings.json', title='sample') }}
  is provided in `/defaults/`, that gets copied if none exists.

* Default configuration makes the service available at the subpath
  `/transmission/`.

* Default configuration listens to ports `9091` for the web-ui and
  `52437` for peer communications. These may need to be
  whitelisted in your firewall.

* Includes optional scripts to send notifications when torrents are
  {{ m.ghfilelink('root/scripts/torrent-added.bash', title='added') }},
  then {{ m.ghfilelink('root/scripts/torrent-done.bash', title='done downloading') }},
  and {{ m.ghfilelink('root/scripts/torrent-done-seeding.bash', title='done seeding') }}.
  By default uses [Gotify][2] to send notifications, feel free to replace the
  {{ m.ghfilelink('root/scripts/notify.bash', title='notifier script') }}
  with your own. {{ m.sincev('4.0.5_20240905') }}

[1]: http://transmissionbt.com/
[2]: https://gotify.net/

{% include "all-include.md" %}
