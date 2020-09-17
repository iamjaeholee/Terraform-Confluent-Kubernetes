locals {
  environment = lookup(var.annotations, "environment", var.environment)
  
  metadata = {
    name = var.name
    namespace = var.namespace
    annotations = merge(var.annotations, {
      environment = local.environment
    })
    
    pod_annotations = {
      prometheus_metrics_enable = true
      prometheus_metrics_port = 5556
    }
    
    labels = {
      app = var.name
      environment = local.environment
      version = "v5.3.2"
    }
  }

  kafka_rest = {
    name = "kafka-rest"
    image = ""
    
    ports = {
      jmx-port = 5555 
      container-port = 7003
    }

    envs = {
      KAFKAREST_JMX_PORT = "5555"
      KAFKA_REST_HOST_NAME = "${local.metadata.name}-svc"
      KAFKA_REST_BOOTSTRAP_SERVERS = var.kafka_broker_uri
      KAFKA_REST_LISTENERS = "http://0.0.0.0:7003"
      KAFKA_REST_SCHEMA_REGISTRY_URL = var.schema_registry_uri
    }

    requests = var.resource_requests
    limits = var.resource_limits
  }

  jmx_exporter = {
    name = "prometheus-jmx-exporter"
    image = ""
    port = local.metadata.pod_annotations.prometheus_metrics_port
    command = [
      "java",
      "-XX:+UnlockExperimentalVMOptions",
      "-XX:+UseCGroupMemoryLimitForHeap",
      "-XX:MaxRAMFraction=1",
      "-XshowSettings:vm",
      "-jar",
      "jmx_prometheus_httpserver.jar",
      local.metadata.pod_annotations.prometheus_metrics_port,
      "/etc/jmx/config.yml"
    ]

    limits = {
      cpu = "100m"
      memory = "128Mi"
    }

    requests = {
      cpu = "100m"
      memory = "128Mi"
    }
  }
}
