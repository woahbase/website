# Types of Images

The images are tagged as per the following categories for ease of
navigation or search,

{% macro anchify(name) %}[`{{ name }}`](#{{ name }}){% endmacro %}

??? info "Categories Explained"

    | Category                    | Description
    | :---                        | :---
    | {{ anchify('base') }}       | Base images that other images inherit.
    | {{ anchify('compose') }}    | These images include an example `docker-compose.yml` file.
    | {{ anchify('deprecated') }} | Deprecated images, to be used with caution.
    | {{ anchify('dev') }}        | Images used to develop or as base for applications that require the compiler/runtime.
    | {{ anchify('github') }}     | Applications that use Github Release to track versions or fetch binaries.
    | {{ anchify('gui') }}        | Images that provide a GUI, requires X.Org or alternatives.
    | {{ anchify('legacy') }}     | Images that are still using the old-style builds, not yet updated.
    | {{ anchify('nomad') }}      | These images include an example `nomad.hcl` job file.
    | {{ anchify('package') }}    | Applications that are installed from Alpine Package Database.
    | {{ anchify('proxy') }}      | Service images that include a reverse-proxy configuration example.
    | {{ anchify('service') }}    | Images that provide a service.
    | {{ anchify('shell') }}      | Images that provide a CLI interface. (Default as `root`)
    | {{ anchify('systemd') }}    | These images include a sample systemd service file.
    | {{ anchify('usershell') }}  | Images that provide a userspace CLI interface. (Default as `alpine`)

    Other than the above, the images are also tagged as per their
    source-image, e.g.

    | Source-Image | Description
    | :---         | :---
    | `glibc`      | Applications that require GNU LibC instead of musl.
    | `nginx`      | Images that build from NGINX.
    | `nodejs`     | Images that build from NodeJS.
    | `openjdk`    | Applications that require a java runtime, and build from OpenJDK.
    | `php`        | Applications that require NGINX/PHP.
    | `python`     | Applications that build from Python 2 or 3.
    | `s6`         | Images that build from s6.

[TAGS]
