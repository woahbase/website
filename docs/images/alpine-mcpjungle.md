---
description: MultiArch Alpine Linux + S6 + MCPJungle (+uvx|npx|docker-cli)
alpine_branch: v3.23
arches: [aarch64, x86_64]
has_services: [compose, nomad, systemd]
tags: [service]
s6_userhome: /config
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [MCPJungle][1] to consolidate and
manage multiple MCP servers (can be either `stdio`, or
`streamable_http`) through a single (or multiple?), authenticated,
access-controlled service endpoint.


{{ m.srcimage('alpine-s6') }} with the [mcpjungle][2] binaries installed
in it. Includes [python3][5]/[uv][6] (for `uvx`), [nodejs][7]/[npm][8]
(for `npx`) and {{ m.alpinepkg('docker-cli') }} to support running most
(if not all) MCP servers that use `stdio`. {{ m.ghreleasestr('mcpjungle/MCPJungle') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_mcpjungle \
  -p 8080:8080 \
  -v $PWD/config:/config \
  -v /var/run/docker.sock:/var/run/docker.sock `#(1)` \
woahbase/alpine-mcpjungle
```

1. Only **required** for Docker-based MCP servers. Optionally, also set
   `PGID` to the numeric `docker`-group-id to allow the server process
   to use docker running outside of the container.

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                        | Default     | Description
| :---                            | :---        | :---
| GID_DOCKER                      | unset       | Group-id of `docker` group on the host. If set, updates group-id of the group `docker` inside container, and adds `${S6_USER}` to the group. When unspecified, the socket permissions are used instead.
| MCPJUNGLE_ROOT                  | /config     | (Preset) Path to `mcpjungle` configuration/data directory
| MCP_SERVER_INIT_REQ_TIMEOUT_SEC | 120         | Maximum time for server initialization. Increase if you're downloading larger packages or container-images.
| OTEL_ENABLED                    | false       | Set to `true` to enable `prometheus` metrics.
| SESSION_IDLE_TIMEOUT_SEC        | 300         | Maximum session idle time for stateful MCP servers.
| SERVER_MODE                     | development | Can be either `development` or `enterprise`, determines whether to enable authentication.
| PORT                            | 8080        | Default port.
| MCPJUNGLE_SKIP_PERMFIX          | unset       | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `mcpjungle` configuration files/directories.
| MCPJUNGLE_ARGS                  | unset       | Customizable arguments passed to `mcpjungle` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Refer to their [docs][1] or [cli-reference][3] for customizing your
  own.

* By default, expects the environment-configuration file to exist under
  the configuration directory e.g. `/config/.env`.

* **Does not include** Docker Engine. You must have docker setup and
  configured in your host system, and the user runnng MCPJungle allowed
  to communicate to docker via the socket.

* By default, the service uses `sqlite3` as the database. If using
  `postgresql`, you will need to set `DATABASE_URL` or any of the
  database-specific [environment-variables][4], also checkout our {{
  m.myimage('alpine-postgresql') }} image.

* For any MCP server that provides its own binary, mount those inside
  `/usr/local/bin` to make them available to MCPJungle.

* {{ m.customscript('p11-mcpjungle-customize') }}

* Checkout the official [examples][9] and [servers-list][10] to discover
  and use awesome MCP-servers.

[1]: https://docs.mcpjungle.com/
[2]: https://github.com/mcpjungle/MCPJungle/releases
[3]: https://docs.mcpjungle.com/reference/cli-overview
[4]: https://docs.mcpjungle.com/reference/environment-variables
[5]: https://www.python.org/
[6]: https://docs.astral.sh/uv/
[7]: https://nodejs.org/
[8]: https://www.npmjs.com/
[9]: https://modelcontextprotocol.io/examples
[10]: https://github.com/modelcontextprotocol/servers?tab=readme-ov-file#-resources

{% include "all-include.md" %}
