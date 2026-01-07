---
description: MultiArch Alpine Linux + S6 + RClone
alpine_branch: v3.23
arches: [aarch64, armhf, armv7l, i386, x86_64]
tags:
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [Rclone][1] (statically-linked)
to backup/copy files to and from between local and various cloud
storage services. Checkout their [docs][2] to get started.

{{ m.srcimage('alpine-s6') }} with the rclone binary installed
in it. {{ m.ghreleasestr('rclone/rclone') }}

{% include "pull-image.md" %}

---
Run
---

We can call `rclone` directly on the container, or run `bash` in
the container to get a [user-scoped][114] shell,

=== "command"
    ``` sh
    docker run --rm -it \
      --name docker_rclone \
      --workdir /home/alpine \
      -v $PWD/data:/home/alpine \
    woahbase/alpine-rclone \
      rclone --version
    ```
=== "shell"
    ``` sh
    docker run --rm -it \
      --name docker_rclone \
      --workdir /home/alpine \
      -v $PWD/data:/home/alpine \
    woahbase/alpine-rclone \
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

* Mount configurations at `/home/alpine/.config/rclone`.

* Mount your directory anywhere in image (e.g `/storage` or even
  `/home/alpine`) and set it as workdir.  Then you can run `rclone
  ...` commands in the shell, just as you would anywhere else.

[1]: https://rclone.org/
[2]: https://rclone.org/docs/
[3]: https://github.com/rclone/rclone

{% include "all-include.md" %}
