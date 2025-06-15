{% if not (('shell' in tags) or ('usershell' in tags)) -%}
{% include "common-tasks.md" %}
{%- endif %}
{% include "has-snippets.md" %}
{% include "build-image.md" %}
{% include "build-image-push.md" %}
{% if not (('deprecated' in tags) or ('legacy' in tags)) -%}{#- no annotate or version tags for old images -#}
{% include "build-image-annotate.md" %}
{%- endif %}

That's all folks! Happy containerizing!

{% include "maintenance.md" %}
{% include "common-links.md" %}
