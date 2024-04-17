variable "cloud_id" {
  type        = string
  default     = null
  description = "Cloud-ID where where need to add permissions. Mandatory variable for CLOUD, if omited default CLOUD_ID will be used"
}

variable "folder_id" {
  default     = null
  type        = string
  description = "Folder-ID where need to add permissions. Mandatory variable for FOLDER, if omited default FOLDER_ID will be used"
}

variable "org_id" {
  default = null
  type    = string
  description = "organization id"  
}

variable "yc_token" {
  description = "Yandex.Cloud security OAuth token"
  default     = "key.json" # generate yours: https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
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

variable "redis_pas" {
  default = null
  type = string
  description = "Redis password"
}