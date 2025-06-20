---
description: Container for Alpine Linux + S6 + GNU LibC + OpenJDK8 + WildFly (JBoss) server
tags:
  - deprecated
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the server for applications / services
that require a [WildFly][1] server, running under [OpenJDK-8][2].

Current [released version][3] is `17.0.1.Final`.

{{ m.srcimage('alpine-openjdk8') }} with the server
[jarfile][3] installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm -it \
  --name docker_wildfly \
  -e USERNAME=admin \
  -e PASSWORD=insecurebydefault \
  -e SERVERCONFIG=standalone.xml \
  -p 8080:8080 \
  -p 9990:9990 \
  -v deployments:/opt/jboss/wildfly/standalone/deployments \
woahbase/alpine-wildfly:x86_64
```
--8<-- "multiarch.md"

---
##### Configuration
---

* Wildfly runs under the user `alpine`, which is ideal to run in
  non-root mode.

* Default administration credentials are : `admin` : `insecurebydefault`.

* For standalone usage, only needed to mount the `deployments`
  directory with the WAR/JAR files, optionally `standalone.xml` if
  there are specifications. For the latter and if additional libs
  are needed, rebind the `lib` directory as well.

* the `SERVERCONFIG` environment variable which configuration to
  use inside the configuration directory, the `USERNAME` and the
  `PASSWORD` environment variables specify the default
  administrator credentials.

[1]: http://wildfly.org/
[2]: https://openjdk.org/projects/jdk8/
[3]: https://wildfly.org/downloads/

{% include "all-include.md" %}

