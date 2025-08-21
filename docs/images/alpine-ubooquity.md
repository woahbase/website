---
description: MultiArch Alpine Linux + S6 + GNU LibC + OpenJDK17 + Ubooquity
alpine_branch: v3.22
arches: [aarch64, ppc64le, s390x, x86_64]
has_services:
  - compose
has_proxies:
  - nginx
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [Ubooquity][1] e-book
server/viewer, to serve files and read comics/ebooks shared from
a device in the network, running under [OpenJDK][2] 17.\*.\*.

{{ m.srcimage('alpine-openjdk17') }} with the application
[jarfile][3] installed in it. Current released version is `3.1.0`.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_ubooquity \
  -e MAXMEM=1024 \
  -p 2202:2202 \
  -p 2203:2203 \
  -v $PWD/data/config:/config \
  -v $PWD/data/books:/books \
  -v $PWD/data/comics:/comics \
  -v $PWD/data/files:/files \
woahbase/alpine-ubooquity
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                | Default                                      | Description
| :---                    | :---                                         | :---
| UBOOQUITY_HOME          | /opt/ubooquity                               | Path to `ubooquity` jarfile.
| UBOOQUITY_CONFIG        | /config                                      | Path to configuration directory.
| UBOOQUITY_PATH_BOOKS    | /books                                       | Path to books directory, if set and `${UBOOQUITY_CONFIG}/preferences.json` does not exist (i.e. on first run), updated in the default configuration. Required for permission-fixes on files. {{ m.sincev('2.1.5') }}
| UBOOQUITY_PATH_COMICS   | /comics                                      | Path to comics directory, if set and `${UBOOQUITY_CONFIG}/preferences.json` does not exist (i.e. on first run), updated in the default configuration. Required for permission-fixes on files. {{ m.sincev('2.1.5') }}
| UBOOQUITY_PATH_FILES    | /files                                       | Path to files directory, if set and `${UBOOQUITY_CONFIG}/preferences.json` does not exist (i.e. on first run), updated in the default configuration. Required for permission-fixes on files. {{ m.sincev('2.1.5') }}
| UBOOQUITY_ADMIN_PORT    | 2203                                         | Default admin port, if set and `${UBOOQUITY_CONFIG}/preferences.json` does not exist (i.e. on first run), updated in the default configuration. {{ m.sincev('2.1.5') }}
| UBOOQUITY_ADMIN_ENABLED | true                                         | Whether admin is enabled, if set and `${UBOOQUITY_CONFIG}/preferences.json` does not exist (i.e. on first run), updated in the default configuration. {{ m.sincev('2.1.5') }}
| UBOOQUITY_LIBRARY_PORT  | 2202                                         | Default library port, if set and `${UBOOQUITY_CONFIG}/preferences.json` does not exist (i.e. on first run), updated in the default configuration. {{ m.sincev('2.1.5') }}
| UBOOQUITY_SUBPATH       | unset                                        | Default reverse proxy prefix, if set and `${UBOOQUITY_CONFIG}/preferences.json` does not exist (i.e. on first run), updated in the default configuration. {{ m.sincev('2.1.5') }}
| UBOOQUITY_ARGS          | --headless --host 0.0.0.0 --libraryport 2202 | Customizable arguments passed to `ubooquity` service.
| UBOOQUITY_SKIP_PERMFIX  | unset                                        | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `ubooquity` configuration/data files/directories. {{ m.sincev('3.1.0') }}
| UBOOQUITY_PERMFIX_FILES | unset                                        | If set to `true`, ensures files inside books/comics/files directories are owned/accessible by `${S6_USER}`. {{ m.sincev('2.1.5') }}
| MAXMEM                  | 1024                                         | Limits how much memory (MB) the JVM can use.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/config/preferences.json', fr='`ubooquity`') }}

* By default, expects books to be at path `/books`, comics at
  `/comics` and files from `/files`. They should be readable by
  the process user.

* By default, exposes the `libraryport` at `2202` and if enabled,
  `adminport` at `2203`.

* On first-run, visit the administrator url (e.g.
  [http://your.service.local:2203/admin](http://your.service.local:2203/admin)
  when no reverse proxy prefix is set, else `/(prefix)/admin`, no
  ending `/`) and set your administrator password. Afterwards, you
  can disable `adminport` either from the web-ui-configuration or
  modify `preferences.json` accordingly.

* Version `2.x.x` used to require OpenJDK8, since version `3.1.0`,
  that has been updated to OpenJDK17, architecture support is
  subject to OpenJDK APK packages as made available by Alpine
  Linux.

* Refer to the [Installation Guide][4] or [User Manual][5] for
  more information.

[1]: http://vaemendis.net/ubooquity/
[2]: https://openjdk.org/projects/jdk/17/
[3]: https://vaemendis.net/ubooquity/static2/download
[4]: https://vaemendis.github.io/ubooquity-doc/pages/installation-guide.html
[5]: https://vaemendis.github.io/ubooquity-doc/pages/manual.html

{% include "all-include.md" %}
