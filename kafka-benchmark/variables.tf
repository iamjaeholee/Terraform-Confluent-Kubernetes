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
  default = "kafka-benchmark"
}

variable "namespace" {
  type = string
  default = "default"
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
    cpu = "512m"
    memory = "512Mi"
  }
}

variable "resource_limits" {
  type = object({
    cpu = string
    memory = string
  })
  
  default = {
    cpu = "512m"
    memory = "512Mi"
  }
}

variable "required_node_affinity" {
  type = any
  default = null
}