
resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo \"$${OUTPUT}\" > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name          = module.gitops_module.name
        branch        = module.gitops_module.branch
        namespace     = module.gitops_module.namespace
        server_name   = module.gitops_module.server_name
        layer         = module.gitops_module.layer
        layer_dir     = module.gitops_module.layer == "infrastructure" ? "1-infrastructure" : (module.gitops_module.layer == "services" ? "2-services" : "3-applications")
        type          = module.gitops_module.type
        port          = module.gitops_module.port
        servicename   = module.gitops_module.svcname
        password      = module.gitops_module.password
        svc_host      = module.gitops_module.private_svc_host
        master_host   = module.gitops_module.private_master_host
        replica_hosts = module.gitops_module.private_replica_host
      })
    }
  }
}
