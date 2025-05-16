variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 1000  # gid for docker
  puid = 1000  # uid for docker
  version = "1.27.6"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "syncthing" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  # priority    = 50
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
      port        = "http"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "urlprefix-/sync"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/sync"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
        type      = "tcp"
        # path      = "/"
        interval  = "60s"
        timeout   = "10s"
      }
      check_restart {
        limit     = 3
        grace     = "10s"
      }
    }

    ephemeral_disk { size = 128 } # MB
    network {
      # dns { servers = local.var.dns_servers }
      port "http"     { static = 8384  }
      port "quic"     { static = 22000 }
      port "discover" { static = 21027 }
    }
    volume "nomad-syncthing-config" {
      type      = "host"
      read_only = false
      source    = "nomad-syncthing-config"
    }
    volume "nomad-syncthing-data" {
      type      = "host"
      read_only = false
      source    = "nomad-syncthing-data"
    }

    task "syncthing" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-syncthing:${var.version}"
        network_mode = "bridge"
        ports        = ["http", "quic", "discover"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
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
        volume      = "nomad-syncthing-config"
        destination = "/var/syncthing/config"
        read_only   = false
      }
      volume_mount {
        volume      = "nomad-syncthing-data"
        destination = "/var/syncthing/data"
        read_only   = false
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 2000 # MHz
        memory = 1024 # MB
      }
    }
  }
}
