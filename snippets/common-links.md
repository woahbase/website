{% set _coderepo_weburl = coderepo_weburl | default('github.com') %}
{% set _imagerepo_weburl = imagerepo_weburl | default('hub.docker.com/r') %}

[101]: https://git-scm.com
[102]: https://www.gnu.org/software/make/
[103]: https://www.docker.com
[104]: https://{{ _imagerepo_weburl }}/multiarch/qemu-user-static/
[105]: https://github.com/multiarch/qemu-user-static/releases/
[106]: https://github.com/docker/buildx#installing
[107]: https://github.com/docker/cli/blob/master/experimental/README.md
[108]: https://{{ _coderepo_weburl }}/{{ orgname }}
[109]: https://hub.docker.com/u/{{ orgname }}
[110]: {{ homepage | default(config.site_url) }}

[111]: https://buildbot.net/
[112]: {{ homepage | default(config.site_url) }}/images/{{ page.title }}
[113]: https://alpinelinux.org/
[114]: alpine-s6.md#usershell

[151]: https://{{ _coderepo_weburl }}/{{ orgname }}/{{ ghrepo | default(page.title) }}
[152]: https://{{ _coderepo_weburl }}/{{ orgname }}/{{ ghrepo | default(page.title) }}/stargazers
[153]: https://{{ _coderepo_weburl }}/{{ orgname }}/{{ ghrepo | default(page.title) }}/network/members
[154]: https://{{ _coderepo_weburl }}/{{ orgname }}/{{ ghrepo | default(page.title) }}/watchers
[155]: https://{{ _imagerepo_weburl }}/{{ orgname }}/{{ dhrepo | default(page.title) }}
[156]: https://{{ _imagerepo_weburl }}/{{ orgname }}/{{ dhrepo | default(page.title) }}
[157]: https://{{ _imagerepo_weburl }}/{{ orgname }}/{{ dhrepo | default(page.title) }}/tags?name=x86_64&ordering=last_updated
[158]: https://{{ _imagerepo_weburl }}/{{ orgname }}/{{ dhrepo | default(page.title) }}/tags?name=aarch64&ordering=last_updated
[159]: https://{{ _imagerepo_weburl }}/{{ orgname }}/{{ dhrepo | default(page.title) }}/tags?name=armv7l&ordering=last_updated
[160]: https://{{ _imagerepo_weburl }}/{{ orgname }}/{{ dhrepo | default(page.title) }}/tags?name=armhf&ordering=last_updated
[161]: https://{{ _coderepo_weburl }}/{{ orgname }}/{{ ghrepo | default(page.title) }}/issues
[162]: https://{{ _coderepo_weburl }}/{{ orgname }}/{{ ghrepo | default(page.title) }}/pulls

[201]: https://img.shields.io/github/last-commit/{{ orgname }}/{{ ghrepo | default(page.title) }}?{{ shieldparams }}&logo=github
[202]: https://img.shields.io/github/stars/{{ orgname }}/{{ ghrepo | default(page.title) }}?{{ shieldparams }}&logo=github
[203]: https://img.shields.io/github/forks/{{ orgname }}/{{ ghrepo | default(page.title) }}?{{ shieldparams }}&logo=github
[204]: https://img.shields.io/github/watchers/{{ orgname }}/{{ ghrepo | default(page.title) }}?{{ shieldparams }}&logo=github
[205]: https://img.shields.io/docker/pulls/{{ orgname }}/{{ dhrepo | default(page.title) }}?{{ shieldparams }}&logo=docker&label=pulls
[206]: https://img.shields.io/docker/stars/{{ orgname }}/{{ dhrepo | default(page.title) }}?{{ shieldparams }}&logo=docker&label=stars
[207]: https://img.shields.io/docker/image-size/{{ orgname }}/{{ dhrepo | default(page.title) }}/x86_64?label=x86_64&{{ shieldparams }}&logo=docker
[208]: https://img.shields.io/docker/image-size/{{ orgname }}/{{ dhrepo | default(page.title) }}/aarch64?label=aarch64&{{ shieldparams }}&logo=docker
[209]: https://img.shields.io/docker/image-size/{{ orgname }}/{{ dhrepo | default(page.title) }}/armv7l?label=armv7l&{{ shieldparams }}&logo=docker
[210]: https://img.shields.io/docker/image-size/{{ orgname }}/{{ dhrepo | default(page.title) }}/armhf?label=armhf&{{ shieldparams }}&logo=docker
[211]: https://img.shields.io/github/issues/{{ orgname }}/{{ ghrepo | default(page.title) }}?{{ shieldparams }}&logo=github
[212]: https://img.shields.io/github/issues-pr/{{ orgname }}/{{ ghrepo | default(page.title) }}?{{ shieldparams }}&logo=github
