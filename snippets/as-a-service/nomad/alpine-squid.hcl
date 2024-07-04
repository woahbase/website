variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "5.2"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "squidproxy" {
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
      name        = "proxy"
      port        = "http"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "host=proxy"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}"
        type      = "tcp"
        interval  = "60s"
        timeout   = "10s"
      }
      check {
        name      = "ping-client"
        command   = "squidclient"
        args      = ["--ping", "-g", "3", "-I", "1"]
        task      = "squidproxy"
        type      = "script"
        interval  = "60s"
        timeout   = "10s"
      }
      check_restart {
        limit     = 3
        grace     = "10s"
      }
    }

    # service {
    #   name        = "proxy-intercept"
    #   port        = "intercept"
    #   tags        = ["squid${NOMAD_ALLOC_INDEX}", "intc"]
    #   canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
    #   check {
    #     name      = "alive"
    #     type      = "tcp"
    #     interval  = "60s"
    #     timeout   = "10s"
    #   }
    # }

    # service {
    #   name        = "proxy-intercepts"
    #   port        = "intercepts"
    #   tags        = ["squid${NOMAD_ALLOC_INDEX}", "intcs"]
    #   canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
    #   check {
    #     name      = "alive"
    #     type      = "tcp"
    #     interval  = "60s"
    #     timeout   = "10s"
    #   }
    # }

    ephemeral_disk { size = 128 } # MB
    network {
      # dns { servers = local.var.dns_servers }
      port "http"       { static = 3128 }
      port "intercept"  { static = 3129 }
      port "intercepts" { static = 3130 }
    }
    volume "nomad-squid-cache" {
      type      = "host"
      read_only = false
      source    = "nomad-squid-cache"
    }

    task "squidproxy" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-squid:${var.version}"
        network_mode = "host"
        ports        = ["http", "intercept", "intercepts"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        # mount {
        #   source   = "local/squidproxy"
        #   target   = "/etc/squid"
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
        volume      = "nomad-squid-cache"
        destination = "/var/cache/squid"
        read_only   = false
      }

      env {
        # S6_USERGROUPS = "tty"
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 2000 # MHz
        memory = 1024 # MB
      }

      # template {
      #   destination = "local/squidproxy/cachemgr.conf"
      #   data        = <<-EOC
      #     {{ key "nomad/dc1/squidproxy/cachemgr.conf" }}
      #   EOC
      #   perms       = "644"
      #   change_mode = "restart"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "local/squidproxy/errorpage.css"
      #   data        = <<-EOC
      #     {{ key "nomad/dc1/squidproxy/errorpage.css" }}
      #   EOC
      #   perms       = "644"
      #   change_mode = "restart"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "local/squidproxy/mime.conf"
      #   data        = <<-EOC
      #     {{ key "nomad/dc1/squidproxy/mime.conf" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "local/squidproxy/squid.conf"
      #   data        = <<-EOC
      #     {{ key "nomad/dc1/squidproxy/squid.conf" }}
      #   EOC
      #   change_mode = "restart"
      #   perms       = "644"
      #   error_on_missing_key = true
      # }

      # template {
      #   destination = "secrets/env"
      #   data        = <<-EOE
      #     {{ with secret "kv/data/nomad/dc1/squidproxy" }}
      #     WEBADMIN={{ .Data.data.username }}
      #     WEBPASSWORD={{ .Data.data.password }}
      #     {{ end }}
      #   EOE
      #   change_mode = "restart"
      #   env         = true
      #   perms       = "444"
      #   error_on_missing_key = true
      # }
    }
  }
}
