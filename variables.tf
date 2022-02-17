
variable "gitops_config" {
  type        = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo = string
    url = string
    username = string
    token = string
  }))
  description = "The credentials for the gitops repo(s)"
  sensitive   = true
}

variable "namespace" {
  type        = string
  description = "The namespace where the application should be deployed"
}

variable "kubeseal_cert" {
  type        = string
  description = "The certificate/public key used to encrypt the sealed secrets"
  default     = ""
}

variable "server_name" {
  type        = string
  description = "The name of the server"
  default     = "default"
}

variable "password" {
  type        = string
  description = "The database password"
  default     = "password"
}

variable "storage_class_name" {
  type        = string
  description = "The storage class to use for database"
}

variable "port" {
  type        = string
  description = "The port to use for database"
  default     = "27017"
}

variable "mongo_version" {
  type        = string
  description = "version for mongodb to be installed"
  default = "4.2.6"
}

variable "replicaset_count" {
  type        = string
  description = "No of pods to be created as part of replicaset"
  default = "3"
}

variable "mongo_svcname" {
  type        = string
  description = "Mongo svcname"
  default = "mongo-ce"
}




