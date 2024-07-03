---
#### Push the Image
---

If the build and test steps finish without any error, and we want
to use the image on other machines, it is the next step push the
image we built to a container image repository (like
[:material-docker:/hub][155]), for that, run the `push` target
with

``` sh
make push {{ wb_extra_args_push | default(wb_extra_args | default("")) }}
```

If the built image targets another architecture then it is
**required** to specify the `ARCH` parameter when pushing. e.g.

{% if not skip_aarch64 %}
=== "aarch64"
    ``` sh
    make push ARCH=aarch64 {{ wb_extra_args_push | default(wb_extra_args | default("")) }}
    ```
{% endif %}
{% if not skip_armhf %}
=== "armhf"
    ``` sh
    make push ARCH=armhf {{ wb_extra_args_push | default(wb_extra_args | default("")) }}
    ```
{% endif %}
{% if not skip_armv7l %}
=== "armv7l"
    ``` sh
    make push ARCH=armv7l {{ wb_extra_args_push | default(wb_extra_args | default("")) }}
    ```
{% endif %}
{% if not skip_x86_64 %}
=== "x86_64"
    ``` sh
    make push ARCH=x86_64 {{ wb_extra_args_push | default(wb_extra_args | default("")) }}
    ```
{% endif %}

{% if not (('deprecated' in tags) or ('legacy' in tags)) %}{# no version/builddate push for old images #}
???+ info "Pushing Multiple Tags"

    With a single `make push`, we are actually pushing 3 tags of
    the same image, e.g. for x86_64 architecture, they're namely

    * `{{ page.title }}:x86_64`

    :   The actual image that is built.

    * `{{ page.title }}:x86_64_(version)`

    :   It is expected that the application is versioned when
        built or packaged, it can be specified in the tag, this
        makes pulling an image by tag possible. Usually this is
        obtained from the parameter `VERSION`, which by default,
        is set by calling a function to extract the version string
        from the package installed in the container, or from
        github releases. Can be skipped with the parameter
        `SKIP_VERSIONTAG` to a non-empty string value like `1`.

    * `{{ page.title }}:x86_64_(version)_(builddate)`

    :   When building multiple versions of the same image (e.g. for
        providing fixes or revisions), this ensures that a more recent
        push does not fully replace a previously pushed image. This
        way, although the architecture and version tags are replaced,
        it is possible to roll back to the previously built image by
        build date (format `yyyymmdd`). This value is obtained from the `BUILDDATE`
        parameter, and if not essential, can be skipped by setting the
        parameter `SKIP_BUILDDATETAG` to a non-empty string value like `1`.

??? info "Pushing To A Private Registry"

    If you want to push the image to a custom registry that is not
    pre-configured on your system, you can set the `REGISTRY`
    variable either on the build environment, or as a makefile
    parameter, and that will be used instead of the default Docker
    Hub repository. Make sure to have push access set up before
    you actually push, and **include port if needed**. E.g.

    ``` sh
    export REGISTRY=your.private.registry:5000
    make push
    ```

    or

    ``` sh
    make push REGISTRY=your.private.registry:5000
    ```
{% endif %}
