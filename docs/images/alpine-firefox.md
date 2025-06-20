---
description: MultiArch Alpine Linux + S6 + GNU LibC + Firefox Browser
skip_armhf: 1
has_services:
  - systemd
tags:
  - gui
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [Firefox][1] browser.

{{ m.srcimage('alpine-glibc') }} with the {{
m.alpinepkg('firefox') }} package and [GeckoDriver][3] binaries
(from preferably {{ m.ghreleaselink('mozilla/geckodriver') }} or
{{ m.ghreleaselink('jamesmortensen/geckodriver-arm-binaries') }})
installed in it.

{% include "pull-image.md" %}

    **ESR** Tags:

    * **x86_64_esr** The extended support release version (retagged as `latest_esr`, **no updates**)
    * **x86_64_esr_52** Firefox 52 (retagged as `latest_esr_52`, **no updates**)

---
Run
---

Run the browser with,

--8<-- "gui-xhost.md"

``` sh
docker run --rm -it \
  --name docker_firefox \
  --workdir /home/alpine \
  -e DISPLAY=unix:${DISPLAY:-0} \
  -e PULSE_SERVER=tcp:localhost:4713 \
  -v $PWD/data:/home/alpine \
  -v /dev/shm:/dev/shm \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /usr/share/fonts:/usr/share/fonts:ro \
  -v /var/run/dbus:/var/run/dbus \
woahbase/alpine-firefox \
  firefox
```

--8<-- "multiarch.md"

---
#### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                 | Default      | Description
| :---                     | :---         | :---
| GID_AUDIO                | unset        | Group-id of `audio` group on the host. If set, updates group-id of the group `audio` inside container, and adds `S6_USER` to the group.
| GID_PULSE                | unset        | Group-id of `pulse` group on the host. If set, updates group-id of the group `pulse` inside container, and adds `S6_USER` to the group.
| GID_VIDEO                | unset        | Group-id of `video` group on the host. If set, updates group-id of the group `video` inside container, and adds `S6_USER` to the group.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Does **not** contain a X-server, so needs a host running its
  own X, with `/tmp/.X11-unix/` mounted and `$DISPLAY` set inside
  the container.

* Optionally may require `--cap-add=SYS_ADMIN` and `--net=host`.

* To preserve data mount the `/home/alpine` dir in your local. By
  default mounts `$PWD/data`.

* {{ m.customscript('p11-firefox-customize') }}

* By default directs audio to the pulseaudio server whether mounted
  locally from the host system with,
  ```
  --device /dev/snd \
  -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
  -v $HOME/.pulse-cookie:/home/alpine/.pulse-cookie \
  -v /run/user/1000/pulse:/run/user/1000/pulse \
  ```
  or a local/remote pulseaudio server (requires [anonymous network
  access][2] enabled),
  ```
  -e PULSE_SERVER=tcp:localhost:4713
  ```
  to use `/dev/snd` (or alsa directly), need to customize
  `/home/alpine/.asoundrc`.

* Checkout the [docs][5] to get started with [GeckoDriver][3].
  (Check the [support][4] page for testing dependencies or
  capabilities configuration)

[1]: https://www.mozilla.org/en-US/firefox/
[2]: https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Network/
[3]: https://firefox-source-docs.mozilla.org/testing/geckodriver/index.html
[4]: https://firefox-source-docs.mozilla.org/testing/geckodriver/Support.html
[5]: https://firefox-source-docs.mozilla.org/testing/geckodriver/Usage.html
[6]: https://github.com/mozilla/geckodriver
[7]: https://github.com/jamesmortensen/geckodriver-arm-binaries
[8]: https://github.com/jlesage/docker-firefox/tree/master

{% include "all-include.md" %}
