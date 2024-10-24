{% macro genshieldlink(typ, subtyp, repo, label, fpath, fparams, lpath, lparams) -%}
{%-  if 'private' in tags -%}{#- generate links using private repo/registry urls -#}
{%-    set coderepo_weburl  = config.extra.sources['private']['orgurl']     | default('https://github.com')       -%}
{%-    set imagerepo_weburl = config.extra.distributions['private']['repo'] | default('https://hub.docker.com/r') -%}
{%-  else  -%}
{%-    set coderepo_weburl  = (config.extra.sources.values()      |default([])|rejectattr("disabled")|list|first)['orgurl']|default('https://github.com')       -%}
{%-    set imagerepo_weburl = (config.extra.distributions.values()|default([])|rejectattr("disabled")|list|first)['repo']  |default('https://hub.docker.com/r') -%}
{%-  endif -%}
{%-  set furl = 'https://img.shields.io'
        ~'/'~ typ ~'/'~ subtyp
        ~'/'~ orgname ~'/'~ repo
        ~ ('/'~fpath if fpath)
        ~'?'~ shieldparams
        ~ ('&logo='~typ if typ in ['github', 'docker'])
        ~ ('&label='~label if label)
        ~ ('&'~fparams if fparams) -%}
{%-  set iurl = {
            "github" : coderepo_weburl,
            "docker" : imagerepo_weburl
          }[typ]
        ~'/'~ {
            "github" : repo,
            "docker" : orgname ~'/'~ repo
          }[typ]
        ~ ('/'~lpath if lpath)
        ~ ('?'~lparams if lparams) -%}
{%-  if 'private' in tags -%}{#- no shields for private images -#}
        {{ '| [{}]({})'.format(label|default(subtyp), iurl) }}
{%-  else  -%}
        {{ '[![{}]({})]({})'.format(label|default(subtyp), furl, iurl) }}
{%-  endif -%}
{%-endmacro %}

{% macro genline_github(repo, extra) -%}
{{      genshieldlink('github', 'last-commit', repo, label=(extra~" " if extra)~'updated' ) }}
{{      genshieldlink('github', 'stars'      , repo, lpath='stargazers'     ) }}
{{      genshieldlink('github', 'forks'      , repo, lpath='network/members') }}
{{      genshieldlink('github', 'watchers'   , repo, lpath='watchers'       ) }}
{{      genshieldlink('github', 'issues'     , repo, lpath='issues'         ) }}
{{      genshieldlink('github', 'issues-pr'  , repo, lpath='pulls'          ) }}
<br/>
{%-endmacro %}

{% macro genline_dockerhub(repo, extra, mr={}) -%}
{{    genshieldlink('docker', 'pulls', repo, label=(extra~" " if extra)~'pulls' ) }}
{{    genshieldlink('docker', 'stars', repo, label='stars') }}
{%-   if not skip_aarch64|default(false) and not mr.skip_aarch64|default(false) %}
{{      genshieldlink('docker', 'image-size', repo, fpath='aarch64', label='aarch64', lpath='tags?name=aarch64&ordering=last_updated') }}
{%-   endif -%}
{%-   if not skip_armhf|default(false) and not mr.skip_armhf|default(false) %}
{{      genshieldlink('docker', 'image-size', repo, fpath='armhf',   label='armhf',   lpath='tags?name=armhf&ordering=last_updated')   }}
{%-   endif -%}
{%-   if not skip_armv7l|default(false) and not mr.skip_armv7l|default(false) %}
{{      genshieldlink('docker', 'image-size', repo, fpath='armv7l',  label='armv7l',  lpath='tags?name=armv7l&ordering=last_updated')  }}
{%-   endif -%}
{%-   if not skip_x86_64|default(false) and not mr.skip_x86_64|default(false) %}
{{      genshieldlink('docker', 'image-size', repo, fpath='x86_64',  label='x86_64',  lpath='tags?name=x86_64&ordering=last_updated')  }}
{%-   endif -%}
<br/>
{%-endmacro %}

{% include 'deprecated.md' %}
<!--
[:material-github:][151]
[:fontawesome-brands-docker:][155]
-->
{%- if not gh_multirepo -%}
{{    genline_github(ghrepo|default(page.title)) }}
{%- else -%}
{%-   for ms in gh_multirepo -%}
{#-     ms:
          name: repo-name       -#}
{{      genline_github(ms.name, ms.name.split('-')|last) }}
{%-   endfor-%}
{%- endif -%}

{%- if not dh_multirepo -%}
{{    genline_dockerhub(dhrepo|default(page.title)) }}
{%- else -%}
{%-   for mr in dh_multirepo -%}
{#-     mr:
          name: repo-name
          skip_aarch64: boolean
          skip_armhf: boolean
          skip_armv7l: boolean
          skip_x86_64: boolean  -#}
{{      genline_dockerhub(mr.name, mr.name.split('-')|last) }}
{%-   endfor-%}
{%- endif -%}

{% if page.meta.description %}

{{ page.meta.description }}

---
{% endif %}
