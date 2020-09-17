locals {
  environment = lookup(var.annotations, "environment", var.environment)
  
  volume_claim = {
    name = "zookeeper-data"
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

  zookeeper = {
    name = "zookeeper"
    image = ""
    
    ports = {
      jmx-port = 5555 
      container-port = 2181
      server-port = 2888
      election-port = 3888
    }

    command = [
      "sh",
      "-exec",
      "export ZK_FIX_HOST_REGEX='s/$${HOSTNAME}\\.[^:]*:/0.0.0.0:/g' && export ZOOKEEPER_SERVER_ID=$$(($${HOSTNAME##*-}+1)) && export ZOOKEEPER_SERVERS=`echo $ZOOKEEPER_SERVERS | sed -e s/$${HOSTNAME}\\.[^:]*:/0.0.0.0:/g` && /etc/confluent/docker/run"
    ]

    envs = {
      KAFKA_JMX_PORT = "5555"
      KAFKA_HEAP_OPTS = "-Xms512M -Xmx512M"
      ZOOKEEPER_TICK_TIME = "2000"
      ZOOKEEPER_SYNC_LIMIT = "5"
      ZOOKEEPER_INIT_LIMIT = "10"
      ZOOKEEPER_MAX_CLIENT_CNXNS = "60"
      ZOOKEEPER_AUTOPURGE_SNAP_RETAIN_COUNT = "3"
      ZOOKEEPER_AUTOPURGE_PURGE_INTERVAL = "24"
      ZOOKEEPER_CLIENT_PORT = "2181"
      ZOOKEEPER_CLIENT_SECURE = "false"
      ZOOKEEPER_SERVERS = join(";",
        [ 
          for n in range(var.replicas)
          : format(join(".", 
              [
                "${local.metadata.name}-sts-%s",
                "${local.metadata.name}-svc",
                "${local.metadata.namespace}:2888:3888"
              ]
            ), n)
        ]
      )
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
