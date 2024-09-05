variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "4.0.5"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "transmission" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  # priority    = 50
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
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "urlprefix-/torrent"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/torrent"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
        type      = "http"
        path      = "/torrent"
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
      port "http"     { static = 9091  }
      port "announce" { static = 52437 }
    }
    volume "nomad-transmission-config" {
      type      = "host"
      read_only = false
      source    = "nomad-transmission-config"
    }
    volume "nomad-dir-downloads" {
      type      = "host"
      read_only = false
      source    = "nomad-dir-downloads"
    }
    volume "nomad-transmission-torrents" {
      type      = "host"
      read_only = false
      source    = "nomad-transmission-torrents"
    }

    task "transmission" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-transmission:${var.version}"
        network_mode = "host"
        ports        = ["http", "announce"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        # mount {
        #   source   = "local/settings.json"
        #   target   = "/var/lib/transmission/config/settings.json"
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
        volume      = "nomad-transmission-config"
        destination = "/var/lib/transmission/config"
        read_only   = false
      }
      volume_mount {
        volume      = "nomad-dir-downloads"
        destination = "/var/lib/transmission/downloads"
        read_only   = false
      }
      volume_mount {
        volume      = "nomad-transmission-torrents"
        destination = "/var/lib/transmission/torrents"
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
      #   destination = "local/settings.json"
      #   data        = <<-EOC
      #     {{ key "nomad/${var.dc}/transmission/settings.json" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }
    }
  }
}
