locals {
  name          = var.service_name
  bin_dir       = module.setup_clis.bin_dir
  tmp_dir       = "${path.cwd}/.tmp/${local.name}"
  secret_dir    = "${local.tmp_dir}/secrets"
  yaml_dir      = "${local.tmp_dir}/chart/${local.name}"
  service_url   = "http://${local.name}.${var.namespace}"
  secret_name   = "${local.name}-tls"
  password_secret_name = "${local.name}-password"
  service_account_name = "${var.service_name}-sa"
  values_content = {
    secretName = local.secret_name
    passwordSecretName = local.password_secret_name
    storageClassName = var.storage_class_name
    version = var.mongo_version
    replicaset_count = var.replicaset_count
    name = local.name
    serviceName = var.service_name
    service-signed-cert = {
      secretName = local.secret_name
      serviceName = var.service_name
      serviceAccount = {
        name = local.service_account_name
        rbac = false
        create = false
      }
    }
  }
  layer = "services"
  type  = "instances"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
  username = "admin"
}

module setup_clis {
  source  = "cloud-native-toolkit/clis/util"

  clis = ["igc", "kubectl"]
}

module "service_account" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-service-account.git"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  namespace = var.namespace
  name = local.service_account_name
  server_name = var.server_name
  rbac_rules = [{
    apiGroups = ["certificates.k8s.io"]
    resources = ["certificatesigningrequests"]
    verbs = ["*"]
  }]
  rbac_cluster_scope = true
}

module "rbac" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-rbac.git"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  service_account_name = module.service_account.name
  service_account_namespace = module.service_account.namespace
  namespace = module.service_account.namespace
  label = "sealed-secret-cert"
  rules = [{
    apiGroups = [""]
    resources = ["secrets"]
    verbs = ["*"]
  }]
}

resource null_resource create_yaml {
  depends_on = [module.rbac]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

resource gitops_module module {
  depends_on = [null_resource.create_yaml]

  name        = local.name
  namespace   = var.namespace
  content_dir = local.yaml_dir
  server_name = var.server_name
  layer       = local.layer
  type        = local.type
  branch      = local.application_branch
  config      = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}
