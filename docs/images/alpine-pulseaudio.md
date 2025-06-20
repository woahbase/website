---
description: Container for Alpine Linux + S6 + PulseAudio + Bluez
tags:
  - legacy
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [PulseAudio][1] Network
Sound server to setup a central sound service inside a local
network, also runs the [Bluez][2] bluetooth daemon to work with
bluetooth speakers or sources. Includes [Pulsemixer][3] to
manage pulseaudio from CLI.

{{ m.srcimage('alpine-s6') }} with the {{
m.alpinepkg('pulseaudio') }} package installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm -it \
  --name docker_pulseaudio \
  -p 4713:4713 \
  --net=host \
  --cap-add NET_ADMIN \
  --device /dev/snd \
  --device /dev/bus/usb \
  -v $PWD/config/pulse:/etc/pulse \
  -v /var/run/dbus:/var/run/dbus \
  -v /etc/localtime:/etc/localtime:ro \
woahbase/alpine-pulseaudio:x86_64
```

--8<-- "multiarch.md"

---
##### Configuration
---

* This image runs PulseAudio under the user `root`, but also has
  a user `pulse` configured to drop privileges to the passed
  `PUID`/`PGID` which is ideal if its used to run in non-root
  mode.  That way you only need to specify the values at runtime
  and pass the `-u pulse` if need be. (run `id` in your terminal
  to see your own `PUID`/`PGID` values.)

* PulseAudio config files read from `/etc/pulse`. If you have
  custom cards other than your default sound output jack, most
  likely you will need to edit or remount this with your own. For
  example, you can keep the files inside `config/pulse` and mount
  it as `/etc/pulse` on start.

* Does not run own systemd or dbus daemon so cards might not get
  detected automatically, default configuration loads only the
  defauls Alsa Sink, so will need to modify configurations to
  detect the new hardware.

* Default configuration listens to port `4713`. Will need to have
  this port accessible from add devices to get sound. (Check your
  firewall).

* Bluetooth configurations read from `/etc/bluetooth`.

* To persist paired bluetooth configurations, preserve the
  contents of `/var/lib/bluetooth` by mounting it someplace like
  `config/devices`.

* DBUS can cause permission issues if the host is not configured to
  allow Bluez or PulseAudio. **Host** configuration defaults for these
  are provided inside `/config/dbus`.

* Any drivers for audio (and/or bluetooth as in Rasperry Pis) will
  need to be installed in the host machine.

* Don't forget to set the environment variable `PULSE_SERVER` as
  your server host in the client machines so that they forward
  their sound to the server. Check out [this][4] link for more
  information.

* To run only the pulseaudio server without starting bluetooth,
  set the environment variable `DISABLEBLUETOOTH` to the string
  `true`.

[1]: https://www.freedesktop.org/wiki/Software/PulseAudio/
[2]: http://www.bluez.org/
[3]: https://github.com/GeorgeFilipkin/pulsemixer
[4]: https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Network/

{% include "all-include.md" %}
