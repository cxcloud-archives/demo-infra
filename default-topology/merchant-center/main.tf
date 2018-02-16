provider "aws" {
  region = "eu-west-1"
}

module "ecr_repository" {
  source          = "../modules/ecr_repository"
  dev_account_id  = "${var.aws_dev_account_id}"
  prod_account_id = "${var.aws_prod_account_id}"
  name            = "${var.container_name}"
}

locals {
  env_to_node_env_map = {
    "dev"  = "development"
    "test" = "staging"
    "prod" = "production"
  }
}

module "container_definition" {
  source         = "github.com/tieto-cem/terraform-aws-ecs-task-definition//modules/container-definition?ref=v0.1.2"
  name           = "${var.container_name}"
  image          = "${module.ecr_repository.url}:latest"
  mem_soft_limit = "${var.container_mem_soft_limit}"
  port_mappings  = [{
    containerPort = "${var.container_port}"
  }]
  environment    = [{
    name  = "API_ENDPOINT"
    value = "http://${data.terraform_remote_state.shared.svc_alb_dns_name}/api/"
  }, {
    name = "NODE_ENV", value = "${lookup(local.env_to_node_env_map, terraform.workspace)}"
  }]
}

module "task_definition" {
  source                = "github.com/tieto-cem/terraform-aws-ecs-task-definition?ref=v0.1.2"
  name                  = "${var.application_name}-${terraform.workspace}-${var.container_name}"
  container_definitions = ["${module.container_definition.json}"]
}

module "service" {
  source              = "github.com/tieto-cem/terraform-aws-ecs-service?ref=v0.1.0"
  name                = "${var.application_name}-${terraform.workspace}-${var.container_name}"
  cluster_name        = "${data.terraform_remote_state.shared.cluster_name}"
  task_definition_arn = "${module.task_definition.arn}"
  desired_count       = "${lookup(var.task_desired_count, terraform.workspace)}"
  use_load_balancer   = true
  lb_target_group_arn = "${data.terraform_remote_state.shared.mc_alb_default_target_group}"
  lb_container_name   = "${var.container_name}"
  lb_container_port   = "${var.container_port}"
}

data "template_file" "buildspec" {
  count    = "${terraform.workspace == "dev" ? 1 : 0}"
  template = "${file("${path.module}/buildspec.yml")}"

  vars {
    REPOSITORY_URI = "${module.ecr_repository.url}"
    CONTAINER_NAME = "${var.container_name}"
  }
}

module "pipeline" {
  source                = "../modules/ecs_pipeline"
  github_user           = "${var.github_user}"
  github_repository     = "${var.github_repository}"
  GITHUB_TOKEN          = "${var.github_token}"
  gitcrypt_pass         = "${var.gitcrypt_pass}"
  build_spec            = "${terraform.workspace == "dev" ? join("", data.template_file.buildspec.*.rendered) : ""}"
  pipeline_name         = "${var.application_name}-${var.container_name}"
  ecs_dev_cluster_name  = "${data.terraform_remote_state.shared.cluster_name}"
  ecs_dev_service_name  = "${module.service.name}"
  ecs_test_cluster_name = "${var.application_name}-test-cluster"                # FIXME
  ecs_test_service_name = "${var.application_name}-test-${var.container_name}"  # FIXME
  create_pipeline       = "${terraform.workspace == "dev" ? true : false}"
}