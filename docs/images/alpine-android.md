---
description: Container for Alpine Linux + OpenJDK8 + Android + NodeJS + Cordova
alpine_branch: v3.10
arches: [x86_64]
tags:
  - deprecated
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [Android][2] command-line
tools, along with [Gradle][3] and [OpenJDK-8][1] for building
native apps, as well as [Cordova][4] for building hybrid
projects, with its [NPM][5] dependencies.

{{ m.srcimage('alpine-openjdk8') }} with the [android-toolkit][2]
and [cordova][4] packages installed in it.

{% include "pull-image.md" %}

---
#### Run
---

Run the container to get a user-scoped shell,

``` sh
docker run --rm -it \
  --name docker_android \
  -c 512 -m 3072m \
  -v $PWD:/home/alpine/project \
woahbase/alpine-android:x86_64
```

---
##### Configuration
---

* Mount the project directory (where `build.gradle` or
  `package.json` is) at `/home/alpine/project`. Mounts `PWD` by
  default.

* Builds run under the user `alpine`.

* Optionally, if you want to cache the jars/packages downloaded by
  gradle, so that they're downloaded once, and reused in later
  builds, bind mount the user home directory (`/home/alpine`)
  somewhere in your local. The packages get cached inside the
  `/home/alpine/.gradle` folder.

---
##### Common Recipes
---

The usual android stuff. e.g

=== "dev"

    Build developer APK from a project with
    ``` sh
    docker run --rm -it \
      --name docker_android \
      -c 512 -m 1024m \
      -v $PWD:/home/alpine/project \
    woahbase/alpine-android:x86_64 \
      -ec "gradle assembleDebug"
    ```

=== "cordova"

    For Cordova projects, you can build a project with
    ``` sh
    docker run --rm -it \
      --name docker_android \
      -c 512 -m 3072m \
      -v $PWD:/home/alpine/project \
    woahbase/alpine-android:x86_64 \
      -ec "npm install && npm run <your build target>"
    ```

[1]: https://openjdk.org/projects/jdk8/
[2]: https://developer.android.com/studio/#command-tools
[3]: https://gradle.org/
[4]: https://cordova.apache.org/
[5]: https://www.npmjs.com/

{% include "all-include.md" %}
