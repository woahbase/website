---
description: MultiArch Alpine Linux + S6 + Python3 + WeeChat(IRC++)
tags:
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [WeeChat][1] client,
supports multiple protocols and included with `perl` and
`python` support for plugins to get the most out of it.

{{ m.srcimage('alpine-python3') }} with the {{
m.alpinepkg('weechat') }} package installed in it.

{% include "pull-image.md" %}

---
Run
---

Run `weechat` with,

``` sh
docker run --rm -it \
  --name docker_weechat \
  --workdir /home/alpine \
  -p 9001:9001 \
  -v $PWD/data:/home/alpine/.weechat \
woahbase/alpine-weechat \
  weechat
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                 | Default      | Description
| :---                     | :---         | :---
{% include "envvars/alpine-python3.md" %}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* If you want to persist your weechat data, mount a directory at
  `/home/alpine/` or directly at `/home/alpine/.weechat`.

* WeeChat runs under the user `alpine`.

* Check the [docs][2] for customizing your own.

[1]: https://weechat.org/
[2]: https://weechat.org/doc/

{% include "all-include.md" %}
