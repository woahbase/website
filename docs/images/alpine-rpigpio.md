---
description: Container for Alpine Linux + S6 + Python3 + RPi.GPIO
svcname: rpigpio
skip_x86_64: 1
tags:
  - legacy
  - dev
  - python
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
m.pypipkg('pyserial') }} and {{ m.pypipkg('RPi.GPIO') }}
and {{ m.pypipkg('wiringpi') }} installed in it.

{% include "pull-image.md" %}

---
Run
---

Run `bash` in the container to get a shell.

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

Although `--privileged` is not usually required (unless your
usecase demands it) for this image, you will still need to pass

* `--device /dev/gpiomem`, and `--cap-add SYS_RAWIO` to access the gpio.

* `--device /dev/ttyAMA0:/dev/ttyAMA0` for serial access.

[2]: https://www.python.org/
[3]: https://pypi.python.org/pypi/pip
[4]: https://pypi.python.org/pypi/RPi.GPIO
[5]: https://pypi.python.org/pypi/pyserial
[6]: https://pkgs.alpinelinux.org/packages?name=wiringpi
[7]: https://sourceforge.net/projects/raspberry-gpio-python/
[8]: https://github.com/pyserial/pyserial

{% include "all-include.md" %}
