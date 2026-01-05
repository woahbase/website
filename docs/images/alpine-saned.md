---
description: MultiArch Alpine Linux + S6 + SANE Scanner Daemon.
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

This [image][155] containerizes the [Sane][2] Scanner server to
control [supported][3] scanner devices connected to the host (or
in the local network) from any local or remote [supported
frontends][4].

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('sane', star=true)
}} packages installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_saned \
  --device /dev/bus/usb \
  -p 6566:6566/udp \
  -p 6566:6566/tcp \
  -p 10000-10100:10000-10100/udp \
woahbase/alpine-saned
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars              | Default                      | Description
| :---                  | :---                         | :---
| SANED_CONFDIR         | /etc/sane.d                  | (Preset) Path to directory for `saned` configuration files.
| SANED_DATADIR         | /data                        | (Optional) Path to data directory for e.g scanned images.
| GID_LP                | unset                        | Group-id of `lp` group on the host. If set, updates group-id of the group `lp` inside container.
| GID_SCANNER           | unset                        | Group-id of `scanner` group on the host. If set, updates group-id of the group `scanner` inside container.
| SANED_CONF_`filename` | unset                        | File to modify with contents as value. e.g for `pixma.conf` `SANED_CONF_pixma='bjnp-timeout=5000;mfnp://scanner.bad-network.org/timeout=1500'`. See [Modifying `conf` files](#modifying-conf-files)
| SANED_SKIP_PERMFIX    | unset                        | If set to a **non-empty-string** value (e.g. `1`), skips applying permission fixes to `${SANED_CONFDIR}` and `${SANED_DATADIR}`.
| SANED_PORT            | 6566                         | Control Port of `saned` service.
| SANED_ARGS            | -l -b 0.0.0.0 -p ${SANED_PORT} | Customizable arguments passed to `saned` service.

Also,

* {{ m.defcfgfile('/etc/sane.d', plural=true,
  vname='SANED_CONFDIR') }} Reference docs can be found
  [here][1].

* Default configuration listens to `tcp` port `6566` for control
  and `udp` `10000-10100` for data connections , make sure the
  ports are accessible in the firewall configurations.

* Make sure to mount the proper devices (e.g. `/dev/bus/usb/001`
  for USB scanners or `/dev/scanner0`) in the container so that
  `saned` can access the scanner device. (Or you could mount the
  whole `/dev/bus/usb`.) The service drops privileges to
  `${S6_USER}` which should have the appropriate groups to allow
  reading from the scanner device.

??? info "Did you know?"
    To check what devices are available on the host, we could just
    get a [debug shell](#shell-access) into the container and run
    either
    ```
    sane-find-scanner -v
    ```
    or
    ```
    scanimage -L
    ```

---
##### Modifying `conf` Files
---

We can modify any of the configuration files in `SANED_CONFDIR` by
setting the `SANED_CONF_filename` environment variable with the
filename to modify and the content as the lines we need to append
(or remove). E.g. to add `/dev/scanner0` (and remove the default
`/dev/scanner` device) in `abaton.conf`, we can set
```
SANED_CONF_abaton="--/dev/scanner;/dev/scanner0"
```

Some files may also have a toml-like configuration format, in that
case we may need to modify the line after a specific parent
heading. E.g. to add a scanner device in `airscan.conf` under
`[devices]`, then modify a couple options and remove a blacklist
parameter,
```
SANED_CONF_airscan="devices=>\"Kyocera MFP Scanner\" = http://192.168.1.102:9095/eSCL;options=>discovery = enable;options=>model = network;blacklist=>--model = \"Xerox*\""
```

A few other variables control how the modifications happen, like

| ENV Vars               | Default       | Description
| :---                   | :---          | :---
| SANED_LINE_DELIMITER   | `;`           | Default delimiter to split lines in multiline configurations provided via environment variables. Cannot be `space` since a files (like `airscan.conf`) may contain lines with spaces.
| SANED_INS_DELIMITER    | `=>`          | Default delimiter to separate parent heading and configuration line in configurations provided via environment variables.
| SANED_DEL_INDICATOR    | `--`          | Default indicator to delete matching configuration line in file in configurations provided via environment variables.
| SANED_TRIM_CONFLINE    | unset         | If set, trims the leading and trailing spaces from configuration lines.

[1]: https://linux.die.net/man/7/sane
[2]: http://www.sane-project.org/
[3]: http://www.sane-project.org/sane-supported-devices.html
[4]: http://www.sane-project.org/sane-frontends.html

{% include "all-include.md" %}
