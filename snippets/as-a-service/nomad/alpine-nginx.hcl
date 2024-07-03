variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "1.20.2"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "nginx" {
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
      port "http"  { static = 80  }
      port "https" { static = 443 }
    }
    volume "nomad-nginx-data" {
      type      = "host"
      read_only = false
      source    = "nomad-nginx-data"
    }

    task "nginx" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-nginx:${var.version}"
        network_mode = "host"
        ports        = ["http", "https"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        # mount {
        #   type     = "bind"
        #   source   = "secrets/keys"
        #   target   = "/config/keys"
        #   readonly = true
        # }

        # mount {
        #   type     = "bind"
        #   source   = "local/nginx"
        #   target   = "/config/nginx"
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
        volume      = "nomad-nginx-data"
        destination = "/config"
        read_only   = false
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 256 # MHz
        memory = 256 # MB
      }

      # template {
      #   destination = "secrets/env"
      #   data        = <<-EOE
      #     CERTFILE=/config/keys/certificate.crt
      #     PKEYFILE=/config/keys/private.key
      #     HTPASSWDFILE=/config/keys/.htpasswd
      #
      #     {{ with secret "kv/data/nomad/dc1/nginx" }}
      #     USERNAME={{ .Data.data.username }}
      #     PASSWORD={{ .Data.data.password }}
      #     {{ end }}
      #   EOE
      #   change_mode = "restart"
      #   env         = true
      #   perms       = "444"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination   = "secrets/keys/certificate.crt"
      #   data          = <<-EOP
      #     {{ with secret "kv/data/nomad/dc1/certificates/selfsigned" -}}
      #     {{   index .Data.data "certificate.crt"}}
      #     {{- end }}
      #   EOP
      #   change_mode   = "script"
      #   change_script { command = "/config/nginx/validate-n-reload.sh" }
      #   perms         = "444"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination   = "secrets/keys/private.key"
      #   data          = <<-EOP
      #     {{ with secret "kv/data/nomad/dc1/certificates/selfsigned" -}}
      #     {{   index .Data.data "private.key"}}
      #     {{- end }}
      #   EOP
      #   change_mode   = "script"
      #   change_script { command = "/config/nginx/validate-n-reload.sh" }
      #   perms         = "444"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination   = "secrets/keys/.htpasswd"
      #   data          = <<-EOP
      #     {{ with secret "kv/data/nomad/dc1/nginx" -}}
      #     {{   index .Data.data "htpasswd"}}
      #     {{- end }}
      #   EOP
      #   change_mode   = "script"
      #   change_script { command = "/config/nginx/validate-n-reload.sh" }
      #   perms         = "444"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination   = "local/nginx/nginx.conf"
      #   data          = <<-EOC
      #     {{ key "nomad/dc1/nginx/nginx.conf" }}
      #   EOC
      #   change_mode   = "script"
      #   change_script { command = "/config/nginx/validate-n-reload.sh" }
      #   perms         = "644"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination   = "local/nginx/http.d/http"
      #   data          = <<-EOC
      #     {{ key "nomad/dc1/nginx/http" }}
      #   EOC
      #   change_mode   = "script"
      #   change_script { command = "/config/nginx/validate-n-reload.sh" }
      #   perms         = "644"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination   = "local/nginx/http.d/https"
      #   data          = <<-EOC
      #     {{ key "nomad/dc1/nginx/https" }}
      #   EOC
      #   change_mode   = "script"
      #   change_script { command = "/config/nginx/validate-n-reload.sh" }
      #   perms         = "644"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination   = "local/nginx/http.d/upstream"
      #   data          = <<-EOT
      #     {{- /* key "nomad/dc1/nginx/http-upstream" */ -}}
      #     {{- /* defaults params for upstreams */ -}}
      #     {{- $DP := "fail_timeout=10s max_fails=3 weight=1;" -}}
      #
      #     {{- /* multiple instances set ip_hash, optionally 'least_conn;' */ -}}
      #     {{- $MU := "ip_hash;" -}}
      #
      #     {{- /* when service lost redirect to blackhole, dont fail nginx */ -}}
      #     {{- $NC := "server 127.0.0.1:65535 down;" -}}
      #
      #     # hashicorp service proxies
      #     upstream sv_consul { {{range service "consul|passing"}}server {{.Address}}:8500      {{$DP}} {{else}} {{$NC}} {{end}} {{$MU}} }
      #     upstream sv_nomad  { {{range service "http.nomad"    }}server {{.Address}}:{{.Port}} {{$DP}} {{else}} {{$NC}} {{end}} {{$MU}} }
      #     upstream sv_vault  { {{range service "active.vault"  }}server {{.Address}}:{{.Port}} {{$DP}} {{else}} {{$NC}} {{end}} {{$MU}} }
      #
      #     # add your own services here
      #   EOT
      #   change_mode   = "script"
      #   change_script { command = "/config/nginx/validate-n-reload.sh" }
      #   perms         = "644"
      # }

      # template {
      #   destination = "local/nginx/validate-n-reload.sh"
      #   data        = <<-EOS
      #     #!/bin/bash
      #     ###
      #     ## reload nginx only if config valid
      #     ###
      #     nginx -c /config/nginx/nginx.conf -t \
      #     && \
      #     nginx -c /config/nginx/nginx.conf -s reload \
      #   EOS
      #   change_mode = "noop"
      #   perms       = "755"
      # }
    }
  }
}
