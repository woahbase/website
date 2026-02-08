---
description: MultiArch Alpine Linux + S6 + ISC DHCP server.
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, i386, ppc64le, riscv64, s390x, x86_64]
has_services:
  - compose
  - systemd
tags:
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [ISC DHCP][1] to quickly
deploy a DHCP server to serve/manage IP configurations to the
devices in the network.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('dhcp', branch='v3.20') }}
package installed in it.

???+ warning "DHCP deprecated since v3.21"

    `dhcp` packages are unavailable in Alpine Linux Repositories since
    `v3.21`. This image uses the final pre-built packages (`4.4.3-p1`) from
    the `v3.20` repository.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_dhcp \
  --network=host \
  -e INTERFACES=eth0 \
  -p 67:67/tcp -p 67:67/udp \
  -v $PWD/dhcp:/etc/dhcp \
woahbase/alpine-dhcp
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars    | Default                    | Description
| :---        | :---                       | :---
| DHCP_CONF   | /etc/dhcp/dhcpd.conf       | Path to configuration file.
| DHCP_LEASES | /var/lib/dhcp/dhcpd.leases | Path to lease(s) database.
| DHCP_ARGS   | -4 -f -d --no-pid          | Customizable arguments passed to `dhcpd` service.
| INTERFACES  | eth0                       | Bind to the specific NIC.

Also,

* ISC-DHCP needs the `--network=host` flag to have access to the
  NIC of the host machine.

* {{ m.defcfgfile('/etc/dhcp/dhcpd.conf', vname='DHCP_CONF') }}

* Check the [docs][2] or [configuration][3] options for
  customizing your own.

##### Recipes

=== "Event Hooks"

    For running a hook-script when an event takes place, consider the
    following (references [here][6] and [here][7])

    ``` conf
    subnet 172.17.0.0 netmask 255.255.255.0 {
      # your subnet specific configurations

      # event can be one of commit | expiry | release e.g.
      on commit {
        set chw = binary-to-ascii(16, 8, ":", substring(hardware, 1, 6));
        set cip = binary-to-ascii(10, 8, ".", leased-address);
        set cnm = pick-first-value(host-decl-name, option fqdn.hostname, option host-name, "unknown");
        execute("/bin/dhcp_on_event", "commit", chw, cip, cnm);
      }
      on expiry {
        set chw = binary-to-ascii(16, 8, ":", substring(hardware, 1, 6));
        set cip = binary-to-ascii(10, 8, ".", leased-address);
        set cnm = pick-first-value(host-decl-name, option fqdn.hostname, option host-name, "unknown");
        execute("/bin/dhcp_on_event", "expiry", chw, cip, cnm);
      }
      on release {
        set chw = binary-to-ascii(16, 8, ":", substring(hardware, 1, 6));
        set cip = binary-to-ascii(10, 8, ".", leased-address);
        set cnm = pick-first-value(host-decl-name, option fqdn.hostname, option host-name, "unknown");
        execute("/bin/dhcp_on_event", "release", chw, cip, cnm);
      }
    }
    ```

    and the script can be like

    ``` sh
    #!/bin/bash

    EVT="${1:? \$1 event type is required}";
    CHW="${2:? \$2 client-MAC is required}";
    CIP="${3:? \$3 client-ip is required}";
    CNM="${4:? \$4 client-hostname is required}";

    echo "Detected event ${EVT} for host ${CNM} with address ${CIP} (mac ${CHW})";

    # now do whatever is needed,
    # keep in mind the script should return as soon as possible
    ```

=== "Failover"

    To configure failover, consider setting up two servers (namely
    `primary` and `secondary`) like the following.

    === "primary"

        ``` conf
        failover peer "dhcp-failover" {
          primary;
          address 172.17.0.39; # Primary DHCP Server IP
          port 647; # Primary DHCP Server port
          peer address 172.17.0.67; # Secondary DHCP Server IP
          peer port 847; # Secondary DHCP Server port
          mclt 120;
          split 128;
          load balance max seconds 5;
          max-response-delay 15;
          max-unacked-updates 10;
        }

        # optionally include shared configurations from another file
        # include "/etc/dhcp/dhcpd.shared.conf";

        subnet 172.17.0.0 netmask 255.255.255.0 {
          # your subnet specific configurations
          pool {
            failover peer "dhcp-failover";
            # your pool specific parameters
          };
        };
        ```

    === "secondary"

        ``` conf
        failover peer "dhcp-failover" {
          secondary;
          address 172.17.0.67; # Secondary DHCP Server IP
          port 847; # Secondary DHCP Server port
          peer address 172.17.0.39; # Primary DHCP Server IP
          peer port 647; # Primary DHCP Server port
          max-response-delay 15;
          max-unacked-updates 10;
          load balance max seconds 5;
        }

        # optionally include shared configurations from another file
        # include "/etc/dhcp/dhcpd.shared.conf";

        subnet 172.17.0.0 netmask 255.255.255.0 {
          # your subnet specific configurations
          pool {
            failover peer "dhcp-failover";
            # your pool specific parameters
          };
        };
        ```

=== "Multiple Subnets"

    To use the **same** NIC for multiple subnets, define them inside
    a shared network. E.g.

    ``` conf
    shared-network multi-subnet {
      subnet 172.17.0.0 netmask 255.255.255.0 {
        # your subnet specific parameters
        ...
      }
      subnet 172.17.1.0 netmask 255.255.255.0 {
        # your subnet specific parameters
        ...
      }
      subnet 172.17.2.0 netmask 255.255.255.0 {
        # your subnet specific parameters
        ...
      }
      subnet 172.17.3.0 netmask 255.255.255.0 {
        # your subnet specific parameters
        ...
      }
    }
    ```

    Additionally, if clients are on a different subnet than the
    DHCP server, then your router/switch must be configured to act
    as a DHCP relay (IP Helper) to ensure DHCP packets are able to
    reach the hosts.

[1]: https://www.isc.org/dhcp/
[2]: https://linux.die.net/man/8/dhcpd
[3]: https://linux.die.net/man/5/dhcpd.conf
[4]: https://kb.isc.org/docs/en/tags/isc%20dhcp
[5]: https://www.iana.org/assignments/bootp-dhcp-parameters/bootp-dhcp-parameters.xhtml
[6]: https://www.tspi.at/2021/05/15/dhcpdevents.html#gsc.tab=0
[7]: https://jpmens.net/2011/07/06/execute-a-script-when-isc-dhcp-hands-out-a-new-lease/

{% include "all-include.md" %}
