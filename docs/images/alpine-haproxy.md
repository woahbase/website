---
description: MultiArch Alpine Linux + S6 + HAProxy + DataPlaneAPI
svcname: haproxy
has_services:
  - compose
  - nomad
tags:
  - github
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [HAProxy][1] reverse-proxy
server to manage proxying (optionally also load-balancing and
high-availability) for services running in the network. Includes
[Data-Plane API][2] to dynamically configure HAProxy.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('haproxy') }}
package and binaries from {{ m.ghreleaselink('haproxytech/dataplaneapi') }}
installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_haproxy \
  -p 80:80 \
  -p 443:443 \
  -p 8080:8080 \
  -p 5556:5556 \
  -v $PWD/config:/etc/haproxy \
woahbase/alpine-haproxy
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars        | Default                  | Description
| :---            | :---                     | :---
| HAPROXY_CONF    | /etc/haproxy/haproxy.cfg | Path to configuration file.
| HAPROXY_DATA    | /var/lib/haproxy         | Path to datastore.
| HAPROXY_ARGS    | -db                      | Customizable arguments passed to `haproxy` service.
| HAPROXY_CRTFILE | unset                    | (Optional) Path to SSL certificate and private-key as one PEM-encoded file, unset by default, set to enable it in default configuration e.g `/etc/haproxy/ssl/certificate.pem`. Generates self-signed certificates when set but file not found.
| HAPROXY_PROMEX  | unset                    | Set to `true` to enable prometheus exporter frontend at port `8405` in default configuration.
| DPA_ARGS        | unset                    | Customizable arguments passed to `dataplaneapi`, unset by default, **required** to be set to start `dataplaneapi` supervised by `haproxy` in the default configuration. You can either pass all configuration options here or use the `DPA_CONF` file (or both).
| DPA_CONF        | unset                    | Path to `dataplaneapi` configuration file, unset by default, set to enable it in default configuration e.g `/etc/haproxy/dataplaneapi.yaml`. Copies default configuration when set but file not found.
| SSLSUBJECT      | see [here](alpine-nginx.md#ssl-subject) | Default SSL Subject for self-signed certificate generation on first run.
{% include "envvars/alpine-s6.md" %}

Also,

* {{ m.defcfgfile('/etc/haproxy/haproxy.cfg', vname='HAPROXY_CONF') }}
  Check the [haproxy-docs][3] or [examples][5] to configure
  HAProxy.

* {{ m.defcfgfile('/etc/haproxy/dataplaneapi.yaml', fr='DataPlaneAPI (optional)', vname='DPA_CONF') }}
  Check the [Data-Plane API docs][4] and its [API Endpoints][8] for
  customizing Data-Plane API.

* Check the [LUA API Docs][9] to extend HAProxy using the embedded
  Lua interpreter.

* {{ m.customscript('p12-haproxy-customize') }}

<!--* Other Links:
  > * [HAProxy Git Repository][6]
  > * [Github Mirror][7] -->

[1]: https://www.haproxy.org/
[2]: https://github.com/haproxytech/dataplaneapi
[3]: https://www.haproxy.com/documentation/
[4]: https://www.haproxy.com/documentation/haproxy-data-plane-api/
[5]: https://github.com/haproxy/haproxy/tree/master/examples
[6]: https://git.haproxy.org/
[7]: https://github.com/haproxy/haproxy
[8]: https://www.haproxy.com/documentation/dataplaneapi/
[9]: https://www.haproxy.com/documentation/haproxy-lua-api/getting-started/introduction/

{% include "all-include.md" %}
