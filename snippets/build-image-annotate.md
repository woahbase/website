{%- set lstag = 'latest' -%}{%- set vstag = 'version' -%}{%- set bdtag = 'builddate' -%}
{%- set itags = [] -%}{%- set vtags = [] -%}{%- set btags = [] -%}
{%- for ar in page.meta.arches|default(config.extra.arches) -%}
{%-   if not page.meta["skip_"~ar]|default(false) -%}
{{-     itags.append(ar)                              or '' -}}
{{-     vtags.append(ar~'_${'~vstag~'}')              or '' -}}
{{-     btags.append(ar~'_${'~vstag~'}_${'~bdtag~'}') or '' -}}
{%-   endif -%}
{%- endfor -%}

---
#### Annotate Manifest(s)
---

For single architecture images, the above should suffice, the
built image can be used in the host machine, and on other machines
that have the same architecture too, i.e. after a push.

But for use-cases that need to support multiple architectures,
there's a couple more things that need to be done. We need to
`create` (or `amend` if already created beforehand) a manifest for
the image(s) that we built, then annotate it to map the images to
their respective architectures. And for our three tags created
above we need to do it thrice.

??? info "Did you know?"
    We can inspect the manifest of any image by running
    ``` sh
    docker manifest inspect <imagename>:<optional tag, default is latest>
    ```

---
##### Tag {{ lstag | capitalize }}
---

{% set manifest_tag = lstag -%}

Assuming we built the images for all supported architectures, to
facilitate pulling the correct image for the architecture, we
can create/amend the `{{ manifest_tag }}` manifest and annotate it
to map the tags `:{{- itags | join('`, `:') }}` to the tag `:{{
manifest_tag }}` by running

{% include "build-image-annotate-tag.md" %}

---
##### Tag {{ vstag | capitalize }}
---

{% set target_name = vstag -%}
{%- set manifest_tag = '${'~vstag~'}' -%}

Next, to facilitate pulling images by version, we create/amend the
image-version manifest and annotate it to map the tags `:{{- vtags
| join('`, `:') }}` to the tag `:{{ manifest_tag }}` by running

{% include "build-image-annotate-tag.md" %}

---
##### Tag Build-Date
---

{% set target_name = "date" -%}
{%- set manifest_tag = '${'~vstag~'}_${'~bdtag~'}' -%}

Then, (optionally) we create/amend the `{{ manifest_tag }}`
manifest and annotate it to map the tags `:{{- btags | join("`, `:")
}}` to the tag `:{{ manifest_tag }}` by running

{% include "build-image-annotate-tag.md" %}
