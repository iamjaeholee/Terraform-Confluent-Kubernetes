resource "kubernetes_deployment" "kafka_connect" {
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
          name = local.kafka_connect.name
          image = local.kafka_connect.image

          dynamic "port" {
            for_each = local.kafka_connect.ports

            content {
              container_port = port.value
            }
          }

          dynamic "env" {
            for_each = local.kafka_connect.envs

            content {
              name = env.key
              value = env.value
            }
          }

          resources {
            limits {
              cpu = local.kafka_connect.limits.cpu
              memory = local.kafka_connect.limits.memory
            }

            requests {
              cpu = local.kafka_connect.requests.cpu
              memory = local.kafka_connect.requests.memory
            }
          }

          liveness_probe {
            initial_delay_seconds = 150
            period_seconds = 30

            tcp_socket {
              port = local.kafka_connect.ports.container-port
            }
          }
        }

        container {
          name = local.jmx_exporter.name
          image = local.jmx_exporter.image
          command = local.jmx_exporter.command

          port {
            container_port = local.jmx_exporter.port
          }

          resources {
            limits {
              cpu = local.jmx_exporter.limits.cpu
              memory = local.jmx_exporter.limits.memory
            }

            requests {
              cpu = local.jmx_exporter.requests.cpu
              memory = local.jmx_exporter.requests.memory
            }
          }

          volume_mount {
            name = "jmx-config"
            mount_path = "/etc/jmx"
          }
        }

        volume {
          name = "jmx-config"

          config_map {
            name = kubernetes_config_map.jmx_exporter.metadata.0.name
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
