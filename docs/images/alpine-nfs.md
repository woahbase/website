---
description: MultiArch Alpine Linux + S6 + NFS Server
svcname: nfs
has_services:
  - compose
  - nomad
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [NFS][1] server to share
files/directories over the network to devices in the same LAN.
Checkout this [link][2] to get started. Not really useful over the
internet because security concerns. It *can* be tunnelled by SSH but
thats quite slow and there are better options.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('nfs-utils')
}} installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

=== "NFSv4"
    ``` sh
    docker run --rm \
      --name docker_nfs \
      --privileged \
      -p 111:111/tcp   -p 111:111/udp \
      -p 2049:2049/tcp -p 2049:2049/udp \
      -v $PWD/data:/data \
    woahbase/alpine-nfs
    ```
=== "NFSv3-or-v2"
    ``` sh
    docker run --rm \
      --name docker_nfs \
      --privileged \
      -p 111:111/tcp     -p 111:111/udp \
      -p 2049:2049/tcp   -p 2049:2049/udp \
      -p 32765:32765/tcp -p 32765:32765/udp \
      -p 32766:32766/tcp -p 32766:32766/udp \
      -p 32767:32767/tcp -p 32767:32767/udp \
      -p 32768:32768/tcp -p 32768:32768/udp \
      -v $PWD/data:/data \
    woahbase/alpine-nfs
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars            | Default                                                       | Description
| :---                | :---                                                          | :---
| NFS_DATADIR         | /data                                                         | Default directory for exports, created if not exists. {{ m.sincev('2.6.4_20240912') }}
| LOCKD_PORT          | 32768                                                         | Default port exposed for `lockd`, may require firewall whitelisting.
| SKIP_SYSCTL         | unset                                                         | If set to `true`, will skip applying sysctl mods to kernel. Useful if those are already done at the provision level.
| EXPORTFS_ARGS       | -afrv                                                         | Customizable arguments passed to `exportfs`.
| MOUNTD_PORT         | 32767                                                         | Default port exposed for `rpc.mountd`, may require firewall whitelisting.
| MOUNTD_ARGS         | -F -p $MOUNTD_PORT --debug all                                | Customizable arguments passed to `rpc.mountd` service.
| NFSD_ARGS           | --debug 8                                                     | Customizable arguments passed to `rpc.nfsd` service.
| RPCBIND_ARGS        | -fw                                                           | Customizable arguments passed to `rpcbind` service.
| STATD_PORT          | 32765                                                         | Default port exposed for `statd`, may require firewall whitelisting.
| STATD_OUTGOING_PORT | 32766                                                         | Default port exposed for `statd` outbound connections, may require firewall whitelisting.
| STATD_ARGS          | --port $STATD_PORT --outgoing-port $STATD_OUTGOING_PORT -F -d | Customizable arguments passed to `statd` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Requires either `--cap-add SYS_ADMIN` capabilities or
  `--privileged` flag if applying `sysctl` changes.

* {{ m.defcfgfile('/etc/exports', fr='exported directories') }}
  By default it exposes `/data` at `/`.

* NFSv4 configuration listens to ports `111` and `2049`. But for
  older versions there are multiple ports that need to be opened,
  this may be required if PXE-booting hosts e.g. Raspberry Pi
  devices. (For running a `tftp` server, checkout our
  {{ m.myimage('alpine-tftp') }} image)

* By default runs as `NFSMODE = "SERVER"`, to use it as a client
  change its value to `CLIENT`. However, this way is not really
  useful in reality unless for testing.

* Previously used to contain a client pre-task file to mount NFS
  volumes before service-start, but docker has since made it
  easier to mount volumes directly into container, check the
  `client` or `client_volume` targets in the `makefile` or [this
  link][3]. A {{ m.ghfilelink('root/defaults/fstab.nfs',
  title='sample') }} is kept only for testing/reference.

[1]: https://en.wikipedia.org/wiki/Network_File_System
[2]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/deployment_guide/ch-nfs
[3]: https://www.baeldung.com/linux/docker-mount-nfs-shares

{% include "all-include.md" %}
