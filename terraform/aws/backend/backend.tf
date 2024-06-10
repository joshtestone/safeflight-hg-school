terraform {
  backend "s3" {
    bucket               = "457661787930-terraform-backend"
    workspace_key_prefix = "terraform/aws/backend"
    key                  = "terraform.tfstate"
    region               = "us-west-2"
    dynamodb_table       = "457661787930_terraform_backend"
    encrypt              = true
    # Comment out the below line the first time you deploy
    role_arn             = "arn:aws:iam::457661787930:role/457661787930-atlantis-deployer"
    session_name         = "ATLANTIS"
  }
}
