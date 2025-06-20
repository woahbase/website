{%- set cntname = 'docker_'~ svcname|default(page.title.split('-')[-1]) -%}
Stop the container with a timeout, (defaults to 2 seconds)

``` sh
docker stop -t 2 {{ cntname }}
```

Restart the container with

``` sh
docker restart {{ cntname }}
```

Removes the container, (always better to stop it first and `-f`
only when needed most)

``` sh
docker rm -f {{ cntname }}
```

---
##### Shell access
---

Get a shell inside a already running container,

``` sh
docker exec -it {{ cntname }} /bin/bash
```


{% if not ('foreign' in tags) -%}
Optionally, login as a non-root user, (default is `{{ s6_user | default('alpine') }}`)

``` sh
docker exec -u {{ s6_user | default('alpine') }} -it {{ cntname }} /bin/bash
```
{%- endif %}

Or set user/group id e.g 1000/1000,

``` sh
docker exec -u 1000:1000 -it {{ cntname }} /bin/bash
```

---
##### Logs
---

To check logs of a running container in real time

``` sh
docker logs -f {{ cntname }}
```

