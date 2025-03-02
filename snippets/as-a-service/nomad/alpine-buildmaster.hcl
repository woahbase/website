variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "3.11.9"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "buildmaster" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  priority    = 70
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
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "urlprefix-/buildbot"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/buildbot"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
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
    service {
      name        = "${NOMAD_JOB_NAME}-pb"
      port        = "pb"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "host=build", "proto=tcp"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_pb}"
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
      port "http"    { static = 8010 }
      port "pb"      { static = 9989 }
      port "cli"     { static = 9990 }
      port "metrics" { static = 9991 }
    }
    volume "nomad-buildmaster-project" {
      type      = "host"
      read_only = false
      source    = "nomad-buildmaster-project"
    }

    task "buildmaster" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-buildmaster:${var.version}"
        network_mode = "bridge"
        ports        = ["http", "pb", "cli", "metrics"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        # mount {
        #   source   = "local/buildbot.tac"
        #   target   = "/home/alpine/buildbot/buildbot-master/buildbot.tac"
        #   type     = "bind"
        #   readonly = false
        # }

        # mount {
        #   source   = "local/master.cfg"
        #   target   = "/custom/master.cfg"
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
        volume      = "nomad-buildmaster-project"
        destination = "/home/alpine/buildbot"
        read_only   = false
      }

      env {
        BUILDBOT_PROJECTNAME = "buildbot"
        # BUILDBOT_MASTERCFG = "/custom/master.cfg"
        # BUILDBOT_USE_CUSTOM_TACFILE = "1"
        # BUILDBOT_SKIP_SETUP = "1"

        # # configurations from remote source
        # BUILDBOT_CONFIG_URL = "https://github.com/buildbot/buildbot/releases/download/v3.11.9/buildbot-3.11.9.tar.gz"
        # BUILDBOT_CONFIG_CFGFILE = "buildbot/scripts/sample.cfg"
        # # or
        # BUILDBOT_CONFIG_URL = "https://github.com/buildbot/buildbot.git"
        # BUILDBOT_CONFIG_CFGFILE = "master/docker-example/master.cfg"
        # BUILDBOT_CONFIG_TACFILE = "master/contrib/docker/master/buildbot.tac"
        # # or
        # BUILDBOT_CONFIG_URL = "https://raw.githubusercontent.com/buildbot/buildbot/refs/heads/master/master/docker-example/master.cfg"

        BUILDBOT_SKIP_CHECKCONFIG = "true"
        BUILDBOT_UPGRADE_MASTER = "false"
        BUILDBOT_CLEANUP_DB = "false"

        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 1000 # MHz
        memory = 1024 # MB
      }

      # template {
      #   destination = "local/buildbot.tac"
      #   data        = <<-EOC
      #     {{ key "nomad/${var.dc}/buildbot/master/buildbot.tac" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "local/master.cfg"
      #   data        = <<-EOC
      #     {{ key "nomad/${var.dc}/buildbot/master/master.cfg" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }
    }

    task "await-service-mysql" {
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
        EOS
        ]
      }

      env {
        SVC_MYSQL = "mysql.service.${var.dc}.consul"
        WAIT_SEC  = 10
      }

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
    }
  }
}
