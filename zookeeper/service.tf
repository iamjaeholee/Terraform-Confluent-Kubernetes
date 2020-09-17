resource "kubernetes_service" "zookeeper" {
  metadata {
    name = "${local.metadata.name}-svc"
    namespace = local.metadata.namespace
    labels = local.metadata.labels
  }

  spec {
    selector = local.metadata.labels

    dynamic "port" {
      for_each = {for k, v in local.zookeeper.ports: k => v if k != "jmx-port"}

      content {
        name = port.key
        port = port.value
      }
    }

    cluster_ip = "None"
  }
}
