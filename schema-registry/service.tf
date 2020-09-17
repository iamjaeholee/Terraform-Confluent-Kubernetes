resource "kubernetes_service" "schema_registry" {
  metadata {
    name = "${local.metadata.name}-svc"
    namespace = local.metadata.namespace
    labels = local.metadata.labels
  }

  spec {
    selector = local.metadata.labels

    port {
      port = local.schema_registry.ports.container-port
    }
  }
}
