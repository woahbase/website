{% if (has_services | default([]) | length > 0) %}

---
##### As-A-Service
---

Run the container as a service with the following as
reference (and modify it as needed).

{%   if ('compose' in has_services) %}
=== "compose"

    With [docker-compose](https://docs.docker.com/compose/)
    ({{ m.ghfilelink('snippets/as-a-service/compose/' + page.title + '.yml', title=page.title + '.yml', ghrepo='website') }})

    ``` yaml
    --8<-- "as-a-service/compose/{{ page.title }}.yml"
    ```
{{     (page.meta.tags.append('compose') or "") if not 'compose' in page.meta.tags }}
{%   endif %}
{%   if ('nomad' in has_services) %}
=== "nomad"

    With [HashiCorp Nomad](https://www.nomadproject.io/)
    ({{ m.ghfilelink('snippets/as-a-service/nomad/' + page.title + '.hcl', title=page.title + '.hcl', ghrepo='website') }})

    ``` hcl
    --8<-- "as-a-service/nomad/{{ page.title }}.hcl"
    ```
{{     (page.meta.tags.append('nomad') or "") if not 'nomad' in page.meta.tags }}
{%   endif %}
{%   if ('openrc' in has_services) %}
=== "openrc"

    As a [SysVInit/OpenRC](https://wiki.gentoo.org/wiki/OpenRC) service.
    ({{ m.ghfilelink('snippets/as-a-service/openrc/' + page.title, title=page.title + '.init', ghrepo='website') }})

    ``` sh
    --8<-- "as-a-service/openrc/{{ page.title }}"
    ```
{{     (page.meta.tags.append('openrc') or "") if not 'openrc' in page.meta.tags }}
{%   endif %}
{%   if ('systemd' in has_services) %}
=== "systemd"

    As a [SystemD](https://www.freedesktop.org/software/systemd/man/255/systemd.service.html) service.
    ({{ m.ghfilelink('snippets/as-a-service/systemd/' + page.title + '.service', title=page.title + '.service', ghrepo='website') }})

    ``` ini
    --8<-- "as-a-service/systemd/{{ page.title }}.service"
    ```
{{     (page.meta.tags.append('systemd') or "") if not 'systemd' in page.meta.tags }}
{%   endif %}
{% endif %}

{% if (has_proxies | default([]) | length > 0) %}

---
##### Reverse Proxy
---

To proxy it through a web server, see below

{%   if ('nginx' in has_proxies) %}
=== "NGINX"

    This
    {{ m.ghfilelink('snippets/proxies/nginx/' + page.title + '.conf', title='snippet', ghrepo='website') }}
    can be used to reverse-proxy the service using
    [NGINX](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/).

    ``` nginx
    --8<-- "proxies/nginx/{{ page.title }}.conf"
    ```
{{     (page.meta.tags.append('proxy') or "") if not 'proxy' in page.meta.tags }}
{%   endif %}
{% endif %}
