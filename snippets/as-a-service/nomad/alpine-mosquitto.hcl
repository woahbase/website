variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "2.0.14"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "mosquitto" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  priority    = 80
  # region      = local.var.region
  type        = "service"

  constraint { distinct_hosts = true }

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
      port        = "mqtt"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "host=mosquitto"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_mqtt}"
        type      = "tcp"
        interval  = "60s"
        timeout   = "10s"
      }
      check {
        name      = "${NOMAD_JOB_NAME}-ping-client"
        command   = "/bin/bash"
        args      = ["-c", "mosquitto_sub -t '$SYS/#' -u $USERNAME -P $PASSWORD -C 1"]
        task      = "mosquitto"
        type      = "script"
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
      port "mqtt"  { static = 1883 }
      # port "mqtts" { static = 8883 }
    }
    volume "nomad-mosquitto-data" {
      type      = "host"
      read_only = false
      source    = "nomad-mosquitto-data"
    }

    task "mosquitto" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-mosquitto:${var.version}"
        network_mode = "host"
        ports        = ["mqtt"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        # mount {
        #   type     = "bind"
        #   source   = "local/mosquitto.conf"
        #   target   = "/mosquitto/config/mosquitto.conf"
        #   readonly = true
        # }

        # mount {
        #   type     = "bind"
        #   source   = "secrets/htpasswd"
        #   target   = "/mosquitto/config/.passwd"
        #   readonly = true
        # }

        mount {
          type     = "bind"
          source   = "/etc/localtime"
          target   = "/etc/localtime"
          readonly = true
        }
      }

      volume_mount {
        # ensure policies allow vault-generated-token to read-write to the volume
        volume      = "nomad-mosquitto-data"
        destination = "/mosquitto"
        read_only   = false
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 256 # MHz
        memory = 256 # MB
      }

      # template {
      #   destination = "local/mosquitto.conf"
      #   data = <<-EOC
      #     {{ key "nomad/dc1/mosquitto/mosquitto.conf" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "secrets/env"
      #   data        = <<-EOE
      #     {{ with secret "kv/data/nomad/dc1/mosquitto" }}
      #     USERNAME={{ .Data.data.username }}
      #     PASSWORD={{ .Data.data.password }}
      #     {{ end }}
      #   EOE
      #   change_mode = "restart"
      #   env         = true
      #   perms       = "444"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "secrets/htpasswd"
      #   data        = <<-EOP
      #     {{ with secret "kv/data/nomad/dc1/mosquitto" }}
      #     {{ .Data.data.htpasswd }}
      #     {{ end }}
      #   EOP
      #   change_mode = "restart"
      #   perms       = "444"
      #   error_on_missing_key = true
      # }
    }
  }
}
