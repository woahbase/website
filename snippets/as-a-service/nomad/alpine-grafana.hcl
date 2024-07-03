variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "9.1.2"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "grafana" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  # priority    = 30
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
      port        = "http"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "urlprefix-/grafana"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/grafana"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
        type      = "http"
        path      = "/grafana"
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
      port "http" { static = 3000 }
    }
    volume "nomad-grafana-dashboards" {
      type      = "host"
      read_only = false
      source    = "nomad-grafana-dashboards"
    }
    volume "nomad-grafana-data" {
      type      = "host"
      read_only = false
      source    = "nomad-grafana-data"
    }

    task "grafana" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-grafana:${var.version}"
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
        #   source   = "local/defaults.ini"
        #   target   = "/var/lib/grafana/conf/defaults.ini"
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
        volume      = "nomad-grafana-dashboards"
        destination = "/var/lib/grafana/dashboards"
        read_only   = false
      }
      volume_mount {
        volume      = "nomad-grafana-data"
        destination = "/var/lib/grafana/data"
        read_only   = false
      }

      env {
        GF_LOG_MODE="console" # log to console only
        # for logging to file
        # GF_PATHS_LOGS=/var/log/grafana/
        # GF_LOG_MODE="console file"

        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 1000 # MHz
        memory = 1024 # MB
      }

      # template {
      #   destination = "local/defaults.ini"
      #   data        = <<-EOC
      #     {{ key "nomad/dc1/grafana/defaults.ini" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }

      # user/pass only needed to initialize sqlite database,
      # enable on firstrun
      # template {
      #   destination = "secrets/env"
      #   data        = <<-EOE
      #     {{ with secret "kv/data/nomad/dc1/grafana" }}
      #     GF_SECURITY_ADMIN_USER={{ .Data.data.username }}
      #     GF_SECURITY_ADMIN_PASSWORD={{ .Data.data.password }}
      #     GF_SECURITY_SECRET_KEY={{ .Data.data.secret_key }}
      #     {{ end }}
      #   EOE
      #   change_mode = "restart"
      #   env         = true
      #   perms       = "444"
      #   error_on_missing_key = true
      # }
    }

    task "await-service-influxdb" {
      driver = "raw_exec"
      # user   = local.var.exec_user

      config {
        command = "bash"
        args    = [ "-c", <<-EOS
          echo -n Waiting for $SVC_INFLUXDB.; \
          until \
            drill $SVC_INFLUXDB 2>/dev/null | grep -q 'rcode: NOERROR'; \
            do echo -n ' .'; sleep $WAIT_SEC; done; \
          echo 'Available.'; \
        EOS
        ]
      }

      env {
        SVC_INFLUXDB = "influxdb.service.${var.dc}.consul"
        WAIT_SEC     = 10
      }

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
    }
  }
}
