{% if (has_services | default([]) | length > 0) -%}

---
##### As-A-Service
---

Run the container as a service with the following as
reference (and modify it as needed).

{%   if ('compose' in has_services) -%} {{- m.addpagetag('compose') -}}
=== "compose"

    With [docker-compose](https://docs.docker.com/compose/)
    ({{ m.ghfilelink('snippets/as-a-service/compose/' ~ page.title ~ '.yml',
      title=page.title ~ '.yml',
      org=config.repo_name.split("/")[0],
      ghrepo=config.repo_name.split("/")[-1]
    ) }})

    ``` yaml
    --8<-- "as-a-service/compose/{{ page.title }}.yml"
    ```
{%-  endif %}
{%   if ('nomad' in has_services) -%} {{- m.addpagetag('nomad') -}}
=== "nomad"

    With [HashiCorp Nomad](https://www.nomadproject.io/)
    ({{ m.ghfilelink('snippets/as-a-service/nomad/' ~ page.title ~ '.hcl',
      title=page.title ~ '.hcl',
      org=config.repo_name.split("/")[0],
      ghrepo=config.repo_name.split("/")[-1]
    ) }})

    ``` hcl
    --8<-- "as-a-service/nomad/{{ page.title }}.hcl"
    ```
{%-  endif %}
{%   if ('openrc' in has_services) -%} {{- m.addpagetag('openrc') -}}
=== "openrc"

    As a [SysVInit/OpenRC](https://wiki.gentoo.org/wiki/OpenRC) service.
    ({{ m.ghfilelink('snippets/as-a-service/openrc/' ~ page.title,
      title=page.title ~ '.init',
      org=config.repo_name.split("/")[0],
      ghrepo=config.repo_name.split("/")[-1]
    ) }})

    ``` sh
    --8<-- "as-a-service/openrc/{{ page.title }}"
    ```
{%-  endif %}
{%   if ('systemd' in has_services) -%} {{- m.addpagetag('systemd') -}}
=== "systemd"

    As a [SystemD](https://www.freedesktop.org/software/systemd/man/255/systemd.service.html) service.
    ({{ m.ghfilelink('snippets/as-a-service/systemd/' ~ page.title ~ '.service',
      title=page.title ~ '.service',
      org=config.repo_name.split("/")[0],
      ghrepo=config.repo_name.split("/")[-1]
    ) }})

    ``` ini
    --8<-- "as-a-service/systemd/{{ page.title }}.service"
    ```
{%-   endif %}
{%- endif %}

{% if (has_proxies | default([]) | length > 0) -%}

---
##### Reverse Proxy
---

To proxy it through a web server, see below

{%   if ('nginx' in has_proxies) -%} {{- m.addpagetag('proxy') -}}
=== "NGINX"

    This
    {{ m.ghfilelink('snippets/proxies/nginx/' ~ page.title ~ '.conf',
      title='snippet',
      org=config.repo_name.split("/")[0],
      ghrepo=config.repo_name.split("/")[-1]
    ) }} can be used to reverse-proxy the service using
    [NGINX](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/).

    ``` nginx
    --8<-- "proxies/nginx/{{ page.title }}.conf"
    ```
{%-   endif %}
{%- endif %}
