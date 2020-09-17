resource "kubernetes_pod" "kafka_benchmark" {
  metadata {
    name = "${local.metadata.name}-pod"
    namespace = local.metadata.namespace
    labels = local.metadata.labels
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
      image = local.kafka_benchmark.image
      name = local.kafka_benchmark.name
      command = local.kafka_benchmark.command

      resources {
        limits {
          cpu = local.kafka_benchmark.limits.cpu
          memory = local.kafka_benchmark.limits.memory
        }

        requests {
          cpu = local.kafka_benchmark.requests.cpu
          memory = local.kafka_benchmark.requests.memory
        }
      }
    }

    restart_policy = "Never"
  }
}

