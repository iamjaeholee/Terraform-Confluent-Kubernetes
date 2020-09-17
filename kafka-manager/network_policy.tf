resource "kubernetes_network_policy" "kafka_connect" {
  metadata {
    name = "${local.metadata.name}-netpol"
    namespace = local.metadata.namespace
    labels = local.metadata.labels
  }

  spec {
    pod_selector {
      match_labels = local.metadata.labels
    }

    ingress {
      ports {
        port = local.kafka_manager.port
        protocol = "TCP"
      }
    }

    egress {}

    policy_types = [
      "Ingress",
      "Egress"
    ]
  }
}