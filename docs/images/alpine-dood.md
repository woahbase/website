---
description: MultiArch Alpine Linux + S6 + Docker(-outside-of-docker) Toolkit
alpine_branch: v3.23
arches: [aarch64, armhf, armv7l, ppc64le, riscv64, s390x, x86_64]
tags:
  - github
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [docker][103] with [buildx][106]
plugin, as well as [docker-compose][1] and [skopeo][6].  Also
includes [git][101] and [GNU Make][102]. Intended to be used as
a self-contained appliance to manage the docker
containers/images/services running on the host machine (aka
*docker-outside-of-docker*), or for building images.

{{ m.srcimage('alpine-s6') }} with the packages {{
m.alpinepkg('docker-cli') }}, and {{ m.alpinepkg('skopeo') }}
along with binaries for [buildx][5] and [docker-compose][3]
installed in it.

**Does not include docker-engine.**

(Newer versions replaced legacy `docker-compose` with plugin
`compose`, older versions also included [docker-machine][4], but
not anymore since its deprecation.)

{% include "pull-image.md" %}

---
Run
---

We can call `docker` or `compose` directly on
the container, or run `bash` in the container to get
a [user-scoped][114] shell,

=== "docker"
    ``` sh
    docker run --rm -it \
      --name docker_dood \
      --workdir=/home/alpine \
      -e PGID=1000 \
      -e PUID=1000 \
      -v $PWD/data:/home/alpine `#(1)` \
      -v /var/run/docker.sock:/var/run/docker.sock \
    woahbase/alpine-dood \
      docker version
    ```

    1. Required if using docker authentication or alternative docker.json or ssh-KBA.

=== "shell"
    ``` sh
    docker run --rm -it \
      --name docker_dood \
      --workdir=/home/alpine \
      -e PGID=1000 \
      -e PUID=1000 \
      -v $PWD/data:/home/alpine `#(1)` \
      -v /var/run/docker.sock:/var/run/docker.sock \
    woahbase/alpine-dood \
      /bin/bash
    ```

    1. Required if using docker authentication or alternative docker.json or ssh-KBA.

=== "compose"
    ``` sh
    docker run --rm -it \
      --name docker_dood \
      --workdir=/home/alpine/project \
      -e GID_DOCKER=995 `#(1)` \
      -e HOSTCWD=$PWD `#(3)` \
      -e PGID=1000 \
      -e PUID=1000 \
      -v $PWD/data:/home/alpine `#(2)` \
      -v $PWD/project:/home/alpine/project \
      -v /var/run/docker.sock:/var/run/docker.sock \
    woahbase/alpine-dood \
      docker compose up -d
    ```

    1. GID of the group `docker`. Needed to access docker
        socket inside container. Check yours with
        ``` sh
        getent group docker | awk -F ":" '{ print $$3 }'
        ```
    2. Required if using docker authentication or alternative docker.json or ssh-KBA.
    3. Only required if using relative mounts e.g. for `docker-compose`.

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                 | Default      | Description
| :---                     | :---         | :---
| GID_DOCKER               | unset        | Group-id of `docker` group on the host. If set, updates group-id of the group `docker` inside container, and adds `${S6_USER}` to the group. When unspecified, the socket permissions are used instead. {{ m.sincev('26.1.5') }}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Mount the project directory (e.g. where `docker-compose.yml` is) at
  `/home/alpine/project`, and use it as `workdir`. Mounts `PWD` by default.

* Optionally, for relative mounts (e.g. for providing project-specific
  configuration/defaults in `docker-compose` via directories that
  exist in the host, but not inside container) we can set an
  environment variable (e.g. `${HOSTCWD}`) to a directory in the
  host machine, and use it similar to `${PWD}`.

* Processes/services/tasks are generally recommended to be run as
  the non-root user `alpine`.

* Checkout [Awesome Docker][7] for best practices, books, or tools.

[1]: https://docs.docker.com/compose/
[2]: https://github.com/docker/machine/
[3]: https://github.com/docker/compose/releases/
[4]: https://github.com/docker/machine/releases/
[5]: https://github.com/docker/buildx/releases/
[6]: https://github.com/containers/skopeo
[7]: https://github.com/veggiemonk/awesome-docker

{% include "all-include.md" %}
