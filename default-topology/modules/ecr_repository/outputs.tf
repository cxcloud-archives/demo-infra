output "url" {
  value = "${lookup(map(
        "dev", join("", aws_ecr_repository.ecr_repository.*.repository_url),
        "test", format("https://%s.dkr.ecr.region.amazonaws.com/%s", var.dev_account_id, var.name),
        "prod", format("https://%s.dkr.ecr.region.amazonaws.com/%s", var.prod_account_id, var.name))
  , terraform.workspace)}"
}