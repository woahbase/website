---
description: Container for Alpine Linux + S6 + GNU LibC + OpenJDK8 + Jenkins
skip_aarch64: true
skip_armv7l: true
tags:
  - legacy
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the [Jenkins][1] master to monitor and
run periodic/triggered builds/jobs/tasks. Uses [OpenJDK-8][2] as
runtime.

{{ m.srcimage('alpine-glibc') }} with the Jenkins (stable)
[warfile][3] installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm -it \
  --name docker_jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v data:/var/jenkins_home \
woahbase/alpine-jenkins:x86_64
```

--8<-- "multiarch.md"

[1]: http://jenkins.io/
[2]: https://openjdk.org/projects/jdk8/
[3]: http://mirrors.jenkins.io/war-stable/

{% include "all-include.md" %}
