---
description: MultiArch Alpine Linux + S6 + Python3 + WeeChat(IRC++)
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, i386, ppc64le, riscv64, s390x, x86_64]
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
| WEECHAT_HOME             | unset        | If set to a directory, skips creating separate directories for `weechat` configurations/cache and puts everything under this directory instead. {{ m.sincev('4.6.3') }}
| WEECHAT_SKIP_PERMFIX     | unset        | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `weechat` configuration files/directories. {{ m.sincev('4.6.3') }}
{% include "envvars/alpine-python3.md" %}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* If you want to persist your weechat data, mount a directory at
  `/home/alpine/` or directly at `/home/alpine/.weechat`.

* By default, WeeChat runs under the user `alpine`. If the
  container is running as an arbitrary user, you may need to use
  `with-contenv` so the environment variables are accessible to
  the user process.

* Check the [docs][2] for customizing your own.

[1]: https://weechat.org/
[2]: https://weechat.org/doc/

{% include "all-include.md" %}
