module "gitops_module" {
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.mongo-operator.namespace
  kubeseal_cert = module.gitops.sealed_secrets_cert
  storage_class_name = var.mongo_storageclass
  
}
