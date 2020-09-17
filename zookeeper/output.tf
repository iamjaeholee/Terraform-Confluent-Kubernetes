output "uri" {
  value = "${kubernetes_service.zookeeper.metadata.0.name}.${kubernetes_service.zookeeper.metadata.0.namespace}:${local.zookeeper.ports.container-port}"
}
