resource "kubernetes_deployment" "topics_ui" {
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
          name = local.topics_ui.name
          image = local.topics_ui.image
          
          port {
            container_port = local.topics_ui.port
          }

          dynamic "env" {
            for_each = local.topics_ui.envs

            content {
              name = env.key
              value = env.value
            }
          }

          resources {
            limits {
              cpu = local.topics_ui.limits.cpu
              memory = local.topics_ui.limits.memory
            }

            requests {
              cpu = local.topics_ui.requests.cpu
              memory = local.topics_ui.requests.memory
            }
          }

          liveness_probe {
            initial_delay_seconds = 150
            period_seconds = 30

            tcp_socket {
              port = local.topics_ui.port
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
