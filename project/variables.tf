variable "folder_id" {
  type = string
  description = "Yandex Cloud folder"
}

variable "user" {
  type = string
  description = "$USER"
}

variable "cloud_id" {
  type        = string
  default     = null
  description = "Cloud-ID where where need to add permissions. Mandatory variable for CLOUD, if omited default CLOUD_ID will be used"
}

variable "org_id" {
  default = null
  type    = string
  description = "organization id"
}

variable "service_account_key_file" {
  default = null
  type    = string
  description = "Generate yours: https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "service_account_id" {
  default = null
  type    = string
  description = "Service account Terraform ID"
}

variable "zone" {
  default = "ru-central1-d"
  type    = string
  description = "Yandex Zone"
}

variable "registry_name" {
  type    = string
  description = "Registry name for project"
}

variable "postgre_dbname" {
  type    = string
  description = "db name"
}

variable "postgre_owner" {
  type    = string
  description = "db owner"
}

variable "postgre_user" {
  type    = string
  description = "db user"
}

variable "postgre_password" {
  type    = string
  description = "db user password"
}