variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "3.14.14"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "apcupsd" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  priority    = 50
  # region      = local.var.region
  type        = "service"

  constraint { distinct_hosts = true }

  # constraint { # check meta toggle enabled
  #   attribute = meta.has_apcups
  #   value     = true
  # }

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
      name        = "ups"
      port        = "nis"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "ups0"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_nis}"
        type      = "tcp"
        interval  = "60s"
        timeout   = "2s"
      }
      check_restart {
        limit     = 3
        grace     = "10s"
      }
    }

    /* service { */
    /*   name        = "ups-web" */
    /*   port        = "http" */
    /*   tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "ups0"] */
    /*   canary_tags = ["canary${NOMAD_ALLOC_INDEX}"] */
    /*   check { */
    /*     name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_http}" */
    /*     type      = "http" */
    /*     path      = "/apcupsd" */
    /*     interval  = "60s" */
    /*     timeout   = "10s" */
    /*     # tls_skip_verify = true */
    /*   } */
    /*   check_restart { */
    /*     limit     = 3 */
    /*     grace     = "10s" */
    /*   } */
    /* } */

    ephemeral_disk { size = 128 } # MB
    network {
      # dns { servers = local.var.dns_servers }
      port "nis" { static = 3551 }
      /* port "http" { */
      /*   static = 3552 */
      /*   to = 80 */
      /* } */
    }

    task "apcupsd" {
      driver = "docker"

      config {
        devices = [{
          # must be same as container path
          host_path    = "/dev/usb/hiddev0"
          container_path    = "/dev/usb/hiddev0"
          # host_path      = "/dev/usb"
          # container_path = "/dev/usb"
          # cgroup_permissions = "r"
        }]

        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-apcupsd:${var.version}"
        # labels     = { upstype = "ups0" }
        network_mode = "bridge"
        ports        = ["nis"] # , "http"
        # volumes    = []

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        /* enable to mount custom apcupsd.conf */
        /* mount { */
        /*   type     = "bind" */
        /*   source   = "local/apcupsd.conf" */
        /*   target   = "/etc/apcupsd/apcupsd.conf" */
        /*   readonly = true */
        /* } */
        mount {
          type     = "bind"
          target   = "/etc/localtime"
          source   = "/etc/localtime"
          readonly = true
          # bind_options { propagation = "rshared" }
        }
      }

      env {
        /* APCUPSD_HEADLESS = "true" */
        /* APCUPSD_MONITOR_HOSTS="ups.service.${var.dc}.${local.var.domain}:${var.dc} UPS" */
        APCUPSD__DEVICE   = ""
        APCUPSD__UPSCABLE = "usb"
        APCUPSD__UPSNAME  = "ups0"
        APCUPSD__UPSTYPE  = "usb"

        # TZ = local.var.tz
      }

      resources {
        cpu    = 250 # MHz
        memory = 256 # MB
      }

      /* enable to mount custom apcupsd.conf */
      /* template { */
      /*   destination = "local/apcupsd.conf" */
      /*   data        = <<-EOC */
      /*     {{ key "nomad/${var.dc}/apcups/apcupsd.conf" }} */
      /*   EOC */
      /*   change_mode = "restart" */
      /*   perms       = "644" */
      /*   error_on_missing_key = true */
      /* } */
    }
  }
}
