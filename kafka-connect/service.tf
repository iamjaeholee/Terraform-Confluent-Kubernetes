resource "kubernetes_service" "kafka_connect" {
  metadata {
    name = "${local.metadata.name}-svc"
    namespace = local.metadata.namespace
    labels = local.metadata.labels
  }

  spec {
    selector = local.metadata.labels

    port {
      port = local.kafka_connect.ports.container-port
    }
  }
}
