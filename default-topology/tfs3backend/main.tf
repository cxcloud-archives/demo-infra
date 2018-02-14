provider "aws" {
  region = "eu-west-1"
}

module "s3backend" {
  source               = "github.com/tieto-cem/terraform-aws-s3-backend?ref=v0.1.6"
  bucket_name          = "cxcloud-tf-state"
  dynamodb_table_name  = "cxcloud-tf-state"
  bucket_versioned     = false
  bucket_force_destroy = true
}