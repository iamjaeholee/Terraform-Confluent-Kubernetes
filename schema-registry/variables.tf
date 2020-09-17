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
  default = "schema-registry"
}

variable "namespace" {
  type = string
  default = "default"
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

variable "zookeeper_uri" {
  type = string
}

variable "required_node_affinity" {
  type = any
  default = null
}

variable "replicas" {
  type = number
  default = 1
}