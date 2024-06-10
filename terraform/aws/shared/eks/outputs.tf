output "argocd_password" {
  value = nonsensitive(data.kubernetes_secret_v1.argocd_password.data["password"])
}

output "argocd_url" {
  value = data.kubernetes_service.argocd_service.status[0].load_balancer[0].ingress[0].hostname
}

# output "ca_certificate" {
#   value = module.eks.cluster_certificate_authority_data
# }

output "cluster_name" {
  value = module.eks.cluster_name
}

output "endpoint" {
  value = module.eks.cluster_endpoint
}

# output "karpenter" {
#   value     = helm_release.karpenter
#   sensitive = true
# }

output "kubernetes_connector_name" {
  value = local.kubernetes_connector_name
}

output "node_role_arn" {
  value = module.eks.cluster_iam_role_arn
}

# output "token" {
#   value     = data.aws_eks_cluster_auth.eks_cluster.token
#   sensitive = true
# }
