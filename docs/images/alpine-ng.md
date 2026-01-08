---
description: Container for Alpine Linux + S6 + NodeJS + Angular CLI
alpine_branch: v3.10
arches: [x86_64]
tags:
  - legacy
  - dev
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [ng][1] command line tool
for [Angular][2] along with its [NPM][3] dependencies to
initialize, scaffold and maintain angular applications.

{{ m.srcimage('alpine-nodejs') }} with the {{ m.npmpkg('@angular/cli')
}} package installed in it.

{% include "pull-image.md" %}

---
Run
---

We can call `ng` commands directly on the container, or run
`bash` in the container to get a user-scoped shell,

=== "command"
    ``` sh
    docker run --rm -it \
      --name docker_ng \
      --workdir /home/alpine/project \
      -p 4200:4200 \
      -v $PWD:/home/alpine/project \
    woahbase/alpine-ng:x86_64 \
      --version
    ```
=== "shell"
    ``` sh
    docker run --rm -it \
      --entrypoint /bin/bash \
      --name docker_ng \
      --workdir /home/alpine/project \
      -p 4200:4200 \
      -v $PWD/project:/home/alpine/project \
    woahbase/alpine-ng:x86_64
    ```

--8<-- "; multiarch.md"

---
##### Configuration
---

* Mount the project directory (where `package.json` is) at
  `/home/alpine/project`. Mounts `PWD` by default.

* `ng` runs under the user `alpine`.

---
##### Common Recipes
---

The usual `ng` stuff. e.g

=== "init"

    Initialize projects with
    ``` sh
    docker run --rm -it \
      --name docker_ng \
      -v $PWD:/home/alpine/project \
    woahbase/alpine-ng:x86_64 \
      new
    ```
=== "dev"

    Run the dev server,
    ``` sh
    docker run --rm -it \
      --name docker_ng \
      -v $PWD:/home/alpine/project \
      -p 4200:4200 \
    woahbase/alpine-ng:x86_64 \
      serve
    ```
=== "build"

    Build the project with
    ``` sh
    docker run --rm -it \
      --name docker_ng \
      -v $PWD:/home/alpine/project \
    woahbase/alpine-ng:x86_64 \
      build --prod
    ```
=== "custom"

    To use npm scripts from `package.json`, change the entrypoint
    to `npm`, e.g. to start the dev server of an Angular-Starter
    project
    ``` sh
    docker run --rm -it \
      --entrypoint npm \
      --name docker_ng \
      -v $PWD:/home/alpine/project \
    woahbase/alpine-ng:x86_64 \
      start
    ```

[1]: https://github.com/angular/angular-cli
[2]: https://angular.io/
[3]: https://www.npmjs.com/

{% include "all-include.md" %}
