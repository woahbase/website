---
description: Container for Alpine Linux + S6 + GNU LibC + OpenJDK 7
svcname: openjdk7
ghrepo: alpine-openjdk
dockerfile: Dockerfile.7
wb_extra_args: JVVMAJOR=7
tags:
  - deprecated
  - dev
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}


This [image][155] serves as the base image for applications
/ services that require an [OpenJDK7][1] compiler/runtime.

{{ m.srcimage('alpine-glibc') }} with the {{
m.alpinepkg('openjdk7', star=true, branch='v3.18') }} packages
installed in it.

???+ warning "JDK 7 Deprecation"

    OpenJDK `7.*.*` prebuilt packages has been excluded from
    Alpine Linux Repositories since `v3.19`. This image uses the
    packages from the `v3.18` repo.

{% include "pull-image.md" %}

---
Run
---

We can call `java` commands directly on the container, or run
`bash` in the container to get a shell,

=== "command"
    ``` sh
    docker run --rm -it --name docker_openjdk7 woahbase/alpine-openjdk7 java -version
    ```
=== "shell"
    ``` sh
    docker run --rm -it --name docker_openjdk7 woahbase/alpine-openjdk7 /bin/bash
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars  | Default                       | Description
| :---      | :---                          | :---
| JAVA_HOME | /usr/lib/jvm/java-1.7-openjdk | (Preset) Specifies which Java runtime environment (JRE) to use.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

[1]: https://openjdk.org/projects/jdk7/
[2]: https://github.com/openjdk/jdk/

{% include "all-include.md" %}
