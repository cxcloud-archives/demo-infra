provider "aws" {
  region = "eu-west-1"
  assume_role {
    role_arn = "${lookup(var.workspace_iam_roles, terraform.workspace)}"
  }
}

module "service_alb_certificate" {
  source                     = "../modules/acm_certificate"
  certificate_domain_name    = "${lookup(var.svc_domain_names, terraform.workspace)}"
  zone_domain_name           = "${var.zone_domain_name}"
  route53_configuration_role = "${var.route53_configuration_role}"
}

module "service_alb" {
  source                     = "../modules/alb"
  vpc_id                     = "${module.vpc.id}"
  alb_name                   = "${var.application_name}-${terraform.workspace}-svc"
  internal                   = false
  subnet_ids                 = "${module.vpc.public_subnet_ids}"
  allow_cidrs                = {
    "443" = ["0.0.0.0/0"]
  }
  http_enabled               = false
  https_enabled              = true
  https_certificate_arn      = "${module.service_alb_certificate.arn}"

  zone_domain_name           = "${var.zone_domain_name}"
  route53_configuration_role = "${var.route53_configuration_role}"
  alb_domain_name            = "${lookup(var.svc_domain_names, terraform.workspace)}"
}

module "mc_alb_certificate" {
  source                     = "../modules/acm_certificate"
  certificate_domain_name    = "${lookup(var.mc_domain_names, terraform.workspace)}"
  zone_domain_name           = "${var.zone_domain_name}"
  route53_configuration_role = "${var.route53_configuration_role}"
}

module "mc_alb" {
  source                     = "../modules/alb"
  vpc_id                     = "${module.vpc.id}"
  alb_name                   = "${var.application_name}-${terraform.workspace}-mc"
  internal                   = false
  subnet_ids                 = "${module.vpc.public_subnet_ids}"
  allow_cidrs                = {
    "443" = ["0.0.0.0/0"]
  }
  http_enabled               = false
  https_enabled              = true
  https_certificate_arn      = "${module.mc_alb_certificate.arn}"

  zone_domain_name           = "${var.zone_domain_name}"
  route53_configuration_role = "${var.route53_configuration_role}"
  alb_domain_name            = "${lookup(var.mc_domain_names, terraform.workspace)}"
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
  allow_sgroups     = ["${module.mc_alb.sg_id}", "${module.service_alb.sg_id}"]
  depends_on        = "${module.vpc.nat_gateway_public_ips}"
  dynatrace_enabled = "${var.dynatrace_enabled}"
  dynatrace_url     = "${var.dynatrace_url}"
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