{% set _coderepo_weburl  = (config.extra.sources.values()      |first)['orgurl']| default('https://github.com')       %}
{% set _imagerepo_weburl = (config.extra.distributions.values()|first)['repo']  | default('https://hub.docker.com/r') %}

[101]: https://git-scm.com
[102]: https://www.gnu.org/software/make/
[103]: https://www.docker.com
[104]: {{ _imagerepo_weburl }}/multiarch/qemu-user-static/
[105]: https://github.com/multiarch/qemu-user-static/releases/
[106]: https://github.com/docker/buildx#installing
[107]: https://github.com/docker/cli/blob/master/experimental/README.md
[108]: {{ _coderepo_weburl }}
[109]: https://hub.docker.com/u/{{ orgname }}
[110]: {{ homepage | default(config.site_url) }}

[111]: https://buildbot.net/
[112]: {{ homepage | default(config.site_url) }}/images/{{ page.title }}
[113]: https://alpinelinux.org/
[114]: alpine-s6.md#usershell

[151]: {{ _coderepo_weburl }}/{{ ghrepo | default(page.title) }}
<!-- [152]: {{ _coderepo_weburl }}/{{ ghrepo | default(page.title) }}/stargazers -->
<!-- [153]: {{ _coderepo_weburl }}/{{ ghrepo | default(page.title) }}/network/members -->
<!-- [154]: {{ _coderepo_weburl }}/{{ ghrepo | default(page.title) }}/watchers -->
[155]: {{ _imagerepo_weburl }}/{{ orgname }}/{{ dhrepo | default(page.title) }}
<!-- [156]: {{ _imagerepo_weburl }}/{{ orgname }}/{{ dhrepo | default(page.title) }} -->
<!-- [157]: {{ _imagerepo_weburl }}/{{ orgname }}/{{ dhrepo | default(page.title) }}/tags?name=x86_64&ordering=last_updated -->
<!-- [158]: {{ _imagerepo_weburl }}/{{ orgname }}/{{ dhrepo | default(page.title) }}/tags?name=aarch64&ordering=last_updated -->
<!-- [159]: {{ _imagerepo_weburl }}/{{ orgname }}/{{ dhrepo | default(page.title) }}/tags?name=armv7l&ordering=last_updated -->
<!-- [160]: {{ _imagerepo_weburl }}/{{ orgname }}/{{ dhrepo | default(page.title) }}/tags?name=armhf&ordering=last_updated -->
<!-- [161]: {{ _coderepo_weburl }}/{{ ghrepo | default(page.title) }}/issues -->
<!-- [162]: {{ _coderepo_weburl }}/{{ ghrepo | default(page.title) }}/pulls -->
