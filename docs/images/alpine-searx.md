---
description: Container for Alpine Linux + S6 + Python3 + SearX
svcname: searx
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - legacy
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] provides the [Searx Metasearch Engine][1] inside
a [Python3][2] container.

{{ m.srcimage('alpine-python3') }} with the [searx][3] package
installed in it. {{ m.ghreleasestr('asciimoo/searx') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm -it \
  --name docker_searx \
  -p 8888:8888 \
  -v $PWD/data:/data \
woahbase/alpine-searx:x86_64
```

--8<-- "multiarch.md"

[1]: https://searx.github.io/searx/
[2]: https://www.python.org/
[3]: https://github.com/asciimoo/searx/

{% include "all-include.md" %}
