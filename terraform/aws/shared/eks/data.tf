data "aws_caller_identity" "current" {}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.us-east-1
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = module.eks.cluster_name

  #depends_on = [
  #  module.eks
  #]
}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

data "aws_partition" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = ["${var.vpc_name}"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name = "*private*"
  }
}

data "aws_subnets" "intra" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name = "*intra*"
  }
}

data "kubernetes_service" "argocd_service" {
  metadata {
    name      = "argocd-server"
    namespace = "argocd"
  }

  depends_on = [
    helm_release.argocd
  ]
}

data "kubernetes_secret_v1" "argocd_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }

  depends_on = [
    helm_release.argocd
  ]
}
