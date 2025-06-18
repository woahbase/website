# Types of Images

The images are tagged as per the following categories for ease of
navigation or search,

{% macro anchify(name) %}[`{{ name }}`](#tag:{{ name }}){% endmacro %}

??? info "Categories Explained"

    | Category                    | Description
    | :---                        | :---
    | {{ anchify('base') }}       | Base images that other images inherit.
    | {{ anchify('compose') }}    | These images include an example `docker-compose.yml` file.
    | {{ anchify('deprecated') }} | Deprecated images, to be used with caution.
    | {{ anchify('dev') }}        | Images used to develop or as base for applications that require the compiler/runtime.
    | {{ anchify('foreign') }}    | Images not built by us.
    | {{ anchify('github') }}     | Applications that use Github Release to track versions or fetch binaries.
    | {{ anchify('gui') }}        | Images that provide a GUI, requires X.Org or alternatives.
    | {{ anchify('legacy') }}     | Images that are still using the old-style builds, not yet updated.
    | {{ anchify('nomad') }}      | These images include an example `nomad.hcl` job file.
    | {{ anchify('package') }}    | Applications that are installed from Alpine Package Database.
    | {{ anchify('proxy') }}      | Service images that include a reverse-proxy configuration example.
    | {{ anchify('service') }}    | Images that provide a service.
    | {{ anchify('shell') }}      | Images that provide a CLI interface. (Default as `root`)
    | {{ anchify('systemd') }}    | These images include a sample systemd service file.
    | {{ anchify('usershell') }}  | Images that provide a [user-scoped](alpine-s6.md#usershell) CLI interface. (Default user as `alpine`)

    Other than the above, the images are also tagged as per their
    source-image, e.g.

    | Source-Image                | Description
    | :---                        | :---
    | {{ anchify('glibc') }}      | Applications that require GNU LibC instead of musl.
    | {{ anchify('nginx') }}      | Images that build from NGINX.
    | {{ anchify('nodejs') }}     | Images that build from NodeJS.
    | {{ anchify('openjdk8') }}   | Applications that require a java runtime, and build from OpenJDK8.
    | {{ anchify('php') }}        | Applications that require NGINX/PHP.
    | {{ anchify('python3') }}    | Applications that build from Python 3.
    | {{ anchify('s6') }}         | Images that build from s6.

<!-- material/tags { scope: true } -->
