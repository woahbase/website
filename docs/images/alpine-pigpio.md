---
description: MultiArch Alpine Linux + S6 + PiGPIO Daemon
svcname: pigpio
skip_x86_64: 1
has_services:
  - compose
  - nomad
tags:
  - compose
  - github
  - nomad
  - s6
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [PiGPIO][1] daemon to remotely
control the GPIO pins on a Raspberrpi Pi.

{{ m.srcimage('alpine-s6') }} with the `pigpiod` binary (compiled
from [joan2937][2]'s project) included in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_pigpio \
  --device /dev/gpiochip0 \
  -p 8888:8888 \
  --privileged \
woahbase/alpine-pigpio
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars    | Default | Description
| :---        | :---    | :---
| PIGPIO_PORT | 8888    | Port the `pigpiod` service listens on.
| PIGPIO_ARGS | -g      | Customizable arguments passed to `pigpiod` service.

Also,

* Although `--privileged` is not usually required (unless your
  usecase demands it) for this image, to access the GPIO, you may
  still need to pass

    * `--device /dev/gpiochip0`
    * `--cap-add SYS_RAWIO`

* Includes a {{ m.ghfilelink('root/etc/s6-overlay/s6-rc.d/p10-pigpio-setup/run', title='placeholder') }}
  script for further customizations. Override the shell script
  located at `/etc/s6-overlay/s6-rc.d/p10-pigpio-setup/run`
  with your custom pre-tasks as needed.

[1]: https://abyz.me.uk/rpi/pigpio/
[2]: https://github.com/joan2937/pigpio/
[3]: https://github.com/zinen/docker-alpine-pigpiod/

{% include "all-include.md" %}
