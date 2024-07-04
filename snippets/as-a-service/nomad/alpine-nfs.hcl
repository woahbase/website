variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "2.5.4"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "nfs" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  priority    = 80
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
      port        = "nfs"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_nfs}"
        type      = "script"
        interval  = "60s"
        timeout   = "10s"
        task      = "nfs"
        command   = "/bin/bash"
        args      = ["-ec", "nfsstat -s"]
      }
      check_restart {
        limit     = 3
        grace     = "10s"
      }
    }

    ephemeral_disk { size = 128 } # MB
    network {
      # dns { servers = local.var.dns_servers }
      port "lockd"  { static = 32768 }
      port "mapper" { static = 111   }
      port "mountd" { static = 32767 }
      port "nfs"    { static = 2049  }
      port "statd5" { static = 32765 }
      port "statd6" { static = 32766 }
      # port-range mapping unsupported in nomad
      # using host network anyway
      # port "statd"  { static = 32765-32766 }
    }
    volume "nomad-nfs-data" {
      type      = "host"
      read_only = false
      source    = "nomad-nfs-data"
    }

    task "nfs" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-nfs:${var.version}"
        network_mode = "host"
        ports        = ["lockd", "mapper", "mountd", "nfs", "statd5", "statd6"]

        /* cap_add      = ["sys_admin", "setpcap"] */
        /* cap_drop     = [] */
        # TODO: figure actual caps needed until then
        privileged   = true

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        mount {
          readonly = true
          source   = "local/exports"
          target   = "/etc/exports"
          type     = "bind"
        }
        mount {
          readonly = true
          source   = "/etc/localtime"
          target   = "/etc/localtime"
          type     = "bind"
        }
      }

      volume_mount {
        # ensure policies allow vault-generated-token to read-write to the volume
        volume      = "nomad-nfs-data"
        destination = "/data"
        read_only   = false
      }

      env {
        # NFSMODE     = "SERVER"
        MOUNTD_ARGS = "-F -N 2 --debug all -p 32767"
        # disable nfsv2 but enable nfsv3 for pxe-boot clients
        # default disables both and only enables nfsv4+
        NFSD_ARGS   = "-N 2 --debug 8" # -N 3

        PUID        = var.puid
        PGID        = var.pgid
        # TZ          = local.var.tz
      }

      resources {
        cpu    = 512 # MHz
        memory = 512 # MB
      }

      template {
        destination = "local/exports"
        data        = <<-EOC
          {{- /* Locate the exports file specific to this host from configs */ -}}
          {{- $fnm := "nomad/dc1/nfs/exports" -}}
          {{- $h   := env "attr.unique.hostname" -}}
          {{ key (print $fnm "." $h) }}
        EOC
        change_mode = "restart"
        perms       = "644"
        error_on_missing_key = true
      }
    }
  }
}
