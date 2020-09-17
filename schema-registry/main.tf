/**
 * Provider
 */

provider "kubernetes" {
  load_config_file = "false"
  host = var.kubernetes_settings.host
  token = var.kubernetes_settings.token
  cluster_ca_certificate = var.kubernetes_settings.cluster_ca_certificate
  version = "~> 1.9"
}