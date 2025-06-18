{% if 'deprecated' in tags -%}
???+ warning "Deprecation Warning"
    This image has been deprecated
    {%- if deprecator_link %}
    by [{{ deprecator_linktitle | default('this link') }}]({{ deprecator_link }})
    {%- elif deprecator_content %}
    {{ deprecator_content }}
    {%- endif %}
    and no updates (or support) may be available in future. Even
    though it is a container, it may or may not keep working as
    expected, use at your own risk.
{% elif 'legacy' in tags -%}
???+ warning "Legacy Image"
    This image still uses the old-style format for
    Dockerfiles/makefile recipes, that may (or may not) be
    compatible with the newer image sources. The container should
    keep working as expected, but for building new images,
    a significant part of the code needs to be updated.
{%- endif %}
{% if 'foreign' in tags -%}
???+ info "Not Our Image"
    This image is not built (or modified or maintained) by, nor
    has any direct affiliation with us. But like many other FOSS,
    we like and trust it enough and may (or may not) use it ourselves.
    Any issues/questions/support regarding this image that is not
    relevant to this documentation or snippets go to the actual
    owner or maintainers.
{%- endif %}
