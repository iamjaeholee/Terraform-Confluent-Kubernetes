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

  mongo_connector = {
    name = "ubuntu"
    image = ""
    command = [
      "sh",
      "-c",
      <<EOF
      apt-get update && apt-get install -y curl && sleep 180 && curl -X POST -H "Accept: application/json" -H "Content-Type: application/json" --data '
        {
          "name": "avro-test3",
          "config": {
            "connector.class":"com.mongodb.kafka.connect.MongoSinkConnector",
            "tasks.max":"1",
            "topics":"avro-test2",
            "connection.uri":${var.mongodb_uri},
            "database":"anton",
            "collection":"avro-test3",
            "key.converter": "io.confluent.connect.avro.AvroConverter",
            "value.converter": "io.confluent.connect.avro.AvroConverter",
            "key.converter.schema.registry.url": "http://${var.schema_registry_uri}",
            "value.converter.schema.registry.url": "http://${var.schema_registry_uri}",
          }
        }' ${var.kafka_connect_uri}/connectors
      EOF
    ]

    requests = var.resource_requests
    limits = var.resource_limits
  }
}
