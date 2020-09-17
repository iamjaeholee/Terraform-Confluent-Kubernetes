/**
 * Backend
 */

terraform {
  backend "pg" {}
}


/**
 * Providers
 */

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  load_config_file = "false"
  host = local.kubernetes_settings.host
  token = local.kubernetes_settings.token
  cluster_ca_certificate = local.kubernetes_settings.cluster_ca_certificate
  version = "~> 1.9"
}


/**
 * Data
 */

data "aws_eks_cluster" "anton" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "anton" {
  name = var.eks_cluster_name
}


/**
 * Module
 */

module "zookeeper" {
  source = "./zookeeper"
  kubernetes_settings = local.kubernetes_settings
  region = var.region
  image_pull_secrets = var.image_pull_secrets
  termination_grace_period_seconds = local.termination_grace_period_seconds
  namespace = var.namespace
  name = "${var.app_name}-zookeeper"
  annotations = local.default_annotations
  storage_class_name = "csi-ebs-gp2-sc"
  backup_bucket_name = var.backup_bucket_name

  required_node_affinity = merge(local.required_node_affinity, {
    group_type = [
      "kafka"
    ]
  })
}

module "kafka_broker" {
  source = "./kafka-broker"
  kubernetes_settings = local.kubernetes_settings
  region = var.region
  image_pull_secrets = var.image_pull_secrets
  termination_grace_period_seconds = local.termination_grace_period_seconds
  namespace = var.namespace
  name = "${var.app_name}-kafka-broker"
  annotations = local.default_annotations
  storage_class_name = "csi-ebs-gp2-sc"
  backup_bucket_name = var.backup_bucket_name
  zookeeper_uri = module.zookeeper.uri

  required_node_affinity = merge(local.required_node_affinity, {
    group_type = [
      "kafka"
    ]
  })
}

module "schema_registry" {
  source = "./schema-registry"
  kubernetes_settings = local.kubernetes_settings
  region = var.region
  image_pull_secrets = var.image_pull_secrets
  termination_grace_period_seconds = local.termination_grace_period_seconds
  namespace = var.namespace
  name = "${var.app_name}-schema-registry"
  annotations = local.default_annotations
  zookeeper_uri = module.zookeeper.uri
  required_node_affinity = local.required_node_affinity
}

module "kafka_connect" {
  source = "./kafka-connect"
  kubernetes_settings = local.kubernetes_settings
  region = var.region
  image_pull_secrets = var.image_pull_secrets
  termination_grace_period_seconds = local.termination_grace_period_seconds
  namespace = var.namespace
  name = "${var.app_name}-kafka-connect"
  annotations = local.default_annotations
  kafka_broker_uri = module.kafka_broker.uri
  schema_registry_uri = module.schema_registry.uri
  required_node_affinity = local.required_node_affinity
}

module "kafka_manager" {
  source = "./kafka-manager"
  kubernetes_settings = local.kubernetes_settings
  region = var.region
  image_pull_secrets = var.image_pull_secrets
  termination_grace_period_seconds = local.termination_grace_period_seconds
  namespace = var.namespace
  name = "${var.app_name}-kafka-manager"
  annotations = local.default_annotations
  zookeeper_uri = module.zookeeper.uri
  kafka_broker_uri = module.kafka_broker.uri
  required_node_affinity = local.required_node_affinity
}

module "kafka_rest" {
  source = "./kafka-rest"
  kubernetes_settings = local.kubernetes_settings
  region = var.region
  image_pull_secrets = var.image_pull_secrets
  termination_grace_period_seconds = local.termination_grace_period_seconds
  namespace = var.namespace
  name = "${var.app_name}-kafka-rest"
  annotations = local.default_annotations
  kafka_broker_uri = module.kafka_broker.uri
  schema_registry_uri = module.schema_registry.uri
  required_node_affinity = local.required_node_affinity
}

module "topics_ui" {
  source = "./topics-ui"
  kubernetes_settings = local.kubernetes_settings
  region = var.region
  image_pull_secrets = var.image_pull_secrets
  termination_grace_period_seconds = local.termination_grace_period_seconds
  namespace = var.namespace
  name = "${var.app_name}-topics-ui"
  annotations = local.default_annotations
  kafka_rest_uri = module.kafka_rest.uri
  required_node_affinity = local.required_node_affinity
}

module "mongodb_connector" {
  source = "./mongodb-connector"
  kubernetes_settings = local.kubernetes_settings
  region = var.region
  namespace = var.namespace
  name = "${var.app_name}-kafka-mongodb-connector"
  annotations = local.default_annotations
  kafka_connect_uri = module.kafka_connect.uri
  schema_registry_uri = module.schema_registry.uri
  mongodb_uri = var.mongodb_uri
  required_node_affinity = local.required_node_affinity
}

module "kafka_benchamark" {
  source = "./kafka-benchmark"
  kubernetes_settings = local.kubernetes_settings
  region = var.region
  namespace = var.namespace
  name = "${var.app_name}-kafka-benchmark"
  annotations = local.default_annotations
  required_node_affinity = local.required_node_affinity
}
