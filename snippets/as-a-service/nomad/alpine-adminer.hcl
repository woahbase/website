variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "4.8.1"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "adminer" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  priority    = 30
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
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "urlprefix-/adminer"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/adminer"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}=>${NOMAD_PORT_http}"
        type      = "http"
        path      = "/adminer/"
        interval  = "60s"
        timeout   = "10s"
        # tls_skip_verify = true
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
        static = 64080
        to     = 80
      }
      # port "https" {
      #   static = 64443
      #   to     = 443
      # }
    }

    task "adminer" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-adminer:${var.version}"
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
        #   source   = "secrets/keys"
        #   target   = "/config/keys"
        #   type     = "bind"
        #   readonly = false
        # }
        mount {
          type     = "bind"
          source   = "/etc/localtime"
          target   = "/etc/localtime"
          readonly = true
        }
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz

        # CSSURL = "https://raw.githubusercontent.com/vrana/adminer/master/designs/nette/adminer.css"
        # NGINX_NO_HTTPS = "true"
        # NGINX_NO_CERTGEN = "true"
        # NGINX_NO_HTPASSWD = "true"
      }

      resources {
        cpu    = 512 # MHz
        memory = 256 # MB
      }
      # template {
      #   destination   = "secrets/keys/certificate.crt"
      #   data          = <<-EOP
      #     {{ with secret "kv/data/nomad/dc1/certificates/selfsigned" -}}
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
      #     {{ with secret "kv/data/nomad/dc1/certificates/selfsigned" -}}
      #     {{   index .Data.data "private.key"}}
      #     {{- end }}
      #   EOP
      #   change_mode   = "restart"
      #   perms         = "444"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination   = "secrets/keys/.htpasswd"
      #   data          = <<-EOP
      #     {{ with secret "kv/data/nomad/dc1/certificates/selfsigned" -}}
      #     {{   index .Data.data "htpasswd"}}
      #     {{- end }}
      #   EOP
      #   change_mode   = "restart"
      #   perms         = "444"
      #   error_on_missing_key = true
      # }
    }

    # task "firewalld-open-port" {
    #   # constraint {
    #   #   attribute = meta.firewalld_zone
    #   #   operator  = "is_set"
    #   # }
    #   driver = "raw_exec"
    #
    #   config {
    #     command = "bash"
    #     args    = [ "-ec", <<-EOS
    #       set -ex;
    #       if [ "X$(systemctl is-active firewalld)" = "Xactive" ] && [ "X$ZONE" != "X" ];
    #       then
    #         firewall-cmd --zone=$ZONE --add-port=$PORT/$PROTO \
    #         && firewall-cmd --reload;
    #       else
    #         echo "No firewalld. Doing nothing.";
    #       fi;
    #     EOS
    #     ]
    #   }
    #
    #   lifecycle {
    #     hook    = "poststart"
    #     sidecar = false
    #   }
    #
    #   template {
    #     destination = "local/env"
    #     data        = <<-EOE
    #       PORT={{ env "NOMAD_HOST_PORT_http" }}
    #       PROTO=tcp
    #       ZONE={{ or (env "meta.firewalld_zone") "" }}
    #     EOE
    #     change_mode = "restart"
    #     env         = true
    #     perms       = "444"
    #     error_on_missing_key = false
    #   }
    # }

    # task "firewalld-close-port" {
    #   # constraint {
    #   #   attribute = meta.firewalld_zone
    #   #   operator  = "is_set"
    #   # }
    #   driver = "raw_exec"
    #
    #   config {
    #     command = "bash"
    #     args    = [ "-ec", <<-EOS
    #       set -ex;
    #       if [ "X$(systemctl is-active firewalld)" = "Xactive" ] && [ "X$ZONE" != "X" ];
    #       then
    #         firewall-cmd --zone=$ZONE --remove-port=$PORT/$PROTO \
    #         && firewall-cmd --reload;
    #       else
    #         echo "No firewalld. Doing nothing.";
    #       fi;
    #     EOS
    #     ]
    #   }
    #
    #   lifecycle {
    #     hook    = "poststop"
    #     sidecar = false
    #   }
    #
    #   template {
    #     destination = "local/env"
    #     data        = <<-EOE
    #       PORT={{ env "NOMAD_HOST_PORT_http" }}
    #       PROTO=tcp
    #       ZONE={{ or (env "meta.firewalld_zone") "" }}
    #     EOE
    #     change_mode = "restart"
    #     env         = true
    #     perms       = "444"
    #     error_on_missing_key = false
    #   }
    # }
  }
}
