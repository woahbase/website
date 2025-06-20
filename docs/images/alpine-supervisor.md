---
description: MultiArch Alpine Linux + Supervisor Init System.
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, i386, loong64, ppc64le, riscv64, s390x, x86_64]
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base image for
applications/services that need [Supervisor][1] as an init system to
launch the processes and pass the proper signals when interacted
with the containers.

{{ m.srcimage('alpine-base') }} with the {{
m.alpinepkg('supervisor') }} package installed in it.

{% include "pull-image.md" %}

---
Run
---

By default, the container starts the `supervisord` daemon as the
initialization service, or we can run `bash` inside it to drop
into a shell.

=== "service"
    Running the container starts the service.
    ``` sh
    docker run --rm -it \
      --name docker_supervisor \
      -v $PWD/supervisor.d`#(1)`:/etc/supervisor.d \
    woahbase/alpine-supervisor
    ```

    1. (Required) Path to your supervisor configurations directory.

=== "shell"
    Run `bash` in the container to get a shell inside it, this does
    not start the init system, so that it can be done manually. It is
    quite useful if we need to test custom tasks/services, or run
    other commands before initialization.
    ``` sh
    docker run --rm -it \
      --entrypoint /bin/bash \
      --name docker_supervisor \
      -v $PWD/supervisor.d`#(1)`:/etc/supervisor.d \
    woahbase/alpine-supervisor
    ```

    1. (Required) Path to your supervisor configurations directory.

--8<-- "multiarch.md"

---
##### Configuration
---

For custom configuration, replace the `/etc/supervisord.conf` with
your own. By default, the supervisor configuration `ini` files
inside `/etc/supervisor.d/` are sourced so we can volume mount the
directory containing your application configurations at there.

[1]: http://supervisord.org/index.html

{% include "all-include.md" %}
