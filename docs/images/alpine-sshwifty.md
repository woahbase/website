---
description: MultiArch Alpine Linux + S6 + SSHwifty Web SSH & Telnet Client
alpine_branch: v3.23
arches: [aarch64, armhf, armv7l, i386, ppc64le, x86_64]
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [SSHwifty][1], a SSH and
Telnet client with a *nice* WebUI. Useful to connect to multiple
hosts via the browser without needing any additional dependencies
on the host.

{{ m.srcimage('alpine-s6') }} with the `sshwifty` binary installed
in it. {{ m.ghreleasestr('nirui/sshwifty') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_sshwifty \
  -p 8182:8182 \
  -v $PWD/config:/config \
  -v $PWD/ssh:/config/ssh \
woahbase/alpine-sshwifty
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                 | Default                    | Description
| :---                     | :---                       | :---
| SSHWIFTY_CONFIG          | /config/sshwifty.conf.json | Path to `sshwifty` configuration file.
| SSHWIFTY_SHAREDKEY       | insecurebydefault          | Default authorization password. (Only set if using default configuration file)
| SSHWIFTY_LISTENINTERFACE | 0.0.0.0                    | Default listen interface. (Only set if using default configuration file)
| SSHWIFTY_LISTENPORT      | 8182                       | Default listen port. (Only set if using default configuration file)
| SSHWIFTY_SERVERMESSAGE   | empty string               | Default server message. (Only set if using default configuration file)
| SSHWIFTY_SKIP_PERMFIX    | unset                      | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `sshwifty` configuration/data files/directories. {{ m.sincev('0.3.25-beta-release-prebuild') }}
| SSHWIFTY_ARGS            | unset                      | Customizable arguments passed to `sshwifty` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/config/sshwifty.conf.json', vname='SSHWIFTY_CONFIG') }}

* Optionally, mount your SSH private/public keys under
  `/config/ssh/`. Make sure configurations reflect the same.

[1]: https://sshwifty-demo.nirui.org/
[2]: https://github.com/nirui/sshwifty/releases

{% include "all-include.md" %}
