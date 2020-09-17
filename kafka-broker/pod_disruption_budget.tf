resource "kubernetes_pod_disruption_budget" "kafka" {
  metadata {
    name = "${local.metadata.name}-pdb"
    namespace = local.metadata.namespace
    labels = local.metadata.labels
  }

  spec {
    max_unavailable = "1"

    selector {
      match_labels = local.metadata.labels
    }
  }
}
