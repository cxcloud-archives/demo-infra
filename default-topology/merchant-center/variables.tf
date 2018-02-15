
variable "application_name" {}

variable "aws_dev_account_id" {}

variable "aws_prod_account_id" {
  default = ""
}

variable "container_name" {}

variable "container_mem_soft_limit" {}

variable "container_port" {}

variable "task_desired_count" {
  type = "map"
}

variable "github_user" {}

variable "github_token" {}

variable "github_repository" {}

variable "gitcrypt_pass" {}
