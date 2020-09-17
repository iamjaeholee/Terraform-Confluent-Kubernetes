/**
* Locals
*/

locals {
  kubernetes_settings = {
    host = data.aws_eks_cluster.anton.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.anton.certificate_authority.0.data)
    token = data.aws_eks_cluster_auth.anton.token
  }

  required_node_affinity ={
    environment = [ 
      var.environment 
    ]
  }

  default_annotations = {
    ManagedBy = "terraform"
    Service = "kafka"
    environment = var.environment
  }

  termination_grace_period_seconds = (var.environment == "production") ? 300 : 10
}

