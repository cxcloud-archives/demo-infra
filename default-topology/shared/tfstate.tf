
terraform {
  backend "s3" {
    key                         = "shared"
    bucket                      = "cxcloud-tf-state"
    dynamodb_table              = "cxcloud-tf-state"
    region                      = "eu-west-1"
    workspace_key_prefix        = "env"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_get_ec2_platforms      = true
  }
}