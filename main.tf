locals {
  name          = var.service_name
  bin_dir       = module.setup_clis.bin_dir
  tmp_dir       = "${path.cwd}/.tmp/${local.name}"
  secret_dir    = "${local.tmp_dir}/secrets"
  yaml_dir      = "${local.tmp_dir}/chart/${local.name}"
  service_url   = "http://${local.name}.${var.namespace}"
  secret_name   = "${local.name}-tls"
  ca_config_name = "${local.name}-ca"
  password_secret_name = "${local.name}-password"
  service_account_name = "${var.service_name}-sa"
  values_content = {
    global = {
      syncWave = "1"
    }
    secretName = local.secret_name
    passwordSecretName = local.password_secret_name
    storageClassName = var.storage_class_name
    version = var.mongo_version
    replicaset_count = var.replicaset_count
    name = local.name
    serviceName = var.service_name
    caConfigMapName = local.ca_config_name
    ocp-service-tls = {
      secretName = local.secret_name
      caConfigName = local.ca_config_name
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
    apiGroups = [""]
    resources = ["services", "configmaps"]
    verbs = ["*"]
  }]
}

resource null_resource create_yaml {
  depends_on = [module.service_account]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

resource null_resource create_secrets {
  depends_on = [null_resource.create_yaml]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-secrets.sh '${var.namespace}' '${local.secret_dir}' '${local.password_secret_name}' '${var.password}'"
  }
}

module seal_secrets {
  depends_on = [null_resource.create_secrets]

  source = "github.com/cloud-native-toolkit/terraform-util-seal-secrets.git?ref=v1.1.0"

  source_dir    = local.secret_dir
  dest_dir      = "${local.yaml_dir}/templates"
  kubeseal_cert = var.kubeseal_cert
  label         = local.name
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  triggers = {
    name = local.name
    namespace = var.namespace
    yaml_dir = local.yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}' --debug"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}
