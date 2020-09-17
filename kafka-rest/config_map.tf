resource "kubernetes_config_map" "jmx_exporter" {
  metadata {
    name = "${local.metadata.name}-cm"
    namespace = local.metadata.namespace
    labels = local.metadata.labels
  }

  data = {
    "config.yml" = file("${path.module}/templates/jmx-kafka-rest-prometheus.yml")
  }
}