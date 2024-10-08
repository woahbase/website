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
        {% if not skip_aarch64  %}{{ mimg }}:aarch64{{ msuffix }} \
        {% endif -%}
        {%- if not skip_armhf   %}{{ mimg }}:armhf{{   msuffix }} \
        {% endif -%}
        {%- if not skip_armv7l  %}{{ mimg }}:armv7l{{  msuffix }} \
        {% endif -%}
        {%- if not skip_x86_64  %}{{ mimg }}:x86_64{{  msuffix }} \
        {% endif %};
        ```

    === "amend"
        ``` sh
        docker manifest create --amend \
        {{ mimg }}:{{ mtag }} \
        {% if not skip_aarch64  %}{{ mimg }}:aarch64{{ msuffix }} \
        {% endif -%}
        {%- if not skip_armhf   %}{{ mimg }}:armhf{{   msuffix }} \
        {% endif -%}
        {%- if not skip_armv7l  %}{{ mimg }}:armv7l{{  msuffix }} \
        {% endif -%}
        {%- if not skip_x86_64  %}{{ mimg }}:x86_64{{  msuffix }} \
        {% endif %};
        ```

    Then annotate the image for each architecture in the manifest with

    {% if not skip_aarch64 %}
    === "aarch64"
        ``` sh
        docker manifest annotate --os linux --arch arm64 \
            {{ mimg }}:{{ mtag }} \
            {{ mimg }}:aarch64{{ msuffix }};
        ```
    {% endif %}
    {% if not skip_armhf %}
    === "armhf"
        ``` sh
        docker manifest annotate --os linux --arch arm --variant v6 \
            {{ mimg }}:{{ mtag }} \
            {{ mimg }}:armhf{{ msuffix }};
        ```
    {% endif %}
    {% if not skip_armv7l %}
    === "armv7l"
        ``` sh
        docker manifest annotate --os linux --arch arm --variant v7 \
            {{ mimg }}:{{ mtag }} \
            {{ mimg }}:armv7l{{ msuffix }};
        ```
    {% endif %}
    {% if not skip_x86_64 %}
    === "x86_64"
        ``` sh
        docker manifest annotate --os linux --arch amd64 \
            {{ mimg }}:{{ mtag }} \
            {{ mimg }}:x86_64{{ msuffix }};
        ```
    {% endif %}

    And finally, push it to the repository using

    ```
    docker manifest push -p {{ mimg }}:{{ mtag }}
    ```
