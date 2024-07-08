---
description: Container for Alpine Linux + S6 + GNU LibC + OpenJDK8 + ActiveMQ
svcname: activemq
skip_aarch64: 1
skip_armv7l: 1
tags:
  - legacy
  - openjdk
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes Apache [ActiveMQ][1] server, for
applications / services that require a pub-sub message queue
, running under [OpenJDK][2] 8.\*.\*.

Current stable version is `5.15.9`.

{{ m.srcimage('alpine-openjdk8') }} with the [activemq][3] package
overlayed on it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm -it \
  --name docker_activemq \
  -p 1883:1883 -p 5672:5672 \
  -p 8161:8161 -p 61613:61613 \
  -p 61614:61614 -p 61616:61616 \
  -v /etc/localtime:/etc/localtime:ro \
woahbase/alpine-activemq:x86_64
```

--8<-- "multiarch.md"

[1]: https://activemq.apache.org/
[2]: http://openjdk.java.net/
[3]: https://downloads.apache.org/activemq/

{% include "all-include.md" %}
