locals {
  name          = var.service_name
  bin_dir       = module.setup_clis.bin_dir
  tmp_dir       = "${path.cwd}/.tmp/${local.name}"
  secret_dir    = "${local.tmp_dir}/secrets"
  yaml_dir      = "${local.tmp_dir}/chart/${local.name}"
  service_url   = "http://${local.name}.${var.namespace}"
  secret_name   = "${local.name}-tls"
  password_secret_name = "${local.name}-password"
  cacrt = tls_self_signed_cert.ca.cert_pem
  values_content = {
    secretName = local.secret_name
    passwordSecretName = local.password_secret_name
    storageClassName = var.storage_class_name
    version = var.mongo_version
    replicaset_count = var.replicaset_count
    name = local.name
    crt =  base64encode(local_file.srvcrtfile.sensitive_content)
    key = base64encode(local_file.srvkeyfile.sensitive_content)
    serviceName = var.service_name
    mongocecm  = {
      cacrt = tls_self_signed_cert.ca.cert_pem
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
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

#  CREATE A CA CERTIFICATE

resource "tls_private_key" "ca" {
  algorithm   = "RSA"
  rsa_bits    = "2048"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm     = tls_private_key.ca.algorithm
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true
  set_subject_key_id = true

  subject {
    common_name  = "*.${local.name}.${var.namespace}.svc.cluster.local"
    organization = "Example, LLC"
  }

  validity_period_hours = 730 * 24
  allowed_uses = [
    "digital_signature",
    "content_commitment",
    "key_encipherment",
    "data_encipherment",
    "key_agreement",
    "cert_signing",
    "crl_signing",
    "encipher_only",
    "decipher_only",
    "any_extended",
    "server_auth",
    "client_auth",
    "code_signing",
    "email_protection",
    "ipsec_end_system",
    "ipsec_tunnel",
    "ipsec_user",
    "timestamping",
    "ocsp_signing"
  ]
  dns_names = [ "*.${local.name}.${var.namespace}.svc.cluster.local","127.0.0.1","localhost" ]

}

# CREATE A TLS CERTIFICATE SIGNED USING THE CA CERTIFICATE

resource "tls_private_key" "cert" {
  algorithm   = "RSA"
  rsa_bits    = "2048"
}

resource "tls_cert_request" "cert" {
  key_algorithm   = tls_private_key.cert.algorithm
  private_key_pem = tls_private_key.cert.private_key_pem

  dns_names = [ "*.${local.name}.${var.namespace}.svc.cluster.local","127.0.0.1","localhost" ]

  subject {
    common_name  = "*.${local.name}.${var.namespace}.svc.cluster.local"
    organization = "Example, LLC"
  }
}

resource "tls_locally_signed_cert" "cert" {
  cert_request_pem = tls_cert_request.cert.cert_request_pem

  ca_key_algorithm   = tls_private_key.ca.algorithm
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem
  is_ca_certificate = true

  validity_period_hours = 730 * 24
  allowed_uses = [
    "digital_signature",
    "content_commitment",
    "key_encipherment",
    "data_encipherment",
    "key_agreement",
    "cert_signing",
    "crl_signing",
    "encipher_only",
    "decipher_only",
    "any_extended",
    "server_auth",
    "client_auth",
    "code_signing",
    "email_protection",
    "ipsec_end_system",
    "ipsec_tunnel",
    "ipsec_user",
    "timestamping",
    "ocsp_signing"
  ]

}

resource "local_file" "srvkeyfile" {
  sensitive_content = tls_private_key.cert.private_key_pem
  file_permission = "0600"
  filename    = "${local.tmp_dir}/server.key"
}

resource "local_file" "srvcrtfile" {
  sensitive_content = tls_locally_signed_cert.cert.cert_pem
  file_permission = "0600"
  filename    = "${local.tmp_dir}/server.crt"
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

resource null_resource create_secret {
  depends_on = [null_resource.create_yaml]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-secrets.sh '${local.secret_name}' '${var.namespace}' '${local.tmp_dir}/server.key' '${local.tmp_dir}/server.crt' '${local.secret_dir}' '${local.password_secret_name}' '${var.password}'"
  }
}

module seal_secrets {
  depends_on = [null_resource.create_secret]

  source = "github.com/cloud-native-toolkit/terraform-util-seal-secrets.git?ref=v1.0.0"

  source_dir    = local.secret_dir
  dest_dir      = "${local.yaml_dir}/templates"
  kubeseal_cert = var.kubeseal_cert
  label         = local.name
}

resource gitops_module module {
  depends_on = [null_resource.create_yaml, module.seal_secrets]

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
