---
description: MultiArch Alpine Linux + S6 + GNU LibC + OpenJDK 17
alpine_branch: v3.22
arches: [aarch64, ppc64le, s390x, x86_64]
ghrepo: alpine-openjdk
dockerfile: Dockerfile.17
wb_extra_args: JVVMAJOR=17
tags:
  - dev
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}


This [image][155] serves as the base image for applications
/ services that require an [OpenJDK17][1] compiler/runtime.

{{ m.srcimage('alpine-glibc') }} with the {{
m.alpinepkg('openjdk17', star=true) }} packages installed in it.

{% include "pull-image.md" %}

---
Run
---

We can call `java` commands directly on the container, or run
`bash` in the container to get a shell,

=== "command"
    ``` sh
    docker run --rm -it --name docker_openjdk17 woahbase/alpine-openjdk17 java -version
    ```
=== "shell"
    ``` sh
    docker run --rm -it --name docker_openjdk17 woahbase/alpine-openjdk17 /bin/bash
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars  | Default                      | Description
| :---      | :---                         | :---
| JAVA_HOME | /usr/lib/jvm/java-17-openjdk | (Preset) Specifies which Java runtime environment (JRE) to use.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

[1]: https://openjdk.org/projects/jdk/17/
[2]: https://github.com/openjdk/jdk/

{% include "all-include.md" %}
