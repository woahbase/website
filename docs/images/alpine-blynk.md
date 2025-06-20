---
description: Container for Alpine Linux + S6 + GNU LibC + OpenJDK8 + Blynk Server
skip_aarch64: 1
skip_armv7l: 1
tags:
  - deprecated
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [Blynk][1] IOT server,
a platform for visualizing/controlling microcontrollers like
Arduino, RaspberryPi etc that use their [library][3], over the
web, running under [OpenJDK-8][2].

{{ m.srcimage('alpine-openjdk8') }} with the blynk-server [jar][4]
installed in it. {{ m.ghreleasestr('blynkkk/blynk-server') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm -it \
  --name docker_blynk \
  -p 7443:7443 -p 8080:8080 \
  -p 8081:8081 -p 8082:8082 \
  -p 8441:8441 -p 8442:8442 \
  -p 8443:8443 -p 9443:9443 \
  -v /etc/localtime:/etc/localtime:ro \
woahbase/alpine-blynk:x86_64
```

--8<-- "multiarch.md"

---
##### Configuration
---

* Blynk home is at `/opt/blynk`.

* User data is at `/opt/blynk/data`. Mount this directory in local
  to persist blynk configuration data.

* Default configurations for server and mail is provided right
  inside the Blynk home directory as `/opt/blynk/server.properties` and
  `/opt/blynk/mail.properties`. Edit or remount these files to use
  custom configurations.

* By default, Blynk binds to the following ports :

    * 7443: Administration UI HTTPS port
    * 8080: HTTP port
    * 8081: Web socket ssl/tls port
    * 8082: Web sockets plain tcp/ip port
    * 8441: Hardware ssl/tls port (for hardware that supports SSL/TLS sockets)
    * 8442: Hardware plain tcp/ip port
    * 8443: Application mutual ssl/tls port
    * 9443: HTTPS port

* This image already has a user `alpine` configured to drop
  privileges to the passed `PUID`/`PGID` which is ideal if its
  used to run in non-root mode. That way you only need to specify
  the values at runtime. (run `id` in your terminal to see your
  own `PUID`/`PGID` values.)

[1]: https://www.blynk.cc/
[2]: https://openjdk.org/projects/jdk8/
[3]: https://github.com/blynkkk/blynk-library
[4]: https://github.com/blynkkk/blynk-server/releases

{% include "all-include.md" %}
