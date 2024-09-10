---
description: MultiArch Alpine Linux + S6 + Squid Proxy/Content Cache.
svcname: squid
has_services:
  - compose
  - nomad
tags:
  - compose
  - nomad
  - package
  - s6
  - service

s6_user: squid
s6_userhome: /var/cache/squid

---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [Squid][1] proxy server to
setup a local web content cache or transparent proxy.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('squid') }}
package installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_squid \
  -p 3128:3128 -p 3129:3129 \
  -v $PWD/config:/etc/squid \
  -v $PWD/cache:/var/cache/squid \
woahbase/alpine-squid
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars           | Default              | Description
| :---               | :---                 | :---
| SQUID_CONFDIR      | /etc/squid           | Path to configuration dir. Expects `squid.conf` to exist in this directory. {{ m.sincev('6.9') }} Previously `CONFDIR`.
| SQUID_CACHEDIR     | /var/cache/squid     | Path to cached contents directory as set in `squid.conf`. If empty, the required directory hierarchy for `squid` is initialized. {{ m.sincev('6.9') }} Previously `CACHEDIR`.
| SQUID_HTPASSWDFILE | /etc/squid/.htpasswd | Path to `squid` authentication file. {{ m.sincev('6.9') }} Previously `HTPASSWDFILE`.
| WEBADMIN           | admin                | Default user.
| PASSWORD           | insecurebydefault    | Default user password.
| SQUID_NO_HTPASSWD  | unset                | Set to `true` to disable generating password file. Ensure it is disabled in your own configuration if not needed.
| SQUID_ARGS         | -NYCd 5              | Customizable arguments passed to `squid` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Config files are at `/etc/squid/`, edit or remount files here
  with your own. A {{ m.ghfilelink('root/defaults/squid/', title='sample') }}
  is provided in `/defaults`, these get copied if none exists.
  Look into the [Configuration reference][3] and
  [ConfigExamples][2] to customize as needed.

* Default configuration listens to ports `3128` and
  `3129`(interceptor).

[1]: http://www.squid-cache.org/
[2]: https://wiki.squid-cache.org/ConfigExamples/
[3]: http://www.squid-cache.org/Doc/config/

{% include "all-include.md" %}
