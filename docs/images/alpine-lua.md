---
description: MultiArch Alpine Linux + S6 + Lua + LuaRocks
svcname: lua
tags:
  - dev
  - usershell

# pin lua major.minor
luamajmin: "5.2"
wb_extra_args_build: LUAMAJMIN=5.2

---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base image for applications
/ services that require [Lua][1] and [Luarocks][2] to manage
dependencies.

{{ m.srcimage('alpine-s6') }} with the {{
m.alpinepkg('lua'~luamajmin, star=true) }} and {{
m.alpinepkg('luarocks'~luamajmin) }} package(s) installed
in it.

{% include "pull-image.md" %}

---
Run
---

We can call `lua` commands directly on the container, or run `bash`
in the container to get a [user-scoped][114] shell,

=== "command"
    ``` sh
    docker run --rm -it --name docker_lua woahbase/alpine-lua lua -v
    ```
=== "shell"
    ``` sh
    docker run --rm -it --name docker_lua woahbase/alpine-lua /bin/bash
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                 | Default      | Description
| :---                     | :---         | :---
| S6_LUA_PACKAGES          | empty string | **Comma**-separated list of packages (with optional version) to install globally with `luarocks`. E.g. `luasocket,luajson 1.3.3`
| S6_LUA_USER_PACKAGES     | empty string | **Comma**-separated list of packages (with optional version) to install with `luarocks` that are local for `S6_USER`. These are installed in `~/.luarocks/`.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Lua `(major).(minor)` version (e.g. `{{ luamajmin }}`) is available in the
  image as the environment variable `LUAMAJMIN`, for any image
  built from this image, this can be used to install the correct
  packages for the specific lua version installed.

* When installing user packages via the `S6_LUA_USER_PACKAGES`
  variable, it is required to run `eval "$(luarocks path --bin)"`
  to make those packages require-able. The command is
  automatically appended in `/etc/bash/bashrc` so that it is
  executed when a `/usershell` session starts.

* If the user packages have binaries inside `~/.luarocks/bin`,
  those are automatically added to path.

[1]: http://www.lua.org/
[2]: https://luarocks.org/

{% include "all-include.md" %}
