variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "0.23.14"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "mpd" {
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
      name        = NOMAD_JOB_NAME
      port        = "mpd"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_mpd}"
        type      = "tcp"
        interval  = "60s"
        timeout   = "10s"
      }
      check_restart {
        limit     = 3
        grace     = "10s"
      }
    }

    service {
      name        = "${NOMAD_JOB_NAME}-stream"
      port        = "stream"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
    }

    service {
      name        = "${NOMAD_JOB_NAME}-http"
      port        = "http"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "urlprefix-/ympd"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/ympd"]
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

    ephemeral_disk { size = 128 } # MB
    network {
      # dns { servers = local.var.dns_servers }
      port "mpd"    { static = 6600  }
      port "stream" { static = 8000  }
      port "http"   { static = 64801 }
    }
    volume "nomad-mpd-data" {
      type      = "host"
      read_only = false
      source    = "nomad-mpd-data"
    }
    volume "nomad-media-music" {
      type      = "host"
      read_only = false
      source    = "nomad-media-music"
    }

    task "mpd" {
      driver = "docker"

      config {
        cap_add      = ["sys_nice"]
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-mpd:${var.version}"
        network_mode = "bridge"
        ports        = ["mpd", "stream", "http"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        # mount {
        #   type     = "bind"
        #   source   = "local/mpd.conf"
        #   target   = "/etc/mpd.conf"
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
        volume      = "nomad-mpd-data"
        destination = "/var/lib/mpd"
        read_only   = false
      }
      volume_mount {
        volume      = "nomad-media-music"
        destination = "/music"
        read_only   = false
      }

      env {
        # PULSE_SERVER = local.var.pulse_server

        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 500 # MHz
        memory = 512 # MB
      }

      # template {
      #   destination = "local/mpd.conf"
      #   data = <<-EOC
      #     {{ key "nomad/${var.dc}/mpd/mpd.conf" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }
    }
  }
}
