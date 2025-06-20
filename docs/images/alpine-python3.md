---
description: MultiArch Alpine Linux + S6 + Python 3.x.x Runtime + PIP
tags:
  - dev
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base image for applications
/ services that require [Python3][1] and [Pip][2] to manage
dependencies.

{{ m.srcimage('alpine-s6') }} with the package {{
m.alpinepkg('python3') }} installed in it.

{% include "pull-image.md" %}

---
Run
---

We can call `python` or `pip` directly on the container, or run `bash` in the container to get a [user-scoped][114] shell,

=== "command"
    ``` sh
    docker run --rm -it --name docker_python3 woahbase/alpine-python3 python -V
    ```
=== "shell"
    ``` sh
    docker run --rm -it --name docker_python3 woahbase/alpine-python3 /bin/bash
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                | Default             | Description
| :---                    | :---                | :---
{% include "envvars/alpine-python3.md" %}
| PYTHONUSERBASE          | /home/alpine/.local | Default prefix for installing user-scoped packages with `pip`. {{ m.sincev('3.12.10_20250524') }} Previously named `USERINSTPREFIX`.
| PYTHON_SKIP_MODIFY_PATH | unset               | By default, user-scoped binaries installed by `pip` (in `~/.local/bin`) are added automatically to path, setting this to e.g `1` skips that step. {{ m.sincev('3.12.10_20250524') }}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* If the user packages have binaries inside `~/.local/bin`,
  they're automatically added to path.

[1]: https://www.python.org/
[2]: https://pypi.python.org/pypi/pip

{% include "all-include.md" %}
