---
description: MultiArch Alpine Linux + S6 + Python3 + MkDocsMaterial
svcname: mkdocsmaterial
skip_armhf: 1
tags:
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [MkDocsMaterial][1] (OSS) to
generate static sites, that can build, serve, watch for changes,
and pack static sites as output. Checkout [this][2] link to get
started.

{{ m.srcimage('alpine-python3') }} with the {{
m.pypipkg('mkdocs-material') }} package installed in it.

{% include "pull-image.md" %}

---
Run
---

We can call `mkdocs` commands directly on the container, or run
`bash` in the container to get a [user-scoped][114] shell,

=== "command"
    ``` sh
    docker run --rm -it \
      --name docker_mkdocsmaterial \
      --workdir /home/alpine/project \
      -p 8000:8000 \
      -v $PWD/yoursite`#(1)`:/home/alpine/project \
    woahbase/alpine-mkdocsmaterial \
      mkdocs serve
    ```

    1. (Required) Path to your website project directory.

=== "shell"
    ``` sh
    docker run --rm -it \
      --name docker_mkdocsmaterial \
      --workdir /home/alpine/project \
      -p 8000:8000 \
      -v $PWD/yoursite`#(1)`:/home/alpine/project \
    woahbase/alpine-mkdocsmaterial \
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
{% include "envvars/alpine-python3.md" %}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Mount your site-project at `/home/alpine/project` and optionally
  set it as workdir.  Then you can run `mkdocs ...` commands as
  a non-root user (alpine) in the shell, just as you would
  anywhere else.

* Additionally, these plugins are bundled in the docker image,
  along with the [default][3] ones.

    * [mkdocs-awesome-pages-plugin](https://github.com/lukasgeiter/mkdocs-awesome-pages-plugin/) ({{ m.pypipkg('mkdocs-awesome-pages-plugin', dname='PyPi') }})
    * [mkdocs-git-authors-plugin](https://github.com/timvink/mkdocs-git-authors-plugin) ({{ m.pypipkg('mkdocs-git-authors-plugin', dname='PyPi') }})
    * [mkdocs-git-revision-date-localized-plugin](https://github.com/timvink/mkdocs-git-revision-date-localized-plugin) ({{ m.pypipkg('mkdocs-git-revision-date-localized-plugin', dname='PyPi') }})
    * [mkdocs-macros-plugin](https://github.com/fralau/mkdocs-macros-plugin) ({{ m.pypipkg('mkdocs-macros-plugin', dname='PyPi') }})
    * [mkdocs-meta-descriptions-plugin](https://github.com/prcr/mkdocs-meta-descriptions-plugin) ({{ m.pypipkg('mkdocs-meta-descriptions-plugin', dname='PyPi') }})
    * [mkdocs-minify-plugin](https://github.com/byrnereese/mkdocs-minify-plugin) ({{ m.pypipkg('mkdocs-minify-plugin', dname='PyPi') }})
    * [mkdocs-redirects](https://github.com/datarobot/mkdocs-redirects) ({{ m.pypipkg('mkdocs-redirects', dname='PyPi') }})

[1]: https://squidfunk.github.io/mkdocs-material/
[2]: https://squidfunk.github.io/mkdocs-material/getting-started/
[3]: https://squidfunk.github.io/mkdocs-material/plugins/

{% include "all-include.md" %}
