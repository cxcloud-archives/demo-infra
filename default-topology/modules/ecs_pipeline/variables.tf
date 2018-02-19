variable "pipeline_name" {}

variable "ecs_dev_cluster_name" {}

variable "ecs_dev_service_name" {}

variable "ecs_test_cluster_name" {}

variable "ecs_test_service_name" {}

variable "ecs_prod_cluster_name" {}

variable "ecs_prod_service_name" {}

variable "ecs_prod_role_arn" {}

variable "github_user" {}

variable "github_repository" {}

variable "github_repository_branch" {
  default = "master"
}

variable "gitcrypt_pass" {}

variable "build_spec" {}

variable "GITHUB_TOKEN" {}

variable "create_pipeline" {}


