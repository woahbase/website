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
##### Tag Latest
---

Assuming we built the images for all four architectures, we can
create/amend the manifest and annotate it to map the images tagged
`x86_64`, `aarch64`, `armv7l` and `armhf` to the tag `latest` by
running

{% set manifest_tag = "latest" %}
{% include "build-image-annotate-tag.md" %}

---
##### Tag Version
---

Next, to facilitate pulling images by version, we create/amend the
manifest and annotate it to map the images tagged
`x86_64_(version)`, `aarch64_(version)`, `armv7l_(version)` and
`armhf_(version)` to the tag `(version)` by running

{% set target_name = "version" %}
{% set manifest_tag = "(version)" %}
{% include "build-image-annotate-tag.md" %}

---
##### Tag Build-Date
---

Then, (optionally) we create/amend the manifest and annotate it to
map the images tagged `x86_64_(version)_(builddate)`,
`aarch64_(version)_(builddate)`, `armv7l_(version)_(builddate)`
and `armhf_(version)_(builddate)` to the tag
`(version)_(builddate)` by running

{% set target_name = "date" %}
{% set manifest_tag = "(version)_(builddate)" %}
{% include "build-image-annotate-tag.md" %}

