
output "vpc_id" {
  value = "${module.vpc.id}"
}

output "alb_dns_name" {
  value = "${module.alb.dns_name}"
}

output "alb_http_listener_arn" {
  value = "${module.alb.http_listener_arn}"
}

output "alb_https_listener_arn" {
  value = "${module.alb.https_listener_arn}"
}

output "alb_default_target_group" {
  value = "${module.alb.target_group_arn}"
}

output "cluster_name" {
  value = "${module.cluster.name}"
}