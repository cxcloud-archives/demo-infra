provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    key                         = "shared"
    bucket                      = "cxcloud-tf-state"
    dynamodb_table              = "cxcloud-tf-state"
    region                      = "eu-west-1"
    workspace_key_prefix        = "env"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_get_ec2_platforms      = true
  }
}

module "alb" {
  source        = "../modules/alb"
  vpc_id        = "${module.vpc.id}"
  alb_name      = "${var.application_name}-${terraform.workspace}-alb"
  internal      = false
  subnet_ids    = "${module.vpc.public_subnet_ids}"
  allow_cidrs   = {
    "80"  = ["0.0.0.0/0"]
    "443" = ["0.0.0.0/0"]
  }
  http_enabled  = true
  https_enabled = true
}

module "cluster" {
  source            = "../modules/ecs_cluster"
  cluster_name      = "${var.application_name}-${terraform.workspace}-cluster"
  ecs_optimized_ami = "${var.cluster_ecs_ami}"
  vpc_id            = "${module.vpc.id}"
  subnet_ids        = "${module.vpc.private_subnet_ids}"
  desired_size      = "${lookup(var.cluster_desired_size, terraform.workspace)}"
  min_size          = "${var.cluster_min_size}"
  max_size          = "${var.cluster_max_size}"
  instance_type     = "${lookup(var.cluster_instance_type, terraform.workspace)}"
  allow_sgroups     = ["${module.alb.sg_id}"]
  depends_on        = "${module.vpc.nat_gateway_public_ips}"
}

module "vpc" {
  source               = "github.com/tieto-cem/terraform-aws-vpc?ref=v0.1.2"
  name_prefix          = "${var.application_name}-${terraform.workspace}"
  cidr                 = "${lookup(var.vpc_cidr, terraform.workspace)}"
  azs                  = "${var.azs}"
  private_subnet_cidrs = "${var.vpc_private_subnets[terraform.workspace]}"
  public_subnet_cidrs  = "${var.vpc_public_subnets[terraform.workspace]}"
  enable_nat_gateway   = true
  single_nat_gateway   = "${lookup(var.single_nat_gateway, terraform.workspace)}"
}