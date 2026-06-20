variables {
  dc      = "dc1" # to load the dc-local config file
  pgid    = 1000  # gid for docker
  puid    = 995  # uid for group docker on the host
  ghslug  = "mcpjungle/MCPJungle"
  dhslug  = "woahbase/alpine-mcpjungle"
  version = "0.4.4"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "mcpjungle" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  priority    = 70
  # region      = local.var.region
  type = "service"

  constraint { distinct_hosts = true }

  # vault { policies = ["nomad-kv-readonly"] }

  group "docker" {
    count = 1

    reschedule {
      delay          = "1m"
      delay_function = "constant"
      unlimited      = true
    }
    restart {
      attempts = 2
      interval = "5m"
      delay    = "1m"
      mode     = "fail"
    }
    update {
      max_parallel     = 1
      min_healthy_time = "10s"
      healthy_deadline = "3m"
      auto_revert      = false
    }

    service {
      name = NOMAD_JOB_NAME
      port = "http"
      tags = ["aid=${NOMAD_ALLOC_ID}", "host=${attr.unique.hostname}", "ins${NOMAD_ALLOC_INDEX}", "proxy=nginx", "proxy-prefix=/mcpjungle", "proxy-proto=http"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "proxy-prefix=/c/mcpjungle"]
      check {
        name     = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
        type     = "http"
        path     = "/"
        interval = "60s"
        timeout  = "10s"
      }
      check_restart {
        limit = 3
        grace = "10s"
      }
      meta {
        dc      = "${node.datacenter}"
        region  = "${node.region}"
        github  = "https://github.com/${var.ghslug}"
        image   = "https://hub.docker.com/r/${var.dhslug}"
        version = "${var.version}"
      }
    }

    ephemeral_disk { size = 128 } # MB
    network {
      # dns { servers = local.var.dns_servers }
      port "http" { static = 8080 }
    }
    volume "nomad-mcpjungle-data" {
      type      = "host"
      read_only = false
      source    = "nomad-mcpjungle-data"
    }

    task "mcpjungle" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "${var.dhslug}:${var.version}"
        network_mode = "bridge"
        ports        = ["http"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag  = NOMAD_JOB_NAME
          }
        }

        # # only required if using docker base mcp-servers
        # mount {
        #   type     = "bind"
        #   target   = "/var/run/docker.sock"
        #   source   = "/var/run/docker.sock"
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
        volume      = "nomad-mcpjungle-data"
        destination = "/config"
        read_only   = false
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz

        HOME = "/config"
        SERVER_MODE = "development"
        PORT = "8080"
      }

      resources {
        cpu    = 512  # MHz
        memory = 1024 # MB
      }
    }
  }
}
