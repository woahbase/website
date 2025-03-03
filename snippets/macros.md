{% macro addpagetag(tag) -%}
{{- (page.meta.tags.append(tag) or page.meta.tags.sort() or "") if not tag in page.meta.tags -}}
{%- endmacro %}

{% macro alpinepkg(name, branch, repo, arch, star) -%}
{{- addpagetag('package') -}}
[{{ name }}](https://pkgs.alpinelinux.org/packages?name=
{{- name -}}
{{- '*' if star else '' -}}
{{- '&branch=' + (branch if branch else alpine_branch) -}}
{{- ('&repo=' + repo) if repo else '' -}}
{{- ('&arch=' + arch) if arch else '' -}} "AlpineLinux Package")
{%- endmacro %}

{% macro srcimage(name) -%}
Based on
{% if 'alpine-' in name -%}
{{- addpagetag(name|replace('alpine-', '')) -}}
[Alpine Linux][113]
from the
[{{ name | replace('alpine-', '') }}]({{ name }}.md "Go to {{ name }} docs")
{%- endif %}
image
{%- endmacro %}

{% macro ghfilelink(fp, org, ghrepo, branch, title) -%}
[{{ title|default(fp) }}]({{ 'https://github.com'
~'/'~ org   |default(orgname)
~'/'~ ghrepo|default(page.title)
~'/'~ 'blob'
~'/'~ branch|default('master')
~'/'~ fp }})
{%- endmacro%}

{% macro ghfileraw(fp, org, ghrepo, branch, title) -%}
[{{ title|default(fp) }}]({{ 'https://raw.githubusercontent.com'
~'/'~ org   |default(orgname)
~'/'~ ghrepo|default(page.title)
~'/'~ branch|default('master')
~'/'~ fp }})
{%- endmacro%}

{% macro ghreleaselink(repo_name, title) -%}
[:material-github:/{{ title | default(repo_name) }}](https://github.com/{{ repo_name }}/releases/ "Go to Github Releases")
{%- endmacro %}

{% macro ghreleasestr(repo_name) -%}
{{- addpagetag('github') -}}
Versioned accordingly with releases from {{ ghreleaselink(repo_name) }}.
{%- endmacro %}

{% macro myimage(name, title) -%}
[{{ title | default(name) }}]({{ name }}.md "Go to {{ name }} docs")
{%- endmacro %}

{% macro myimagetag(tag, name) -%}
[:material-tag-text-outline: {{ tag }}](https://hub.docker.com/r/{{ orgname }}/{{ name | default(page.title) }}/tags?name={{ tag }} "Filter Images with Tag")
{%- endmacro %}

{% macro npmpkg(name) -%}
[{{ name }}](https://www.npmjs.com/package/{{ name }} "NPM Package")
{%- endmacro %}

{% macro pypipkg(name) -%}
[{{ name }}](https://pypi.org/project/{{ name }}/ "PYPI Package")
{%- endmacro %}

{% macro sincev(tag, name) -%}
(since {{ myimagetag(tag, name) }})
{%- endmacro %}

{% macro defcfgfile(dst, src, fr, vname, title="sample", ddir="defaults", plural=false) -%}
{%- if not src -%}{%- set src = 'root' ~'/'~ ddir ~'/'~ (dst.split("/")|last) -%}{%- endif -%}
Configuration {{ 'files' if plural else 'file' }} {{ 'for '~fr if
fr }} {{ 'are' if plural else 'is' }} at `{{ dst }}`{{ ' (the
filepath preset in the env-var `'~vname~'`)' if vname }},
edit or remount {{ 'these' if plural else 'this' }} with your own.
A {{ ghfilelink(src, title=title) }} is provided in `{{ '/'~ddir
}}`, {{ 'these get' if plural else 'this gets' }} copied when no
such {{ 'files exist' if plural else 'file exists' }} before {{
'services are' if plural else 'service is' }} started.
{%- endmacro %}

{% macro customscript(p, fr, ghrepo, title="shellscript", ddir="etc/s6-overlay/s6-rc.d") -%}
Includes a placeholder script for {{ 'customizing `'~fr~'`' if fr
else 'further customizations'}} before starting processes.
Override the {{ ghfilelink('root' ~'/'~ ddir ~'/'~ p ~'/run', ghrepo=ghrepo, title=title) }}
located at `{{ '/'~ ddir ~'/'~ p ~'/run' }}` with your custom
pre-tasks as needed.
{%- endmacro %}
