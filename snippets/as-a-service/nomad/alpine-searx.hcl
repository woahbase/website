variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "1.0.0"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "searx" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  # priority    = 50
  # region      = local.var.region
  type        = "service"

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
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "urlprefix-/search"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/search"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
        type      = "http"
        path      = "/"
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
      port "http" { static = 64888 }
    }

    task "searx" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-searx:${var.version}"
        network_mode = "host"
        ports        = ["http"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        # mount {
        #   source   = "local/settings.yml"
        #   target   = "/data/settings.yml"
        #   type     = "bind"
        #   readonly = true
        # }
        mount {
          type     = "bind"
          target   = "/etc/localtime"
          source   = "/etc/localtime"
          readonly = true
        }
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 1000 # MHz
        memory = 512  # MB
      }

      # template {
      #   destination = "local/settings.yml"
      #   data        = <<-EOC
      #     {{ key "nomad/${var.dc}/searx/settings.yml" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }
    }
  }
}
