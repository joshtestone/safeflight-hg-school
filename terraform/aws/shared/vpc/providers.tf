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
  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/${var.account_id}-atlantis-deployer"
    session_name = "ATLANTIS"
  }
}
