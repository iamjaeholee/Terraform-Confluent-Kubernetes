resource "kubernetes_job" "mongodb_sink_connect_worker" {
  metadata {
    name = "${var.name}-job"
    namespace = local.metadata.namespace
    labels = local.metadata.labels
    annotations = local.metadata.annotations
  }

  spec {
    template {
      metadata {
        labels = local.metadata.labels
        annotations = local.metadata.annotations
      }

      spec {
        dynamic "affinity" {
          for_each = var.required_node_affinity != null ? [ var.required_node_affinity ] : []

          content {
            node_affinity {
              required_during_scheduling_ignored_during_execution {
                node_selector_term {
                  dynamic "match_expressions" {
                    for_each = affinity.value

                    content {
                      key = match_expressions.key
                      operator = "In"
                      values = match_expressions.value
                    }
                  }
                }
              }
            }
          }
        }
        
        container {
          name = local.mongo_connector.name
          image = local.mongo_connector.image
          command = local.mongo_connector.command

          resources {
            limits {
              cpu = local.mongo_connector.limits.cpu
              memory = local.mongo_connector.limits.memory
            }

            requests {
              cpu = local.mongo_connector.requests.cpu
              memory = local.mongo_connector.requests.memory
            }
          }
        }

        restart_policy = "Never"
      }
    }

    backoff_limit = 4
  }
}
