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

{% if not skip_aarch64 %}
      &nbsp;&nbsp;{{ m.myimagetag('aarch64') }}
{% endif %}
{% if not skip_armhf %}
      &nbsp;&nbsp;{{ m.myimagetag('armhf') }}
{% endif %}
{% if not skip_armv7l %}
      &nbsp;&nbsp;{{ m.myimagetag('armv7l') }}
{% endif %}
{% if not skip_x86_64 %}
      &nbsp;&nbsp;{{ m.myimagetag('x86_64') }}
{% endif %}

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
