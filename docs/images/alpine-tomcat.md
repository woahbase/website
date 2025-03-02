---
description: Container for Alpine Linux + S6 + GNU LibC + OpenJDK8 + Tomcat
svcname: tomcat
tags:
  - legacy
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the server for applications / services
that require a [Tomcat8][1] server **with tomcat-native
extentions**, running under [OpenJDK-8][2].

Current [stable version][3] is `8.5.50`.

{{ m.srcimage('alpine-openjdk8') }} with the [tomcat][3] package
overlayed on it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm -it \
  --name docker_tomcat \
  -p 8080:8080 \
  -v $PWD/webapps:/opt/tomcat/webapps \
woahbase/alpine-tomcat:x86_64
```

--8<-- "multiarch.md"

[1]: https://tomcat.apache.org/
[2]: https://openjdk.org/projects/jdk8/
[3]: https://www.apache.org/dist/tomcat/tomcat-8/

{% include "all-include.md" %}
