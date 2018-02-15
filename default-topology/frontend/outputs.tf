
output "test_url" {
  value = "${data.terraform_remote_state.shared.svc_alb_dns_name}/"
}