---
description: Container for Alpine Linux + S6 + GNU LibC + OpenJDK 14
ghrepo: alpine-openjdk
dockerfile: Dockerfile.14
skip_armhf: true
skip_armv7l: true
wb_extra_args: JVVMAJOR=14
tags:
  - deprecated
  - dev
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}


This [image][155] serves as the base image for applications
/ services that require an [OpenJDK14][1] compiler/runtime.

{{ m.srcimage('alpine-glibc') }} with the {{
m.alpinepkg('openjdk14', star=true, branch='v3.18') }} packages installed in it.

???+ warning "JDK 14 Deprecation"

    OpenJDK `14.*.*` prebuilt packages has been excluded from
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
    docker run --rm -it --name docker_openjdk14 woahbase/alpine-openjdk14 java -version
    ```
=== "shell"
    ``` sh
    docker run --rm -it --name docker_openjdk14 woahbase/alpine-openjdk14 /bin/bash
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars  | Default                      | Description
| :---      | :---                         | :---
| JAVA_HOME | /usr/lib/jvm/java-14-openjdk | (Preset) Specifies which Java runtime environment (JRE) to use.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

[1]: https://openjdk.org/projects/jdk/14/
[2]: https://github.com/openjdk/jdk/

{% include "all-include.md" %}
