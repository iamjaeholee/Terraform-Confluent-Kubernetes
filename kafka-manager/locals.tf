locals {
  environment = lookup(var.annotations, "environment", var.environment)
  
  metadata = {
    name = var.name
    namespace = var.namespace
    annotations = merge(var.annotations, {
      environment = local.environment
    })
    
    pod_annotations = {}
    
    labels = {
      app = var.name
      environment = local.environment
      version = "v1.3.1.8"
    }
  }

  kafka_manager = {
    name = "kafka-manager"
    image = ""
    port = 8081

    envs = {
      ZK_HOSTS = var.zookeeper_uri
      KAFKA_ZOOKEEPER_CONNECT = var.zookeeper_uri
      KAFKA_ADVERTISED_LISTENERS = "PLAINTEXT://${var.kafka_broker_uri}"
    }

    requests = var.resource_requests
    limits = var.resource_limits
  }
}
