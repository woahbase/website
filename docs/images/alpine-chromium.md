---
description: MultiArch Alpine Linux + S6 + GNU LibC + Chromium Browser
alpine_branch: v3.23
arches: [aarch64, armv7l, x86_64]
has_services:
  - systemd
tags:
  - gui
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [Chromium][1] browser.

{{ m.srcimage('alpine-glibc') }} with the {{
m.alpinepkg('chromium') }} and {{
m.alpinepkg('chromium-chromedriver') }} packages installed in it.

{% include "pull-image.md" %}

---
Run
---

Run the browser with,

--8<-- "gui-xhost.md"

``` sh
docker run --rm -it \
  --cap-add=SYS_ADMIN \
  --name docker_chromium \
  --workdir /home/alpine \
  -e DISPLAY=unix:${DISPLAY:-0} \
  -e PULSE_SERVER=tcp:localhost:4713 \
  -v $PWD/data:/home/alpine \
  -v /dev/shm:/dev/shm \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /usr/share/fonts:/usr/share/fonts:ro \
  -v /var/run/dbus:/var/run/dbus \
woahbase/alpine-chromium \
  chromium-browser --no-sandbox
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                      | Default | Description
| :---                          | :---    | :---
| GID_AUDIO                     | unset   | Group-id of `audio` group on the host. If set, updates group-id of the group `audio` inside container, and adds `${S6_USER}` to the group.
| GID_PULSE                     | unset   | Group-id of `pulse` group on the host. If set, updates group-id of the group `pulse` inside container, and adds `${S6_USER}` to the group.
| GID_VIDEO                     | unset   | Group-id of `video` group on the host. If set, updates group-id of the group `video` inside container, and adds `${S6_USER}` to the group.
| CHROMIUM_SKIP_PERMFIX         | unset   | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `chromium` configuration/data files/directories. {{ m.sincev('138.0.7204.157') }}
| CHROMIUM_PERMFIX_DOWNLOADSDIR | unset   | If set to a **non-empty-string** value (e.g. `1`), ensures files inside `~/Downloads/` are owned/accessible by `${S6_USER}`. {{ m.sincev('138.0.7204.157') }}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Does **not** contain a X-server, so needs a host running its
  own X, with `/tmp/.X11-unix/` mounted and `${DISPLAY}` set inside
  the container.

* By default, runs with sandboxing disabled using the
  `--cap-add=SYS_ADMIN` and `--no-sandbox` flags. Optionally add
  `--net=host` if needed.

* To preserve data mount the `/home/alpine` dir in your local. By
  default mounts `${PWD}/data`.

* {{ m.customscript('p11-chromium-customize') }}

* By default directs audio to the pulseaudio server whether mounted
  locally from the host system with,
  ```
  --device /dev/snd \
  -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
  -v $HOME/.pulse-cookie:/home/alpine/.pulse-cookie \
  -v /run/user/1000/pulse:/run/user/1000/pulse \
  ```
  or a local/remote pulseaudio server (requires [anonymous network
  access][4] enabled),
  ```
  -e PULSE_SERVER=tcp:localhost:4713
  ```
  to use `/dev/snd` (or alsa directly), need to customize
  `/home/alpine/.asoundrc`.

* You can get JessFrazelle's seccomp `chrome.json` file from [here][2].
  Need to pass the flag `--security-opt seccomp=/path/to/chrome.json`
  to use it.

* See [this page][10] for an explanation of the differences
  between Chromium and Google Chrome.

* Check [here][3] for a reference of most of the
  command-line-switches that can be used to tune browser
  behaviour.

* Checkout the [docs][6] to get started with [ChromeDriver][5].

* By default, Chromium runs under the user `alpine`. If the
  container is running as an arbitrary user, you may need to use
  `with-contenv` so the environment variables are accessible to
  the user process.

[1]: https://www.chromium.org/
[2]: https://github.com/jessfraz/dotfiles/blob/master/etc/docker/seccomp/chrome.json
[3]: https://peter.sh/experiments/chromium-command-line-switches/
[4]: https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Network/
[5]: https://developer.chrome.com/docs/chromedriver
[6]: https://developer.chrome.com/docs/chromedriver/get-started
[7]: https://github.com/GoogleChrome/chrome-launcher
[8]: https://docs.docker.com/engine/security/apparmor/
[9]: https://discourse.ubuntu.com/t/mantic-minotaur-release-notes/35534#security-improvements
[10]: https://chromium.googlesource.com/chromium/src/+/master/docs/chromium_browser_vs_google_chrome.md

{% include "all-include.md" %}
