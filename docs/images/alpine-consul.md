---
description: MultiArch Alpine Linux + S6 + HashiCorp Consul
alpine_branch: v3.23
arches: [aarch64, armhf, armv7l, i386, x86_64]
has_services:
  - compose
has_proxies:
  - nginx
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as a distributed key-value-store and
service registry, to monitor and serve DNS for running services
using Hashicorp [Consul][1].  Can be coupled with the {{
m.myimage('alpine-vault') }} image or used by itself.

{{ m.srcimage('alpine-s6') }} with the [consul][2] **OSS** binaries
installed in it. {{ m.ghreleasestr('hashicorp/consul') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_consul \
  -p 8300:8300 \
  -p 8301:8301/tcp \
  -p 8301:8301/udp \
  -p 8302:8302/tcp \
  -p 8302:8302/udp \
  -p 8500:8500 \
  -p 8501:8501 \
  -p 8502:8502 \
  -p 8503:8503 \
  -p 8600:8600/tcp \
  -p 8600:8600/udp \
  -v $PWD/data:/consul \
woahbase/alpine-consul
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                 | Default               | Description
| :---                     | :---                  | :---
| CONSUL_HOME              | /consul               | (Preset) Root directory for `consul` configuration and data.
| CONSUL_CONFIG_DIR        | ${CONSUL_HOME}/config | Configuration directory for `consul`.
| CONSUL_LOCAL_CONFIG      | unset                 | If set, creates the file `${CONSUL_CONFIG_DIR}/local.hcl` with the contents of the variable (JSON/hcl extension can be changed by setting `${CONSUL_CONFLANG}`, defaults to `hcl`).
| CONSUL_DATA_DIR          | ${CONSUL_HOME}/data   | Data directory for `consul`.
| CONSUL_CONFLANG          | hcl                   | Used to set the extension to the local configuration file (e.g. `local.hcl` or `local.json`).
| CONSUL_SKIP_ENSURECONFIG | unset                 | If set, skips setting up default configuration for agent.
| CONSUL_SKIP_SETCAP       | unset                 | If set, skips setting capabilities on `consul` binary before starting service.
| CONSUL_SKIP_PERMFIX      | unset                 | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `consul` configuration or data files/directories.
| CONSUL_ARGS              | unset                 | Customizable arguments passed to `consul` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/consul/config/agent.hcl') }}

* {{ m.customscript('p11-consul-customize') }}

* Checkout their [docs][3] for configuration, or tutorials. Refer
  to the [version specific changes][4] before upgrading.

[1]: https://www.consul.io/
[2]: https://releases.hashicorp.com/consul/
[3]: https://developer.hashicorp.com/consul/docs
[4]: https://developer.hashicorp.com/consul/docs/upgrade/version-specific

{% include "all-include.md" %}
