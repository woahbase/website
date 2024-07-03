variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "2.7.1"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "registry" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  priority    = 90
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
      min_healthy_time = "1m"
      healthy_deadline = "5m"
      auto_revert      = false
    }

    service {
      name        = NOMAD_JOB_NAME
      port        = "http"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "host=registry"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
        type      = "tcp"
        # path      = "/v2"
        interval  = "60s"
        timeout   = "10s"
      }
      check_restart {
        limit     = 3
        grace     = "10s"
      }
    }
    service {
      name        = "${NOMAD_JOB_NAME}-ui"
      port        = "ui"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_ui}"
        type      = "tcp"
        # path      = "/"
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
      # port "health" { static = 4999 }
      port "http"   { static = 5000 }
      port "ui"     { static = 5001 }
    }
    volume "nomad-registry-data" {
      type      = "host"
      read_only = false
      source    = "nomad-registry-data"
    }

    task "registry" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-registry:${var.version}"
        network_mode = "host"
        ports        = ["http", "ui"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        # mount {
        #   source   = "local/config.yml"
        #   target   = "/data/config.yml"
        #   type     = "bind"
        #   readonly = true
        # }
        # mount {
        #   source   = "secrets/auth"
        #   target   = "/data/auth"
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
        volume      = "nomad-registry-data"
        destination = "/data"
        read_only   = false
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 1000 # MHz
        memory = 1024 # MB
      }

      # template {
      #   destination = "local/config.yml"
      #   data        = <<-EOC
      #     {{ key "nomad/dc1/docker_registry/config.yml" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "secrets/env"
      #   data        = <<-EOE
      #     REGISTRY_AUTH_HTPASSWD_PATH=/data/auth/.htpasswd
      #     REGISTRY_HTTP_HOST=https://registry.service.${var.dc}.consul
      #     REGISTRY_HTTP_TLS_CERTIFICATE=/data/auth/certificate.crt
      #     REGISTRY_HTTP_TLS_KEY=/data/auth/private.key
      #     REGISTRY_REDIS_ADDR=redis.service.${var.dc}.consul:6379
      #     REGISTRY_REDIS_DB=0
      #
      #     {{ with secret "kv/data/nomad/dc1/docker_registry" }}
      #     REGISTRY_HTTP_SECRET={{ .Data.data.http_secret }}
      #     REGISTRY_REDIS_PASSWORD={{ .Data.data.redis_password }}
      #
      #     REG_USER={{ .Data.data.username }}
      #     REG_PASS={{ .Data.data.password }}
      #     {{ end }}
      #   EOE
      #  change_mode = "restart"
      #   env         = true
      #   perms       = "444"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "secrets/auth/certificate.crt"
      #   data        = <<-EOP
      #     {{ with secret "kv/data/nomad/dc1/certificates/selfsigned" -}}
      #     {{   index .Data.data "certificate.crt"}}
      #     {{- end }}
      #   EOP
      #   change_mode = "restart"
      #   perms       = "444"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "secrets/auth/private.key"
      #   data        = <<-EOP
      #     {{ with secret "kv/data/nomad/dc1/certificates/selfsigned" -}}
      #     {{   index .Data.data "private.key"}}
      #     {{- end }}
      #   EOP
      #   change_mode = "restart"
      #   perms       = "444"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "secrets/auth/.htpasswd"
      #   data        = <<-EOP
      #     {{ with secret "kv/data/nomad/dc1/docker_registry" -}}
      #     {{   .Data.data.htpassword }}
      #     {{- end }}
      #   EOP
      #   # different htpasswd file
      #   # apache/nginx doesnt do bcrypt,
      #   # and registry only does bcrypt
      #   change_mode = "restart"
      #   perms       = "444"
      #   error_on_missing_key = true
      # }
    }

    task "await-service-redis" {
      driver = "raw_exec"
      # user   = local.var.exec_user

      config {
        command = "bash"
        args    = [ "-c", <<-EOS
          echo -n Waiting for $SVC_REDIS.; \
          until \
            drill $SVC_REDIS 2>/dev/null | grep -q 'rcode: NOERROR'; \
            do echo -n ' .'; sleep $WAIT_SEC; done; \
          echo 'Available.'; \
        EOS
        ]
      }

      env {
        SVC_REDIS = "redis.service.${var.dc}.consul"
        WAIT_SEC  = 10
      }

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
    }
  }
}
