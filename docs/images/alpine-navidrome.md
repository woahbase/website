---
description: MultiArch Alpine Linux + S6 + Navidrome
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - github
  - s6
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [Navidrome][1] audio streaming
service. It being Subsonic-compatible allows for a number of
features and remote frontends (e.g. Android/iOS) apps to be used.

{{ m.srcimage('alpine-s6') }} with the [navidrome][2] binaries
installed in it. {{ m.ghreleasestr('navidrome/navidrome') }}

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_navidrome \
  -p 4533:4533 \
  -v $PWD/data:/data \
  -v $PWD/music:/music \
woahbase/alpine-navidrome
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars       | Default              | Description
| :---           | :---                 | :---
| ND_DATAFOLDER  | /data                | Path to music database store.
| ND_CONFIGFILE  | /data/navidrome.toml | Path to `navidrome` configuration file.
| ND_CACHEFOLDER | /data/cache          | Cache for album-art etc.
| ND_MUSICDIR    | /music               | Path to audio files store.
| ND_BASEURL     | /navidrome           | Subpath for application.
| ND_PORT        | 4533                 | Port to listen on.
| NAVIDROME_ARGS | unset                | Customizable arguments passed to `navidrome` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* {{ m.defcfgfile('/data/navidrome.toml', vname='ND_CONFIGFILE')
  }} Optionally you may unset the `ND_CONFIGFILE` variable if all your
  configurations are from environment variables.

* Checkout their [docs][3] for available [configuration][4]
  options.

[1]: https://www.navidrome.org/
[2]: https://github.com/navidrome/navidrome/releases
[3]: https://www.navidrome.org/docs/
[4]: https://www.navidrome.org/docs/usage/configuration-options/#available-options

{% include "all-include.md" %}
