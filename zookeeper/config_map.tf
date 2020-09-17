resource "kubernetes_config_map" "jmx_exporter" {
  metadata {
    name = "${local.metadata.name}-cm"
    namespace = local.metadata.namespace
    labels = local.metadata.labels
  }

  data = {
    "config.yml" = file("${path.module}/templates/jmx-zookeeper-prometheus.yml")
  }
}

resource "kubernetes_config_map" "zookeeper_backup_job" {
  metadata {
    name = "${local.metadata.name}-backup-job-cm"
    namespace = local.metadata.namespace
    labels = local.metadata.labels
  }

  data = {
    jobfile = yamlencode({
      version = "1.4"

      jobs = {
        s3Backup = {
          cmd = "/etc/backup/run_backup_awscli.sh"
          time = local.backup.schedule
          onError = "Continue"
        }
      }
    })
  }
}