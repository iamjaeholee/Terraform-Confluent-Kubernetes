/**
 * Kubernetes settings
 *
 * {
 *   host = string
 *   token = string
 *   cluster_ca_certificate = string
 * }
 */

variable "kubernetes_settings" {
  type = any
  default = {}
} 

variable "environment" {
  type = string
  default = "development"      
}

variable "region" {
  type = string
  default = "ap-northeast-2"      
}

variable "name" {
  type = any
  default = "zookeeper"
}

variable "namespace" {
  type = string
  default = "default"
}

variable "storage_class_name" {
  type = string
  default = ""
}

variable "image_pull_secrets" {
  type = string
  default = null
}

variable "termination_grace_period_seconds" {
  type = number
  default = 300
}

variable "annotations" {
  type = map(any)
  default = {}
}

variable "resource_requests" {
  type = object({
    cpu = string
    memory = string
  })
  
  default = {
    cpu = "1"
    memory = "1.5Gi"
  }
}

variable "resource_limits" {
  type = object({
    cpu = string
    memory = string
  })
  
  default = {
    cpu = "1"
    memory = "1.5Gi"
  }
}

variable "backup_bucket_name" {
  type = string
}

variable "required_node_affinity" {
  type = any
  default = null
}

variable "replicas" {
  type = number
  default = 3
}