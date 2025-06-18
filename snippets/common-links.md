{%- if 'private' in tags %}{#- generate links using private repo/registry urls -#}
{%-   set coderepo_weburl  = config.extra.sources['private']['weburl']     | default('https://github.com')       -%}
{%-   set imagerepo_weburl = config.extra.distributions['private']['weburl'] | default('https://hub.docker.com/r') -%}
{%- else  %}
{%-   set coderepo_weburl  = (config.extra.sources.values()      |default([])|rejectattr("disabled")|list|first)['weburl']|default('https://github.com')       -%}
{%-   set imagerepo_weburl = (config.extra.distributions.values()|default([])|rejectattr("disabled")|list|first)['weburl']  |default('https://hub.docker.com/r') -%}
{%- endif %}

[101]: https://git-scm.com
[102]: https://www.gnu.org/software/make/
[103]: https://www.docker.com
[104]: {{ imagerepo_weburl }}/multiarch/qemu-user-static/
[105]: https://github.com/multiarch/qemu-user-static/releases/
[106]: https://github.com/docker/buildx#installing
[107]: https://github.com/docker/cli/blob/master/experimental/README.md
[108]: https://github.com/tonistiigi/binfmt/releases/
[109]: {{ imagerepo_weburl }}/tonistiigi/binfmt
[110]: {{ homepage | default(config.site_url) }}

[111]: https://buildbot.net/
[112]: {{ homepage | default(config.site_url) }}/images/{{ page.title }}
[113]: https://alpinelinux.org/
[114]: alpine-s6.md#usershell

[151]: {{ coderepo_weburl  ~'/'~ ghorgname|default(orgname) ~'/'~ ghrepo|default(page.title) }}
[155]: {{ imagerepo_weburl ~'/'~ dhorgname|default(orgname) ~'/'~ dhrepo|default(page.title) }}
