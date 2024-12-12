---
description: MultiArch Alpine Linux + S6 + SSH/SSL + RSync + TMux
svcname: ssh
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base image for applications
/ services that require running an isolated shell via
[OpenSSH][1] server or for transferring files securely via
[RSync][2] (over SSH). Also includes [openssl][3],
[autossh][6] and [sshfs][5] and [tmux][8].

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('openssh') }}
and {{ m.alpinepkg('rsync') }} and {{ m.alpinepkg('tmux') }}
package(s) installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_ssh \
  -p 64822:22 \
  -e S6_ROOTPASS=insecurebydefaultroot \
  -e S6_USER=alpine \
  -e S6_USERPASS=insecurebydefault \
  -v $PWD/data/host:/etc/ssh \
  -v $PWD/data/user:/home/alpine \
woahbase/alpine-ssh
```

--8<-- "multiarch.md"

then login inside the container from anywhere in the network
with

```
ssh alpine@<machine-ip-or-hostname> -p 64822
```

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars          | Default                             | Description
| :---              | :---                                | :---
| S6_ROOTPASS       | insecurebydefaultroot               | Default root password. (Unset if not supplied)
| S6_USERPASS       | insecurebydefault                   | Default user password. (Unset if not supplied)
| S6_USERSHELL      | /bin/bash                           | Default user shell.
| SSHD_CONFDIR      | /etc/ssh                            | Path to configuration dir. Expects `sshd_config` or `ssh_config` files to exist in this directory.
| SSHD_ARGS         | -De                                 | Customizable arguments passed to `sshd` service.
| SSHD__(parameter) | unset                               | If set, will update the parameter (if exists) with the value in `sshd_config`. E.g. `SSHD__Port=2222`. (Note the **double** underscores.)
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Default configuration files for SSH Daemon, namely {{
  m.ghfilelink('root/defaults/sshd_config', title='sshd_config')
  }} (and {{ m.ghfilelink('root/defaults/ssh_config',
  title='ssh_config') }}) is provided in `/defaults`, these are
  copied into place if none exist.

* Custom configuration snippets can also be mounted at
  `/etc/ssh/sshd_config.d/` or `/etc/ssh/ssh_config.d/` if needed.

* {{ m.customscript('p11-autossh-setup', fr='autossh') }} Refer
  to the [manpage][4] to configure your own.

* {{ m.customscript('p12-sshfs-setup', fr='sshfs') }} Refer to
  the [manpage][7] to configure your own.

[1]: https://www.openssh.com/
[2]: https://www.samba.org/rsync/
[3]: https://www.openssl.org/
[4]: https://linux.die.net/man/1/autossh
[5]: https://github.com/libfuse/sshfs
[6]: https://github.com/Autossh/autossh
[7]: https://linux.die.net/man/1/sshfs
[8]: https://github.com/tmux/tmux

{% include "all-include.md" %}
