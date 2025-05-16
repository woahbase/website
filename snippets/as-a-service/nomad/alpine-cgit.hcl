variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 1000  # gid for docker
  puid = 1000  # uid for docker
  version = "1.2.3"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "cgit" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  priority    = 80
  # region      = local.var.region
  type        = "service"

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
      max_parallel      = 1
      min_healthy_time  = "10s"
      healthy_deadline  = "10m"
      progress_deadline = "15m"
      auto_revert       = false
    }

    service {
      name        = NOMAD_JOB_NAME
      port        = "http"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "aid=${NOMAD_ALLOC_ID}", "urlprefix-/git"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/git"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}=>${NOMAD_PORT_http}"
        type      = "http"
        path      = "/git/?p=about"
        interval  = "60s"
        timeout   = "10s"
      }
      check_restart {
        limit     = 3
        grace     = "10m"
      }
    }

    service {
      name        = "${NOMAD_JOB_NAME}-ssh"
      port        = "ssh"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "aid=${NOMAD_ALLOC_ID}", "host=git"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}=>${NOMAD_PORT_ssh}"
        type      = "tcp"
        interval  = "60s"
        timeout   = "10s"
      }
      check_restart {
        limit     = 3
        grace     = "10m"
      }
    }

    ephemeral_disk { size = 128 } # MB
    network {
      # dns { servers = local.var.dns_servers }
      port "http" {
        static = 64801
        to     = 80
      }
      port "ssh"  {
        static = 64822
        to     = 22
      }
    }
    volume "nomad-cgit-repos" {
      type      = "host"
      read_only = false
      source    = "nomad-cgit-repos"
    }
    volume "nomad-cgit-hostkeys" {
      type      = "host"
      read_only = false
      source    = "nomad-cgit-hostkeys"
    }
    volume "nomad-cgit-userkeys" {
      type      = "host"
      read_only = false
      source    = "nomad-cgit-userkeys"
    }
    # volume "nomad-cgit-scripts" {
    #   type      = "host"
    #   read_only = false
    #   source    = "nomad-cgit-scripts"
    # }
    volume "nomad-cgit-web" {
      type      = "host"
      read_only = false
      source    = "nomad-cgit-web"
    }

    task "cgit" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "${local.var.docker_registry.url}/woahbase/alpine-cgit:${var.version}"
        network_mode = "bridge"
        ports        = ["http", "ssh"]

        # volumes      = [
        #   "/path/to/your/cgit/git/.ssh:/home/git/.ssh",
        #   "/path/to/your/cgit/scripts:/scripts",
        #   "/path/to/your/cgit/hooks:/defaults/hooks",
        #   "/path/to/your/cgit/ssh:/etc/ssh",
        #   "/path/to/your/cgit/web:/var/www"
        # ]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        mount {
          source   = "local/cgitrc"
          target   = "/etc/cgitrc"
          type     = "bind"
          readonly = true
        }
        mount {
          type     = "bind"
          target   = "/etc/localtime"
          source   = "/etc/localtime"
          readonly = true
        }
      }

      volume_mount {
        # ensure policies allow vault-generated-token to read-write to the volume
        volume      = "nomad-cgit-repos"
        destination = "/home/git/repositories"
        read_only   = false
      }

      volume_mount {
        volume      = "nomad-cgit-hostkeys"
        destination = "/etc/ssh"
        read_only   = false
      }

      # volume_mount {
      #   volume      = "nomad-cgit-scripts"
      #   destination = "/scripts"
      #   read_only   = true
      # }

      volume_mount {
        volume      = "nomad-cgit-userkeys"
        destination = "/home/git/.ssh"
        read_only   = false
      }

      volume_mount {
        volume      = "nomad-cgit-web"
        destination = "/var/www"
        read_only   = true
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 1536 # MHz
        memory = 2048 # MB
      }

      template {
        change_mode = "restart"
        destination = "local/cgitrc"
        data        = <<-EOC
          {{ key "nomad/${var.dc}/cgit/cgitrc" }}
        EOC
        error_on_missing_key = true
      }
    }
  }
}
