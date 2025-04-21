{% import "macros.md" as m with context %}
---
Get the Image
---

{% for d in config.extra.distributions.values() %}
{%   if not d.disabled|default(false) %}
=== "{{ d.name }}"
    Pull the image from [{{ d.name }}]({{ d.repo ~'/'~ config.extra.orgname ~'/'~ dhrepo | default(page.title) }}).

    ``` sh
    docker pull {{ d.ns~"/" if d.ns else "" }}{{ config.extra.orgname }}/{{ dhrepo | default(page.title) }}
    ```
{%   endif %}
{% endfor %}

???+ info "Image Tags"
    The image is tagged respectively for the following architectures,

    <div class="grid cards pull-image-arches" markdown>

    {% if not skip_aarch64 -%}- {{ m.myimagetag('aarch64', icon='octicons-container-24') }}
    {% endif -%}
    {%- if not skip_armhf  -%}- {{ m.myimagetag('armhf'  , icon='octicons-container-24') }}
    {% endif -%}
    {%- if not skip_armv7l -%}- {{ m.myimagetag('armv7l' , icon='octicons-container-24') }}
    {% endif -%}
    {%- if not skip_x86_64 -%}- {{ m.myimagetag('x86_64' , icon='octicons-container-24') }}
    {% endif %}

    </div>

{% if (('deprecated' in tags) or ('legacy' in tags)) %}{# no annotate or version tags for old images #}
    **latest** tag is retagged from `x86_64`, so pulling without any
    tag fetches you that image. For any other architectures specify
    the tag for that architecture. e.g. for `armv8` or
    `aarch64` host it is `{{ dhrepo | default(page.title) }}:aarch64`.
{% else %}
    **latest** tag is annotated as multiarch so pulling without any
    tags should fetch the correct image for your architecture. Same goes
    for any of the **version** tags.
{% endif %}

{% if (not (skip_aarch64 and skip_armhf and skip_armv7l)) %}{# only 86_64 build available #}
    **non-x86_64** builds have embedded binfmt_misc support and contain the
    [qemu-user-static](https://github.com/multiarch/qemu-user-static/releases/)
    binary that allows for running it also inside an x86_64 environment that has
    support for it.
{% endif %}
