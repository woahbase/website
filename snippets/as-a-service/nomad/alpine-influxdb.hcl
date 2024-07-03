variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "1.8.10"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "influxdb" {
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
      port        = "http"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "aid=${NOMAD_ALLOC_ID}", "host=influxdb"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
        type      = "http"
        path      = "/health"
        interval  = "60s"
        timeout   = "10s"
      }
      check {
        name      = "ping-client"
        command   = "/bin/bash"
        args      = ["-c", "influx -username $INFLUXDB_HEALTHCHECK_USER -password $INFLUXDB_HEALTHCHECK_USER_PWD -execute 'SHOW DATABASES'"]
        task      = "influxdb"
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
      # port "admin"    { static = 8083  } # deprecated
      port "http"     { static = 8086  }
      port "rpc"      { static = 8088  }
      # port "udp"      { static = 8089  }
      # port "collectd" { static = 25826 }
      port "graphite" { static = 2003  }
      # port "otsdb"    { static = 4242  }
    }
    volume "nomad-influxdb-data" {
      type      = "host"
      read_only = false
      source    = "nomad-influxdb-data"
    }

    task "influxdb" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-influxdb:${var.version}"
        network_mode = "host"
        ports        = ["http", "rpc", "graphite"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        # mount {
        #   source   = "local/influxdb.conf"
        #   target   = "/etc/influxdb.conf"
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
        # works to pin the task to client with the volume available
        # ensure polices allow token to write to the volume
        volume      = "nomad-influxdb-data"
        destination = "/var/lib/influxdb"
        read_only   = false
      }

      env {
        PUID = var.puid
        PGID = var.pgid
        # TZ   = local.var.tz

        INFLUXDB_REPORTING_DISABLED = "true"
        INFLUXDB_GRAPHITE_ENABLED   = "false"
      }

      resources {
        cpu    = 2000 # MHz
        memory = 5120 # MB
      }

      # template {
      #   destination = "local/influxdb.conf"
      #   data        = <<-EOC
      #     {{ key "nomad/dc1/influxdb/influxdb.conf" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }

      template {
        destination = "secrets/env"
        data        = <<-EOE
          {{ with secret "kv/data/nomad/dc1/influxdb" }}
          INFLUXDB_HEALTHCHECK_USER={{ .Data.data.username }}
          INFLUXDB_HEALTHCHECK_USER_PWD={{ .Data.data.password }}
          {{ end }}
        EOE
        change_mode = "restart"
        env         = true
        perms       = "444"
        error_on_missing_key = true
      }
    }
  }
}
