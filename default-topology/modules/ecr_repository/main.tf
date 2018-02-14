
resource "aws_ecr_repository" "ecr_repository" {
  count = "${terraform.workspace == "dev" ? 1 : 0}"
  name  = "${var.name}"
}

# ECR repository policy for allowing access from production account (doesn't activate if prod account id is not present)

resource "aws_ecr_repository_policy" "ecr_repository_policy" {
  count      = "${terraform.workspace == "dev" && var.prod_account_id != "" ? 1 : 0}"
  repository = "${aws_ecr_repository.ecr_repository.name}"
  policy     = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "CrossAccountPull",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${var.prod_account_id}"
            },
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
EOF
}
