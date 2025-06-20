---
description: MultiArch Alpine Linux + S6 + Webhook Server
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

| ENV Vars         | Default                      | Description
| :---             | :---                         | :---
| WEBHOOK_ARGS     | -verbose -nopanic -hotreload | Customizable arguments passed to webhook binary.
| WEBHOOK_JSON     | /etc/webhook/hooks.json      | (Preset) Path to webhooks definition file.
| WEBHOOK_JSON_URL | empty string                 | If set, will fetch hooks.json from this url.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/etc/webhook/hooks.json', vname='WEBHOOK_JSON') }}

* Checkout the [docs][2] for more information about writing hooks.

[1]: https://www.hookdoo.com/
[2]: https://github.com/adnanh/webhook/tree/master/docs

{% include "all-include.md" %}
