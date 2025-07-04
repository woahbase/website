---
description: MultiArch Alpine Linux + S6 + Trivial FTP(-hpa) Daemon
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, i386, ppc64le, riscv64, s390x, x86_64]
has_services:
  - compose
  - nomad
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [Trivial FTP][1] daemon, providing
a primitive but reliable file-access service intended to
network-boot (or PXE) hosts. Checkout {{ m.myimage('alpine-nfs')
}} for post-boot rootfs-serving needs.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('tftp-hpa')
}} package installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_tftp \
  -p 69:69/udp \
  -p 63050-63100/udp \
  -v $PWD/data:/data \
woahbase/alpine-tftp
```
--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars       | Default               | Description
| :---           | :---                  | :---
| TFTP_ROOT      | /data                 | Path to storage directory.
| TFTP_ADDR      | 0.0.0.0               | Default address to listen to. {{ m.sincev('5.2_20250630') }}
| TFTP_PORT      | 69                    | Default port to listen to. {{ m.sincev('5.2_20250630') }}
| TFTP_PORTRANGE | 63050:63100           | Default port range for file transfers. {{ m.sincev('5.2_20250630') }}
| TFTP_USER      | ${S6_USER}            | When `tftp` is started as root user, it drops privileges to this user for file transfers. The user must exist, defaults to `alpine`, can also be set to `nobody`. {{ m.sincev('5.2_20250630') }}
| TFTPD_ARGS     | --secure ${TFTP_ROOT} | Customizable arguments passed to `in.tftp` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Recommended to use a remap-file to add further safety. E.g.
  ```
  rg \\ /      # Convert backslashes to slashes
  r ^[^/] /\0  # Convert non-absolute files
  a ^/private/ # Reject requests for private dir
  a \.pvt$     # Reject requests for private files
  e ^/public/  # Allow access to  public files
  # Add the remote IP address as a folder on the front of all requests.
  # Essentially puts every request under its own IP jail. This way,
  #  Any host can have its own fileset in its own directory by its IP, referenced by /
  #  Only provisioned hosts can boot, other hosts unaffected
  #  HostA cannot get HostB files
  r ^ \i/
  ```

* Checkout the [docs][2] to customize your own.

[1]: https://git.kernel.org/pub/scm/network/tftp/tftp-hpa.git
[2]: https://linux.die.net/man/8/in.tftpd

{% include "all-include.md" %}
