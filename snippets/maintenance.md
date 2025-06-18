{%- set coderepos  = config.extra.sources.values()      |default([])|rejectattr("disabled")|list -%}
{%- set imagrepos  = config.extra.distributions.values()|default([])|rejectattr("disabled")|list -%}
{%- macro genrepolinks(items) -%}
{%-   for d in items -%}
{%-     if not d.disabled|default(false) -%}
{%-       if loop.first -%} [{{ d.name }}]({{ d.orgurl }})
{%-       else          -%} [*{{ d.name }}*]({{ d.orgurl }}) {{- ', ' if not loop.last -}}
{%-       endif         -%}
{{-       ' and ' if (loop.first and items|length>1) -}}
{{-       ''      if (loop.last  and items|length>1) -}}
{%-     endif -%}
{%-   endfor -%}
{%- endmacro -%}
{%- macro genobjlinks(items, t="Sources|Images") -%}
{%-   for d in items -%}
{%-     if not d.disabled|default(false) -%}
{%-       if   t == "Sources" -%} {%- set ln = d.weburl ~'/'~ orgname ~'/'~ ghrepo|default(page.title) -%}
{%-       elif t == "Images"  -%} {%- set ln = d.weburl ~'/'~ orgname ~'/'~ dhrepo|default(page.title) -%}
{%-       endif               -%}
{%-       if loop.first -%} [{{ t }}]({{ ln }} "View {{ t }}")
{%-       else          -%} [*Mirror{{ loop.index - 1 }}*]({{ ln }} "{{ t }} Mirror #{{ loop.index - 1 }}") {{- ', ' if not loop.last -}}
{%-       endif         -%}
{{-       ' (' if (loop.first and items|length>1) -}}
{{-       ') ' if (loop.last  and items|length>1) -}}
{%-     endif -%}
{%-   endfor -%}
{%- endmacro -%}

---
Maintenance
---

{{ genobjlinks(coderepos, "Sources") }} at {{ genrepolinks(coderepos) }}.
{%- if not (('deprecated' in tags) or ('legacy' in tags)) %}
Built and tested at home using [Buildbot][111].
{%- endif %}
{{ genobjlinks(imagrepos, "Images") }} at {{ genrepolinks(imagrepos) }}.

<!-- Pull requests are welcome, forks even more so. :) -->

Maintained (or sometimes a lack thereof?) by [{{ config.site_name }}][110].
