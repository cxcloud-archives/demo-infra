data "aws_caller_identity" "current" {}

provider "aws" {
  alias  = "prod"
  region = "eu-west-1"
  assume_role {
    role_arn = "${var.terraform_prod_role}"
  }
}

resource "aws_iam_role" "prod_deploy_role" {
  count              = "${var.create_pipeline ? 1 : 0}"
  provider           = "aws.prod"
  name               = "${var.pipeline_name}-prod-deploy-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.pipeline_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "prod_deploy_role_policy" {
  count    = "${var.create_pipeline ? 1 : 0}"
  provider = "aws.prod"
  name     = "${var.pipeline_name}-prod-deploy-role-policy"
  role     = "${aws_iam_role.prod_deploy_role.id}"
  policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
       "Effect": "Allow",
       "Action": [
         "s3:*"
       ],
       "Resource": [
          "${aws_s3_bucket.pipeline_artifact_bucket.arn}",
          "${aws_s3_bucket.pipeline_artifact_bucket.arn}/*"
       ]
    },
    {
      "Effect": "Allow",
      "Action": [
         "kms:DescribeKey",
         "kms:GenerateDataKey*",
         "kms:Encrypt",
         "kms:ReEncrypt*",
         "kms:Decrypt"
        ],
      "Resource": [
         "${aws_kms_key.kms_key.arn}"
      ]
    },
    {
      "Action": [
          "ecs:*",
          "iam:PassRole"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_kms_key" "kms_key" {
  count  = "${var.create_pipeline ? 1 : 0}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Allow administration of the key",
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
      "Action": [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow use of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.pipeline_role.arn}",
          "${aws_iam_role.codebuild_role.arn}",
          "${aws_iam_role.prod_deploy_role.arn}",
          "arn:aws:iam::${var.prod_account_id}:root"
        ]
      },
      "Action": [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kms_alias" "key_alias" {
  count         = "${var.create_pipeline ? 1 : 0}"
  name          = "alias/${var.pipeline_name}-key"
  target_key_id = "${aws_kms_key.kms_key.id}"
}

resource "aws_s3_bucket" "pipeline_artifact_bucket" {
  count         = "${var.create_pipeline ? 1 : 0}"
  bucket        = "${var.pipeline_name}-bucket"
  acl           = "private"
  force_destroy = true

  policy        = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
	{
  	"Sid": "DenyUnEncryptedObjectUploads",
	  "Effect": "Deny",
	  "Principal": "*",
	  "Action": "s3:PutObject",
	  "Resource": "arn:aws:s3:::${var.pipeline_name}-bucket/*",
	  "Condition": {
		"StringNotEquals": {
		  "s3:x-amz-server-side-encryption": "aws:kms"
		}
      }
    },
	{
	  "Effect": "Allow",
	  "Principal": {
		"AWS": "arn:aws:iam::${var.prod_account_id}:root"
      },
	  "Action": [
        "s3:*"
      ],
	  "Resource": [
        "arn:aws:s3:::${var.pipeline_name}-bucket",
	    "arn:aws:s3:::${var.pipeline_name}-bucket/*"
      ]
	}
  ]
}
EOF
}

resource "aws_iam_role" "pipeline_role" {
  count              = "${var.create_pipeline ? 1 : 0}"
  name               = "${var.pipeline_name}-pipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "pipeline_policy" {
  count  = "${var.create_pipeline ? 1 : 0}"
  name   = "${var.pipeline_name}-policy"
  role   = "${aws_iam_role.pipeline_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning"
      ],
      "Resource": [
        "${aws_s3_bucket.pipeline_artifact_bucket.arn}",
        "${aws_s3_bucket.pipeline_artifact_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "${aws_iam_role.prod_deploy_role.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
          "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.pipeline_artifact_bucket.arn}",
        "${aws_s3_bucket.pipeline_artifact_bucket.arn}/*"
      ]
    },
    {
      "Action": [
          "ecs:*",
          "iam:PassRole"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "codebuild_role" {
  count              = "${var.create_pipeline ? 1 : 0}"
  name               = "${var.pipeline_name}-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codebuild_policy" {
  count       = "${var.create_pipeline ? 1 : 0}"
  name        = "${var.pipeline_name}-codebuild-policy"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild"

  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Sid": "S3GetObjectPolicy",
      "Effect": "Allow",
      "Action": [
        "s3:ListObjects",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": [
        "${aws_s3_bucket.pipeline_artifact_bucket.arn}",
        "${aws_s3_bucket.pipeline_artifact_bucket.arn}/*"
      ]
    },
    {
      "Sid": "S3PutObjectPolicy",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.pipeline_artifact_bucket.arn}",
        "${aws_s3_bucket.pipeline_artifact_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  count      = "${var.create_pipeline ? 1 : 0}"
  name       = "${var.pipeline_name}-codebuild-policy-attachment"
  policy_arn = "${aws_iam_policy.codebuild_policy.arn}"
  roles      = ["${aws_iam_role.codebuild_role.id}"]
}

resource "aws_iam_role_policy_attachment" "ecr_power_user_policy_attachment" {
  count      = "${var.create_pipeline ? 1 : 0}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = "${aws_iam_role.codebuild_role.name}"
}

resource "aws_codebuild_project" "codebuild_project" {
  count          = "${var.create_pipeline ? 1 : 0}"
  name           = "${var.pipeline_name}-codebuild"
  service_role   = "${aws_iam_role.codebuild_role.arn}"
  encryption_key = "${aws_kms_key.kms_key.arn}"

  source {
    type      = "CODEPIPELINE"
    buildspec = "${var.build_spec}"
  }

  artifacts {
    type      = "CODEPIPELINE"
    packaging = "NONE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:17.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "GITCRYPT_PASS"
      value = "${var.gitcrypt_pass}"
    }
  }
}

resource "aws_codepipeline" "pipeline" {
  count    = "${var.create_pipeline ? 1 : 0}"
  name     = "${var.pipeline_name}"
  role_arn = "${aws_iam_role.pipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.pipeline_artifact_bucket.bucket}"
    type     = "S3"

    encryption_key {
      id   = "${aws_kms_key.kms_key.id}"
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["app-sources"]

      configuration {
        Owner      = "${var.github_user}"
        Repo       = "${var.github_repository}"
        Branch     = "${var.github_repository_branch}"
        OAuthToken = "${var.GITHUB_TOKEN}"
      }
    }
  }
  # see https://stackoverflow.com/questions/48243968/terraform-ignore-changes-and-sub-blocks
  lifecycle {
    ignore_changes = ["stage.0.action.0.configuration.OAuthToken", "stage.0.action.0.configuration.%"]
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["app-sources"]
      output_artifacts = ["app-build"]
      version          = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.codebuild_project.name}"
      }
    }
  }

  stage {

    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["app-build"]
      version         = "1"

      configuration {
        ClusterName = "${var.ecs_dev_cluster_name}"
        ServiceName = "${var.ecs_dev_service_name}"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}
/*
  stage {

    name = "Staging"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["app-build"]
      version         = "1"

      configuration {
        ClusterName = "${var.ecs_dev_cluster_name}"
        ServiceName = "${var.ecs_dev_service_name}"
        FileName    = "imagedefinitions.json"
      }
    }
  }

  stage {

    name = "Production"

    action {
      name      = "Approve"
      category  = "Approval"
      owner     = "AWS"
      version   = "1"
      provider  = "Manual"
      run_order = 1
    }

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["app-build"]
      version         = "1"
      run_order       = 2
      role_arn        = "${aws_iam_role.prod_deploy_role.arn}"

      configuration {
        ClusterName = "${var.ecs_prod_cluster_name}"
        ServiceName = "${var.ecs_prod_service_name}"
        FileName    = "imagedefinitions.json"
      }
    }
  }*/


