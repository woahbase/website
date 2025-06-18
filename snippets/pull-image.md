{% import "macros.md" as m with context -%}
---
Get the Image
---

{% for d in config.extra.distributions.values() -%}
{%-  if not d.disabled|default(false) -%}
=== "{{ d.name }}"
    Pull the image from [{{ d.name }}]({{
      d.weburl~'/'
      ~ dhorgname|default(orgname)~'/'
      ~ dhrepo | default(page.title)
    }}).

    ``` sh
    docker pull {{
      (d.ns~'/' if d.ns else '')
      ~ dhorgname|default(orgname)~'/'
      ~ dhrepo|default(page.title)
    }}
    ```
{%-  endif %}
{% endfor %}

{% if page.meta.has_perarch_tags|default(true) -%}
???+ info "Image Tags"
    The image is tagged respectively for the following architectures,

    <div class="grid cards pull-image-arches" markdown>

    {% for ar in page.meta.arches|default(config.extra.arches) -%}
    {%   if not page.meta["skip_"~ar] -%}
    {{     '- ' ~ m.myimagetag(page.meta["tagname_"~ar]|default(ar), icon='octicons-container-24') }}
    {%   endif -%}
    {% endfor %}

    </div>

    {%   if (('deprecated' in tags) or ('legacy' in tags)) -%}{#- no annotate or version tags for old images -#}

    **latest** tag is retagged from `x86_64`, so pulling without
    any tag fetches you that image. For any other architectures
    specify the tag for that architecture. e.g. for `armv8` or
    `aarch64` host it is `{{ dhrepo | default(page.title)
    }}:aarch64`.

    {%- else -%}

    **latest** tag is annotated as multiarch so pulling without
    specifying any architecture tags should fetch the correct
    image for your architecture. Same goes for any of the
    **version** tags.

    {%- endif %}

    {% if (not (skip_aarch64 and skip_armhf and skip_armv7l)) -%}{#- only 86_64 build available -#}

    **non-x86_64** images used to contain the embedded
    [qemu-user-static][105] binary which has been
    [redundant](https://github.com/multiarch/qemu-user-static?tab=readme-ov-file#multiarch-compatible-images-deprecated)
    for a while, and is being **deprecated** starting with our
    Alpine Linux `v3.22` base-image release, see
    [qemu-user-static](#qemu-user-static) or the more recent
    [binfmt](#binfmt) instead for running multi-arch containers.

    {%- endif %}
{%- endif %}
