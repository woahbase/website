---
description: Cross-platform emulator collection distributed with Docker images.
svcname: binfmt
orgname: tonistiigi
has_perarch_tags: false
has_services:
  - compose
tags:
  - foreign
  - dev
  - shell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This is the official [image][155] of [binfmt][151] containing
qemu-user binaries to emulate binary compatibilty of multiple
architectures on the same host machine. {{
m.ghreleasestr('tonistiigi/binfmt') }}

{% include "pull-image.md" %}

---
Run
---

We can install or uninstall support for a specific architecture like

=== "install"
    ``` sh
    docker run --rm --privileged tonistiigi/binfmt --install <arch>
    ```
=== "uninstall"
    ``` sh
    docker run --rm --privileged tonistiigi/binfmt --uninstall <arch|qemu-*>
    ```

---
##### Supported Architectures
---

| Argument | Architecture | Image Platform |
| :--      | :--          | :--            |
| amd64    | x86_64       | linux/amd64    |
| arm64    | aarch64      | linux/arm64    |
| arm      | armv6        | linux/arm/v6   |
| arm      | armv7        | linux/arm/v7   |
| 386      | i386         | linux/386      |
| loong64  | loongarch64  | linux/loong64  |
| mips64   | mips64       | linux/mips64   |
| mips64le | mips64le     | linux/mips64le |
| ppc64le  | ppc64le      | linux/ppc64le  |
| riscv64  | riscv64      | linux/riscv64  |
| s390x    | s390x        | linux/s390x    |

For multiple architectures, pass them in a **comma**-separated
list e.g `arm64,arm,amd64`.

{% include "all-include.md" %}
