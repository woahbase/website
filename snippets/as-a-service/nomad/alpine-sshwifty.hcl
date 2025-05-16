variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 1000  # gid for docker
  puid = 1000  # uid for docker
  version = "0.2.27-beta-release-prebuild"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "sshwifty" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  priority    = 70
  # region      = local.var.region
  type        = "service"

  # vault { policies = ["nomad-kv-readonly"] }

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
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "host=ssh"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      port        = "http"
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
      port "http" { static = 8182 }
    }

    task "sshwifty" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-sshwifty:${var.version}"
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
        #   source   = "local/sshwifty.conf.json"
        #   target   = "/config/sshwifty.conf.json"
        #   type     = "bind"
        #   readonly = true
        # }
        # mount {
        #   source = "secrets/ssh"
        #   target = "/config/ssh"
        #   type = "bind"
        #   readonly = true
        # }
        mount {
          type = "bind"
          target = "/etc/localtime"
          source = "/etc/localtime"
          readonly = true
        }
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 500 # MHz
        memory = 256 # MB
      }

      # template {
      #   destination = "local/sshwifty.conf.json"
      #   data        = <<-EOP
      #     {{ key "nomad/${var.dc}/sshwifty/sshwifty.conf.json" }}
      #   EOP
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }
      # template {
      #   destination = "secrets/ssh/id_rsa"
      #   data        = <<-EOP
      #     {{ with secret "kv/data/nomad/${var.dc}/sshwifty" -}}
      #     {{   .Data.data.privkey }}
      #     {{- end }}
      #   EOP
      #   change_mode = "restart"
      #   perms       = "444"
      #   error_on_missing_key = true
      # }
      # template {
      #   destination = "secrets/ssh/id_rsa.pub"
      #   data        = <<-EOP
      #     {{ with secret "kv/data/nomad/${var.dc}/sshwifty" -}}
      #     {{   .Data.data.pubkey }}
      #     {{- end }}
      #   EOP
      #   change_mode = "restart"
      #   perms       = "444"
      #   error_on_missing_key = true
      # }
    }
  }
}
