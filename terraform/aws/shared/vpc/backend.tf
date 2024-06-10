terraform {
  #required_version = "1.1.9"
  backend "s3" {
    bucket               = "457661787930-terraform-backend"
    workspace_key_prefix = "terraform/aws/shared/vpc"
    key                  = "terraform.tfstate"
    region               = "us-west-2"
    dynamodb_table       = "457661787930_terraform_backend"
    role_arn             = "arn:aws:iam::457661787930:role/457661787930-atlantis-deployer"
    session_name         = "ATLANTIS"
  }
}
