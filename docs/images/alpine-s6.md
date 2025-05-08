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

| ENV Vars                   | Default         | Description
| :---                       | :---            | :---
{% include "envvars/alpine-s6.md" %}
| S6_USERGROUPS              | empty string    | **Comma**-separated list of groups to add `S6_USER` to. E.g. `"audio,video,tty"`, groups **must** exist.
| S6_USERPASS                | unset           | Password for `S6_USER`.
| FILEURL_`varname`          | unset           | If set to `<url>|<optional /file/path>`, will download `url` to `/file/path`. See [URL to File](#url-to-file). {{ m.sincev('3.2.1.0') }}
| HGID_`groupname`           | unset           | Update (or create) `groupname` with **non-zero positive integer** `gid` (to match with host). E.g `HGID_VIDEO=995` will change (or create if not exists) `gid` of `video` group to `995`. {{ m.sincev('3.2.0.0') }}
| SECRET__`varname`          | unset           | If set to a filepath, the contents of file are loaded in the environment variable `varname`. See [Secrets](#secrets).

--8<-- "check-id.md"

But wait!! There's more...

###### Secrets

To use [docker-secrets][3] that are available inside the container
as pre-exported environment variables, we can specify the variable
as `SECRET__variablename` with the path to the secret-file set
as the value, and at runtime the {{
m.ghfilelink('root/etc/s6-overlay/s6-rc.d/p01-file2env/run',
title='helper-script') }} should read and export the secret as
the value of `variablename`. These environment variables are
available to any scope that uses container-env (`with-contenv`).

###### URL to File

To fetch a file (or a `.tar.gz` archive) from your local
file-server (or any public URL) into the container, use the
environment variable `FILEURL_variablename`
{{ m.ghfilelink('root/etc/s6-overlay/s6-rc.d/p03-wgetfile/run',
title='helper-script') }} {{ m.sincev('3.2.1.0') }}. This will
fetch the file from the specified URL, optionally put the file
in specified filepath (in `/defaults` if not specified). If
the URL points to a `.tar.gz` archive, it is unpacked in the
specified directory.

??? info "URL-to-File defaults and few examples"

    These environment variable control how the file is downloaded
    and unpacked.

    | ENV Vars                   | Default         | Description
    | :---                       | :---            | :---
    | S6_FILEURL_DEFDIR          | /defaults/      | Default directory where the file is downloaded/unpacked when no filepath is specified.
    | S6_FILEURL_DEFOWNER        | root:root       | Default owner/group for a downloaded file. **Does not** apply to unpacked archives by default, set `S6_FILEURL_FIXOWNER_UNPACK` to a non-empty string e.g. `1` to enable for unpacked archives.
    | S6_FILEURL_DEFPERMS        | 0644            | Default permissions for a downloaded file. **Does not** apply to unpacked archives.
    | S6_FILEURL_DELIMITER       | `|`             | Delimiter to separate the `url` and `/file/path`.
    | S6_FILEURL_RETRIES         | 5               | Number of retries for fetching a file, sleeps `5` seconds between retries.
    | S6_FILEURL_STRIPCOMPONENTS | 0               | For stripping directories when unpacking a downloaded archive.
    | S6_FILEURL_TMPDIR          | /tmp/           | Directory where the temporary file is downloaded before moving into proper place.

    For example,

    | Value of FILEURL_(variablename)            | Action
    | :---                                       | :---
    | `https://test.site/a.txt`                  | Get `a.txt` in `/defaults`.
    | `https://test.site/a.txt|/srv/`            | Get `a.txt` in `/srv`.
    | `https://test.site/a.txt|/srv/b.txt`       | Get `a.txt` contents in `/srv/b.txt`.
    | `https://test.site/c.tar.gz`               | Get and unpack `c.tar.gz` in `/defaults`.
    | `https://test.site/c.tar.gz|/srv/`         | Get and unpack `c.tar.gz` in `/srv`.
    | `https://test.site/c.tar.gz|/srv/d.tar.gz` | Get `c.tar.gz` as `/srv/d.tar.gz` but **don't** unpack it.

There are **some limitations**, it uses busybox `wget` so
authentications are not supported (although retries are) so use it
with a hint of caution, and it only supports unpacking for
`.tar.gz` archives. The variable-name has no effect at the moment,
but for the value, remember to specify only **full-paths** (beginning
with a `/`) for filepaths, and end with a `/` to distinguish
between files and directories.

###### Usershell

Docker images by default, do not provide a easy way to dynamically
drop privileges to a user before executing `CMD` definitions, it
is not always feasible to hardcode those in the `Dockerfile` and
it becomes more complex with the additional initialization stages
that `s6` introduces. To ease this problem, in addition to the
`/init` entrypoint script that s6 brings, another {{
m.ghfilelink('root/usershell', title='alternate initscript') }}
is added at `/usershell` that run the initialization stage tasks
as root-user, and then executes the `CMD` **as a not-root
user**. This way, images that set their entrypoint to
`/usershell` have all the benefits of s6, but the CMD that is
run, is run by `S6_USER` (by default `alpine`). Checkout any of
the images tagged [usershell][4] for an example.

[1]: https://skarnet.org/software/s6/
[2]: https://github.com/just-containers/s6-overlay
[3]: https://docs.docker.com/engine/reference/commandline/secret/
[4]: /images/index.md#tag:usershell
[5]: https://github.com/just-containers/s6-overlay/blob/master/MOVING-TO-V3.md
[6]: https://skarnet.org/software/s6-rc/s6-rc-compile.html
[7]: https://skarnet.org/software/s6/servicedir.html

{% include "all-include.md" %}
