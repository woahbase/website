variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "79"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "pigpio" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  priority    = 30
  # region      = local.var.region
  type        = "service"

  constraint { distinct_hosts = true }

  # constraint { # check meta toggle enabled
  #   attribute = meta.has_gpio_rpi
  #   value     = true
  # }

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
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "urlprefix-/pigpio/${attr.unique.hostname}"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/pigpio/${attr.unique.hostname}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
        type      = "tcp"
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
      port "http" { static = 8888 }
    }

    task "pigpio" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-pigpio:${var.version}"
        network_mode = "bridge"
        ports        = ["http"]

        # cap_add      = ["sys_rawio", "sys_admin"]
        # cap_drop     = []
        # privileged   = true

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        mount {
          type     = "bind"
          source   = "/etc/localtime"
          target   = "/etc/localtime"
          readonly = true
        }
      }

      # env {
      #   PIGPIO_ARGS = "-g"
      #   PIGPIO_PORT = "8888"
      #   # TZ   = local.var.tz
      # }

      resources {
        cpu    = 256 # MHz
        memory = 256 # MB
      }
    }
  }
}
