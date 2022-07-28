
output "name" {
  description = "The name of the module"
  value       = local.name
  depends_on  = [null_resource.setup_gitops]
}

output "branch" {
  description = "The branch where the module config has been placed"
  value       = local.application_branch
  depends_on  = [null_resource.setup_gitops]
}

output "namespace" {
  description = "The namespace where the module will be deployed"
  value       = local.namespace
  depends_on  = [null_resource.setup_gitops]
}

output "server_name" {
  description = "The server where the module will be deployed"
  value       = var.server_name
  depends_on  = [null_resource.setup_gitops]
}

output "layer" {
  description = "The layer where the module is deployed"
  value       = local.layer
  depends_on  = [null_resource.setup_gitops]
}

output "type" {
  description = "The type of module where the module is deployed"
  value       = local.type
  depends_on  = [null_resource.setup_gitops]
}

output "username" {
  value       = local.username
  description = "mongo admin user"
  depends_on  = [null_resource.setup_gitops]
}

output "password" {
  value       = var.password
  description = "mongo admin password"
  depends_on  = [null_resource.setup_gitops]
}

output "port" {
  value       = var.port
  description = "mongo admin pw"
  depends_on  = [null_resource.setup_gitops]
  sensitive   = true
}

output "svcname" {
  value       = var.service_name
  description = "mongo service name"
  depends_on  = [null_resource.setup_gitops]
  sensitive   = true
}

output "private_svc_host" {
  value       = "${var.service_name}.${local.namespace}.svc"
  description = "Host name for private service endpoint"
}

output "private_master_host" {
  value       = "${var.service_name}-0.${var.service_name}.${local.namespace}.svc"
  description = "Host name for private master instance endpoint"
}

output "private_replica_host" {
  value       = [ for index in range(var.replicaset_count): "${var.service_name}-${index}.${var.service_name}.${local.namespace}.svc" ]
  description = "Host names for private replica instance endpoints"
}

output "replicaset_count" {
  value       = var.replicaset_count
  description = "Count of replicaset count"
  depends_on  = [null_resource.setup_gitops]
  sensitive   = true
}






