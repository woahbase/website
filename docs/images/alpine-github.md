---
description: Container for Alpine Linux + S6 + GNU LibC + Git + Hub
skip_aarch64: 1
skip_armv7l: 1
tags:
  - deprecated
  - dev
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the statically built [Hub][1]
cli along with [Git][2].

{{ m.srcimage('alpine-glibc') }} with the hub binaries installed in
it. {{ m.ghreleasestr('github/hub') }}

{% include "pull-image.md" %}

---
Run
---

We can call `git` or `hub` commands directly on the container, or
run `bash` in the container to get a user-scoped shell,

=== "command"
    ``` sh
    docker run --rm -it \
      --name docker_github \
      --workdir /home/alpine/project \
      -v $PWD/yourproject:/home/alpine/project \
    woahbase/alpine-github:x86_64 \
      --version
    ```

=== "shell"
    ``` sh
    docker run --rm -it \
      --entrypoint /bin/bash \
      --name docker_github \
      --workdir /home/alpine/project \
      -v $PWD/yourproject:/home/alpine/project \
    woahbase/alpine-github:x86_64
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

* Default project dir for alpine is `/home/alpine/project`. Mount
  your project here. By default mounts `$PWD`.

* Runs under the user `alpine`, which is ideal to run in
  non-root mode.

* To persist configurations, mount the `/home/alpine` dir in your
  local.

[1]: http://hub.github.com/
[2]: https://git-scm.com/

{% include "all-include.md" %}
