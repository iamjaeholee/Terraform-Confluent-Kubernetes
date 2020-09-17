locals {
  environment = lookup(var.annotations, "environment", var.environment)
  
  volume_claim = {
    name = "kafka-data"
    storage_class_name = var.storage_class_name
    storage_size = "2Gi"
  }

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

  kafka = {
    name = "kafka"
    image = ""
    
    ports = {
      external-port1 = 31090
      external-port2 = 31091
      external-port3 = 31092
      jmx-port = 5555 
      container-port = 9092
    }

    command = [
      "sh", 
      "-exec",
      "export KAFKA_BROKER_ID=$${HOSTNAME##*-} && export KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://$${POD_NAME}.$${KAFKA_POD_SERVICE_NAME}.$${POD_NAMESPACE}:9092,EXTERNAL://localhost:$$((31090 + $${KAFKA_BROKER_ID})) && exec /etc/confluent/docker/run"
    ]

    envs = {
      KAFKA_LOG_DIRS = "/opt/kafka/data-0/logs" 
#     KAFKA_METRIC_REPORTERS = "io.confluent.metrics.reporter.ConfluentMetricsReporter"
#     CONFLUENT_METRICS_REPORTER_BOOTSTRAP_SERVERS = "PLAINTEXT://anton-kafka-svc:9092"
      KAFKA_HEAP_OPTS = "-Xms512M -Xmx512M"
      KAFKA_JMX_PORT = "5555"
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR = "3"
      KAFKA_DEFAULT_REPLICATION_FACTOR = "3"
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP = "PLAINTEXT:PLAINTEXT, EXTERNAL:PLAINTEXT"
      KAFKA_ZOOKEEPER_CONNECT = var.zookeeper_uri
      KAFKA_POD_SERVICE_NAME = "${local.metadata.name}-svc"
#     KAFKA_ZOOKEEPER_CONNECT = join(",",[for n in [0, 1, 2] : format("anton-zookeeper-sts-%s.anton-zookeeper-svc.default:2181", n)])
#     KAFKA_SOCKET_REQUEST_MAX_BYTES = "20000000"
    }

    envs_from = {
      POD_IP = "status.podIP"
      HOST_IP = "status.hostIP"
      POD_NAME = "metadata.name"
      POD_NAMESPACE = "metadata.namespace"
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

  backup = {
    name = "s3-backup"
    image = ""
    schedule = "0 30 4 * * *"                     # sec min hour month_day month week_day

    envs = {
      BACKUP_BUCKET = var.backup_bucket_name
      BACKUP_PATH = "/data"
      BACKUP_SPLIT_SIZE = 100 * 1024 * 1024       # 100MiB
      AWS_S3_REGION = var.region
    }

    envs_from = {
      BACKUP_BUCKET_PATH = "metadata.name"
    }

    requests = {
      cpu = "100m"
      memory = "128Mi"
    }

    limits = {
      cpu = "200m"
      memory = "256Mi"
    }
  }
}
