variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 1000  # gid for docker
  puid = 1000  # uid for docker
  version = "1.3.1"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "saned" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  priority    = 50
  # region      = local.var.region
  type        = "service"

  constraint { distinct_hosts = true }

  # constraint { # check meta toggle enabled
  #   attribute = meta.has_scanner
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
      name        = "scanner"
      port        = "saned"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "scanner0"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_saned}"
        type      = "tcp"
        interval  = "60s"
        timeout   = "2s"
      }
      check_restart {
        limit     = 3
        grace     = "10s"
      }
    }

    ephemeral_disk { size = 128 } # MB
    network {
      # dns { servers = local.var.dns_servers }
      port "saned" { static = 6566 }
      # port-range mapping unsupported in nomad
      # using host network anyway
      # port "range" { static = 10000-10100 }
    }
    volume "nomad-saned-conf" {
      type      = "host"
      read_only = false
      source    = "nomad-saned-conf"
    }
    # volume "nomad-saned-data" {
    #   type      = "host"
    #   read_only = false
    #   source    = "nomad-saned-data"
    # }

    task "saned" {
      driver = "docker"

      config {
        devices = [{
          # must be same as container path
          host_path    = "/dev/bus/usb"
          container_path    = "/dev/bus/usb"
          # host_path      = "/dev/usb"
          # container_path = "/dev/usb"
          # host_path      = "/dev/scanner0"
          # container_path = "/dev/scanner0"
          # cgroup_permissions = "r"
        }]

        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-saned:${var.version}"
        # labels     = { scannertype = "canon-pixma" }
        network_mode = "host"
        ports        = ["saned"] # , "range"
        # volumes    = []

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        /* enable to mount custom saned.conf */
        /* mount { */
        /*   type     = "bind" */
        /*   source   = "local/saned.conf" */
        /*   target   = "/etc/sane.d/saned.conf" */
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

      volume_mount {
        # ensure policies allow vault-generated-token to read-write to the volume
        volume      = "nomad-saned-conf"
        destination = "/etc/sane.d"
        read_only   = false
      }
      # volume_mount {
      #   # ensure policies allow vault-generated-token to read-write to the volume
      #   volume      = "nomad-saned-data"
      #   destination = "/data"
      #   read_only   = false
      # }

      env {
        PGID = var.pgid
        PUID = var.puid

        # SANED_CONF_abaton = "--/dev/scanner;/dev/scanner0"
        # SANED_CONF_airscan: "devices=>\"Kyocera MFP Scanner\" = http://192.168.1.102:9095/eSCL;options=>discovery = enable;options=>model = network;blacklist=>--model = \"Xerox*\""
        # SANED_TRIM_CONFLINE = "1"

        # TZ = local.var.tz
      }

      resources {
        cpu    = 512 # MHz
        memory = 512 # MB
      }

      /* enable to mount custom saned.conf */
      /* template { */
      /*   destination = "local/saned.conf" */
      /*   data        = <<-EOC */
      /*     {{ key "nomad/${var.dc}/saned/saned.conf" }} */
      /*   EOC */
      /*   change_mode = "restart" */
      /*   perms       = "644" */
      /*   error_on_missing_key = true */
      /* } */
    }
  }
}
