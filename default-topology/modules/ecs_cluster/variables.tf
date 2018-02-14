variable "cluster_name" {}

variable "vpc_id" {}

variable "instance_type" {}

variable "ecs_optimized_ami" {}

variable "desired_size" {}

variable "min_size" {
  default = 0
}
variable "max_size" {
  default = 10
}

variable "subnet_ids" {
  type = "list"
}

variable "allow_sgroups" {
  type = "list"
}

variable "depends_on" {
  type = "list"
  description = "Used to make cluster instances depend on NAT Gateways. Without it, instances can start too early without functioning NAT instances."
}