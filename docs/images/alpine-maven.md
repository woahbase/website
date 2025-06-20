---
description: MultiArch Alpine Linux + S6 + GNU LibC + OpenJDK8 + Maven
tags:
  - dev
  - github
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [Maven][2], a build automation
tool along with its [OpenJDK8][1] dependencies.

{{ m.srcimage('alpine-openjdk8') }} with the maven3 [binaries][4]
installed in it. {{ m.ghreleasestr('apache/maven') }}

{% include "pull-image.md" %}

---
Run
---

We can call `mvn` commands directly on the container, or run
`bash` in the container to get a shell,

=== "command"
    The usual maven stuff. e.g clean pack a project with
    ``` sh
    docker run --rm -it \
      --name docker_maven \
      --workdir /home/alpine/project \
      -v $PWD:/home/alpine/project \
    woahbase/alpine-maven \
      mvn clean package
    ```
=== "shell"
    ``` sh
    docker run --rm -it \
      --name docker_maven \
      --workdir /home/alpine/project \
      -v $PWD:/home/alpine/project \
    woahbase/alpine-maven \
      /bin/bash
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars           | Default          | Description
| :---               | :---             | :---
| MAVEN_HOME         | /usr/share/maven | (Preset) Path to `mvn` binaries.
| MAVEN_CONFIG       | /home/alpine/.m2 | Path to user-scoped directory for configurations or cache.
| MAVEN_SKIP_PERMFIX | unset            | If set to non-empty-string value (e.g. `1`), skips ensuring files under `${MAVEN_CONFIG}` directory are readable by `${S6_USER}`. {{ m.sincev('3.9.9') }}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Mount the project directory (where `pom.xml` is) at
  `/home/alpine/project` and (optionally set it as `workdir`).
  Mounts `$PWD` by default.

* Maven runs under the user `alpine`.

* {{ m.customscript('p11-maven-customize') }}

* Optionally, if you want to cache the jars/packages downloaded by
  maven, so that they're downloaded once, and reused in later
  builds, bind mount the user home directory (`/home/alpine`)
  somewhere in your local. The packages get cached inside the
  `/home/alpine/.m2` folder.

[1]: http://openjdk.java.net/
[2]: https://maven.apache.org/
[3]: https://maven.apache.org/download.cgi
[4]: https://archive.apache.org/dist/maven/maven-3/

{% include "all-include.md" %}
