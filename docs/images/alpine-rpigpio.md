---
description: MultiArch Alpine Linux + S6 + Python3 + RPi.GPIO
skip_x86_64: 1
tags:
  - dev
  - shell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base image for applications
/ services running on Raspberrpi Pi(s) that require GPIO
access, using [RPi.GPIO][7] or serial access using
[PySerial][8], on [Python3][2] and [Pip][3] to manage
dependencies.

{{ m.srcimage('alpine-python3') }} with the packages {{
m.pypipkg('pyserial') }} and {{ m.pypipkg('RPi.GPIO')
}} and {{ m.alpinepkg('wiringpi') }} installed in it.

{% include "pull-image.md" %}

---
Run
---

We can call `gpio` commands directly on the container, or run `bash`
in the container to get a [user-scoped][114] shell,

=== "command"
    ``` sh
    docker run --rm -it \
      --name docker_rpigpio \
      --device /dev/gpiomem \
      --cap-add SYS_RAWIO \
      --device /dev/ttyAMA0:/dev/ttyAMA0 \
    woahbase/alpine-rpigpio \
      gpio -h
    ```
=== "shell"
    ``` sh
    docker run --rm -it \
      --name docker_rpigpio \
      --device /dev/gpiomem \
      --cap-add SYS_RAWIO \
      --device /dev/ttyAMA0:/dev/ttyAMA0 \
    woahbase/alpine-rpigpio \
      /bin/bash
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
| GID_TTY                  | unset        | Group-id of `tty` group on the host. If set, updates group-id of the group `tty` inside container, and adds `${S6_USER}` to the group.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

Flag `--privileged` is not usually required (unless your
usecase demands for it) for this image, you will still need to
pass

* `--device /dev/gpiochip0` (previously `/dev/gpiomem`), and
  `--cap-add SYS_RAWIO` to access the gpio.

* `--device /dev/ttyAMA0:/dev/ttyAMA0` for serial access.

[2]: https://www.python.org/
[3]: https://pypi.python.org/pypi/pip
[4]: https://pypi.python.org/pypi/RPi.GPIO
[5]: https://pypi.python.org/pypi/pyserial
[6]: https://pkgs.alpinelinux.org/packages?name=wiringpi
[7]: https://sourceforge.net/projects/raspberry-gpio-python/
[8]: https://github.com/pyserial/pyserial

{% include "all-include.md" %}
