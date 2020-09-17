resource "kubernetes_stateful_set" "zookeeper" {
  metadata {
    name = "${local.metadata.name}-sts"
    namespace = local.metadata.namespace
    labels = local.metadata.labels
    annotations = local.metadata.annotations
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = local.metadata.labels
    }

    service_name = kubernetes_service.zookeeper.metadata.0.name

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
          name = local.zookeeper.name
          image = local.zookeeper.image
          command = local.zookeeper.command

          dynamic "port" {
            for_each = local.zookeeper.ports

            content {
              container_port = port.value
            }
          }

          dynamic "env" {
            for_each = local.zookeeper.envs

            content {
              name = env.key
              value = env.value
            }
          }

          resources {
            limits {
              cpu = local.zookeeper.limits.cpu
              memory = local.zookeeper.limits.memory
            }

            requests {
              cpu = local.zookeeper.requests.cpu
              memory = local.zookeeper.requests.memory
            }
          }

          volume_mount {
            name = local.volume_claim.name
            mount_path = "/var/lib/zookeeper/data"
            sub_path = "zookeeper/data"
          }

          liveness_probe {
            initial_delay_seconds = 150
            period_seconds = 30

            tcp_socket {
              port = local.zookeeper.ports.container-port
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

        container {
          name = local.backup.name
          image = local.backup.image

          dynamic "env" {
            for_each = local.backup.envs

            content {
              name = env.key
              value = env.value
            }
          }

          dynamic "env" {
            for_each = local.backup.envs_from

            content {
              name = env.key
              value_from {
                field_ref {
                  field_path = env.value
                }
              }
            }
          }

          resources {
            limits {
              cpu = local.backup.limits.cpu
              memory = local.backup.limits.memory
            }

            requests {
              cpu = local.backup.requests.cpu
              memory = local.backup.requests.memory
            }
          }

          volume_mount {
            name = local.volume_claim.name
            mount_path = local.backup.envs.BACKUP_PATH
            sub_path = "zookeeper/data"
          }

          volume_mount {
            name = "backup-job"
            mount_path = "/jobber"
          }
        }

        volume {
          name = "jmx-config"

          config_map {
            name = kubernetes_config_map.jmx_exporter.metadata.0.name
          }
        }

        volume {
          name = "backup-job"

          config_map {
            name = kubernetes_config_map.zookeeper_backup_job.metadata.0.name
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

    volume_claim_template {
      metadata {
        name = local.volume_claim.name
      }

      spec {
        storage_class_name = local.volume_claim.storage_class_name
        access_modes = [
          "ReadWriteOnce"
        ]

        resources {
          requests = {
            storage = local.volume_claim.storage_size
          }
        }
      }
    }
  }
}
