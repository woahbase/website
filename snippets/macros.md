{% macro alpinepkg(name, branch, repo, arch, star) -%}
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
[Alpine Linux][113]
from the
[{{ name | replace('alpine-', '') }}]({{ name }}.md "Go to {{ name }} docs")
{%- endif %}
image
{%- endmacro %}

{% macro ghreleaselink(repo_name, title) -%}
[:material-github:/{{ title | default(repo_name) }}](https://github.com/{{ repo_name }}/releases/ "Go to Github Releases")
{%- endmacro %}

{% macro ghreleasestr(repo_name) -%}
Versioned accordingly with releases from {{ ghreleaselink(repo_name) }}.
{%- endmacro %}

{% macro myimage(name, title) -%}
[{{ title | default(name) }}]({{ name }}.md "Go to {{ name }} docs")
{%- endmacro %}

{% macro npmpkg(name) -%}
[{{ name }}](https://www.npmjs.com/package/{{ name }} "NPM Package")
{%- endmacro %}

{% macro pypipkg(name) -%}
[{{ name }}](https://pypi.org/project/{{ name }}/ "PYPI Package")
{%- endmacro %}
