
output "name" {
  description = "The name of the module"
  value       = gitops_module.module.name
}

output "branch" {
  description = "The branch where the module config has been placed"
  value       = gitops_module.module.branch
}

output "namespace" {
  description = "The namespace where the module will be deployed"
  value       = gitops_module.module.namespace
}

output "server_name" {
  description = "The server where the module will be deployed"
  value       = gitops_module.module.server_name
}

output "layer" {
  description = "The layer where the module is deployed"
  value       = gitops_module.module.layer
}

output "type" {
  description = "The type of module where the module is deployed"
  value       = gitops_module.module.type
}

output "username" {
  value       = local.username
  description = "mongo admin user"
  depends_on  = [gitops_module.module]
}

output "password" {
  value       = var.password
  description = "mongo admin pw"
  depends_on  = [gitops_module.module]
  sensitive   = true
}

output "port" {
  value       = var.port
  description = "mongo admin pw"
  depends_on  = [gitops_module.module]
  sensitive   = true
}
output "cacrt" {
  value       = var.cacrt
  description = "mongo cacert stored in cm"
  depends_on  = [gitops_module.module]
  sensitive   = true
}

output "svcname" {
  value       = var.service_name
  description = "mongo service name"
  depends_on  = [gitops_module.module]
  sensitive   = true
}

output "replicaset_count" {
  value       = var.replicaset_count
  description = "Count of replicaset count"
  depends_on  = [gitops_module.module]
  sensitive   = true
}






