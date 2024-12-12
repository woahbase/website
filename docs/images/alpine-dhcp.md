---
description: MultiArch Alpine Linux + S6 + ISC DHCP server.
svcname: dhcp
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

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('dhcp') }}
package installed in it.

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

##### DHCP Failover

For failover, consider configuring two servers (namely `primary` and
`secondary`) like the following.

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

[1]: https://www.isc.org/dhcp/
[2]: https://linux.die.net/man/8/dhcpd
[3]: https://linux.die.net/man/5/dhcpd.conf
[4]: https://kb.isc.org/docs/en/tags/isc%20dhcp
[5]: https://www.iana.org/assignments/bootp-dhcp-parameters/bootp-dhcp-parameters.xhtml

{% include "all-include.md" %}
