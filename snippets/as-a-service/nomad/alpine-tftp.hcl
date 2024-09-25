variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "5.2"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "tftp" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  priority    = 80
  # region      = local.var.region
  type        = "service"

  constraint { distinct_hosts = true }

  group "docker" {
    count = 1

    restart {
      attempts = 2
      interval = "2m"
      delay    = "15s"
      mode     = "fail"
    }
    update {
      max_parallel     = 1
      min_healthy_time = "10s"
      healthy_deadline = "3m"
      auto_revert      = false
    }

    service {
      name        = NOMAD_JOB_NAME
      port        = "tftp"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
    }

    ephemeral_disk { size = 128 } # MB
    network {
      # dns { servers = local.var.dns_servers }
      port "tftp"  { static = 69  }
      # port-range mapping unsupported in nomad
      # using host network anyway
      # port "range" { static = 63050-63100 }
    }
    volume "nomad-tftp-pxe" {
      type      = "host"
      read_only = false
      source    = "nomad-tftp-pxe"
    }

    task "tftp" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-tftp:${var.version}"
        network_mode = "host"
        ports        = ["tftp"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        mount {
          type     = "bind"
          source   = "local/tftpd.map"
          target   = "/etc/tftpd.map"
          readonly = true
        }
        mount {
          type     = "bind"
          target   = "/etc/localtime"
          source   = "/etc/localtime"
          readonly = true
        }
      }

      volume_mount {
        # ensure policies allow vault-generated-token to read-write to the volume
        volume      = "nomad-tftp-pxe"
        destination = "/tftp"
        read_only   = false
      }

      env {
        PUID = var.puid
        PGID = var.pgid
        # TZ   = local.var.tz

        TFTP_ROOT = "/tftp"
        TFTPD_ARGS  = "-L4 --address 0.0.0.0:69 --port-range 63050:63100 --secure --map-file /etc/tftpd.map -vvv /tftp/"
      }

      resources {
        cpu    = 512 # MHz
        memory = 256 # MB
      }

      template {
        change_mode = "restart"
        destination = "local/tftpd.map"
        perms       = "755"
        data        = <<-EOF
          # from: https://linux.die.net/man/8/in.tftpd
          rg \\ /      # Convert backslashes to slashes
          r ^[^/] /\0  # Convert non-absolute files
          a ^/private/ # Reject requests for private dir
          a \.pvt$     # Reject requests for private files
          e ^/public/  # Allow access to  public files
          # Add the remote IP address as a folder on the front of all requests.
          # Essentially puts every request under its own IP jail. This way,
          #  Any host can have its own fileset in its own directory by its IP, referenced by /
          #  Only provisioned hosts can boot, other hosts unaffected
          #  HostA cannot get HostB files
          r ^ \i/
        EOF
      }
    }
  }
}
