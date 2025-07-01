---
description: MultiArch Alpine Linux + S6 + RSync(-Daemonized)
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, i386, ppc64le, riscv64, s390x, x86_64]
has_services:
  - compose
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as a local RSync(-Daemonized) server for
transferring files. Includes [openssl][2] with [rsync][1].

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('rsync') }}
package(s) installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service(s).

``` sh
docker run --rm \
  --name docker_rsyncd \
  -p 63873:873 \
  -e RSYNC_USER=user \
  -e RSYNC_USERPASS=insecurebydefault \
  -v $PWD/storage:/storage \
woahbase/alpine-rsyncd
```

--8<-- "multiarch.md"

then copy files to/from the host with `rsync` from anywhere in the
local network, (this is **unencrypted** and **weakly
authenticated**, use with moderate caution and only for
public/static datastores inside local networks)

e.g. list the datastores with

```
rsync -t rsync://user@<machine-ip-or-hostname> --port 63873
```

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars          | Default                             | Description
| :---              | :---                                | :---
| RSYNCD_CONFDIR    | /etc/rsyncd                         | Path to configuration dir. Expects `rsyncd.conf` to exist in this directory.
| RSYNCD_SNIPDIR    | /etc/rsyncd.d                       | Path to configuration snippets dir. Expects `*.inc` or `*.conf` files to exist in this directory.
| RSYNCD_EXCLUDES   | $RSYNCD_CONFDIR/rsyncd-excludes.txt | Path to default excludes file.
| RSYNCD_ROOTDIR    | /storage                            | Path to datastores root directory.
| RSYNCD_SECRETS    | $RSYNCD_CONFDIR/rsyncd.secrets      | Path to file containing `username:password` for `rsync` weak authentication.
| RSYNCD_PORT       | 873                                 | Rsyncd default port.
| RSYNCD_PIDFILE    | /var/run/rsyncd.pid                 | Path to PID file. (Set only if file does not exist.)
| RSYNCD_LOCKFILE   | /var/run/rsync.lock                 | Path to lock file. (Set only if file does not exist.)
| RSYNCD_LOGFILE    | /dev/stdout                         | Path to log file. (Set only if file does not exist.)
| RSYNCD_USER       | root                                | Rsyncd **default** user. Must be a user already exising in the system.
| RSYNCD_GROUP      | root                                | Rsyncd **default** group. Must be a group already exising in the system.
| RSYNCD_USERPASS   | insecurebydefaultroot               | Rsyncd **default user** password. Only set if `$RSYNCD_SECRETS` file does not exist.
| RSYNC_USER        | user                                | Rsyncd **alternate** user, for local network access.
| RSYNC_USERPASS    | insecurebydefault                   | Rsyncd **alternate** user password. Only set if `$RSYNCD_SECRETS` file does not exist.
| RSYNCD_ARGS       | --daemon --no-detach                | Customizable arguments passed to `rsync` service.
| RSYNCD_MAKEDIRS   | false                               | If set to `true`, ensure datastores (modules) referenced (as `path = ...`) in `rsyncd.conf` exist as directories.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* A default configuration set for RSync Daemon, (namely
  {{ m.ghfilelink('root/defaults/rsyncd.conf', title='rsyncd.conf') }})
  (and
  {{ m.ghfilelink('root/defaults/rsyncd.secrets', title='rsyncd.secrets') }}
  for password authentication, and
  {{ m.ghfilelink('root/defaults/rsyncd-excludes.txt', title='rsyncd-excludes.txt') }}
  to exclude a few system paths)
  is provided in `/defaults/`, these are copied into place if none
  exist. Check the [docs][3] to configure your own. Consider [this
  link][4] for best practices.

* Default `rsyncd.conf` sets up two datastores,

    * `/storage` : The root directory for datastores.

    * `/storage/data` : An example data directory.

[1]: https://www.samba.org/rsync/
[2]: https://www.openssl.org/
[3]: https://linux.die.net/man/5/rsyncd.conf
[4]: https://www.upguard.com/blog/secure-rsync

{% include "all-include.md" %}
