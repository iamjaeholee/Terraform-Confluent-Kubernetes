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
      version = "v0.9.4"
    }
  }

  topics_ui = {
    name = "topics-ui"
    image = ""
    port = 8082

    envs = {
      KAFKA_REST_PROXY_URL = var.kafka_rest_uri
      PORT = "8082"
      PROXY = "true"
    }

    requests = var.resource_requests
    limits = var.resource_limits
  }
}
