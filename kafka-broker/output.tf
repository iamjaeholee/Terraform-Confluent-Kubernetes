output "uri" {
  value = "${kubernetes_service.kafka.metadata.0.name}.${kubernetes_service.kafka.metadata.0.namespace}:${local.kafka.ports.container-port}"
}