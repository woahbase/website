---
description: MultiArch Alpine Linux + S6 + GNU LibC + OpenJDK8 + Libreoffice
svcname: libreoffice
skip_armhf: 1
tags:
  - gui
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [Libreoffice][1] suite for
working with documents, also includes some free fonts e.g Ubuntu,
OpenSans, Inconsolata etc.

{{ m.srcimage('alpine-openjdk8') }} with the {{
m.alpinepkg('libreoffice', star=true) }} package(s) installed
in it.

{% include "pull-image.md" %}

---
Run
---

Run `libreoffice` with,

--8<-- "gui-xhost.md"

``` sh
docker run --rm -it \
  --name docker_libreoffice \
  -e DISPLAY=unix:${DISPLAY:-0} \
  -v $PWD/data:/home/alpine \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /usr/share/fonts:/usr/share/fonts:ro \
woahbase/alpine-libreoffice
```

--8<-- "multiarch.md"

To start the editors directly without showing the splash screen
add the `--nologo` flag along with the editor type e.g

=== "Calc"
    ``` sh
    docker run --rm -it \
      --name docker_libreoffice \
      -e DISPLAY=unix:${DISPLAY:-0} \
      -v $PWD/data:/home/alpine \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -v /usr/share/fonts:/usr/share/fonts:ro \
    woahbase/alpine-libreoffice \
      libreoffice --calc --nologo
    ```
=== "Draw"
    ``` sh
    docker run --rm -it \
      --name docker_libreoffice \
      -e DISPLAY=unix:${DISPLAY:-0} \
      -v $PWD/data:/home/alpine \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -v /usr/share/fonts:/usr/share/fonts:ro \
    woahbase/alpine-libreoffice \
      libreoffice --draw --nologo
    ```
=== "Global"
    ``` sh
    docker run --rm -it \
      --name docker_libreoffice \
      -e DISPLAY=unix:${DISPLAY:-0} \
      -v $PWD/data:/home/alpine \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -v /usr/share/fonts:/usr/share/fonts:ro \
    woahbase/alpine-libreoffice \
      libreoffice --global --nologo
    ```
=== "Impress"
    ``` sh
    docker run --rm -it \
      --name docker_libreoffice \
      -e DISPLAY=unix:${DISPLAY:-0} \
      -v $PWD/data:/home/alpine \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -v /usr/share/fonts:/usr/share/fonts:ro \
    woahbase/alpine-libreoffice \
      libreoffice --impress --nologo
    ```
=== "Math"
    ``` sh
    docker run --rm -it \
      --name docker_libreoffice \
      -e DISPLAY=unix:${DISPLAY:-0} \
      -v $PWD/data:/home/alpine \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -v /usr/share/fonts:/usr/share/fonts:ro \
    woahbase/alpine-libreoffice \
      libreoffice --math --nologo
    ```
=== "Web"
    ``` sh
    docker run --rm -it \
      --name docker_libreoffice \
      -e DISPLAY=unix:${DISPLAY:-0} \
      -v $PWD/data:/home/alpine \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -v /usr/share/fonts:/usr/share/fonts:ro \
    woahbase/alpine-libreoffice \
      libreoffice --web --nologo
    ```
=== "Writer"
    ``` sh
    docker run --rm -it \
      --name docker_libreoffice \
      -e DISPLAY=unix:${DISPLAY:-0} \
      -v $PWD/data:/home/alpine \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -v /usr/share/fonts:/usr/share/fonts:ro \
    woahbase/alpine-libreoffice \
      libreoffice --writer --nologo
    ```
=== "Socket"
    ``` sh
    docker run --rm -it \
      --name docker_libreoffice \
      -e DISPLAY=unix:${DISPLAY:-0} \
      -p 2002:2002 \
      -v $PWD/data:/home/alpine \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -v /usr/share/fonts:/usr/share/fonts:ro \
    woahbase/alpine-libreoffice \
      soffice \
      --nologo \
      --accept="socket,host=localhost,port=2002;urp;StarOffice.ServiceManager" \
      # optionally specify type of editor e.g. --calc or --writer
    ```

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                 | Default      | Description
| :---                     | :---         | :---
| GID_AUDIO                | unset        | Group-id of `audio` group on the host. If set, updates group-id of the group `audio` inside container, and adds `S6_USER` to the group.
| GID_PULSE                | unset        | Group-id of `pulse` group on the host. If set, updates group-id of the group `pulse` inside container, and adds `S6_USER` to the group.
| GID_VIDEO                | unset        | Group-id of `video` group on the host. If set, updates group-id of the group `video` inside container, and adds `S6_USER` to the group.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Needs `/tmp/.X11-unix/` mounted and `$DISPLAY` set inside the
  container.

* To use fonts installed in the host system, mount
  `/usr/share/fonts` inside the container.

* To preserve/load documents from the host system mount the
  `/home/alpine` dir in your local. By default mounts `$PWD/data`.

[1]: https://www.libreoffice.org/

{% include "all-include.md" %}
