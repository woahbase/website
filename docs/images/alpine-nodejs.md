---
description: MultiArch Alpine Linux + S6 + NodeJS + NPM + Yarn + PNPM
svcname: nodejs
tags:
  - dev
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base image for applications
/ services that require [NodeJS][1] and [NPM][2] to manage
dependencies (also includes [Yarn][3], [PNPM][4], and [git][101]).

{{ m.srcimage('alpine-s6') }} with the packages {{
m.alpinepkg('nodejs') }}, {{ m.alpinepkg('npm') }}, {{
m.alpinepkg('yarn') }}, {{ m.alpinepkg('pnpm') }} and {{
m.alpinepkg('git') }} installed in it.

{% include "pull-image.md" %}

---
Run
---

We can call `node` (or `npm`, `yarn`, or `pnpm`) directly on the
container, or run `bash` in the container to get
a [user-scoped][114] shell,

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

| ENV Vars                | Default      | Description
| :---                    | :---         | :---
{% include "envvars/alpine-nodejs.md" %}
| NODEJS_SKIP_MODIFY_PATH | unset        | By default, project-local binaries installed by `npm` or `yarn` or `pnpm` (in `<projectdir>/node_modules/.bin`) are added automatically to path, setting this to a non-empty string e.g `1` skips that step. {{ m.sincev('22.15.1') }}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* If the node project dependencies have local binaries inside
  `node_modules/.bin`, those are automatically added to path.

[1]: https://nodejs.org/
[2]: https://www.npmjs.com/
[3]: https://yarnpkg.com/
[4]: https://pnpm.io/

{% include "all-include.md" %}
