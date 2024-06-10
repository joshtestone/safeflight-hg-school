terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.47"
      #configuration_aliases = [aws.us-east-1]
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.10.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0"
    }
    wiz = {
      version = "~> 1.1"
      source  = "tf.app.wiz.io/wizsec/wiz"
    }
  }
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/${var.account_id}-atlantis-deployer"
    session_name = "ATLANTIS"
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/${var.account_id}-atlantis-deployer"
    session_name = "ATLANTIS"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.eks_cluster.token
  }
  registry {
    url      = "oci://public.ecr.aws"
    username = data.aws_ecrpublic_authorization_token.token.user_name
    password = data.aws_ecrpublic_authorization_token.token.password
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
  load_config_file       = false
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
}
