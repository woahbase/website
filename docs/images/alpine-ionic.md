---
description: Container for Alpine Linux + S6 + NodeJS + Ionic CLI
svcname: ionic
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

This [image][155] containerizes the [ionic][1] command line tool
and [Cordova][3] along with its [NPM][2] dependencies to
initialize, scaffold and develop Ionic/[Angular][4] applications.

**Does not include any application build environments, e.g for
Android build environment, JDK/JRE or Android Tools or Gradle.
This image is to be used for developing apps only.**

{{ m.srcimage('alpine-nodejs') }} with the {{ m.npmpkg('@ionic/cli')
}} package installed in it.

{% include "pull-image.md" %}

---
Run
---

We can call `ionic` commands directly on the container, or run
`bash` in the container to get a user-scoped shell,

=== "command"
    ``` sh
    docker run --rm -it \
      --name docker_ionic \
      --workdir /home/alpine/project \
      -v $PWD:/home/alpine/project \
    woahbase/alpine-ionic:x86_64 \
      --version
    ```
=== "shell"
    ``` sh
    docker run --rm -it \
      --entrypoint /bin/bash \
      --name docker_ionic \
      --workdir /home/alpine/project \
      -p 8100:8100 \
      -v $PWD/project:/home/alpine/project \
    woahbase/alpine-ionic:x86_64
    ```

--8<-- "; multiarch.md"

---
##### Configuration
---

* Mount the project directory (where `package.json` is) at
  `/home/alpine/project`. Mounts `$PWD/project` by default.

* Ionic runs under the user `alpine`.

---
##### Common Recipes
---

The usual `ionic` stuff. e.g

=== "init"

    Initialize projects with
    ``` sh
    docker run --rm -it \
      --name docker_ionic \
      --workdir /home/alpine/project \
      -p 8100:8100 \
      -v $PWD/project:/home/alpine/project \
    woahbase/alpine-ionic:x86_64 \
      start
    ```

=== "dev"

    Run the dev server,
    ``` sh
    docker run --rm -it \
      --name docker_ionic \
      --workdir /home/alpine/project \
      -p 8100:8100 \
      -v $PWD/project:/home/alpine/project \
    woahbase/alpine-ionic:x86_64 \
      serve
    ```

=== "custom"

    To use npm scripts from `package.json`, change the entrypoint
    to `npm`, e.g. to start the dev server of an Angular-Starter
    project
    ``` sh
    docker run --rm -it \
      --entrypoint npm \
      --name docker_ionic \
      --workdir /home/alpine/project \
      -p 8100:8100 \
      -v $PWD/project:/home/alpine/project \
    woahbase/alpine-ionic:x86_64 \
      start
    ```

[1]: https://ionicframework.com/docs/cli/
[2]: https://www.npmjs.com/
[3]: https://cordova.apache.org/
[4]: https://angular.io/

{% include "all-include.md" %}
