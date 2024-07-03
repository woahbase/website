---
description: Container for Alpine Linux + S6 + GNU LibC + OpenJDK 8
svcname: openjdk8
ghrepo: alpine-openjdk
wb_extra_args: JVVMAJOR=8
tags:
  - dev
  - glibc
  - openjdk
  - package
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}


This [image][155] serves as the base image for applications
/ services that require an [OpenJDK8][1] compiler/runtime.

{{ m.srcimage('alpine-glibc') }} with the {{
m.alpinepkg('openjdk8', star=true) }} packages installed in it.

{% include "pull-image.md" %}

---
Run
---

We can call `java` or `npm` directly on the container, or run
`bash` in the container to get a [user-scoped][114] shell,

=== "command"
    ``` sh
    docker run --rm -it --name docker_openjdk8 woahbase/alpine-openjdk8 java -version
    ```
=== "shell"
    ``` sh
    docker run --rm -it --name docker_openjdk8 woahbase/alpine-openjdk8 /bin/bash
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars  | Default                       | Description
| :---      | :---                          | :---
| JAVA_HOME | /usr/lib/jvm/java-1.8-openjdk | (Preset) Specifies which Java runtime environment (JRE) to use.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

[1]: https://openjdk.org/projects/jdk8/
[2]: https://github.com/openjdk/jdk/

{% include "all-include.md" %}
