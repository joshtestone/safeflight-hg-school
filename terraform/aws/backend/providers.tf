terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47"
    }
  }
}

# AWS
provider "aws" {
  region = var.region
  
  # The below assume_role block is commented out the first time you deploy.

  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/${var.account_id}-atlantis-deployer"
    session_name = "ATLANTIS"
  }

  # The below 2 lines are used for initial apply, but can be commented out after the deployer role is created.
  
  # shared_credentials_files = ["~/.aws/credentials"]
  # profile                  = "default"
}
