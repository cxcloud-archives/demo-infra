variable "pipeline_name" {}

variable "ecs_dev_cluster_name" {}

variable "ecs_dev_service_name" {}

variable "github_user" {}

variable "github_repository" {}

variable "github_repository_branch" {
  default = "master"
}

variable "terraform_prod_role" {}

variable "gitcrypt_pass" {}

variable "build_spec" {}

variable "create_pipeline" {}


