
output "test_url" {
  value = "${data.terraform_remote_state.shared.mc_alb_dns_name}/"
}