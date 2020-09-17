output "uri" {
  value = "${kubernetes_service.schema_registry.metadata.0.name}.${kubernetes_service.schema_registry.metadata.0.namespace}:${local.schema_registry.ports.container-port}"
}
