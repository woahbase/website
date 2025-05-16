variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 1000  # gid for docker
  puid = 1000  # uid for docker
  version = "master"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "ttrss" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  # priority    = 50
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
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "urlprefix-/ttrss"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/ttrss"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}=>${NOMAD_PORT_http}"
        type      = "http"
        path      = "/ttrss/public.php?op=healthcheck"
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
      port "http" {
        static = 64802
        to     = 80
      }
    }
    volume "nomad-ttrss-config" {
      type      = "host"
      read_only = false
      source    = "nomad-ttrss-config"
    }

    task "ttrss" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-ttrss:${var.version}"
        network_mode = "bridge"
        ports        = ["http"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        # mount {
        #   source   = "local/config.php"
        #   target   = "/config/www/ttrss/config.php"
        #   type     = "bind"
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
        volume      = "nomad-ttrss-config"
        destination = "/config"
        read_only   = false
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz

        # for updating
        # TTRSSUPDATE = "1"

        TTRSS_DB_TYPE = "pgsql"
        TTRSS_DB_HOST = "pgsql.service.${var.dc}.consul"
        TTRSS_DB_PORT = "5432"

        # NO_STARTUP_SCHEMA_UPDATES = "1"

        # NO_STARTUP_PLUGIN_UPDATES = "1"
        # git required for local plugin updates
        # S6_NEEDED_PACKAGES        = "git"
      }

      resources {
        cpu    = 512 # MHz
        memory = 512 # MB
      }

      # template {
      #   destination = "local/config.php"
      #   data        = <<-EOC
      #     {{ key "nomad/${var.dc}/ttrss/config.php" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }

      template {
        destination = "secrets/env"
        data        = <<-EOE
          {{ with secret "kv/data/nomad/${var.dc}/pgsql" }}
          TTRSS_DB_USER={{ .Data.data.username }}
          TTRSS_DB_PASS={{ .Data.data.pasword }}
          TTRSS_DB_NAME=ttrss
          {{ end }}
          {{ with secret "kv/data/nomad/${var.dc}/ttrss" }}
          # ADMIN_USER_PASS={{ .Data.data.adminpass }}
          # ADMIN_USER_ACCESS_LEVEL=-2
          # AUTO_CREATE_USER={{ .Data.data.username }}
          # AUTO_CREATE_USER_PASS={{ .Data.data.password }}
          # AUTO_CREATE_USER_ENABLE_API=true
          # AUTO_CREATE_USER_ACCESS_LEVEL=0
          {{ end }}
        EOE
        change_mode = "restart"
        env         = true
        perms       = "444"
        error_on_missing_key = true
      }
    }

    task "await-service-db" {
      driver = "raw_exec"
      # user   = local.var.exec_user

      config {
        command = "bash"
        args    = [ "-c", <<-EOS
          echo -n Waiting for $SVC_DB.; \
          until \
            drill $SVC_DB 2>/dev/null | grep -q 'rcode: NOERROR'; \
            do echo -n ' .'; sleep $WAIT_SEC; done; \
          echo 'Available.'; \
        EOS
        ]
      }

      env {
        # SVC_DB = "mysql.service.${var.dc}.consul"
        SVC_DB = "pgsql.service.${var.dc}.consul"
        WAIT_SEC  = 10
      }

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
    }
  }
}
