{% if (has_services | default([]) | length > 0) %}

---
##### As-A-Service
---

Run the container as a service with the following as
reference (and modify it as needed).

{%   if ('compose' in has_services) %}
=== "compose"

    With [docker-compose](https://docs.docker.com/compose/)

    ``` yaml
    --8<-- "as-a-service/compose/{{ page.title }}.yml"
    ```
{%   endif %}
{%   if ('nomad' in has_services) %}
=== "nomad"

    With [HashiCorp Nomad](https://www.nomadproject.io/)

    ``` hcl
    --8<-- "as-a-service/nomad/{{ page.title }}.hcl"
    ```
{%   endif %}
{%   if ('openrc' in has_services) %}
=== "openrc"

    As a [SysVInit/OpenRC](https://wiki.gentoo.org/wiki/OpenRC)
    service.

    ``` sh
    --8<-- "as-a-service/openrc/{{ page.title }}"
    ```
{%   endif %}
{%   if ('systemd' in has_services) %}
=== "systemd"

    As a [SystemD](https://www.freedesktop.org/software/systemd/man/255/systemd.service.html)
    service.

    ``` ini
    --8<-- "as-a-service/systemd/{{ page.title }}.service"
    ```
{%   endif %}
{% endif %}

{% if (has_proxies | default([]) | length > 0) %}

---
##### Reverse Proxy
---

To proxy it through a web server, see below

{%   if ('nginx' in has_proxies) %}
=== "NGINX"

    The following snippet can be used to reverse-proxy the service
    using [NGINX](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/).

    ``` nginx
    --8<-- "proxies/nginx/{{ page.title }}.conf"
    ```
{%   endif %}
{% endif %}
