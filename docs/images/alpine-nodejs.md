---
description: MultiArch Alpine Linux + S6 + NodeJS + NPM + Yarn
svcname: nodejs
tags:
  - dev
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base image for applications
/ services that require [NodeJS][1] and [NPM][2] to manage
dependencies (also includes [Yarn][3] and [git][101]).

{{ m.srcimage('alpine-s6') }} with the packages
{{ m.alpinepkg('nodejs', branch='v3.18') }}, {{ m.alpinepkg('npm', branch='v3.18') }},
{{ m.alpinepkg('yarn', branch='v3.18') }} and {{ m.alpinepkg('git') }}
installed in it.

???+ warning "NodeJS ARM32 v6/v7 Issue"

    NPM seems to hang in current node (20.x.x) versions, affects
    `armv7l` and `armhf` builds, sticking to 18.x.x version from
    Alpine Linux 3.18 repositories until [this issue](https://github.com/nodejs/docker-node/issues/1946)
    (relevant [QEMU issue](https://gitlab.com/qemu-project/qemu/-/issues/1729)) is
    resolved.

{% include "pull-image.md" %}

---
Run
---

We can call `node` or `npm` directly on the container, or run
`bash` in the container to get a [user-scoped][114] shell,

=== "command"
    ``` sh
    docker run --rm -it --name docker_nodejs woahbase/alpine-nodejs node --version
    ```
=== "shell"
    ``` sh
    docker run --rm -it --name docker_nodejs woahbase/alpine-nodejs /bin/bash
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars               | Default      | Description
| :---                   | :---         | :---
{% include "envvars/alpine-nodejs.md" %}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* If the node project dependencies have local binaries inside
  `node_modules/.bin`, those are automatically added to path.

[1]: https://nodejs.org/
[2]: https://www.npmjs.com/
[3]: https://yarnpkg.com/

{% include "all-include.md" %}
