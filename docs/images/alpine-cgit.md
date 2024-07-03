---
description: MultiArch Alpine Linux + S6 + cGit + SSHd for network-local repositories.
svcname: cgit
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - compose
  - nomad
  - package
  - proxy
  - s6
  - service

s6_user: git

---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [cGit][1] running under
a [LigHttpd][2] server to serve locally hosted git repositories.
Can also be used to clone and push/pull the repos using git via
[SSH][3]/PubKey authentication. Scripts included to ease the
tasks e.g creating or mirroring bare repositories, or sync them
periodically.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('cgit') }}
package installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_cgit \
  -p 64801:80 -p 64822:22 \
  -v $PWD/data/git`#(1)`:/home/git \
  -v $PWD/data/repositories`#(2)`:/home/git/repositories \
  -v $PWD/data/ssh`#(3)`:/etc/ssh \
  -v $PWD/data/web`#(4)`:/var/www \
woahbase/alpine-cgit
```

1. Path to git user homedir, ssh-configurations generated/persisted here.
2. (Required) Path to repositories storage root directory.
3. (Required) If you want the host keys to persist.
4. (Optional) Path to web-ui customization files directory.

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars             | Default                          | Description
| :---                 | :---                             | :---
| CGIT_HOSTNAME        | localhost                        | Hostname to set in the url for cloning via web or ssh.
| CGIT_SUBPATH         | /git                             | Alternate virtual-root repositories, default is `/cgit`.
| CGIT_REPODIR         | /home/{{ s6_user }}/repositories | Default path to repositories.
| CGIT_ARCHIVEDIR      | $CGIT_REPODIR/.archived          | Default path to archived repos (used in `backup`/`restore` scripts).
| CGIT_HOOKSDIR        | /defaults/hooks                  | Custom hooks to add into repositories created via the `bareinit` or `mirror` script.
| CGIT_SYNC_RUNFILE    | /tmp/sync_is_running             | File indicator that a sync job is already running. (used in `sync` script)
| CGIT_SYNC_LIST       | /tmp/sync_list_of_repos          | List of repositories to sync, generated at start of sync job. (used in `sync` script)
| CGIT_SYNC_IGNORELIST | $CGIT_REPODIR/ignored.txt        | List of repositories to ignore while sync. (format: (category)/(repo-name).git) (used in `sync` script)
| CGIT_SYNC_ERRORLIST  | $CGIT_REPODIR/errors.txt         | Catches errors encountered while sync. Flushed on each run. (used in `sync` script)
| LIGHTTPD_ARGS        | -D                               | Custom arguments passed to `lighttpd` service.
| SSHD_ARGS            | -De                              | Custom arguments passed to `sshd` service.
{% include "envvars/alpine-s6.md" %}

Also,

* cGit is deployed at the path `/cgit/`, alternately proxied to
  `/git/` for convenience, controlled via the `CGIT_SUBPATH`
  environment variable.

* Default configuration listens to ports `80` and `22`(ssh), these
  may be published at `64801` and `64822` by default, so they
  don't clash with other services.

* Config file loaded from `/etc/cgitrc` edit or remount this with
  your own. A {{ m.ghfilelink('root/defaults/cgitrc',
  title='sample') }} is provided which is auto loaded if there
  aren't any config file to start with.

* To persist the same host keys, preserve their contents at `/etc/ssh`.
  These are re-generated if not found.

* Only allows pubkey authentication by default, either use the one
  for the user git, or add your own in
  `/home/git/.ssh/authorized_keys` to get clone and push/pull
  access. Default adds only the pubkey of the `git` user, if
  that does not exist, a new set of private/public keys are
  generated.

* Repositories stored at `/home/git/repositories`, can be changed
  via setting the `CGIT_REPODIR` environment variable.

* Web specific stuff, e.g `about.html` or syntax filters should be
  inside `/var/www`, cgit provides some default filters (not used)
  located at `/usr/lib/cgit/`. Mount or configure your own if
  that's what you need.

---
##### Scripts
---

A few {{ m.ghfilelink('root/scripts', title='scripts') }} for
common tasks are baked into the image, E.g. we can create a bare
repository with,

``` sh
docker exec -u {{ s6_user }} -it docker_cgit /scripts/bareinit
```

Mirror a copy of an existing online repository locally with,

``` sh
docker exec -u {{ s6_user }} -it docker_cgit /scripts/mirror
```

Sync the repositories already tracking with their remote,

``` sh
docker exec -u {{ s6_user }} -it docker_cgit /scripts/sync
```

Backup a bare or mirror repository to
`$CGIT_ARCHIVEDIR/(optional category-dir)/repo-name`,

``` sh
docker exec -u {{ s6_user }} -it docker_cgit /scripts/backup <filters: category-dirs, or reponames>
```

Restore a backed-up repository from
`$CGIT_ARCHIVEDIR/(optional category-dir)/repo-name`,

``` sh
docker exec -u {{ s6_user }} -it docker_cgit /scripts/restore <filters: category-dirs, or reponames>
```

[1]: https://git.zx2c4.com/cgit/
[2]: https://www.lighttpd.net/
[3]: https://www.openssh.com/

{% include "all-include.md" %}
