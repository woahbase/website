variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "3.0.10"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "haproxy" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  priority    = 70
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

    # service {
    #   name        = "${NOMAD_JOB_NAME}-dpapi"
    #   port        = "dpapi"
    #   tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname]
    #   canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
    #   check {
    #     name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_dpapi}"
    #     type      = "http"
    #     path      = "/v3/info"
    #     interval  = "60s"
    #     timeout   = "10s"
    #   }
    #   check_restart {
    #     limit     = 3
    #     grace     = "10s"
    #   }
    # }
    service {
      name        = "${NOMAD_JOB_NAME}-http"
      port        = "http"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
        type      = "tcp"
        # path      = "/status"
        interval  = "60s"
        timeout   = "10s"
      }
      check_restart {
        limit     = 3
        grace     = "10s"
      }
    }
    service {
      name        = "${NOMAD_JOB_NAME}-https"
      port        = "https"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_https}"
        type      = "tcp"
        # path      = "/status"
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
      port "http"   { static = 80  }
      port "https"  { static = 443 }
      port "dpapi"  { static = 8080 }
      port "promex" { static = 8405 }
      port "stats"  { static = 5556 }
    }
    volume "nomad-haproxy-data" {
      type      = "host"
      read_only = false
      source    = "nomad-haproxy-data"
    }

    task "haproxy" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-haproxy:${var.version}"
        network_mode = "host"
        ports        = ["http", "https", "dpapi", "promex", "stats"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        # mount {
        #   type     = "bind"
        #   source   = "local/haproxy"
        #   target   = "/etc/haproxy"
        #   readonly = true
        # }

        # mount {
        #   type     = "bind"
        #   source   = "secrets/keys"
        #   target   = "/etc/haproxy/ssl"
        #   readonly = true
        # }

        mount {
          type     = "bind"
          source   = "/etc/localtime"
          target   = "/etc/localtime"
          readonly = true
        }
      }

      volume_mount {
        # ensure policies allow vault-generated-token to read-write to the volume
        volume      = "nomad-haproxy-data"
        destination = "/var/lib/haproxy"
        read_only   = false
      }

      env {
        # DPA_ARGS        = "-i -u haproxy-dataplaneapi"
        # DPA_CONF        = "/etc/haproxy/dataplaneapi.yaml"
        # HAPROXY_CONF    = "/etc/haproxy/haproxy.cfg"
        # HAPROXY_CRTFILE = "/etc/haproxy/ssl/certificate.pem"
        # HAPROXY_PROMEX  = "true"
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 256 # MHz
        memory = 256 # MB
      }

      # template {
      #   destination   = "local/haproxy/dataplaneapi.yaml"
      #   data          = <<-EOC
      #     {{ key "nomad/${var.dc}/haproxy/dataplaneapi.yaml" }}
      #   EOC
      #   change_mode   = "restart"
      #   perms         = "644"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination   = "local/haproxy/haproxy.cfg"
      #   data          = <<-EOC
      #     {{ key "nomad/${var.dc}/haproxy/haproxy.cfg" }}
      #   EOC
      #   change_mode   = "restart"
      #   perms         = "644"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "secrets/env"
      #   data        = <<-EOE
      #     {{ with secret "kv/data/nomad/${var.dc}/haproxy" }}
      #     DPA_USERNAME={{ .Data.data.username }}
      #     DPA_PASSWORD={{ .Data.data.password }}
      #     {{ end }}
      #   EOE
      #   change_mode = "restart"
      #   env         = true
      #   perms       = "444"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination   = "secrets/ssl/certificate.pem"
      #   data          = <<-EOP
      #     {{ with secret "kv/data/nomad/${var.dc}/certificates/selfsigned" -}}
      #     {{   index .Data.data "certificate.pem"}}
      #     {{- end }}
      #   EOP
      #   change_mode   = "restart"
      #   perms         = "444"
      #   error_on_missing_key = true
      # }
    }
  }
}
