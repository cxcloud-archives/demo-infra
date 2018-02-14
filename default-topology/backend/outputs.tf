
output "test_url" {
  value = "${data.terraform_remote_state.shared.alb_dns_name}/api/"
}