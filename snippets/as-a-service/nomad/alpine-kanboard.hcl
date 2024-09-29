variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "1.2.40"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "kanboard" {
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
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "urlprefix-/kanboard"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/kanboard"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}=>${NOMAD_PORT_http}"
        type      = "tcp"
        # path      = "/kanboard"
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
        static = 64806
        to     = 80
      }
      # port "https" {
      #   static = 63806
      #   to     = 443
      # }
    }
    volume "nomad-kanboard-data" {
      type      = "host"
      read_only = false
      source    = "nomad-kanboard-data"
    }
    volume "nomad-kanboard-plugins" {
      type      = "host"
      read_only = false
      source    = "nomad-kanboard-plugins"
    }

    task "kanboard" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-kanboard:${var.version}"
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
        #   target   = "/config/www/kanboard/config.php"
        #   type     = "bind"
        #   readonly = true
        # }

        # mount {
        #   source   = "local/nginx.conf"
        #   target   = "/config/nginx/http.d/http"
        #   type     = "bind"
        #   readonly = true
        # }

        # mount {
        #   source   = "secrets/keys"
        #   target   = "/config/keys"
        #   type     = "bind"
        #   readonly = false
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
        volume      = "nomad-kanboard-data"
        destination = "/config/www/kanboard/data"
        read_only   = false
      }
      volume_mount {
        volume      = "nomad-kanboard-plugins"
        destination = "/config/www/kanboard/plugins"
        read_only   = false
      }

      env {
        # KANBOARD_URL = "http://kanboard.service.consul/kanboard/"
        # KANBOARD_UPDATE = "false"

        # NGINX_NO_HTTPS = "true"
        # NGINX_NO_CERTGEN = "true"
        # NGINX_NO_HTPASSWD = "true"

        PGID = var.pgid
        PUID = var.puid

        # TZ   = local.var.tz
      }

      resources {
        cpu    = 512 # MHz
        memory = 512 # MB
      }

      # template {
      #   destination   = "secrets/keys/certificate.crt"
      #   data          = <<-EOP
      #     {{ with secret "kv/data/nomad/${var.dc}/certificates/selfsigned" -}}
      #     {{   index .Data.data "certificate.crt"}}
      #     {{- end }}
      #   EOP
      #   change_mode   = "restart"
      #   perms         = "444"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination   = "secrets/keys/private.key"
      #   data          = <<-EOP
      #     {{ with secret "kv/data/nomad/${var.dc}/certificates/selfsigned" -}}
      #     {{   index .Data.data "private.key"}}
      #     {{- end }}
      #   EOP
      #   change_mode   = "restart"
      #   perms         = "444"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "local/config.php"
      #   data        = <<-EOC
      #     {{ key "nomad/${var.dc}/kanboard/config.php" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "755"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "local/nginx.conf"
      #   data        = <<-EOC
      #     {{ key "nomad/${var.dc}/kanboard/nginx" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }
    }

    # task "await-service-mysql" {
    #   driver = "raw_exec"
    #   # user   = local.var.exec_user
    #
    #   config {
    #     command = "bash"
    #     args    = [ "-c", <<-EOS
    #       echo -n Waiting for $SVC_MYSQL.; \
    #       until \
    #         drill $SVC_MYSQL 2>/dev/null | grep -q 'rcode: NOERROR'; \
    #         do echo -n ' .'; sleep $WAIT_SEC; done; \
    #       echo 'Available.'; \
    #     EOS
    #     ]
    #   }
    #
    #   env {
    #     SVC_MYSQL = "mysql.service.${var.dc}.consul"
    #     WAIT_SEC  = 10
    #   }
    #
    #   lifecycle {
    #     hook    = "prestart"
    #     sidecar = false
    #   }
    # }
  }
}
