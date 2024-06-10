################################################################################
# IRSA
################################################################################

# module "load_balancer_controller_irsa_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name                              = "${var.cluster_name}-load-balancer-controller"
#   attach_load_balancer_controller_policy = true

#   oidc_providers = {
#     ex = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
#     }
#   }
# }

# module "load_balancer_controller_targetgroup_binding_only_irsa_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name                                                       = "${var.cluster_name}-load-balancer-controller-targetgroup-binding-only"
#   attach_load_balancer_controller_targetgroup_binding_only_policy = true

#   oidc_providers = {
#     ex = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
#     }
#   }
# }

module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${var.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}


module "vpc_cni_ipv4_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${var.cluster_name}-vpc-cni-ipv4"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = local.tags
}

module "vpc_cni_ipv6_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${var.cluster_name}-vpc-cni-ipv6"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv6   = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = local.tags
}

# module "external_dns_irsa_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name                     = "${local.name}-external-dns"
#   attach_external_dns_policy    = true
#   external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/Z08760701ISX4D1QQRE2D"]

#   oidc_providers = {
#     ex = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:external-dns"]
#     }
#   }
# }

# module "cert_manager_irsa_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name                     = "${local.name}-cert-manager"
#   attach_cert_manager_policy    = true
#   cert_manager_hosted_zone_arns = ["arn:aws:route53:::hostedzone/Z08760701ISX4D1QQRE2D"]

#   oidc_providers = {
#     ex = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["cert-manager:cert-manager"]
#     }
#   }
# }
