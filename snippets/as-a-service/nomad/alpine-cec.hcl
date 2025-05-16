variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 1000  # gid for docker
  puid = 1000  # uid for docker
  version = "6.0.2"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "hdmicec" {
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
      name        = "cec"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      port        = "cec"
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_cec}"
        type      = "tcp"
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
      port "cec" { static = 9526 }
    }

    task "hdmicec" {
      driver = "docker"

      config {
        devices = [{
          host_path      = "/dev/cec0"
          container_path = "/dev/cec0"
          # cgroup_permissions = "r"
        }, {
          host_path      = "/dev/vchiq"
          container_path = "/dev/vchiq"
        }]

        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-cec:${var.version}"
        network_mode = "bridge"
        ports        = ["cec"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        mount {
          type = "bind"
          target = "/etc/localtime"
          source = "/etc/localtime"
          readonly = true
        }
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # gid of group 'dialout' on host
        # GID_DIALOUT = 984
        # gid of group 'video' on host
        GID_VIDEO = 985
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 250 # MHz
        memory = 256 # MB
      }
    }

    # task "await-hdmi-connect" {
    #   driver = "raw_exec"
    #   # user   = local.var.exec_user
    #
    #   config {
    #     command = "bash"
    #     args    = [ "-c", <<-EOS
    #       echo -n 'Waiting for hdmi connection.'; \
    #       until \
    #         cat /sys/class/drm/card0/*HDMI*/status 2>/dev/null \
    #         | grep -q '^connected'; \
    #         do echo -n ' .'; sleep $WAIT_SEC; done; \
    #       echo 'Connected.'; \
    #     EOS
    #     ]
    #   }
    #
    #   env {
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
