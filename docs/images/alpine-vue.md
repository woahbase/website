---
description: Container for Alpine Linux + S6 + NodeJS + VueJS CLI
svcname: vue
skip_aarch64: 1
skip_armhf: 1
skip_armv7l: 1
tags:
  - legacy
  - nodejs
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [command line client][2] for
[VueJS][1] along with its [NPM][3] dependencies.

{{ m.srcimage('alpine-nodejs') }} with the {{ m.npmpkg('@vue/cli')
}} package installed in it.

{% include "pull-image.md" %}

---
Run
---

We can call `vue` commands directly on the container, or run
`bash` in the container to get a user-scoped shell,

=== "command"
    ``` sh
    docker run --rm -it \
      --name docker_vue \
      --workdir /home/alpine/project \
      -p 8080:8080 \
      -v $PWD:/home/alpine/project \
    woahbase/alpine-vue:x86_64 \
      --version
    ```
=== "shell"
    ``` sh
    docker run --rm -it \
      --entrypoint /bin/bash \
      --name docker_vue \
      --workdir /home/alpine/project \
      -p 8080:8080 \
      -v $PWD/project:/home/alpine/project \
    woahbase/alpine-vue:x86_64
    ```

--8<-- "; multiarch.md"

---
##### Configuration
---

* Mount the project directory (where `package.json` is) at
  `/home/alpine/project`. Mounts `PWD` by default.

* Vue runs under the user `alpine`.

---
##### Common Recipes
---

The usual `vue` stuff. e.g

=== "list"

    List projects with
    ``` sh
    docker run --rm -it \
      --name docker_vue \
      -v $PWD:/home/alpine/project \
    woahbase/alpine-vue:x86_64 \
      list
    ```
=== "init"

    Initialize a project
    ``` sh
    docker run --rm -it \
      --name docker_vue \
      -v $PWD:/home/alpine/project \
      -p 8080:8080 \
    woahbase/alpine-vue:x86_64 \
      init
    ```
=== "dev"

    Run the dev server,
    ``` sh
    docker run --rm -it \
      --entrypoint npm \
      --name docker_vue \
      -v $PWD:/home/alpine/project \
      -p 8080:8080 \
    woahbase/alpine-vue:x86_64 \
      run dev
    ```
=== "build"

    Build the project with
    ``` sh
    docker run --rm -it \
      --entrypoint npm \
      --name docker_vue \
      -v $PWD:/home/alpine/project \
    woahbase/alpine-vue:x86_64 \
      run build
    ```

[1]: https://vuejs.org/
[2]: https://github.com/vuejs/vue-cli
[3]: https://www.npmjs.com/

{% include "all-include.md" %}
