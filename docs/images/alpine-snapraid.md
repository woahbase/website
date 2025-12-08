---
description: MultiArch Alpine Linux + S6 + SnapRAID
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, i386, ppc64le, riscv64, s390x, x86_64]
tags:
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [SnapRAID][1] to setup
a just-works-yet-configurable software-RAID between a bunch of
disks, especially useful for datasets/files that seldom change
(e.g. home media storage).

{{ m.srcimage('alpine-s6') }} with the compiled [snapraid][3]
binaries installed in it. Also includes {{
m.alpinepkg('smartmontools') }}. {{
m.ghreleasestr('amadvance/snapraid') }}

{% include "pull-image.md" %}

---
Run
---

We can call `snapraid` directly on the container, or run `bash` in the container to get a [user-scoped][114] shell,

=== "command"
    ``` sh
    docker run --rm -it \
      --name docker_snapraid \
      --device /dev/disk \
      --privileged \
      -v $PWD/config:/etc/snapraid \
      -v $PWD/content:/var/snapraid \
      -v /mnt:/mnt \
    woahbase/alpine-snapraid \
      snapraid status
    ```
=== "shell"
    ``` sh
    docker run --rm -it \
      --name docker_snapraid \
      --device /dev/disk \
      --privileged \
      -v $PWD/config:/etc/snapraid \
      -v $PWD/content:/var/snapraid \
      -v /mnt:/mnt \
    woahbase/alpine-snapraid \
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
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* By default, the container expects

    * Data and parity stores under `/mnt` e.g. for
      n-data + m-parity disks `/mnt/data/disk[1..n]`
      and `/mnt/parity/parity[1..m]` respectively.

    * Content-file under `/var/snapraid`. Can also be configured
      to be replicated to any data/parity disks.

    * Paths must be exactly the same as configured in
      `/etc/snapraid/snapraid.conf`.

* Check the [manual][4] for configurations, documentations and CLI
  usage.

* Requires `--privileged` flag to detect file moves, or to read
  S.M.A.R.T data from disks, optionally one can mount individual
  disks with the `--device` flag. Without this, `snapraid` gives
  the `WARNING! UUID is unsupported for disks` warning and/or
  considers moved files as copied-then-removed.

* This image is intended to be run using as a Nomad Periodic Job,
  or with task runners like Buildbot (or Jenkins), so it **does
  not** include any scheduler service (like `cron`) or notifier
  (e.g.  `apprise`) components.

[1]: http://www.snapraid.it/
[2]: https://github.com/amadvance/snapraid
[3]: https://www.snapraid.it/download
[4]: https://www.snapraid.it/manual

{% include "all-include.md" %}
