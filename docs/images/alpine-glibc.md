---
description: MultiArch Alpine Linux + S6 + GNU LibC
tags:
  - base
  - shell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as a base image for applications/services
that need the GNU C Library to run binaries linked against it.
AlpineLinux by default uses `musl`, which is simply not compatible
for quite a few applications. This image solves the dynamic
linking problem for a few (definitely not all) of those cases.

{{ m.srcimage('alpine-s6') }} with the compiled [glibc][1]
binaries installed in it.

{% include "pull-image.md" %}

    Pre-`2.33` versions used to use [sgerrand][2]'s builds for
    `x86_64` and [SatoshiPortal][3]'s builds for `aarch64`,
    `armhf` and `armv7l` images. But since `2.33`, we compile our
    own version straight from the [GNU LibC sources][1] upon release.

---
Run
---

Run `bash` in the container to get a shell.

=== "shell"
    ``` sh
    docker run --rm --name docker_glibc woahbase/alpine-glibc /bin/bash
    ```
=== "usershell"
    ``` sh
    docker run --rm -it --name docker_glibc --entrypoint /usershell woahbase/alpine-glibc /bin/bash
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars           | Default       | Description
| :---               | :---          | :---
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

[1]: https://ftp.gnu.org/gnu/glibc/
[2]: https://github.com/sgerrand/alpine-pkg-glibc
[3]: https://github.com/SatoshiPortal/alpine-pkg-glibc/releases
[4]: https://news.ycombinator.com/item?id=10782897
[5]: https://www.gnu.org/software/libc/manual/html_node/Installation.html
[6]: https://github.com/sgerrand/docker-glibc-builder/issues/20
[7]: https://github.com/Lauri-Nomme/alpine-glibc-xb/blob/master/Dockerfile
[8]: https://github.com/jvasileff/alpine-pkg-glibc-armhf/blob/master/build-with-docker.sh

{% include "all-include.md" %}
