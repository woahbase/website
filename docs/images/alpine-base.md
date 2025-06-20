---
description: MultiArch Base Image for Alpine Linux
svcname: base
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, i386, loong64, ppc64le, riscv64, s390x, x86_64]
tags:
  - base
  - shell
---

{% include "shields.md" %}

This [image][155] serves as a base rootfs container for [Alpine Linux][113],
built from scratch using the minirootfs image from [here][1].
Intended to be used as a clean starter image for other containers,
or to get a quick shell for testing stuff in isolation. Updated as
per the [latest stable][2] releases, versioned according to the
same.

{% include "pull-image.md" %}

---
Run
---

Run `bash` in the container to get a shell.

``` sh
docker run --rm -it --name docker_base --entrypoint /bin/bash woahbase/alpine-base
```
--8<-- "multiarch.md"

[1]: https://dl-cdn.alpinelinux.org/alpine/
[2]: https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/
[3]: https://github.com/alpinelinux/docker-alpine

{% include "all-include.md" %}
