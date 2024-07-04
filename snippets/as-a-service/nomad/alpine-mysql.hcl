variables {
  dc   = "dc1" # to load the dc-local config file
  pgid = 100   # gid for docker
  puid = 1000  # uid for docker
  version = "10.11.6"
}
# locals { var = yamldecode(file("${var.dc}.vars.yml")) } # load dc-local config file

job "mysql" {
  datacenters = [var.dc]
  # namespace   = local.var.namespace
  priority    = 80
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
      max_parallel      = 1
      min_healthy_time  = "10s"
      healthy_deadline  = "10m"
      progress_deadline = "15m"
      auto_revert       = false
    }

    service {
      name        = NOMAD_JOB_NAME
      port        = "mysql"
      tags        = ["ins${NOMAD_ALLOC_INDEX}", attr.unique.hostname, "aid=${NOMAD_ALLOC_ID}", "host=mysql"]
      canary_tags = ["canary${NOMAD_ALLOC_INDEX}"]
      check {
        name      = "${NOMAD_JOB_NAME}@${attr.unique.hostname}:${NOMAD_HOST_PORT_mysql}"
        type      = "tcp"
        interval  = "60s"
        timeout   = "10s"
      }
      check {
        name      = "ping-client"
        command   = "/bin/bash"
        args      = ["-c", "/usr/bin/mysql --user=$MYSQL_USER --password=$MYSQL_USER_PWD --execute 'SHOW DATABASES'"]
        task      = "mysql"
        type      = "script"
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
      port "mysql"  { static = 3306 }
      port "mysqls" { static = 3366 }
    }
    volume "nomad-mysql-data" {
      type      = "host"
      read_only = false
      source    = "nomad-mysql-data"
    }

    task "mysql" {
      driver = "docker"

      config {
        healthchecks { disable = true }
        hostname     = NOMAD_JOB_NAME
        image        = "woahbase/alpine-mysql:${var.version}"
        network_mode = "host"
        ports        = ["mysql"]

        logging {
          type = "journald"
          config {
            mode = "non-blocking"
            tag = NOMAD_JOB_NAME
          }
        }

        mount {
          source   = "local/my.cnf"
          target   = "/etc/my.cnf"
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
        # works to pin the task to client with the volume available
        # ensure polices allow token to write to the volume
        volume      = "nomad-mysql-data"
        destination = "/var/lib/mysql"
        read_only   = false
      }

      env {
        PGID = var.pgid
        PUID = var.puid
        # TZ   = local.var.tz
      }

      resources {
        cpu    = 2000 # MHz
        memory = 4096 # MB
      }

      template {
        destination = "local/my.cnf"
        data        = <<-EOC
          {{ key "nomad/dc1/mysql/my.cnf" }}
        EOC
        change_mode = "restart"
        perms       = "644"
        error_on_missing_key = true
      }
      template {
        destination = "secrets/env"
        data        = <<-EOE
          MYSQL_USER_DB=test
          {{ with secret "kv/data/nomad/dc1/mysql" }}
          MYSQL_USER={{ .Data.data.username }}
          MYSQL_USER_PWD={{ .Data.data.password }}
          {{ end }}
        EOE
        change_mode = "restart"
        env         = true
        perms       = "444"
        error_on_missing_key = true
      }
    }
  }
}
