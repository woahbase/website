---
description: MultiArch Alpine Linux + S6 Init System.
svcname: s6
tags:
  - shell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as a base image for applications
/ services that need an init system to launch the process(es) and
pass the proper signals when interacted with the containers.

{{ m.srcimage('alpine-base') }} with the [s6][1] init system
[overlayed][2] on it. {{ m.ghreleasestr('just-containers/s6-overlay') }}

{% include "pull-image.md" %}

---
Run
---

Run `bash` in the container to get a shell.

=== "shell"
    ``` sh
    docker run --rm --name docker_s6 woahbase/alpine-s6 /bin/bash
    ```
=== "usershell"
    ``` sh
    docker run --rm -it --name docker_s6 --entrypoint /usershell woahbase/alpine-s6 /bin/bash
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars           | Default       | Description
| :---               | :---          | :---
{% include "envvars/alpine-s6.md" %}
| HGID_(groupname)   | unset         | Update (or create) `groupname` with **non-zero positive integer** `gid` (to match with host). E.g `HGID_VIDEO=995` will change `gid` of `video` group to `995`. {{ m.sincev('3.2.0.0') }}
| S6_USERGROUPS      | empty string  | **Comma**-separated list of groups to add `S6_USER` to. E.g. `"audio,video,tty"`, groups **must** exist.
| S6_USERPASS        | unset         | Password for `S6_USER`.

--8<-- "check-id.md"

But wait!! There's more...

###### Secrets

To use [docker-secrets][3] that are available inside the container
as pre-exported environment variables, we can specify the variable
as `SECRET__(variablename)` with the path to the secret-file set
as the value, and at runtime it should read and export the secret
as the value of `variablename`. These environment variables are
available to any scope that uses container-env (`with-contenv`).

###### Usershell

Docker images by default, do not provide a easy way to dynamically
drop privileges to a user before executing `CMD` definitions, it
is not always feasible to hardcode those in the `Dockerfile` and
it becomes more complex with the additional initialization stages
that `s6` introduces. To ease this problem, in addition to the
`/init` entrypoint script that s6 brings, another alternate script
is added at `/usershell` that takes over the initialization stage
tasks, and then executes the `CMD` **as a not-root user**. This
way, images that set their entrypoint to `/usershell` have all the
benefits of s6, but the CMD that is run, is run by `S6_USER` (by
default `alpine`). Checkout any of the images tagged
[usershell][4] for an example.

[1]: https://skarnet.org/software/s6/
[2]: https://github.com/just-containers/s6-overlay
[3]: https://docs.docker.com/engine/reference/commandline/secret/
[4]: index.md#usershell
[5]: https://github.com/just-containers/s6-overlay/blob/master/MOVING-TO-V3.md
[6]: https://skarnet.org/software/s6-rc/s6-rc-compile.html
[7]: https://skarnet.org/software/s6/servicedir.html

{% include "all-include.md" %}
