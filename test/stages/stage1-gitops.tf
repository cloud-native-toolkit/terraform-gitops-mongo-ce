module "olm" {
  source = "github.com/cloud-native-toolkit/terraform-k8s-olm"

  cluster_config_file = module.dev_cluster.config_file_path
  cluster_type = module.dev_cluster.platform.type_code
  cluster_version = module.dev_cluster.platform.version
}
module "gitea" {
  source = "github.com/cloud-native-toolkit/terraform-tools-gitea"

  cluster_config_file = module.dev_cluster.config_file_path
  cluster_type = module.dev_cluster.platform.type_code
  instance_name = var.gitea_instance_name
  instance_namespace = module.gitops_namespace.name
  olm_namespace = module.olm.olm_namespace
  operator_namespace = module.olm.target_namespace
  password = var.gitea_password
  username = var.gitea_username
}
module "gitops" {
  source = "github.com/cloud-native-toolkit/terraform-tools-gitops"

  debug = false
  gitea_host = module.gitea.host
  gitea_org = module.gitea.org
  gitea_token = module.gitea.token
  gitea_username = module.gitea.username
  repo = var.git_repo
  gitops_namespace = var.gitops_namespace
  sealed_secrets_cert = module.cert.cert
  strict = true
}

resource null_resource gitops_output {
  provisioner "local-exec" {
    command = "echo -n '${module.gitops.config_repo}' > git_repo"
  }

  provisioner "local-exec" {
    command = "echo -n '${module.gitops.config_token}' > git_token"
  }
}
