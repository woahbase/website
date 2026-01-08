---
description: Container for Alpine Linux + S6 + Ruby + Travis.CI CLI
alpine_branch: v3.10
arches: [aarch64, armhf, armv7l, x86_64]
tags:
  - deprecated
  - dev
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the command-line client for
[Travis.CI][4] (`.org` and `.com`) along with [Ruby][1] and its
[Gem][2] dependencies.

{{ m.srcimage('alpine-ruby') }} with the [travis.rb][3] gem
installed in it.

{% include "pull-image.md" %}

---
#### Run
---

We can call `travis` commands directly on the container, or run
`bash` in the container to get a user-scoped shell,


=== "command"
    ``` sh
    docker run --rm -it \
      --name docker_travis \
      --workdir /home/alpine/project \
      -v $PWD/travis`#(1)`:/home/alpine/.travis \
      -v $PWD/yourproject`#(2)`:/home/alpine/project \
    woahbase/alpine-travis:x86_64 \
      --version
    ```

    1. (Optional) Path to travis.ci configurations.
    2. (Required) Path to your website project directory.

=== "shell"
    ``` sh
    docker run --rm -it \
      --entrypoint /bin/bash \
      --name docker_travis \
      --workdir /home/alpine/project \
      -v $PWD/travis`#(1)`:/home/alpine/.travis \
      -v $PWD/yourproject`#(2)`:/home/alpine/project \
    woahbase/alpine-travis:x86_64
    ```

    1. (Optional) Path to travis.ci configurations.
    2. (Required) Path to your website project directory.

--8<-- "multiarch.md"

---
#### Configuration
---

* Travis runs under the user `alpine`, which is ideal to run in
  non-root mode.

* If you want to persist your travis data (logins or other
  configurations), mount a directory at `/home/alpine/` or
  directly at `/home/alpine/.travis`.

* Mount the project directory (where `.travis.yml` is) at
  `/home/alpine/project`. Mounts `PWD` by default.

[1]: https://www.ruby-lang.org
[2]: https://rubygems.org
[3]: https://github.com/travis-ci/travis.rb
[4]: https://travis-ci.org/

{% include "all-include.md" %}
