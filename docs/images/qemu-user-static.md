---
description: /usr/bin/qemu-\*-static
svcname: qemu-user-static
orgname: multiarch
has_perarch_tags: false
tags:
  - foreign
  - dev
  - shell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This is the official [image][155] of [qemu-user-static][151] containing qemu-user
binaries to execute multi-architecture containers on the same host machine using
`qemu` and `binfmt-misc`. {{ m.ghreleasestr('multiarch/qemu-user-static') }}

{% include "pull-image.md" %}

---
Run
---

We can register `binfmt_misc` support for architectures like

=== "register"
    ``` sh
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    ```
=== "credentials"
    ``` sh
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes  --credentials yes
    ```
    (For when you need credential and security tokens are
    calculated according to the binary to interpret, especially if
    you use sudo inside the container to have the correct EUID
    set)

Also,

* Check their [getting started][151] guide or [image tags][155] to
  customize as per your needs.

{% include "all-include.md" %}
