---
description: MultiArch Alpine Linux + S6 + LibCEC + PyCEC
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, x86_64]
has_services:
  - compose
  - nomad
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [LibCEC][1] client binaries to
control supported TV/displays (connected via HDMI) using the
[CLI][3] or remotely via telnet with [PyCEC][4].

{{ m.srcimage('alpine-s6') }} with the compiled [platform][7] and
[LibCEC][2] binaries and the packages {{ m.pypipkg('PyCEC') }} and
{{ m.alpinepkg('v4l-utils') }} installed in it.
{{ m.ghreleasestr('Pulse-Eight/libcec') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_cec \
  --device /dev/cec0 \
  -e GID_DIALOUT=994 `#(1)` \
  -e GID_VIDEO=995 `#(2)` \
  -p 9526:9526 \
woahbase/alpine-cec
```

1. (Optional) Set GID_DIALOUT to the GID of the group `dialout` on the host, to allow processes
    running inside docker (as user `alpine`) access to cec-enabled
    devices. To find yours, run
    ```
    getent group dialout | awk -F ":" '{ print $3 }'
    ```

2. Set GID_VIDEO to the GID of the group `video` on the host, to allow processes
    running inside docker (as user `alpine`) access to cec-enabled
    devices. To find yours, run
    ```
    getent group video | awk -F ":" '{ print $3 }'
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                 | Default      | Description
| :---                     | :---         | :---
| GID_DIALOUT              | unset        | Group-id of `dialout` group on the host. If set, updates group-id of the group `dialout` inside container, and adds `${S6_USER}` to the group.
| GID_VIDEO                | unset        | Group-id of `video` group on the host. If set, updates group-id of the group `video` inside container, and adds `${S6_USER}` to the group.
| PYCEC_HOST               | 0.0.0.0      | Host address for `pycec` service to listen on.
| PYCEC_PORT               | 9526         | Port for `pycec` service.
| PYCEC_ARGS               | -i ${PYCEC_HOST} -p ${PYCEC_PORT} | Customizable arguments passed to `pycec` service.
| WAIT_FOR_HDMI_CONNECT    | unset        | If set to `true`, will wait for HDMI connection to become available, before starting `pycec` service.
| WAIT_SEC                 | 10           | Poll interval for checking if HDMI is connected.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* For example, to scan the CEC bus to figure connected device
  addresses (running on a Raspberry Pi, requires
  a [user-scoped shell](#shell-access) inside the container)
  ``` sh
  echo "scan" | cec-client RPI -s -d 1
  ```
  Control TV power on/off locally with,
  ``` sh
  # power on
  echo "on 0" | cec-client RPI -s -d 1
  # or
  echo "tx 10:04" | cec-client RPI -s -d 4

  # power off
  echo "standby 0" | cec-client RPI -s -d 1
  # or
  echo "tx 10:36" | cec-client RPI -s -d 4
  ```
  Or remotely via telnet using `nc`,
  ``` sh
  # power on
  echo -e "10:04" | nc -w1 -i1 cec-host.local 9526

  # power off
  echo -e "10:36" | nc -w1 -i1 cec-host.local 9526
  ```

* Check this [link][5] or this [link][8] for more reference
  commands, or depending on what features are supported on your
  TV, find/decode your own with [cec-o-matic][6].

[1]: http://libcec.pulse-eight.com/
[2]: https://github.com/Pulse-Eight/libcec
[3]: https://manpages.debian.org/testing/cec-utils/cec-client.1.en.html
[4]: https://github.com/konikvranik/pyCEC
[5]: https://justaddpower.happyfox.com/kb/article/68-cec-over-ip-control/
[6]: https://www.cec-o-matic.com/
[7]: https://github.com/Pulse-Eight/platform
[8]: https://blog.gordonturner.com/2016/12/14/using-cec-client-on-a-raspberry-pi/
[9]: https://docs.kernel.org/admin-guide/media/cec.html

{% include "all-include.md" %}
