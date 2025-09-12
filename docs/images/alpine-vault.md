---
description: MultiArch Alpine Linux + S6 + HashiCorp Vault
alpine_branch: v3.22
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

This [image][155] serves as a distributed secret
generator/provider/store for running services using Hashicorp
[Vault][1]. Can be coupled with the {{ m.myimage('alpine-consul')
}} image or used by itself.

{{ m.srcimage('alpine-s6') }} with the [vault][2] **OSS** binaries
installed in it. {{ m.ghreleasestr('hashicorp/vault') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --cap-add IPC_LOCK \
  --name docker_vault \
  -p 8200:8200 \
  -p 8201:8201 \
  -v $PWD/data:/vault \
woahbase/alpine-vault
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                | Default              | Description
| :---                    | :---                 | :---
| VAULT_HOME              | /vault               | (Preset) Root directory for `vault` configuration and data.
| VAULT_CONFIG_DIR        | ${VAULT_HOME}/config | Configuration directory for `vault`.
| VAULT_DATA_DIR          | ${VAULT_HOME}/file   | Datastore directory for `vault`.
| VAULT_LOGS_DIR          | ${VAULT_HOME}/logs   | Logs directory for `vault`.
| VAULT_LOCAL_CONFIG      | unset                | If set, creates the file `${VAULT_CONFIG_DIR}/local.hcl` with the contents of the variable (JSON/hcl extension can be changed by setting `${VAULT_CONFLANG}` defaults to `hcl`).
| VAULT_ROLE              | server               | Can be one of `server` or `agent` or `proxy`.  (Agent/Proxy mode will only read `agent.hcl` or `proxy.hcl` respectively)
| VAULT_CONFLANG          | hcl                  | Used to set the extension to the local configuration file (e.g. `local.hcl` or `local.json`).
| VAULT_SKIP_ENSURECONFIG | unset                | If set, skips setting up default configuration.
| VAULT_SKIP_SETCAP       | unset                | If set, skips setting capabilities on `vault` binary before starting service.
| VAULT_SKIP_PERMFIX      | unset                | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `vault` configuration or data files/directories.
| VAULT_ARGS              | unset                | Customizable arguments passed to `vault` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/vault/config/server.hcl', fr='server') }}

* {{ m.defcfgfile('/vault/config/agent.hcl', fr='agent (when `VAULT_ROLE` is `agent`)') }}

* {{ m.defcfgfile('/vault/config/proxy.hcl', fr='proxy (when `VAULT_ROLE` is `proxy`)') }}

* {{ m.customscript('p11-vault-customize') }}

* Checkout their [docs][3] for configuration, integrations, or
  tutorials. Refer to the [change tracker][4], [deprecation
  notices][5], or [important changes][6] before upgrading.

[1]: https://www.vault.io/
[2]: https://releases.hashicorp.com/vault/
[3]: https://developer.hashicorp.com/vault/docs
[4]: https://developer.hashicorp.com/vault/docs/updates/change-tracker
[5]: https://developer.hashicorp.com/vault/docs/updates/deprecation
[6]: https://developer.hashicorp.com/vault/docs/updates/important-changes

{% include "all-include.md" %}
