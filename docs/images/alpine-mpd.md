---
description: MultiArch Alpine Linux + S6 + Music Player Daemon + yMPD WebUI
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, i386, ppc64le, riscv64, s390x, x86_64]
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - service

s6_user: mpd
s6_userhome: /var/lib/mpd

---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [Music Player Daemon][1] to
setup a centralized network-controlled local music playing service.
Compatible with [ALSA][2] but defaults to [PulseAudio][3] server
running either on the host machine, or remotely somewhere in the
local network. Also includes [yMPD][4] for managing music via the
browser, or via CLI using [ncmpcpp][5] and [Last.fm][7] scrobbling
via [mpdscribble][6].

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('mpd') }},
{{ m.alpinepkg('ncmpcpp') }}, {{ m.alpinepkg('ympd') }} and
{{ m.alpinepkg('mpdscribble') }} package(s) installed in it.

{% include "pull-image.md" %}

---
Run
---

Run the `mpd` service using a pulseaudio service running locally,
or on a remote host, with

=== "local"

    If you're running the pulseaudio server on the host system, you
    can use the pulse server directly by mounting it inside the
    container

    ``` sh
    docker run --rm \
      --cap-add=SYS_NICE \
      --name docker_mpd \
      -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
      -p 6600:6600 \
      -p 8000:8000 \
      -p 64801:64801 \
      -v $HOME/.pulse-cookie:/home/mpd/.pulse-cookie
      -v /dev/shm:/dev/shm \
      -v /run/user/${PUID:-1000}/pulse:/run/user/1000/pulse \
      -v $PWD/data:/var/lib/mpd \
      -v $PWD/music:/music \
    woahbase/alpine-mpd
    ```

=== "remote"

    To use a remote pulseaudio standalone server running on
    a different device. (checkout {{ m.myimage('alpine-pulseaudio') }}
    to run PulseAudio as a service)

    ``` sh
    docker run --rm \
      --cap-add=SYS_NICE \
      --name docker_mpd \
      -e PULSE_SERVER=tcp:localhost:4713 \
      -p 6600:6600 \
      -p 8000:8000 \
      -p 64801:64801 \
      -v $PWD/data:/var/lib/mpd \
      -v $PWD/music:/music \
    woahbase/alpine-mpd
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars              | Default                       | Description
| :---                  | :---                          | :---
| MPD_CONF              | /etc/mpd.conf                 | Path to configuration file. {{ m.sincev('0.23.15') }}
| MPD_HOME              | /var/lib/mpd                  | Directory for database, playlists, state etc. {{ m.sincev('0.23.15') }}
| MPD_LOGS              | /var/log/mpd                  | Directory for logs, if not logging to `stdout`. {{ m.sincev('0.24.4') }}
| MPD_GROUP             | mpd                           | Primary group for `mpd` user, updated in configuration file when using the default configurations (not used by default). {{ m.sincev('0.24.4') }}
| MPD_SKIP_PERMFIX      | unset                         | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `mpd` configuration files/directories. {{ m.sincev('0.24.4') }}
| MPD_PERMFIX_MUSIC_DIR | unset                         | If set to a **non-empty-string** value (e.g. `1`), ensures files inside `${MUSIC_DIR}` are owned/accessible by `${S6_USER}`. {{ m.sincev('0.24.4') }}
| MPD_ARGS              | --stdout                      | Customizable arguments passed to `mpd` service.
| YMPD_ARGS             | -h localhost -p 6600 -w 64801 | Customizable arguments passed to `ympd` service.
| MPDSCRIBBLE_CONF      | /etc/mpdscribble.conf         | Path to `mpdscribble` configuration file. Must exist for service to start. {{ m.sincev('0.23.15') }}
| MPDSCRIBBLE_ARGS      | --host localhost --port 6600  | Customizable arguments passed to `mpdscribble` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/etc/mpd.conf', fr='`mpd`', vname='MPD_CONF') }}

* Data stored at `/var/lib/mpd`.

* Mount the music root dir at `/music`.

* Mount playlists at `/var/lib/mpd/playlists`.

* Default configuration listens to ports `6600` and the default
  audiostream port is `8000`, with the `ympd` webui running on
  port `64801`.

* Default directs audio to the pulseaudio server whether mounted
  locally from the host system with,
  ```
  --device /dev/snd \
  -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
  -v $HOME/.pulse-cookie:/home/alpine/.pulse-cookie \
  -v /run/user/1000/pulse:/run/user/1000/pulse \
  ```
  or a local/remote pulseaudio server (requires [anonymous network
  access][8] enabled),
  ```
  -e PULSE_SERVER=tcp:localhost:4713
  ```
  to use `/dev/snd` (or alsa directly), need to customize
  `/etc/asound.conf` as well as enable the ALSA output in
  `/etc/mpd.conf.

* `mpdscribble` is only run when configuration file is available
  at `/etc/mpdscribble.conf`.

[1]: https://www.musicpd.org/
[2]: https://www.alsa-project.org/
[3]: https://www.freedesktop.org/wiki/Software/PulseAudio/
[4]: https://github.com/notandy/ympd
[5]: https://github.com/arybczak/ncmpcpp
[6]: https://www.musicpd.org/clients/mpdscribble/
[7]: https://www.last.fm/
[8]: https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Network/

{% include "all-include.md" %}
