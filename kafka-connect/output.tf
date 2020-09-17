output "uri" {
  value = "${kubernetes_service.kafka_connect.metadata.0.name}.${kubernetes_service.kafka_connect.metadata.0.namespace}:${local.kafka_connect.ports.container-port}"
}