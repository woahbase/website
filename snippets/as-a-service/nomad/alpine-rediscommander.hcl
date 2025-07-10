variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 1000  # gid for docker
  puid = 1000  # uid for docker
  version = "0.9.0"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "rediscommander" {
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
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "urlprefix-/rediscommander"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/rediscommander"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
        type      = "http"
        path      = "/rediscommander"
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
      port "http" { static = 8081 }
    }

    task "rediscommander" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-rediscommander:${var.version}"
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
        #   source   = "local/config.json"
        #   target   = "/redis-commander/config/config.json"
        #   type     = "bind"
        # }

        # mount {
        #   source   = "secrets/local.json"
        #   target   = "/redis-commander/config/local.json"
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

      env {
        PGID = var.pgid
        PUID = var.puid
        # REDISCMDR_LOCAL_JSON =  "{}"
        # REDISCMDR_ARGS = ""
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 512 # MHz
        memory = 256 # MB
      }

      # template {
      #   destination = "local/config.json"
      #   data        = <<-EOC
      #     {{ key "nomad/${var.dc}/redis/cmdr.config.json" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "secrets/local.json"
      #   data        = <<-EOP
      #     {{ with secret "kv/data/nomad/${var.dc}/redis" -}}
      #     {{ index .Data.data "cmdr.connections.json" }}
      #     {{- end }}
      #   EOP
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

    # task "firewalld-open-port" {
    #   /* constraint { */
    #   /*   attribute = meta.firewalld_zone */
    #   /*   operator  = "is_set" */
    #   /* } */
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
    #
    # task "firewalld-close-port" {
    #   /* constraint { */
    #   /*   attribute = meta.firewalld_zone */
    #   /*   operator  = "is_set" */
    #   /* } */
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
