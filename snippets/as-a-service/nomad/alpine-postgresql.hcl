variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "16.8"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "postgresql" {
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
      max_parallel      = 1
      min_healthy_time  = "10s"
      healthy_deadline  = "10m"
      progress_deadline = "15m"
      auto_revert       = false
    }

    service {
      name        = NOMAD_JOB_NAME
      port        = "postgresql"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "aid=${NOMAD_ALLOC_ID}", "host=postgresql"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_postgresql}"
        type      = "tcp"
        interval  = "60s"
        timeout   = "10s"
      }
      check {
        name      = "ping-client"
        command   = "/bin/bash"
        args      = ["-c", "pg_isready -d postgres"]
        task      = "postgresql"
        type      = "script"
        interval  = "60s"
        timeout   = "10s"
      }
      check_restart {
        limit     = 3
        grace     = "10m"
      }
    }

    ephemeral_disk { size = 128 } # MB
    network {
      # dns { servers = local.var.dns_servers }
      port "postgresql"  { static = 5432 }
      port "postgresqls" { static = 5433 }
    }
    volume "nomad-postgresql-data" {
      type      = "host"
      read_only = false
      source    = "nomad-postgresql-data"
    }

    task "postgresql" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-postgresql:${var.version}"
        network_mode = "host"
        ports        = ["postgresql"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        # mount {
        #   source   = "local/postgresql.conf"
        #   target   = "/defaults/postgresql.conf"
        #   type     = "bind"
        #   readonly = true
        # }
        # mount {
        #   source   = "local/pg_hba.conf"
        #   target   = "/defaults/pg_hba.conf"
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
        volume      = "nomad-postgresql-data"
        destination = "/var/lib/postgresql"
        read_only   = false
      }

      env {

        # # only needed for initialization
        # POSTGRES_DB = "test"
        # POSTGRES_INITDIR = "/var/lib/postgresql/initdb.d"

        # PGSQL_SKIP_INITIALIZE = "true"

        # PGSQL_CUSTOM_CONF = "/defaults/postgresql.conf"
        # PGSQL_CUSTOM_HBA = "/defaults/pg_hba.conf"
        # PGSQL_CUSTOM_IDENT = "/defaults/pg_ident.conf"

        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 2000 # MHz
        memory = 4096 # MB
      }

      # template {
      #   destination = "local/postgresql.conf"
      #   data        = <<-EOC
      #     {{ key "nomad/${var.dc}/postgresql/postgresql.conf" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }
      # template {
      #   destination = "local/pg_hba.conf"
      #   data        = <<-EOC
      #     {{ key "nomad/${var.dc}/postgresql/pg_hba.conf" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }
      # template {
      #   destination = "secrets/env"
      #   data        = <<-EOE
      #     {{ with secret "kv/data/nomad/${var.dc}/postgresql" }}
      #     POSTGRES_PASSWORD={{ .Data.data.password }}
      #     {{ end }}
      #   EOE
      #   change_mode = "restart"
      #   env         = true
      #   perms       = "444"
      #   error_on_missing_key = true
      # }
    }
  }
}
