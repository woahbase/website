{%- macro genshieldlink(typ, subtyp, repo, label, fpath, fparams, lpath, lparams) -%}
{%-  if 'private' in tags -%}
{#-    no shields for private images -#}
{#-    generate links using private repo/registry urls -#}

{%-    set coderepo_weburl  = config.extra.sources['private']['weburl']     | default('https://github.com')       -%}
{%-    set imagerepo_weburl = config.extra.distributions['private']['weburl'] | default('https://hub.docker.com/r') -%}

{%-    set iurl = {
             "github" : coderepo_weburl,
             "docker" : imagerepo_weburl
           }[typ]
         ~'/'~ repo
         ~ ('/'~lpath if lpath)
         ~ ('?'~lparams if lparams) -%}

       {{ '| [{}]({})'.format(label|default(subtyp), iurl) }}

{%-  else  -%}
{%-    set coderepo_weburl  = (config.extra.sources.values()      |default([])|rejectattr("disabled")|list|first)['weburl']|default('https://github.com')       -%}
{%-    set imagerepo_weburl = (config.extra.distributions.values()|default([])|rejectattr("disabled")|list|first)['weburl']  |default('https://hub.docker.com/r') -%}

{%-    set furl = 'https://img.shields.io'
         ~'/'~ typ ~'/'~ subtyp
         ~'/'~ repo
         ~ ('/'~fpath if fpath)
         ~'?'~ shieldparams
         ~ ('&logo='~typ if typ in ['github', 'docker'])
         ~ ('&label='~label if label)
         ~ ('&'~fparams if fparams) -%}

{%-    set iurl = {
             "github" : coderepo_weburl,
             "docker" : imagerepo_weburl
           }[typ]
         ~'/'~ repo
         ~ ('/'~lpath if lpath)
         ~ ('?'~lparams if lparams) -%}

       {{ '[![{}]({})]({})'.format(label|default(subtyp), furl, iurl) }}
{%-  endif -%}
{%- endmacro -%}

{%- macro genline_github(repo, extra) -%}
{{      genshieldlink('github', 'last-commit', repo, label=(extra~" " if extra)~'updated' ) }}
{{      genshieldlink('github', 'stars'      , repo, lpath='stargazers'     ) }}
{{      genshieldlink('github', 'forks'      , repo, lpath='network/members') }}
{{      genshieldlink('github', 'watchers'   , repo, lpath='watchers'       ) }}
{{      genshieldlink('github', 'issues'     , repo, lpath='issues'         ) }}
{{      genshieldlink('github', 'issues-pr'  , repo, lpath='pulls'          ) }}
<br/>
{%- endmacro -%}

{%- macro genline_dockerhub(repo, extra, mr={}) -%}
{{    genshieldlink('docker', 'pulls', repo, label=(extra~" " if extra)~'pulls' ) }}
{{    genshieldlink('docker', 'stars', repo, label='stars') }}
{%-   for ar in page.meta.arches|default(config.extra.arches) -%}
{%-     if page.meta.has_perarch_tags|default(true)
          and not page.meta["skip_"~ar]|default(false)
          and not mr["skip_"~ar]|default(false) %}
{{        genshieldlink('docker', 'image-size', repo, fpath=ar, label=ar, lpath='tags?name='~ar~'&ordering=last_updated') }}
{%-     endif -%}
{%-   endfor %}
<br/>
{%- endmacro -%}

{%- include 'deprecated.md' %}
<!--
[:material-github:][151]
[:fontawesome-brands-docker:][155]
-->
{%- if not gh_multirepo -%}
{{    genline_github(ghorgname|default(orgname)~'/'~ghrepo|default(page.title)) }}
{%- else -%}
{%-   for ms in gh_multirepo -%}
{#-     ms:
          name: repo-name       -#}
{{      genline_github(ghorgname|default(orgname)~'/'~ms.name, ms.name.split('-')|last) }}
{%-   endfor -%}
{%- endif -%}

{%- if not dh_multirepo -%}
{{    genline_dockerhub(dhorgname|default(orgname)~'/'~dhrepo|default(page.title)) }}
{%- else -%}
{%-   for mr in dh_multirepo -%}
{#-     mr:
          name: repo-name
          skip_aarch64: boolean
          skip_armhf: boolean
          skip_armv7l: boolean
          skip_x86_64: boolean  -#}
{{      genline_dockerhub(dhorgname|default(orgname)~'/'~mr.name, mr.name.split('-')|last) }}
{%-   endfor -%}
{%- endif %}

{% if page.meta.description -%}
{{ page.meta.description }}

---
{%- endif %}
