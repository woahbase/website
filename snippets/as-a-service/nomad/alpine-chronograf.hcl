variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 1000  # gid for docker
  puid = 1000  # uid for docker
  version = "1.10.6"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "chronograf" {
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
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "urlprefix-/chronograf"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/chronograf"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
        type      = "http"
        path      = "/chronograf"
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
    volume "nomad-chronograf-data" {
      type      = "host"
      read_only = false
      source    = "nomad-chronograf-data"
    }
    # volume "nomad-chronograf-resources" {
    #   type      = "host"
    #   read_only = false
    #   source    = "nomad-chronograf-resources"
    # }

    task "chronograf" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-chronograf:${var.version}"
        network_mode = "host"
        ports        = ["http"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        mount {
          type     = "bind"
          target   = "/etc/localtime"
          source   = "/etc/localtime"
          readonly = true
        }
      }

      volume_mount {
        # ensure policies allow vault-generated-token to read-write to the volume
        volume      = "nomad-chronograf-data"
        destination = "/var/lib/chronograf"
        read_only   = false
      }
      # volume_mount {
      #   # ensure policies allow vault-generated-token to read-write to the volume
      #   volume      = "nomad-chronograf-resources"
      #   destination = "/usr/share/chronograf"
      #   read_only   = false
      # }

      env {
        BASE_PATH = "/chronograf"
        REPORTING_DISABLED = "true"

        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 1000 # MHz
        memory = 1024 # MB
      }
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
