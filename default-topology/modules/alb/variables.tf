
variable "alb_name" {}

variable "internal" {}

variable "http_enabled" {}

variable "https_enabled" {}

variable "https_certificate_arn" {
  default = ""
}

variable "allow_cidrs" {
  type = "map"
  default = {}
}

variable "allow_sgs" {
  type = "map"
  default = {}
}

variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "zone_domain_name" {}

variable "route53_configuration_role" {}

variable "alb_domain_name" {}



