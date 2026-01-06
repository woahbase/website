---
description: MultiArch Alpine Linux + S6 + cGit + SSHd for network-local repositories.
alpine_branch: v3.23
arches: [aarch64, armhf, armv7l, i386, ppc64le, riscv64, s390x, x86_64]
has_services:
  - compose
  - nomad
has_proxies:
  - nginx
tags:
  - service

s6_user: git

---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes [cGit][1] running under
a [LigHttpd][2] server to serve locally hosted git repositories.
Can also be used to clone and push/pull the repos using git via
[SSH][3]/PubKey authentication. Scripts included to ease the tasks
of creating or mirroring bare repositories, or to sync them
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

| ENV Vars              | Default                          | Description
| :---                  | :---                             | :---
| CGIT_HOSTNAME         | localhost                        | Hostname to set in the url for cloning via web or ssh.
| CGIT_SUBPATH          | unset                            | Alternate virtual-root for CGit repositories, can be `""` (unset or empty-string for serving at root path) or a path like `/git` or `/repos`, but **cannot** be `"/"` (single backslash) or `/cgit`. {{ m.sincev('1.2.3_20250702') }} Previously defaulted to `/git`.
| CGIT_REPODIR          | /home/{{ s6_user }}/repositories | Default path to repositories. {{ m.sincev('1.2.3_20240907') }}
| CGIT_ARCHIVEDIR       | ${CGIT_REPODIR}/.archived          | Default path to archived repos (used in `backup`/`restore` scripts). {{ m.sincev('1.2.3_20240907') }}
| CGIT_SKIP_PERMFIX     | unset                            | If set to a **non-empty-string** value (e.g. `1`), skips fixing permissions for `cgit` configuration files/directories. {{ m.sincev('1.2.3_20250702') }}
| CGIT_PERMFIX_REPOS    | unset                            | If set to `true`, will fix repositories permissions to `${S6_USER}` (default `git:git`). {{ m.sincev('1.2.3_20240907') }}
| CGIT_GIT_CONFIG       | /home/{{ s6_user }}/.gitconfig   | Customizable configurations for git. (used in scripts) {{ m.sincev('1.2.3_20250311') }}
| CGIT_HOOKSDIR         | /defaults/hooks                  | Custom hooks to add into repositories created via the `bareinit` or `mirror` script. {{ m.sincev('1.2.3_20240907') }}
| CGIT_HOOKS            | unset                            | **Comma**-separated list of hooks to add into repositories created via the `bareinit` or `mirror` script. e.g. `"post-receive,post-update"`. (Previously all hooks in `${CGIT_HOOKSDIR}` were copied) If any hook listed here is not found, the default hook from the `(repository-name)/hooks` directory is copied instead.{{ m.sincev('1.2.3_20250311') }}
| CGIT_REPOS_MAXDEPTH   | 3                                | Maximum depth to search for repositores, (used in scripts). {{ m.sincev('1.2.3_20250311') }}
| CGIT_SYNC_RUNFILE     | /tmp/sync_is_running             | File indicator that a sync job is already running. (used in `sync` script) {{ m.sincev('1.2.3_20240907') }}
| CGIT_SYNC_LIST        | /tmp/sync_list_of_repos          | List of repositories to sync, generated at start of sync job. (used in `sync` script) {{ m.sincev('1.2.3_20240907') }}
| CGIT_SYNC_IGNORELIST  | ${CGIT_REPODIR}/ignored.txt        | List of repositories to ignore while sync. (format: (category)/(repo-name).git) (used in `sync` script) {{ m.sincev('1.2.3_20240907') }}
| CGIT_SYNC_ERRORLIST   | ${CGIT_REPODIR}/errors.txt         | Catches errors encountered while sync. Flushed on each run. (used in `sync` script) {{ m.sincev('1.2.3_20240907') }}
| CGIT_SYNC_JOBS        | 1                                | Number of threads used by `git` to sync a repository. {{ m.sincev('1.2.3_20240907') }}
| CGIT_SYNC_FSCK        | false                            | If set to `true`, the `sync` script runs a `git fsck` **before** fetch for all repositories. Alternately, create a file named `SYNC_NEED_FSCK` in a repository to enable just for that repository. {{ m.sincev('1.2.3_20250311') }}
| CGIT_SYNC_REPACK      | false                            | If set to `true`, the `sync` script runs a `git repack` **after** fetch for all repositories. Alternately, create a file named `SYNC_NEED_REPACK` in a repository to enable just for that repository. {{ m.sincev('1.2.3_20250311') }}
| LIGHTTPD_CONFDIR      | /etc/lighttpd                    | Path to `lighttpd` configuration directory. {{ m.sincev('1.2.3_20240907') }}
| LIGHTTPD_LOGFILE      | /var/log/lighttpd/lighttpd.log   | Logfile for `lighttpd`, by default logs both access and error logs. {{ m.sincev('1.2.3_20240907') }}
| LIGHTTPD_USER         | lighttpd                         | Non-root user that `lighttpd` drops privileges to. {{ m.sincev('1.2.3_20240907') }}
| LIGHTTPD_ARGS         | -D                               | Customizable arguments passed to `lighttpd` service.
| LIGHTTPD_SKIP_LOGFIFO | unset                            | By default `lighttpd` logs to `stdout` via a `fifo`, set this to `true` to log to a regular file instead. {{ m.sincev('1.2.3_20240907') }}
| SSHD_CONFDIR          | /etc/ssh                         | Path to `ssh` server configuration directory. {{ m.sincev('1.2.3_20240907') }}
| SSHD_ARGS             | -De                              | Customizable arguments passed to `sshd` service.
| SSHD__(parameter)     | unset                            | If set, will update the parameter (if exists) with the value in `sshd_config`. E.g. `SSHD__Port=2222`. (Note the **double** underscores.) {{ m.sincev('1.2.3_20240907') }}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Default configuration listens to ports `80` and `22`(ssh), these
  may be published at `64801` and `64822` by default, so they
  don't clash with other services.

* {{ m.defcfgfile('/etc/cgitrc', fr='CGit') }}

* {{ m.defcfgfile('/etc/lighttpd/lighttpd.conf', fr='Lighttpd') }} {{ m.sincev('1.2.3_20240907') }}

* By default, cGit is deployed using the {{
  m.ghfilelink('root/defaults/cgit.root.lighttpd.conf',
  title='root path example') }} at the root path `/`, {{
  m.sincev('1.2.3_20250702') }}. If you need your repositories
  served at a subpath like `/git/`, set `${CGIT_SUBPATH}` to
  a non-empty-string e.g `/git`, that will use the {{
  m.ghfilelink('root/defaults/cgit.subpath.lighttpd.conf',
  title='subpath example') }} instead to deploy the service at
  `/cgit`, and aliased to `/git/` for convenience. Of course
  this only applies if any custom file
  `${LIGHTTPD_CONFDIR}/cgit.conf` does not already exist.

* {{ m.defcfgfile('/etc/ssh/sshd_config', fr='SSH server') }}

* To persist the same SSH host keys, preserve their contents at `/etc/ssh`.
  These are re-generated if not found.

* Only allows pubkey authentication by default, either use the one
  for the user git, or add your own in
  `/home/git/.ssh/authorized_keys` to get clone and push/pull
  access. Default adds only the pubkey of the `git` user, if
  that does not exist, a new set of private/public keys are
  generated.

* Repositories stored at `/home/git/repositories`, can be changed
  via setting the `${CGIT_REPODIR}` environment variable.

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
`${CGIT_ARCHIVEDIR}/(optional category-dir)/repo-name`, {{ m.sincev('1.2.3_20240907') }}

``` sh
docker exec -u {{ s6_user }} -it docker_cgit /scripts/backup <filters: category-dirs, or reponames>
```

Restore a backed-up repository from
`${CGIT_ARCHIVEDIR}/(optional category-dir)/repo-name`, {{ m.sincev('1.2.3_20240907') }}

``` sh
docker exec -u {{ s6_user }} -it docker_cgit /scripts/restore <filters: category-dirs, or reponames>
```

[1]: https://git.zx2c4.com/cgit/
[2]: https://www.lighttpd.net/
[3]: https://www.openssh.com/
[4]: https://wiki.archlinux.org/title/Cgit

{% include "all-include.md" %}
