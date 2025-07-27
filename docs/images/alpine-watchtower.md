---
description: MultiArch Alpine Linux + S6 + Watchtower
has_services:
  - compose
tags:
  - dev
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [Watchtower][1]. Intended to check
and update (or just notify) containers running in a host when
newer versions of images become available.

{{ m.srcimage('alpine-s6') }} with the [watchtower][2] binaries
installed in it. {{ m.ghreleasestr('containrrr/watchtower') }}

{% include "pull-image.md" %}

---
Run
---

We can call `watchtower` commands directly on the container, or run
`bash` in the container to get a [user-scoped][114] shell,

=== "command"
    ``` sh
    docker run --rm -it \
      --name docker_watchtower \
      -p 8080:8080 \
      -v /var/run/docker.sock`#(1)`:/var/run/docker.sock \
    woahbase/alpine-watchtower \
      watchtower --help
    ```

    1. (Required) Path to `docker` socket.

=== "shell"
    ``` sh
    docker run --rm -it \
      --name docker_watchtower \
      -p 8080:8080 \
      -v /var/run/docker.sock`#(1)`:/var/run/docker.sock \
    woahbase/alpine-watchtower \
      /bin/bash
    ```

    1. (Required) Path to `docker` socket.

--8<-- "multiarch.md"

---
#### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                 | Default      | Description
| :---                     | :---         | :---
| GID_DOCKER               | unset        | Group-id of `docker` group on the host. If set, updates group-id of the group `docker` inside container, and adds `${S6_USER}` to the group.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Watchtower can be configured either via environment-variables,
  or arguments passed to the binary. Checkout their [docs][3] and
  [arguments][4] for customizing your own.

* {{ m.customscript('p11-watchtower-customize') }}

[1]: https://containrrr.dev/watchtower/
[2]: https://github.com/containrrr/watchtower/releases
[3]: https://containrrr.dev/watchtower/usage-overview/
[4]: https://containrrr.dev/watchtower/arguments/

{% include "all-include.md" %}
