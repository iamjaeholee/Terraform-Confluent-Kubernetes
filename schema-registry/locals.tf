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

  schema_registry = {
    name = "schema-registry"
    image = ""
    
    ports = {
      jmx-port = 5555
      container-port = 7002
    }

    envs = {
      JMX_PORT = "5555"
      SCHEMA_REGISTRY_HOST_NAME = "${local.metadata.name}-svc"
      SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL = var.zookeeper_uri
      SCHEMA_REGISTRY_LISTENERS = "http://0.0.0.0:7002"
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
