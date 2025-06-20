---
description: Container for Alpine Linux + S6 + NodeJS + VueJS + Quasar Framework CLI
skip_aarch64: 1
skip_armhf: 1
skip_armv7l: 1
tags:
  - legacy
  - dev
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [command line client][5] for
[Quasar Framework][1] and [VueJS][3] [CLI][2] along with
its [NPM][4] dependencies.

{{ m.srcimage('alpine-vue') }} with the {{ m.npmpkg('@quasar/cli')
}} package installed in it.

{% include "pull-image.md" %}

---
Run
---

We can call `quasar` commands directly on the container, or run
`bash` in the container to get a user-scoped shell,

=== "command"
    ``` sh
    docker run --rm -it \
      --name docker_quasar \
      --workdir /home/alpine/project \
      -p 8080:8080 \
      -v $PWD:/home/alpine/project \
    woahbase/alpine-quasar:x86_64 \
      --version
    ```
=== "shell"
    ``` sh
    docker run --rm -it \
      --entrypoint /bin/bash \
      --name docker_quasar \
      --workdir /home/alpine/project \
      -p 8080:8080 \
      -v $PWD/project:/home/alpine/project \
    woahbase/alpine-quasar:x86_64
    ```

--8<-- "; multiarch.md"

---
##### Configuration
---

* Mount the project directory (where `package.json` is) at
  `/home/alpine/project`. Mounts `PWD` by default.

* Quasar runs under the user `alpine`.

* Checkout this [link][6] to get help on the CLI, or the
  framework.

---
##### Common Recipes
---

The usual `quasar` stuff. e.g

=== "init"

    Initialize projects with
    ``` sh
    docker run --rm -it \
      --name docker_quasar \
      -v $PWD:/home/alpine/project \
    woahbase/alpine-quasar:x86_64 \
      init
    ```
=== "dev"

    Run the dev server,
    ``` sh
    docker run --rm -it \
      --name docker_quasar \
      -v $PWD:/home/alpine/project \
      -p 8080:8080 \
    woahbase/alpine-quasar:x86_64 \
      dev -m pwa -t mat
    ```
=== "build"

    Build the project with
    ``` sh
    docker run --rm -it \
      --name docker_quasar \
      -v $PWD:/home/alpine/project \
    woahbase/alpine-quasar:x86_64 \
      build -m pwa -t mat
    ```

[1]: http://quasar-framework.org/
[2]: https://github.com/vuejs/vue-cli
[3]: https://vuejs.org/
[4]: https://www.npmjs.com/
[5]: https://github.com/quasarframework/quasar-cli
[6]: http://quasar-framework.org/guide/quasar-cli.html

{% include "all-include.md" %}
