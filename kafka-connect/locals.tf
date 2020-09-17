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

  kafka_connect = {
    name = "kafka-connect"
    image = ""
    
    ports = {
      jmx-port = 5555 
      container-port = 7001
    }

    envs = {
      KAFKA_JMX_PORT = "5555"
      CONNECT_REST_PORT = "7001"
      CONNECT_REST_ADVERTISED_HOST_NAME = "anton-kafka-connect-svc"
      CONNECT_BOOTSTRAP_SERVERS = var.kafka_broker_uri
      CONNECT_GROUP_ID = "kafka-connect-group"
      CONNECT_CONFIG_STORAGE_TOPIC = "kafka-connect-config"
      CONNECT_OFFSET_STORAGE_TOPIC = "kafka-connect-offset"
      CONNECT_STATUS_STORAGE_TOPIC = "kafka-connect-status"
      CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL = var.schema_registry_uri
      CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL = var.schema_registry_uri
      CONNECT_PLUGIN_PATH = "/usr/share/java,/usr/share/confluent-hub-components"
      CONNECT_KEY_CONVERTER = "org.apache.kafka.connect.json.JsonConverter"
      CONNECT_VALUE_CONVERTER = "org.apache.kafka.connect.json.JsonConverter"
      CONNECT_KEY_CONVERTER_SCHEMAS_ENABLE = "false"
      CONNECT_VALUE_CONVERTER_SCHEMAS_ENABLE = "false"
      CONNECT_INTERNAL_KEY_CONVERTER = "org.apache.kafka.connect.json.JsonConverter"
      CONNECT_INTERNAL_VALUE_CONVERTER = "org.apache.kafka.connect.json.JsonConverter"
      CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR = "3"
      CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR = "3"
      CONNECT_STATUS_STORAGE_REPLICATION_FACTOR = "3"
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
