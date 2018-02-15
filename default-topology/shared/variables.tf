
variable "application_name" {}

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