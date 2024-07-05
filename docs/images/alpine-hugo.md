---
description: MultiArch Alpine Linux + S6 + Hugo + Pygments
svcname: hugo
tags:
  - github
  - s6
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [Hugo][1] (binary build) to
generate static sites, and Python3+[Pygments][2] for syntax
highlighting, that can build, serve, watch for changes, and pack
static sites as output. Checkout [this][3] link to get started.

{{ m.srcimage('alpine-s6') }} with the hugo binaries installed in
it. {{ m.ghreleasestr('gohugoio/hugo') }}

{% include "pull-image.md" %}

---
Run
---

We can call `hugo` commands directly on the container, or run
`bash` in the container to get a [user-scoped][114] shell,

=== "command"
    ``` sh
    docker run --rm -it \
      --name docker_hugo \
      --workdir /home/alpine/project \
      -p 1313:1313 \
      -v $PWD/yoursite`#(1)`:/home/alpine/project \
    woahbase/alpine-hugo \
      hugo version
    ```

    1. (Required) Path to your website project directory.

=== "shell"
    ``` sh
    docker run --rm -it \
      --name docker_hugo \
      --workdir /home/alpine/project \
      -p 1313:1313 \
      -v $PWD/yoursite`#(1)`:/home/alpine/project \
    woahbase/alpine-hugo \
      /bin/bash
    ```

    1. (Required) Path to your website project directory.

--8<-- "multiarch.md"

---
#### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                 | Default      | Description
| :---                     | :---         | :---
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Mount your site-project at `/home/alpine/project` and optionally
  set it as workdir.  Then you can run `hugo ...` commands as
  a non-root user (alpine) in the shell, just as you would
  anywhere else.

[1]: https://gohugo.io/
[2]: http://pygments.org/
[3]: https://gohugo.io/getting-started/

{% include "all-include.md" %}
