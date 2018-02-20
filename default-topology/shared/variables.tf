variable "application_name" {}

variable "workspace_iam_roles" {
  type = "map"
}

variable "azs" {
  type = "list"
}

variable "single_nat_gateway" {
  type = "map"
}

variable "vpc_cidr" {
  type = "map"
}

variable "vpc_public_subnets" {
  type = "map"
}

variable "vpc_private_subnets" {
  type = "map"
}


variable "cluster_desired_size" {
  type = "map"
}

variable "cluster_instance_type" {
  type = "map"
}

variable "cluster_min_size" {
  default = 0
}

variable "cluster_max_size" {
  default = 10
}

variable "cluster_ecs_ami" {}

variable "dynatrace_enabled" {}

variable "dynatrace_url" {}


variable "svc_domain_names" {
  type = "map"
}

variable "mc_domain_names" {
  type = "map"
}

variable "zone_domain_name" {}

variable "route53_configuration_role" {
  default = ""
}