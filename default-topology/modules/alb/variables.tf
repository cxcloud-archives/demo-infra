
variable "alb_name" {}

variable "internal" {}

variable "http_enabled" {}

variable "https_enabled" {}

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



