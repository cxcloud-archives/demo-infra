output "url" {
  value = "${lookup(map(
        "dev", join("", aws_ecr_repository.ecr_repository.*.repository_url),
        "test", format("%s.dkr.ecr.%s.amazonaws.com/%s", var.dev_account_id, var.region, var.name),
        "prod", format("%s.dkr.ecr.%s.amazonaws.com/%s", var.dev_account_id, var.region, var.name))
  , terraform.workspace)}"
}