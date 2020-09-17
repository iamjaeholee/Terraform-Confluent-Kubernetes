resource "kubernetes_deployment" "kafka_manager" {
  metadata {
    name = "${local.metadata.name}-deploy"
    namespace = local.metadata.namespace
    labels = local.metadata.labels
    annotations = local.metadata.annotations
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = local.metadata.labels
    }

    template {
      metadata {
        labels = local.metadata.labels
        annotations = merge(local.metadata.annotations, local.metadata.pod_annotations)
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
          name = local.kafka_manager.name
          image = local.kafka_manager.image
          
          port {
            container_port = local.kafka_manager.port
          }

          dynamic "env" {
            for_each = local.kafka_manager.envs

            content {
              name = env.key
              value = env.value
            }
          }

          resources {
            limits {
              cpu = local.kafka_manager.limits.cpu
              memory = local.kafka_manager.limits.memory
            }

            requests {
              cpu = local.kafka_manager.requests.cpu
              memory = local.kafka_manager.requests.memory
            }
          }

          liveness_probe {
            initial_delay_seconds = 150
            period_seconds = 30

            tcp_socket {
              port = local.kafka_manager.port
            }
          }
        }

        termination_grace_period_seconds = var.termination_grace_period_seconds

        dynamic "image_pull_secrets" {
          for_each = var.image_pull_secrets == null ? [] : [ var.image_pull_secrets ] 
          
          content {
            name = image_pull_secrets.value
          }
        }
      }
    }
  }
}
