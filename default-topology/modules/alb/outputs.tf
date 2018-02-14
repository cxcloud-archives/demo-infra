
output "dns_name" {
  value = "${module.alb.alb_dns_name}"
}
output "sg_id" {
  value = "${module.alb_sg.id}"
}

output "https_listener_arn" {
  value = "${module.alb.https_listener_arn}"
}

output "http_listener_arn" {
  value = "${module.alb.http_listener_arn}"
}

output "target_group_arn" {
  value = "${module.alb.target_group_arn}"
}