variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 1000  # gid for docker
  puid = 1000  # uid for docker
  version = "1.7.6"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "kapacitor" {
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
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "urlprefix-/kapacitor"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/kapacitor"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
        type      = "http"
        path      = "/kapacitor/v1/ping"
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
      port "http" { static = 9092 }
    }
    volume "nomad-kapacitor-conf" {
      type      = "host"
      read_only = false
      source    = "nomad-kapacitor-conf"
    }
    volume "nomad-kapacitor-data" {
      type      = "host"
      read_only = false
      source    = "nomad-kapacitor-data"
    }

    task "kapacitor" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-kapacitor:${var.version}"
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
        #   source   = "local/kapacitor.conf"
        #   target   = "/etc/kapacitor/kapacitor.conf"
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

      # volume_mount {
      #   # ensure policies allow vault-generated-token to read-write to the volume
      #   volume      = "nomad-kapacitor-conf"
      #   destination = "/etc/kapacitor"
      #   read_only   = false
      # }
      volume_mount {
        # ensure policies allow vault-generated-token to read-write to the volume
        volume      = "nomad-kapacitor-data"
        destination = "/var/lib/kapacitor"
        read_only   = false
      }

      env {
        # set to run as root, defaults to non-root user alpine
        # KAPACITOR_AS_ROOT = 1

        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 1000 # MHz
        memory = 1024 # MB
      }

      # template {
      #   destination = "local/kapacitor.conf"
      #   data        = <<-EOC
      #     {{ key "nomad/${var.dc}/kapacitor/kapacitor.conf" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
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
