---
description: Container for Alpine Linux + S6 + GNU LibC + OpenJDK8 + Libresonic
alpine_branch: v3.10
arches: [armhf, x86_64]
deprecator_link: /images/alpine-navidrome.md
deprecator_linktitle: Navidrome
tags:
  - deprecated
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [Libresonic][1] media streaming
server, running under [OpenJDK-8][2].

{{ m.srcimage('alpine-openjdk8') }} with the libresonic [jar][3]
installed in it. {{ m.ghreleasestr('Libresonic/libresonic') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm -it \
  --name docker_libresonic \
  -p 4040:4040 \
  -v $PWD/config:/config \
  -v $PWD/music:/music \
  -v $PWD/playlists:/playlists \
woahbase/alpine-libresonic:x86_64
```

--8<-- "multiarch.md"

[1]: http://libresonic.org
[2]: https://openjdk.org/projects/jdk8/
[3]: https://github.com/Libresonic/libresonic/releases

{% include "all-include.md" %}
