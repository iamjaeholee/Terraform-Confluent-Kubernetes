variable "eks_cluster_name" {
  type = string
  default = "anton_cluster"
}

variable "environment" {
  type = string
  default = "development"      
}

variable "region" {
  type = string
  default = "ap-northeast-2"      
}

variable "app_name" {
  type = any
  default = "anton"
}

variable "namespace" {
  type = string
  default = "default"
}

variable "image_pull_secrets" {
  type = string
  default = null
}

variable "backup_bucket_name" {
  type = string
  default = "anton-schedule-backup"
}

variable "mongodb_uri" {
  type = string
  default = "mongodb://dev:test@anton-mongodb-svc:2901"
}

variable "required_node_affinity" {
  type = any
  default = null
}
