{%- set mimg = orgname ~ "/" ~ dhrepo|default(page.title) -%}
{%- set mtag = manifest_tag | default("latest")   -%}
{%- set mtarget = target_name | default("latest") -%}
{%- set msuffix = (("_" + mtag) if mtag != "latest" else "") -%}

``` sh
make annotate_{{ mtarget }} {{ wb_extra_args_annotate | default(wb_extra_args | default("")) }}
```

??? info "How it works"

    First we create or amend the manifest with the tag `{{ mtag }}`

    === "create"
        ``` sh
        docker manifest create \
        {{ mimg }}:{{ mtag }} \
        {% for ar in page.meta.arches|default(config.extra.arches) -%}
        {%-  if not page.meta["skip_"~ar]|default(false) -%}
        {{      mimg ~ ':' ~ ar ~ msuffix }} \
        {%   endif -%}
        {%- endfor -%};
        ```

    === "amend"
        ``` sh
        docker manifest create --amend \
        {{ mimg }}:{{ mtag }} \
        {% for ar in page.meta.arches|default(config.extra.arches) -%}
        {%-  if not page.meta["skip_"~ar]|default(false) -%}
        {{      mimg ~ ':' ~ ar ~ msuffix }} \
        {%   endif -%}
        {%- endfor -%};
        ```

    Then annotate the image for each architecture in the manifest with

    {% for ar in page.meta.arches|default(config.extra.arches) -%}
    {%-  if not page.meta["skip_"~ar]|default(false) -%}
    === "{{ ar }}"
        ``` sh
        docker manifest annotate {{ config.extra.platforms[ar] }} \
            {{ mimg }}:{{ mtag }} \
            {{ mimg }}:{{ ar }}{{ msuffix }};
        ```
    {%-   endif %}
    {% endfor %}

    And finally, push it to the repository using

    ``` sh
    docker manifest push -p {{ mimg }}:{{ mtag }}
    ```
