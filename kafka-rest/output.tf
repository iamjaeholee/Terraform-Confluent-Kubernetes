output "uri" {
  value = "${kubernetes_service.kafka_rest.metadata.0.name}.${kubernetes_service.kafka_rest.metadata.0.namespace}:${local.kafka_rest.ports.container-port}"
}