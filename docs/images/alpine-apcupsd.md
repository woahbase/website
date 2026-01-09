---
description: MultiArch Alpine Linux + S6 + APC-UPS Daemon
alpine_branch: v3.23
arches: [aarch64, armhf, armv7l, i386, ppc64le, riscv64, s390x, x86_64]
has_services:
  - compose
  - nomad
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [APCUPSd][2] server to
control APC UPS devices connected via USB or serial port.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('apcupsd')
}} package installed in it. Uses {{ m.alpinepkg('lighttpd') }} to
run the (optional) web-ui provided by {{ m.alpinepkg('apcupsd-webif') }}.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_apcupsd \
  --device /dev/usb/hiddev0 \
  -p 3551:3551/udp \
  -p 3551:3551/tcp \
  -p 80:80 \
woahbase/alpine-apcupsd
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars              | Default                        | Description
| :---                  | :---                           | :---
| APCUPSD_CONFDIR       | /etc/apcupsd                   | (Preset) Path to `apcupsd` configuration files.
| APCUPSD__(parameter)  | unset                          | If set, will update the parameter (if exists) with the value in `apcupsd.conf`. E.g. `APCUPSD__UPSCABLE=usb`. (Note the **double** underscores.)
| APCUPSD_ARGS          | -b --debug 1                   | Customizable arguments passed to `apcupsd` service.
| APCUPSD_HEADLESS      | unset                          | Set to `true` to only start `apcupsd` service, and skip `lighttpd`.
| LIGHTTPD_CONFDIR      | /etc/lighttpd                  | Path to `lighttpd` configuration directory.
| LIGHTTPD_LOGFILE      | /var/log/lighttpd/lighttpd.log | Logfile for `lighttpd`, by default logs both access and error logs.
| LIGHTTPD_USER         | lighttpd                       | Non-root user that `lighttpd` drops privileges to.
| LIGHTTPD_ARGS         | -D                             | Customizable arguments passed to `lighttpd` service.
| LIGHTTPD_SKIP_LOGFIFO | unset                          | By default `lighttpd` logs to `stdout` via a `fifo`, set this to `true` to log to a regular file instead.

Also,

* Default configuration listens to port `3551` and `80` for the
  web-ui, make sure the port is accessible in the firewall
  configurations.

* APCUPSd is available on the subpath `/apcupsd/` of the web-ui.

* Make sure to mount the proper USB device (e.g.
  `/dev/usb/hiddev0`) in the container so that `apcupsd` can
  access the UPS. (Or you could mount the whole `/dev/usb`.)

* Optionally, mount your custom configuration at
  `/etc/apcupsd/apcupsd.conf`. Reference docs can be found
  [here][1].

???+ info "Did you know?"
    To check what data is available from the UPS, we could just
    get a debug shell into the container and run `apcaccess`.

[1]: https://linux.die.net/man/5/apcupsd.conf
[2]: http://www.apcupsd.org/

{% include "all-include.md" %}
