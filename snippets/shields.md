{% include 'deprecated.md' %}
<!--
[:material-github:][151]
[:fontawesome-brands-docker:][155]
-->
{%- if not gh_multirepo -%}
[![gh_commit status][201]][151]
[![gh_stars][202]][152]
[![gh_forks][203]][153]
[![gh_watches][204]][154]
[![gh_issues][211]][161]
[![gh_pr][212]][162]
<br/>
{%- else -%}
{%-   for ms in gh_multirepo -%}
{#-     ms:
          name: repo-name       -#}
[![gh_commit status][201]][151]
[![gh_stars][202]][152]
[![gh_forks][203]][153]
[![gh_watches][204]][154]
[![gh_issues][211]][161]
[![gh_pr][212]][162]
<br/>
{%-   endfor-%}
{%- endif -%}

{%- if not dh_multirepo -%}
[![dh_pulls][205]][155]
[![dh_stars][206]][156]
{%-   if not skip_aarch64 %}
[![dh_size:aarch64][208]][158]
{%-   endif -%}
{%-   if not skip_armhf %}
[![dh_size:armhf][210]][160]
{%-   endif -%}
{%-   if not skip_armv7l %}
[![dh_size:armv7l][209]][159]
{%-   endif -%}
{%-   if not skip_x86_64 %}
[![dh_size:x86_64][207]][157]
{%-   endif -%}
{%- else -%}
{%-   for mr in dh_multirepo -%}
{#-     mr:
          name: repo-name
          skip_aarch64: boolean
          skip_armhf: boolean
          skip_armv7l: boolean
          skip_x86_64: boolean  -#}
[![dh_pulls](https://img.shields.io/docker/pulls/{{ orgname }}/{{ mr.name }}?{{ shieldparams }}&logo=docker&label={{ mr.name.split('-')|last }} pulls)](https://hub.docker.com/r/{{ orgname }}/{{ mr.name }})
[![dh_stars](https://img.shields.io/docker/stars/{{ orgname }}/{{ mr.name }}?{{ shieldparams }}&logo=docker&label=stars)](https://hub.docker.com/r/{{ orgname }}/{{ mr.name }})
{%-     if not mr.skip_aarch64 %}
[![dh_size:aarch64](https://img.shields.io/docker/image-size/{{ orgname }}/{{ mr.name }}/aarch64?label=aarch64&{{ shieldparams }}&logo=docker)](https://hub.docker.com/r/{{ orgname }}/{{ mr }}/tags?name=aarch64&ordering=last_updated)
{%-     endif -%}
{%-     if not mr.skip_armhf %}
[![dh_size:armhf](https://img.shields.io/docker/image-size/{{ orgname }}/{{ mr.name }}/armhf?label=armhf&{{ shieldparams }}&logo=docker)](https://hub.docker.com/r/{{ orgname }}/{{ mr.name }}/tags?name=armhf&ordering=last_updated)
{%-     endif -%}
{%-     if not mr.skip_armv7l %}
[![dh_size:armv7l](https://img.shields.io/docker/image-size/{{ orgname }}/{{ mr.name }}/armv7l?label=armv7l&{{ shieldparams }}&logo=docker)](https://hub.docker.com/r/{{ orgname }}/{{ mr.name }}/tags?name=armv7l&ordering=last_updated)
{%-     endif -%}
{%-     if not mr.skip_x86_64 %}
[![dh_size:x86_64](https://img.shields.io/docker/image-size/{{ orgname }}/{{ mr.name }}/x86_64?label=x86_64&{{ shieldparams }}&logo=docker )](https://hub.docker.com/r/{{ orgname }}/{{ mr.name }}/tags?name=x86_64&ordering=last_updated)
{%-     endif -%}
<br/>
{%-   endfor-%}
{%- endif -%}

{% if page.meta.description %}

{{ page.meta.description }}

---
{% endif %}
