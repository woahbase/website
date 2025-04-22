variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "0.55.2"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "navidrome" {
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
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "urlprefix-/navidrome"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/navidrome"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
        type      = "http"
        path      = "/navidrome"
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
      port "http" { static = 4533  }
    }
    volume "nomad-navidrome-data" {
      type      = "host"
      read_only = false
      source    = "nomad-navidrome-data"
    }
    volume "nomad-media-music" {
      type      = "host"
      read_only = false
      source    = "nomad-media-music"
    }

    task "navidrome" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-navidrome:${var.version}"
        network_mode = "bridge"
        ports        = ["http"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        # mount {
        #   type     = "bind"
        #   source   = "local/navidrome.toml"
        #   target   = "/data/navidrome.toml"
        #   readonly = true
        # }
        mount {
          type     = "bind"
          target   = "/etc/localtime"
          source   = "/etc/localtime"
          readonly = true
        }
      }

      volume_mount {
        # ensure policies allow vault-generated-token to read-write to the volume
        volume      = "nomad-navidrome-data"
        destination = "/data"
        read_only   = false
      }
      volume_mount {
        volume      = "nomad-media-music"
        destination = "/music"
        read_only   = false
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 512 # MHz
        memory = 512 # MB
      }
      # template {
      #   destination = "local/navidrome.toml"
      #   data        = <<-EOC
      #     {{ key "nomad/${var.dc}/navidrome/navidrome.toml" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }
    }
  }
}
