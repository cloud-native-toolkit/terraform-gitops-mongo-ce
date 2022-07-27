
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
  description = "mongo admin password"
  depends_on  = [gitops_module.module]
}

output "port" {
  value       = var.port
  description = "mongo admin pw"
  depends_on  = [gitops_module.module]
  sensitive   = true
}

output "svcname" {
  value       = var.service_name
  description = "mongo service name"
  depends_on  = [gitops_module.module]
  sensitive   = true
}

output "private_svc_host" {
  value       = "${var.service_name}.${gitops_module.module.namespace}.svc"
  description = "Host name for private service endpoint"
}

output "private_master_host" {
  value       = "${var.service_name}-0.${var.service_name}.${gitops_module.module.namespace}.svc"
  description = "Host name for private master instance endpoint"
}

output "private_replica_host" {
  value       = [ for index in range(var.replicaset_count): "${var.service_name}-${index}.${var.service_name}.${gitops_module.module.namespace}.svc" ]
  description = "Host names for private replica instance endpoints"
}

output "replicaset_count" {
  value       = var.replicaset_count
  description = "Count of replicaset count"
  depends_on  = [gitops_module.module]
  sensitive   = true
}






