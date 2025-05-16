variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 1000  # gid for docker
  puid = 1000  # uid for docker
  version = "7.2.5"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "redis" {
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
      port        = "redis"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "host=redis"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_redis}"
        type      = "tcp"
        interval  = "60s"
        timeout   = "10s"
      }
      check {
        name      = "cli-ping"
        command   = "redis-cli"
        args      = ["ping"]
        task      = "redis"
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
      port "redis" { static = 6379 }
      # port "redis-bus" { static = 6380 }
    }
    volume "nomad-redis-data" {
      type      = "host"
      read_only = false
      source    = "nomad-redis-data"
    }

    task "redis" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-redis:${var.version}"
        network_mode = "host"
        ports        = ["redis"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        # mount {
        #   source   = "local/redis.conf"
        #   target   = "/etc/redis.conf"
        #   type     = "bind"
        #   readonly = true
        # }
        # mount {
        #   source   = "secrets/users.acl"
        #   target   = "/etc/redis/users.acl"
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

      volume_mount {
        # ensure policies allow vault-generated-token to read-write to the volume
        volume      = "nomad-redis-data"
        destination = "/var/lib/redis"
        read_only   = false
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 1000 # MHz
        memory = 512 # MB
      }

      # template {
      #   destination = "local/redis.conf"
      #   data        = <<-EOC
      #     {{ key "nomad/${var.dc}/redis/redis.conf" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "secrets/users.acl"
      #   data        = <<-EOP
      #     {{ with secret "kv/data/nomad/${var.dc}/redis" -}}
      #     {{   index .Data.data "users.acl" }}
      #     {{- end }}
      #   EOP
      #   change_mode = "restart"
      #   perms       = "444"
      #   error_on_missing_key = true
      # }
    }
  }
}
