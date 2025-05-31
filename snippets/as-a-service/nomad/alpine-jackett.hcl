variables {
  dc      = "dc1" # to load the dc-local config file
  pgid    = 1000  # gid for docker
  puid    = 1000  # uid for docker
  version = "0.22.1967"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "jackett" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  # priority    = 50
  # region      = local.var.region
  type = "service"

  vault {
    /* disable_file = true */
    env      = false
    policies = ["nomad-kv-readonly"]
  }

  constraint { distinct_hosts = true }

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
      name        = NOMAD_JOB_NAME
      port        = "http"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "urlprefix-/jackett"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}", "urlprefix-/c/jackett"]
      check {
        name = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
        type = "tcp"
        # path      = "/jackett"
        interval = "60s"
        timeout  = "10s"
      }
      check_restart {
        limit = 3
        grace = "10s"
      }
    }

    ephemeral_disk { size = 128 } # MB
    network {
      # dns { servers = local.var.dns_servers }
      port "http" { static = 9117 }
    }
    volume "nomad-jackett-config" {
      type      = "host"
      read_only = false
      source    = "nomad-jackett-config"
    }
    volume "nomad-jackett-downloads" {
      type      = "host"
      read_only = false
      source    = "nomad-jackett-downloads"
    }

    task "jackett" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-jackett:${var.version}"
        network_mode = "bridge"
        ports        = ["http"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag  = NOMAD_JOB_NAME
          }
        }

        mount {
          type     = "bind"
          source   = "local/ServerConfig.json"
          target   = "/config/Jackett/ServerConfig.json"
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
        # works to pin the task to client with the volume available
        # ensure polices allow token to write to the volume
        volume      = "nomad-jackett-config"
        destination = "/config"
        read_only   = false
      }
      volume_mount {
        volume      = "nomad-jackett-downloads"
        destination = "/torrents"
        read_only   = false
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 1000 # MHz
        memory = 512  # MB
      }
      template {
        destination          = "local/ServerConfig.json"
        data                 = <<-EOT
          {{ with secret "kv/data/nomad/${var.dc}/jackett" -}}
          {
            "APIKey"                    : "{{ .Data.data.apikey }}",
            "AdminPassword"             : "{{ .Data.data.adminpassword }}",
            "AllowCORS"                 : true,
            "AllowExternal"             : true,
            "BasePathOverride"          : "/jackett",
            "BaseUrlOverride"           : "https://your-domain.local",
            "BlackholeDir"              : "/torrents",
            "CacheEnabled"              : true,
            "CacheMaxResultsPerIndexer" : 1000,
            "CacheTtl"                  : 2100,
            "FlareSolverrMaxTimeout"    : 55000,
            "FlareSolverrUrl"           : "",
            "InstanceId"                : "{{ .Data.data.instanceid }}",
            "OmdbApiKey"                : "",
            "OmdbApiUrl"                : "",
            "Port"                      : 9117,
            "ProxyIsAnonymous"          : true,
            "ProxyPassword"             : "",
            "ProxyPort"                 : 3128,
            "ProxyType"                 : -1,
            "ProxyUrl"                  : "http://proxy.service.${var.dc}.consul",
            "ProxyUsername"             : "",
            "UpdateDisabled"            : true,
            "UpdatePrerelease"          : false
          }
          {{- end }}
        EOT
        change_mode          = "restart"
        perms                = "444"
        error_on_missing_key = true
      }
    }
  }
}
