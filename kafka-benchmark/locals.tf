locals {
  environment = lookup(var.annotations, "environment", var.environment)
  
  metadata = {
    name = var.name
    namespace = var.namespace
    annotations = merge(var.annotations, {
      environment = local.environment
    })
    
    labels = {
      app = var.name
      environment = local.environment
      version = "v0.1"
    }
  }

  kafka_benchmark = {
    name = "kafka-benchmark"
    image = ""
    command = [
      "sh",
      "-exec",
      "tail -f"
    ]

    requests = var.resource_requests
    limits = var.resource_limits
  }
}
