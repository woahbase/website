---
description: Container for Alpine Linux + S6 + Python2 + PIP
tags:
  - deprecated
  - dev
  - shell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base image for applications
/ services that require [Python2][1] and [Pip][2] to manage
dependencies.

{{ m.srcimage('alpine-s6') }} with the package {{
m.alpinepkg('python2', branch='v3.15') }} installed in it.

{% include "pull-image.md" %}

---
Run
---

We can call `python` directly on the container, or run `bash` in
the container to get a shell,

=== "command"
    ``` sh
    docker run --rm -it --name docker_python2 woahbase/alpine-python2:x86_64 python -V
    ```
=== "shell"
    ``` sh
    docker run --rm -it --name docker_python2 woahbase/alpine-python2:x86_64 /bin/bash
    ```

--8<-- "multiarch.md"

[1]: https://www.python.org/
[2]: https://pypi.python.org/pypi/pip

{% include "all-include.md" %}
