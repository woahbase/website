---
description: MultiArch Alpine Linux + S6 + RSysLog (and LogRotate)
has_services:
  - compose
tags:
  - service

s6_user: rsyslog
s6_userhome: /var/lib/rsyslog

---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [RSysLog][1] to
forward/collect log files to and from (respectively) between
devices in the network.

This container can collect or aggregate logs from

* the container itself,
* systemd of the host machine running docker via Journald socket,
* from other containers running in the same host via TCP/UDP (default port 514),
* (optionally) receive from (or send them to) remote machines
    using the Reliable Protocol (default port 2514).

Checkout the [rsyslog docs][2] to learn more. Also includes
[logrotate][3] to trim the collected logs daily with a Cron Job.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('rsyslog')
}} and {{ m.alpinepkg('logrotate') }} packages installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_rsyslog --hostname rsyslog \
  -e SYS_HOSTNAME=$HOSTNAME \
  -p 514:514/tcp \
  -p 514:514/udp \
  -p 2514:2514 \
  -v $PWD/data/log:/var/log \
  -v $PWD/data/spool:/var/spool/rsyslog \
  -v /run/systemd/journal:/run/systemd/journal  \
woahbase/alpine-rsyslog
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                    | Default                  | Description
| :---                        | :---                     | :---
| RSYSLOG_CONF                | /etc/rsyslog.conf        | Path to `rsyslog` configuration file.
| RSYSLOG_CONFD               | /etc/rsyslog.d           | Path to `rsyslog` configuration snippets directory.
| RSYSLOG_LOGDIR              | /var/log                 | Path to log store directory.
| RSYSLOG_SPOOLDIR            | /var/spool/rsyslog       | Path to log spooldir.
| RSYSLOG_PROFILE             | default                  | Use specified profile for configuration. Options are `default` for the configuration that comes with package, or `listener` for central log server, or `forwarder` to forward logs to remote host. Has no effect if file already exists.
| SYS_HOSTNAME                | name-of-host-machine     | Use specified hostname to separate container and host machine logs.
| FWD_PROTOCOL                | relp                     | Protocol for sending logs to remote host. (Used when `RSYSLOG_PROFILE` is set to `forwarder`.)
| FWD_TO_HOST                 | your.logserver.local     | Address of log-receiver host (Used when `RSYSLOG_PROFILE` is set to `forwarder`.)
| FWD_TO_PORT                 | 2514                     | Port of log-receiver host. (Used when `RSYSLOG_PROFILE` is set to `forwarder`.)
| RSYSLOG_ARGS                | -n                       | Customizable arguments passed to `rsyslog` service.
| LOGROTATE_CONF              | /etc/logrotate.conf      | Path to `logrotate` configuration file.
| LOGROTATE_CONFD             | /etc/logrotate.d         | Path to `logrotate` configuration snippets directory.
| LOGROTATE_CONF_RSYSLOG      | /etc/logrotate.d/rsyslog | Path to `logrotate` configuration file for `rsyslog`. (Copied from `/defaults` if not exists.)
| LOGROTATE_SKIP_CONF_RSYSLOG | unset                    | Set to `true` to skip copying `rsylog` default snippet, useful if using only `$LOGROTATE_CONF` for configurations. {{ m.sincev('8.2404.0') }}
| LOGROTATE_STATE             | /tmp/logrotate.state     | Holds runtime state for `logrotate`.
| LOGROTATE_PERIOD            | daily                    | When should `cron` run `logrotate`, options are `hourly`, `daily` , `weekly`, `monthly` etc.
{% include "envvars/cron.md" %}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* The configuration for RSysLog defaults to `/etc/rsyslog.conf`,
  in which case you drop your custom configurations at
  `/etc/rsyslog.d/`, but to use a different configuration, use the
  `RSYSLOG_CONF` variable, a {{ m.ghfilelink('root/defaults/rsyslog.conf', title='sample') }}
   is provided inside `/defaults/`, this gets copied if none exists.

* {{ m.defcfgfile('/etc/logrotate.conf', fr='`logrotate` (to trim
  the log files periodically)', vname='LOGROTATE_CONF') }} By
  default, it uses `/tmp/logrotate.state` for its state.

* Log rotation configurations for `rsyslog` are defined in
  `/etc/logrotate.d/rsyslog`. A {{ m.ghfilelink('root/defaults/rsyslog.logrotate', title='sample') }}
  configuration is provided in `/defaults/`, this gets copied if
  none exists.

* A {{ m.ghfilelink('root/defaults/logrotate.cron', title='sample') }}
  cron job script to rotate logs periodically
  is provided at `/defaults/`. This gets copied inside
  `/etc/periodic/` and is picked up by `cron` to be executed.
  The period is configurable by the `LOGROTATE_PERIOD`
  environment variable.

* To forward logs from Journald to the syslog inside the
  container, first make sure `syslog.socket` service is not
  running (or enabled) in the host machine, (that usually manages
  the socket at `/run/systemd/journal/syslog.socket`), then add
  the following to `/etc/systemd/journald.conf` under the
  `Journal` block,
  ```
  [Journal]
  ForwardToSyslog=yes
  ```
  and restart the service `systemd-journald`. Might want to set
  a name to the docker host instead of 'localhost', in that case set
  the name in the environment variable `SYS_HOSTNAME`, and uncomment
  the hostname configuration inside the `imuxsock` module input.

* To forward logs to a remote host, uncomment the transport type
  (TCP/UDP or RELP) in the configuration file at
  `data/config/rsyslog.conf`, the host and port to forward to can
  be set by the environment variable `FWD_TO_HOST` and
  `FWD_TO_PORT`, for TCP/UDP selection use the environment
  variable `FWD_PROTOCOL`.

[1]: https://www.rsyslog.com/
[2]: https://www.rsyslog.com/doc/
[3]: https://linux.die.net/man/8/logrotate

{% include "all-include.md" %}
