variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "2.6.12"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "wallabag" {
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
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "host=wallabag"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}=>${NOMAD_PORT_http}"
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
      port "http" {
        static = 64807
        to     = 80
      }
    }
    volume "nomad-wallabag-images" {
      type      = "host"
      read_only = false
      source    = "nomad-wallabag-images"
    }

    task "wallabag" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-wallabag:${var.version}"
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
        #   source   = "local/parameters.yml"
        #   target   = "/defaults/parameters.yml"
        #   type     = "bind"
        #   readonly = true
        # }
        # mount {
        #   source   = "local/nginx.site"
        #   target   = "/config/nginx/site-confs/default"
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
        volume      = "nomad-wallabag-images"
        destination = "/config/www/wallabag/web/assets/images"
        read_only   = false
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 512  # MHz
        memory = 1024 # MB
      }

      # template {
      #   destination = "local/parameters.yml"
      #   data        = <<-EOC
      #     {{ key "nomad/${var.dc}/wallabag/parameters.yml" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "local/nginx.site"
      #   data        = <<-EOC
      #     {{ key "nomad/${var.dc}/wallabag/nginx.site" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }
    }

    task "await-service-mysql-redis" {
      driver = "raw_exec"
      # user   = local.var.exec_user

      config {
        command = "bash"
        args    = [ "-c", <<-EOS
          echo -n Waiting for $SVC_MYSQL.; \
          until \
            drill $SVC_MYSQL 2>/dev/null | grep -q 'rcode: NOERROR'; \
            do echo -n ' .'; sleep $WAIT_SEC; done; \
          echo 'Available.'; \
          # echo -n Waiting for $SVC_REDIS.; \
          # until \
          #   drill $SVC_REDIS 2>/dev/null | grep -q 'rcode: NOERROR'; \
          #   do echo -n ' .'; sleep $WAIT_SEC; done; \
          # echo 'Available.'; \
        EOS
        ]
      }

      env {
        SVC_MYSQL = "mysql.service.${var.dc}.consul"
        # SVC_REDIS = "redis.service.${var.dc}.consul"  # optional
        WAIT_SEC  = 10
      }

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
    }
  }
}
