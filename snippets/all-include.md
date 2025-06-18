{% if not (('shell' in tags) or ('usershell' in tags)) -%}
{% include "common-tasks.md" %}
{%- endif %}
{% include "has-snippets.md" %}
{% if not ('foreign' in tags) -%}{#- no build for foreign images -#}
{%   include "build-image.md" %}
{%   include "build-image-push.md" %}
{%   if not (('deprecated' in tags) or ('legacy' in tags)) -%}{#- no annotate or version tags for old images -#}
{%     include "build-image-annotate.md" %}
{%-   endif %}
{%- endif %}

That's all folks! Happy containerizing!

{% if not ('foreign' in tags) -%}{#- no maintenance for foreign images -#}
{%   include "maintenance.md" %}
{%- endif %}
{% include "common-links.md" %}
