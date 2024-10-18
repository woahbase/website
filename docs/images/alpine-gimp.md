---
description: MultiArch Alpine Linux + S6 + GNU LibC + GIMP
svcname: gimp
tags:
  - glibc
  - gui
  - package
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [GNU Image Manipulation][1]
program for working with images, also includes some free fonts e.g
Ubuntu, OpenSans, Inconsolata etc.

{{ m.srcimage('alpine-glibc') }} with the {{ m.alpinepkg('gimp')
}} package installed in it.

{% include "pull-image.md" %}

---
Run
---

Run `gimp` with,

--8<-- "gui-xhost.md"

``` sh
docker run --rm -it \
  --name docker_gimp \
  --workdir /home/alpine \
  -e DISPLAY=unix:${DISPLAY:-0} \
  -v /usr/share/fonts:/usr/share/fonts:ro \
  -v $PWD/data:/home/alpine \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
woahbase/alpine-gimp \
  gimp \
  --no-splash
```

--8<-- "multiarch.md"

---
#### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                 | Default      | Description
| :---                     | :---         | :---
| GID_VIDEO                | unset        | Group-id of `video` group on the host. If set, updates group-id of the group `video` inside container, and adds `S6_USER` to the group.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Needs `/tmp/.X11-unix/` mounted and `$DISPLAY` set inside the
  container.

* To use fonts installed in the host system, mount
  `/usr/share/fonts` inside the container.

* {{ m.customscript('p11-gimp-customize') }}

* To preserve/load images from the host system,  mount the
  `/home/alpine` dir somewhere in your host storage. By default
  mounts `$PWD/data`.

[1]: https://www.gimp.org/

{% include "all-include.md" %}
