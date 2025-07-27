---
description: MultiArch Alpine Linux + S6 + Lua + LuaRocks
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, i386, ppc64le, riscv64, s390x, x86_64]
tags:
  - dev
  - usershell

# pin lua major.minor
luamajmin: "5.4"
wb_extra_args: LUAMAJMIN=5.4
wb_extra_args_run: ""
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base image for applications
/ services that require [Lua][1] and [Luarocks][2] to manage
dependencies.

{{ m.srcimage('alpine-s6') }} with the {{
m.alpinepkg('lua?.?', title='lua') }} and {{
m.alpinepkg('luarocks?.?', title='luarocks') }} package(s) installed
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
| S6_LUA_USER_PACKAGES     | empty string | **Comma**-separated list of packages (with optional version) to install with `luarocks` that are local for `${S6_USER}`. These are installed in `${USERROCKSDIR}`.
| USERROCKSDIR             | ~/.luarocks  | Customizable path where user-specified rocks are installed in.
| LUA_SKIP_MODIFY_PATH     | unset        | By default, user-scoped binaries installed by `luarocks` (in `${USERROCKSDIR}`) are added automatically to path, setting this to e.g `1` skips that step. {{ m.sincev('5.2.4_20250622') }}
| LUA_SKIP_MODIFY_LUAPATH  | unset        | By default, user-scoped libararies installed by `luarocks` (in `${USERROCKSDIR}`) are added automatically to `LUA_PATH` if not already exists, setting this to e.g `1` skips that step. {{ m.sincev('5.2.4_20250622') }}
| LUA_SKIP_MODIFY_LUACPATH | unset        | By default, user-scoped shared objects installed by `luarocks` (in `${USERROCKSDIR}`) are added automatically to `LUA_CPATH` if not already exists, setting this to e.g `1` skips that step. {{ m.sincev('5.2.4_20250622') }}
| LUA_SKIP_MODIFY_SHELL    | unset        | By default, `/etc/bash/bashrc` is changed to evaluate updated paths for `lua` at session start, setting this to e.g `1` skips that step. {{ m.sincev('5.2.4_20250622') }}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Lua `(major).(minor)` version (e.g. `{{ luamajmin }}`) is available in the
  image as the environment variable `${LUAMAJMIN}`, for any image
  built from this image, this can be used to install the correct
  packages for the specific lua version installed.

* When installing user packages via the `${S6_LUA_USER_PACKAGES}`
  variable, it is required to run `eval "$(luarocks path --bin)"`
  to make those packages require-able. By default, the command is
  automatically appended in `/etc/bash/bashrc` so that it is
  executed when a `/usershell` session starts.

* By default, if the user packages have binaries inside
  `${USERROCKSDIR}/bin`, those are automatically added to path.

[1]: http://www.lua.org/
[2]: https://luarocks.org/

{% include "all-include.md" %}
