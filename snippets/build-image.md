{% import "macros.md" as m with context %}

---
Build Your Own
---

Feel free to clone (or fork) the repository and customize it for your own
usage, build the image for yourself on your own systems, and optionally, push
it to your own public (or {{ m.myimage('alpine-registry', 'private') }})
repository.

Here's how...


---
#### Setting up
---

Before we clone the [:material-github:/repository][151], we must have [Git][101], [GNU
make][102], and [Docker][103] (optionally, with [buildx][106] plugin for
multi-platform images) setup on the machine. Also, for multi-platform
annotations, we might require enabling [experimental features][107] of Docker.

Clone the repo with,
``` sh
git clone https://github.com/{{ orgname }}/{{ ghrepo | default(page.title) }}
cd {{ ghrepo | default(page.title) }}
```

{% if not (('deprecated' in tags) or ('legacy' in tags)) %}{# no help target for legacy/deprecated images #}
To get a list of all available targets, run

``` sh
make help
```
{% endif %}

??? info "Always Check Before You Make!"
    Did you know, we could check what any make target is going to
    execute before we actually run them, with

    ``` sh
    make -n <targetname> <optional args>
    ```
---
#### Build and Test
---

To create the image for your architecture, run the `build` and
`test` target with

``` sh
make build test {{ wb_extra_args_build | default(wb_extra_args | default("")) }}
```

For building an image that targets another architecture, it is
**required** to specify the `ARCH` parameter when building. e.g.

{% if not skip_aarch64 %}
=== "aarch64"
    ``` sh
    make build test ARCH=aarch64 {{ wb_extra_args_build | default(wb_extra_args | default("")) }}
    ```
{% endif %}
{% if not skip_armhf %}
=== "armhf"
    ``` sh
    make build test ARCH=armhf {{ wb_extra_args_build | default(wb_extra_args | default("")) }}
    ```
{% endif %}
{% if not skip_armv7l %}
=== "armv7l"
    ``` sh
    make build test ARCH=armv7l {{ wb_extra_args_build | default(wb_extra_args | default("")) }}
    ```
{% endif %}
{% if not skip_x86_64 %}
=== "x86_64"
    ``` sh
    make build test ARCH=x86_64 {{ wb_extra_args_build | default(wb_extra_args | default("")) }}
    ```
{% endif %}

{% if not (('deprecated' in tags) or ('legacy' in tags)) %}
???+ info "Build Parameters"
    All images have a few common build parameters that can be
    customized at build time, like

    * `ARCH`

    :   The target architecture to build for. Defaults to host
        architecture, auto-detected at build-time if not specified.
        Also determines if binfmt support is required before build
        or run and runs the `regbinfmt` target automatically.
        Possible values are `aarch64`, `armhf`, `armv7l`, and
        `x86_64`.

    * `BUILDDATE`

    :   The date of the build. Can be used to create separate tags for
        images. (format: `yyyymmdd`)

    * `DOCKERFILE`

    {% set dcf = dockerfile|default("Dockerfile") -%}

    :   The dockerfile to use for build. Defaults to the file
        {{ m.ghfilelink(dcf) }}, but if per-arch dockerfiles
        exist, (e.g. for x86_64 the filename would be
        `{{ dcf }}_x86_64`) that is used instead.

    * `TESTCMD`

    :   The command to run for testing the image after build. Runs
        in a bash shell.

    * `VERSION`

    :   The version of the app/tool, may need to be preset before
        starting the build (e.g. for binaries from github releases),
        or extracted from the image after build (e.g. for APK or pip
        packages).

    * `REGISTRY`

    :   The registry to push to, defaults to the Docker Hub
        Registry (`docker.io`) or any custom registry that is set via
        docker configurations. Does not need to be changed for local
        or test builds, but to override, either pass it by setting an
        environment variable, or with every `make` command.

    * `ORGNAME`

    :   The organization (or user) name under which the image
        repositories exist, defaults to `{{ config.extra.orgname }}`.
        Does not need to be changed for local or test builds, but to
        override, either pass it by setting an environment variable,
        or with every `make` command.

    The image may also require custom parameters (like binary
    architecture). **Before you build**, check the {{ m.ghfilelink('makefile') }}
    for a complete list of parameters to see what may (or may
    not) need to be set.

??? info "BuildX and Self-signed certificates"

    If you're using a private registry (a-la docker distribution
    server) with self-signed certificates, that fail to validate
    when pulling/pushing images. You will need to configure buildx
    to allow insecure access to the registry. This is configured
    via the `config.toml` file. A {{ m.ghfilelink('config.toml', title='sample') }}
    is provided in the repository, make sure to replace
    `YOUR.PRIVATE.REGISTRY` with your own (include port if needed).
{% endif %}

---
#### Make to Run
---

Running the image creates a container and either starts a service
(for service images) or provides a shell (can be either a root-shell
or usershell) to execute commands in, depending on the image. We
can run the image with

``` sh
make run {{ wb_extra_args_run | default(wb_extra_args | default("")) }}
```

But if we just need a root-shell in the container without
any fance pre-tasks (e.g. for debug or to test something bespoke), we can
run `bash` in the container with `--entrypoint /bin/bash`. This is
wrapped in the {{ m.ghfilelink('makefile') }} as

``` sh
make shell {{ wb_extra_args_run | default(wb_extra_args | default("")) }}
```

???+ info "Nothing vs All vs Run vs Shell"
    By default, if `make` is run without any arguments, it calls
    the target `all`. In our case this is usually mapped to the
    target `run` (which in turn may be mapped to `shell`).

There may be more such targets defined as per the usage of the
image. Check the {{ m.ghfilelink('makefile') }} for more information.
