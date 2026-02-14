---
description: MultiArch Alpine Linux + S6 + Webhook Server
alpine_branch: v3.23
arches: [aarch64, armhf, armv7l, i386, x86_64]
has_services:
  - compose
  - systemd
has_proxies:
  - nginx
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the prebuilt static [Webhook][1]
server by HookDoo, used to serve incoming webhooks with custom
actions/scripts.

{{ m.srcimage('alpine-s6') }} with the webhook binary
installed in it. {{ m.ghreleasestr('adnanh/webhook') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_webhook \
  -p 9000:9000 \
  -e WEBHOOK_ARGS="-verbose -ip 0.0.0.0" \
  -v $PWD/webhook`#(1)`:/etc/webhook \
woahbase/alpine-webhook
```

1. (Required) Path to your hooks configurations directory.

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars             | Default                      | Description
| :---                 | :---                         | :---
| WEBHOOK_FILE         | /etc/webhook/hooks.json      | (Preset) Path to webhooks definition file. {{ m.sincev('2.8.2_20250807') }} Previously named `WEBHOOK_JSON`.
| WEBHOOK_FILE_URL     | empty string                 | If set, will fetch hooks definition file from this url. {{ m.sincev('2.8.2_20250807') }} Previously named `WEBHOOK_JSON_URL`.
| WEBHOOK_SKIP_PERMFIX | unset                        | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `webhook` configuration/data files/directories. {{ m.sincev('2.8.2_20250807') }}
| WEBHOOK_ARGS         | -verbose -nopanic -hotreload | Customizable arguments passed to webhook binary.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/etc/webhook/hooks.json', vname='WEBHOOK_FILE') }}

* Checkout the [docs][2] for more information about writing hooks.

[1]: https://www.hookdoo.com/
[2]: https://github.com/adnanh/webhook/tree/master/docs

{% include "all-include.md" %}
