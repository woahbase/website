Stop the container with a timeout, (defaults to 2 seconds)

``` sh
docker stop -t 2 docker_{{ svcname }}
```

Restart the container with

``` sh
docker restart docker_{{ svcname }}
```

Removes the container, (always better to stop it first and `-f`
only when needed most)

``` sh
docker rm -f docker_{{ svcname }}
```

---
##### Shell access
---

Get a shell inside a already running container,

``` sh
docker exec -it docker_{{ svcname }} /bin/bash
```

Optionally, login as a non-root user, (default is `{{ s6_user | default('alpine') }}`)

``` sh
docker exec -u {{ s6_user | default('alpine') }} -it docker_{{ svcname }} /bin/bash
```

Or set user/group id e.g 1000/1000,

``` sh
docker exec -u 1000:1000 -it docker_{{ svcname }} /bin/bash
```

---
##### Logs
---

To check logs of a running container in real time

``` sh
docker logs -f docker_{{ svcname }}
```
