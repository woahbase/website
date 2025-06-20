---
description: MultiArch Alpine Linux + S6 + Python3 + Ansible
tags:
  - dev
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base container for applications
/ services that require or build from [Ansible][1]. Checkout their
[docs][2] for [configuration][3] or [modules][4] to get started.

{{ m.srcimage('alpine-python3') }} with the {{
m.pypipkg('ansible') }} and {{ m.pypipkg('ansible-lint') }} and
{{ m.pypipkg('molecule') }} packages installed in it. Optionally
includes [Mitogen][6]. {{ m.ghreleasestr('ansible/ansible') }}

{% include "pull-image.md" %}

---
Run
---

We can call `ansible` commands directly on the container, or run `bash`
in the container to get a [user-scoped][114] shell,

=== "command"
    ``` sh
    docker run --rm -it \
      --name docker_ansible \
      --workdir /etc/ansible \
      -v $PWD:/etc/ansible \
    woahbase/alpine-ansible \
      ansible --version
    ```
=== "shell"
    ``` sh
    docker run --rm -it \
      --name docker_ansible \
      --workdir /etc/ansible \
      -v $PWD:/etc/ansible \
    woahbase/alpine-ansible \
      /bin/bash
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

* For environment variables that are specific to ansible, check
  [here][5].

* [Mitogen][6] is located at `/opt/mitogen`. To enable it, modify your
  `ansible.cfg` like below.
    ```
    [defaults]
    strategy_plugins = /opt/mitogen/ansible_mitogen/plugins/strategy
    # strategy = mitogen_linear
    # # setting strategy is optional, recommended to enable via
    # #   set strategy in playbook where needed
    # #   or environment variable ANSIBLE_STRATEGY=mitogen_linear
    ```

* Also, by default, the image expects

    * Your playbooks at `/etc/ansible/playbooks`
    * Inventory under `/etc/ansible/inventory`
    * Roles under `/etc/ansible/roles`
    * Collections under `/usr/share/ansible/collections` or `~/.ansible/collections`.
    * Modules under `/usr/share/ansible/plugins/modules` or `~/.ansible/modules`.
    * Ansible to be run as the user `alpine`.
    * Your ssh keys/configs at `/home/alpine/.ssh`

[1]: https://www.ansible.com/
[2]: https://docs.ansible.com/ansible/latest/index.html
[3]: https://docs.ansible.com/ansible/latest/reference_appendices/config.html
[4]: https://docs.ansible.com/ansible/latest/collections/index_module.html
[5]: https://docs.ansible.com/ansible/latest/reference_appendices/config.html#environment-variables
[6]: https://mitogen.networkgenomics.com/ansible_detailed.html#

{% include "all-include.md" %}
