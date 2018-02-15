
output "vpc_id" {
  value = "${module.vpc.id}"
}

output "svc_alb_dns_name" {
  value = "${module.service_alb.dns_name}"
}

output "svc_alb_https_listener_arn" {
  value = "${module.service_alb.https_listener_arn}"
}

output "svc_alb_default_target_group" {
  value = "${module.service_alb.target_group_arn}"
}

output "mc_alb_dns_name" {
  value = "${module.mc_alb.dns_name}"
}

output "mc_alb_https_listener_arn" {
  value = "${module.mc_alb.https_listener_arn}"
}

output "mc_alb_default_target_group" {
  value = "${module.mc_alb.target_group_arn}"
}


output "cluster_name" {
  value = "${module.cluster.name}"
}