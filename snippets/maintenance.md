{%- set src  = config.extra.sources.values()|default([])       -%}
{%- set dist = config.extra.distributions.values()|default([]) -%}
{%- macro genrepolinks(vals) -%}
{%-   for d in vals -%}
{%-     if not d.disabled|default(false) -%}
{%-       if loop.first -%} [{{ d.name }}]({{ d.orgurl }})
{%-       else          -%} [*{{ d.name }}*]({{ d.orgurl }}) {{- ', ' if not loop.last -}}
{%-       endif         -%}
{{-       ' and ' if (loop.first and src|length>1) -}}
{{-       '' if (loop.last  and src|length>1)   -}}
{%-     endif -%}
{%-   endfor -%}
{%- endmacro %}
{%- macro genobjlinks(vals, t="Sources|Images") -%}
{%-   for d in vals -%}
{%-     if not d.disabled|default(false) -%}
{%-       if   t == "Sources" -%} {%- set ln = d.orgurl ~'/'~ dhrepo|default(page.title) -%}
{%-       elif t == "Images"  -%} {%- set ln = d.repo ~'/'~ orgname ~'/'~ dhrepo|default(page.title) -%}
{%-       endif               -%}
{%-       if loop.first -%} [{{ t }}]({{ ln  ~' "View '~t~'"' }})
{%-       else          -%} [*Mirror{{ loop.index - 1 }}*]({{ ln  ~' "'~t~' Mirror #'~(loop.index - 1)~'"'}}) {{- ', ' if not loop.last -}}
{%-       endif         -%}
{{-       ' (' if (loop.first and src|length>1) -}}
{{-       ') ' if (loop.last  and src|length>1) -}}
{%-     endif -%}
{%-   endfor -%}
{%- endmacro %}

---
Maintenance
---

{{ genobjlinks(src, "Sources") }} at {{ genrepolinks(src) }}.
{%- if not (('deprecated' in tags) or ('legacy' in tags)) %}
Built and tested at home using [Buildbot][111].
{%- endif %}
{{ genobjlinks(dist, "Images") }} at {{ genrepolinks(dist) }}.

<!-- Pull requests are welcome, forks even more so. :) -->

Maintained (or sometimes a lack thereof?) by [{{ config.site_name }}][110].
